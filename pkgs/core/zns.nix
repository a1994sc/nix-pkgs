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
  version = "0.2.0";
  sha256 = "sha256-Xm3fMMfP70U5hc0wcmvqM4ESVhUtuGBu+6cKMScIG8o=";
  vendorHash = "sha256-dNPcoV336sjpDCsRJwoqvchPYIVkOMyBz/AV7QYPEws=";
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
