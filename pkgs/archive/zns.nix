{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  fuse,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "zns";
  version = "0.4.0";
  sha256 = "sha256-hJYn5/QNE0QTw1FaAY8R2MXbSGiMbx/XRB5LNJ2vFQw=";
  vendorHash = "sha256-u5C/A9o41GFhE7dM2/e10bnhLEjd2t4qJeQatO1tAiM=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
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
