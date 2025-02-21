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
  pname = "go-fuseftp";
  version = "0.6.1";
  sha256 = "sha256-qOMkFIpeV9r+2RuFyo2J4EPeB+DNMrJLRd7o9SvMFKY=";
  vendorHash = "sha256-D7y1In21shInPNBGUYq/Olx53/rxQN1K+Cfvb+4qVRs=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "telepresenceio";
    repo = pname;
  };

  buildInputs = [ fuse ];

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "pkg/main" ];
}
