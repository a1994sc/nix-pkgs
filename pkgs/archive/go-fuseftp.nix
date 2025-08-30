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
  pname = "go-fuseftp";
  version = "0.6.7";
  sha256 = "sha256-O2t0l/t2UrBmTkclqCRziw31d9mtOpuDlAgA+KN6ZtE=";
  vendorHash = "sha256-KXuwOneaBL1Ic+8B+mSiDb8IRUy1S/kN/pyKEKfYnHQ=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
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
