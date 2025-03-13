{
  description = "Nix packages";
  inputs = {
    # keep-sorted start block=yes case=no
    flake-utils = {
      inputs.systems.follows = "systems";
      url = "github:numtide/flake-utils";
    };
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
    inputs.flake-utils.lib.eachSystem inputs.flake-utils.lib.defaultSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (
              final: prev:
              {
                buildGoModule = prev.buildGo124Module;
                go_1_24 = self.packages.${system}.go-1-24;
                go-fuseftp = self.packages.${system}.go-fuseftp;
                cosign-hauler = self.packages.${system}.cosign-hauler;
              }
              // (import ./pkgs.nix { inherit final self system; })
            )
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
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # keep-sorted start case=no
              check-executables-have-shebangs.enable = true;
              check-shebang-scripts-are-executable.enable = true;
              commitizen.enable = true;
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
        };
        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
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
            self.packages.${system}.lastversion
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
                  (builtins.map (ver: {
                    name = pkgs.lib.removeSuffix ".nix" "${name}-${ver}";
                    value = pkgs.callPackage ./pkgs/multi/${name}/${ver} { };
                  }) (builtins.attrNames (builtins.readDir ./pkgs/multi/${name})))
                )
                (
                  builtins.attrNames (
                    pkgs.lib.attrsets.filterAttrs (_n: v: v == "directory") (builtins.readDir ./pkgs/multi)
                  )
                )
            )
          );
      }
    );
}
