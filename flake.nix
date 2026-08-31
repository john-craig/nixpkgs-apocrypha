{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
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
      checks = forAllSystems (system: let pkgs = import nixpkgs { inherit system; }; in {
        remaining-shell-user-configuration = import ./tests/remaining-shell-user-configuration.nix { inherit pkgs; };
      });
      # darwinModules = import ./darwin-modules;
      # flakeModules = import ./flake-modules;
    };
}
