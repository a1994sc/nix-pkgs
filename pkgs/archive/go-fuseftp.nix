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
  version = "0.6.6";
  sha256 = "sha256-70VmT8F+RNiDk6fnrzDktdfNhZk20sXF+b3TBTAkNHo=";
  vendorHash = "sha256-wp4jOmeVdfuRwdclCzBonNCkhgsNUBOBL6gxlrznC1A=";
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

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/telepresenceio/go-fuseftp/releases/tag/v${version}";
    description = "User space file system for FTP";
    homepage = "https://github.com/telepresenceio/go-fuseftp";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
