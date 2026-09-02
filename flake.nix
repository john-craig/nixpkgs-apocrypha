{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.opencode-nix = {
    url = "github:albertov/opencode-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, opencode-nix }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      nixosModules = import ./nixos-modules;
      homeModules = import ./home-modules;
      overlays.opencode-nix = opencode-nix.overlays.default;
      checks = forAllSystems (system: let pkgs = import nixpkgs { inherit system; }; in {
        sceptre = pkgs.runCommand "sceptre-check" {
          nativeBuildInputs = [ self.legacyPackages.${system}.sceptre ];
        } ''
          test -x "${self.legacyPackages.${system}.sceptre}/bin/sceptre"
          sceptre --help >/dev/null
          sceptre repository --help | grep -q "Usage: sceptre repository"
          test ! -e "${self.legacyPackages.${system}.sceptre}/credentials"
          test ! -e "${self.legacyPackages.${system}.sceptre}/secrets"
          touch "$out"
        '';
        remaining-shell-user-configuration = import ./tests/remaining-shell-user-configuration.nix { inherit pkgs; };
        traefik-modules = import ./tests/traefik-modules.nix { inherit pkgs; };
        opencode-agents = import ./tests/opencode-agents.nix {
          pkgs = pkgs.extend opencode-nix.overlays.default;
        };
      });
      # darwinModules = import ./darwin-modules;
      # flakeModules = import ./flake-modules;
    };
}
