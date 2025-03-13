{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  fuse,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "zns";
  version = "0.3.0";
  sha256 = "sha256-gcR/jNVWYVOiynsLdPG+sxnSPCqzYfKwKXBXh1G2/rc=";
  vendorHash = "sha256-vMcOVoNO8CJ7L3Wsy9HCovSfdezwopHIipPV1gGCZog=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "znscli";
    repo = pname;
  };

  ldflags = [
    "-s"
    "-w"
    "-X github.com/znscli/zns/cmd.version=${version}"
  ];

  subPackages = [ "." ];

  env.CGO_ENABLED = 0;

  meta = with lib; {
    # keep-sorted start
    description = "CLI tool for querying DNS records with readable, colored output.";
    homepage = "https://github.com/znscli/zns";
    license = [ licenses.mit ];
    mainProgram = "zns";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
