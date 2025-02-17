{ pkgs, ... }:
pkgs.go_1_24.overrideAttrs (
  old:
  let
    version = "1.24.0";
  in
  {
    inherit version;
    src = pkgs.fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      hash = "sha256-0UEgYUrLKdEryrcr1onyV+tL6eC2+IqPt+Qaxl+FVuU=";
    };
    meta = old.meta // {
      priority = 30;
    };
  }
)
