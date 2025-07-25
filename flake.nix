{
  description = "Nix packages";
  inputs = {
    # keep-sorted start block=yes case=no
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    pre-commit-hooks = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:cachix/git-hooks.nix";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };
    # keep-sorted end
  };
  nixConfig = {
    extra-substituters = [
      "https://a1994sc.cachix.org"
    ];
    extra-trusted-public-keys = [
      "a1994sc.cachix.org-1:xZdr1tcv+XGctmkGsYw3nXjO1LOpluCv4RDWTqJRczI="
    ];
  };
  outputs =
    inputs@{ self, nixpkgs, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [
        inputs.flake-root.flakeModule
      ];
      perSystem =
        {
          pkgs,
          config,
          lib,
          system,
          ...
        }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                go-fuseftp = self.legacyPackages.${system}.go-fuseftp;
                cosign-hauler = self.legacyPackages.${system}.cosign-hauler;
                go_1_23 = self.packages.${system}.go-1-23;
                go_1_24 = self.packages.${system}.go-1-24;
                final.buildGoModule = prev.buildGo124Module;
              })
            ];
          };
          fmt = inputs.treefmt-nix.lib.evalModule pkgs (
            { pkgs, ... }:
            {
              # keep-sorted start block=yes
              programs.keep-sorted.enable = true;
              programs.nixfmt = {
                enable = true;
                package = pkgs.nixfmt-rfc-style;
              };
              projectRootFile = "flake.nix";
              # keep-sorted end
            }
          );
        in
        {
          checks.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # keep-sorted start case=no
              check-executables-have-shebangs.enable = true;
              check-shebang-scripts-are-executable.enable = true;
              detect-private-keys.enable = true;
              end-of-file-fixer.enable = true;
              nixfmt-rfc-style.enable = true;
              trim-trailing-whitespace.enable = true;
              # keep-sorted end
              end-of-file-fixer.excludes = [
                ".cz.json"
              ];
            };
          };
          devShells.default = pkgs.mkShell {
            shellHook = self.checks.${system}.pre-commit-check.shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages ++ [
              pkgs.nix-update
              pkgs.nix-prefetch
              pkgs.nix-output-monitor
              pkgs.cachix
            ];
          };
          devShells.ci = pkgs.mkShell {
            packages = with pkgs; [
              nix-update
              nix-output-monitor
            ];
          };
          formatter = fmt.config.build.wrapper;
          legacyPackages = nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
            inherit (pkgs) callPackage;
            directory = ./pkgs/archive;
          };
          packages =
            nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
              inherit (pkgs) callPackage;
              directory = ./pkgs/core;
            }
            # TL;DR: Looks through pkgs/multi,
            # finds all the folders,
            # then for each folder finds each version of the main program,
            # and lastly creates entry of the main program and each version discovered
            // builtins.listToAttrs (
              builtins.concatLists (
                builtins.map
                  (
                    name:
                    (builtins.map
                      (ver: {
                        name = pkgs.lib.removeSuffix ".nix" "${name}-${ver}";
                        value = pkgs.callPackage ./pkgs/multi/${name}/${ver} { };
                      })
                      (
                        builtins.filter (name: name != "default.nix") (
                          builtins.attrNames (builtins.readDir ./pkgs/multi/${name})
                        )
                      )
                    )
                  )
                  (
                    builtins.attrNames (
                      pkgs.lib.attrsets.filterAttrs (_n: v: v == "directory") (builtins.readDir ./pkgs/multi)
                    )
                  )
              )
            );
        };
    };
}
