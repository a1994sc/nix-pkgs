{ pkgs, ... }:
pkgs.go_1_23.overrideAttrs (
  old:
  let
    version = "1.23.6";
  in
  {
    inherit version;
    src = pkgs.fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      hash = "sha256-A5xbBOZSedrO7opvcecL0Fz1uAF4K293xuGeLtBREiI=";
    };
    meta = old.meta // {
      priority = 30;
    };
  }
)
