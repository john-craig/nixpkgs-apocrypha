{ config, lib, pkgs, ... }:
let
  cfg = config.services.apocrypha.traefikJitAccess;
  json = pkgs.formats.json { };
  normalize = pkgs.writeText "traefik-jit-normalize.py" ''
    import ipaddress, sys
    try:
        value = sys.argv[1]
        if "/" in value:
            print(ipaddress.ip_network(value, strict=False))
        else:
            address = ipaddress.ip_address(value)
            print(f"{address}/{32 if address.version == 4 else 128}")
    except ValueError as error:
        raise SystemExit(f"invalid IP or CIDR: {sys.argv[1]}: {error}")
  '';
  duration = pkgs.writeText "traefik-jit-duration.py" ''
    import re, sys
    value = sys.argv[1].strip().lower()
    units = {"s": 1, "m": 60, "h": 3600, "d": 86400, "w": 604800}
    matches = list(re.finditer(r"(\d+)([smhdw])", value))
    if not matches or "".join(match.group(0) for match in matches) != value:
        raise SystemExit(f"unsupported duration format: {value}")
    seconds = sum(int(match.group(1)) * units[match.group(2)] for match in matches)
    if seconds <= 0:
        raise SystemExit(f"unsupported duration format: {value}")
    print(seconds)
  '';
  discover = pkgs.writeText "traefik-jit-discover.py" ''
    import json, re, sys, urllib.request
    host, endpoint, prefix, offset, fragments, middleware_prefixes = sys.argv[1:]
    payload = json.load(urllib.request.urlopen(endpoint))
    raw = payload if isinstance(payload, list) else payload.get("routers", {})
    routers = raw if isinstance(raw, list) else [dict(router, name=name) for name, router in raw.items()]
    pattern = re.compile(rf"(^|[^A-Za-z0-9.-]){re.escape(host)}([^A-Za-z0-9.-]|$)", re.I)
    strip = json.loads(fragments)
    middleware_strip = json.loads(middleware_prefixes)
    selected = []
    for router in routers:
        rule = router.get("rule", "")
        name = router.get("name", "")
        if not router.get("service") or name.startswith(prefix) or router.get("status") in ("disabled", "Disabled"):
            continue
        for fragment in strip:
            rule = re.sub(rf"\s*&&\s*\(?{re.escape(fragment)}\)?", "", rule)
        if not pattern.search(rule):
            continue
        selected.append({
            "name": f"{prefix}{re.sub(r'[^a-z0-9]+', '-', host.lower()).strip('-')}-{len(selected)}",
            "rule": rule,
            "service": router["service"],
            "entryPoints": router.get("entryPoints") or ["websecure"],
            "middlewares": [m for m in router.get("middlewares", []) if not any(m == p or m.startswith(p + "@") for p in middleware_strip)],
            "priority": int(router.get("priority") or 0) + int(offset),
            "tls": router.get("tls") if isinstance(router.get("tls"), dict) else ({} if router.get("tls") else None),
        })
    if not selected:
        raise SystemExit(f"no usable Traefik route found for hostname: {host}")
    print(json.dumps(selected))
  '';
  jitCommand = pkgs.writeShellApplication {
    name = "traefik-jit-access";
    runtimeInputs = with pkgs; [ coreutils curl jq python3 util-linux ];
    text = ''
      set -euo pipefail
      umask 0027
      state=${lib.escapeShellArg cfg.stateDirectory}
      grants="$state/grants"
      dynamic=${lib.escapeShellArg cfg.dynamicDirectory}
      metadata() { printf '%s/%s.json\n' "$grants" "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"; }
      override() { printf '%s/%s.json\n' "$dynamic" "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"; }
      setup() { install -d -m 0750 "$state" "$grants" "$dynamic"; chgrp traefik "$dynamic"; }
      lock() { exec 9>"$state/lock"; chmod 0600 "$state/lock"; flock 9; }
      usage() { printf '%s\n' 'traefik-jit-access grant --ip IP [--duration 24h] HOST...' 'traefik-jit-access revoke HOST...' 'traefik-jit-access list' 'traefik-jit-access prune'; }
      render() {
        local metadata_file="$1" output="$2" tmp
        tmp=$(mktemp)
        jq '. as $root | ($root.hostname | ascii_downcase | gsub("[^a-z0-9]+"; "-") | "${cfg.routerPrefix}mw-" + .) as $middleware | {http: {middlewares: {($middleware): {ipAllowList: {sourceRange: [$root.grants[].sourceRange]}}}, routers: (reduce $root.routers[] as $route ({}; .[$route.name] = ($route + {middlewares: (($route.middlewares // []) + [$middleware])})))}}' "$metadata_file" > "$tmp"
        chmod 0640 "$tmp"; chgrp traefik "$tmp"; mv -f "$tmp" "$output"
      }
      command=''${1:-}; shift || true
      setup
      case "$command" in
        grant)
          ip=""; duration_value="24h"; hosts=()
          while (($#)); do case "$1" in --ip) ip="$2"; shift 2;; --duration) duration_value="$2"; shift 2;; *) hosts+=("$1"); shift;; esac; done
          [[ -n "$ip" && ''${#hosts[@]} -gt 0 ]] || { usage >&2; exit 1; }
          source_range=$(python3 ${normalize} "$ip"); seconds=$(python3 ${duration} "$duration_value"); now=$(date -u +%s); expires=$((now + seconds)); lock
          for host in "''${hosts[@]}"; do
            metadata_file=$(metadata "$host"); output=$(override "$host");
            # shellcheck disable=SC2016
            routers=$(python3 ${discover} "$host" ${lib.escapeShellArg cfg.apiEndpoint} ${lib.escapeShellArg cfg.routerPrefix} ${toString cfg.priorityOffset} ${lib.escapeShellArg (builtins.toJSON cfg.ruleFragmentsToStrip)} ${lib.escapeShellArg (builtins.toJSON cfg.middlewarePrefixesToStrip)})
            old='{"hostname":"'"$host"'","grants":[],"routers":[]}'
            [[ -f "$metadata_file" ]] && old=$(<"$metadata_file")
            tmp=$(mktemp)
            jq --arg host "$host" --arg source "$source_range" --argjson expires "$expires" --arg granted "$(date -u --iso-8601=seconds)" --arg expiresAt "$(date -u --iso-8601=seconds --date="@$expires")" --argjson routers "$routers" '.hostname=$host | .routers=$routers | .grants=[.grants[] | select(.sourceRange != $source)] + [{sourceRange:$source, grantedAt:$granted, expiresAt:$expiresAt, expiresEpoch:$expires}]' <<<"$old" > "$tmp"
            chmod 0640 "$tmp"; mv -f "$tmp" "$metadata_file"; render "$metadata_file" "$output"; printf 'granted %s to %s\n' "$source_range" "$host"
          done;;
        revoke) lock; for host in "$@"; do rm -f "$(metadata "$host")" "$(override "$host")"; done;;
        list) for file in "$grants"/*.json; do [[ -e "$file" ]] || continue; jq -r '.hostname as $host | .grants[] | [$host,.sourceRange,.expiresAt] | @tsv' "$file"; done;;
        prune) lock; now=$(date -u +%s); for file in "$grants"/*.json; do [[ -e "$file" ]] || continue; host=$(jq -r .hostname "$file"); tmp=$(mktemp); jq --argjson now "$now" '.grants |= map(select(.expiresEpoch > $now))' "$file" > "$tmp"; chmod 0640 "$tmp"; mv -f "$tmp" "$file"; if [[ $(jq '.grants | length' "$file") -eq 0 ]]; then rm -f "$file" "$(override "$host")"; else render "$file" "$(override "$host")"; fi; done;;
        ""|help|--help|-h) usage;;
        *) usage >&2; exit 1;;
      esac
    '';
  };
in
{
  options.services.apocrypha.traefikJitAccess = {
    enable = lib.mkEnableOption "temporary Traefik IP allowlist overrides";
    apiEndpoint = lib.mkOption { type = lib.types.str; default = "http://127.0.0.1:8080/api/http/routers"; };
    dynamicDirectory = lib.mkOption { type = lib.types.path; default = "/var/lib/traefik/dynamic/jit-access"; };
    stateDirectory = lib.mkOption { type = lib.types.path; default = "/var/lib/traefik-jit-access"; };
    pruneInterval = lib.mkOption { type = lib.types.str; default = "1m"; };
    priorityOffset = lib.mkOption { type = lib.types.int; default = 10000; };
    routerPrefix = lib.mkOption { type = lib.types.str; default = "jit-access-"; };
    ruleFragmentsToStrip = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ ]; };
    middlewarePrefixesToStrip = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "authelia" "authelia-basic" ]; };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = config.services.traefik.enable; message = "services.apocrypha.traefikJitAccess requires services.traefik.enable = true."; }
      { assertion = config.users.groups ? traefik; message = "services.apocrypha.traefikJitAccess requires a traefik group."; }
    ];
    environment.systemPackages = [ jitCommand ];
    users.groups.traefik = { };
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDirectory} 0750 root root - -"
      "d ${cfg.stateDirectory}/grants 0750 root root - -"
      "d ${cfg.dynamicDirectory} 0750 root traefik - -"
    ];
    services.traefik.staticConfigOptions.providers.file = { directory = cfg.dynamicDirectory; watch = true; };
    system.activationScripts.apocrypha-traefik-jit-access = ''
      install -d -m 0750 ${cfg.stateDirectory}/grants ${cfg.dynamicDirectory}
    '';
    systemd.services.traefik-jit-access-prune = {
      description = "Prune expired Traefik JIT access grants";
      serviceConfig = { Type = "oneshot"; ExecStart = "${jitCommand}/bin/traefik-jit-access prune"; };
    };
    systemd.timers.traefik-jit-access-prune = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnBootSec = "2m"; OnUnitActiveSec = cfg.pruneInterval; Persistent = true; };
    };
  };
}
