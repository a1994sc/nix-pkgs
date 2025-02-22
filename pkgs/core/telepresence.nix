{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  fuse,
  go-fuseftp,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "telepresence";
  version = "2.21.3";
  sha256 = "sha256-s0P8l8EokVGCUXo9Bm+uPtxS9uwIhBULtFeVR/Fl38M=";
  vendorHash = "sha256-FvNC0E367p473yNfbMntSOxh6TYa7OoR6/YbZ7q4WRs=";
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

  propagatedBuildInputs = [
    go-fuseftp
  ];

  preBuild = ''
    cp ${go-fuseftp}/bin/main ./pkg/client/remotefs/fuseftp.bits
  '';

  # nativeBuildInputs = [
  #   installShellFiles
  # ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/telepresenceio/telepresence/v2/pkg/version.Version=${src.rev}"
  ];

  subPackages = [ "cmd/telepresence" ];

  env.CGO_ENABLED = 0;

  meta = with lib; {
    # keep-sorted start
    description = "Local development against a remote Kubernetes or OpenShift cluster";
    homepage = "https://telepresence.io";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
