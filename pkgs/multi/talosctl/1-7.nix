{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "talosctl";
  version = "1.7.7";
  sha256 = "sha256-gihVZX1wwlpV9w/pydV9wQLQVbBCeIwOVMwd2PdI9Nw=";
  vendorHash = "sha256-6KSa1XEAVPI1Pyhatsv8vhzY+1G/Gt426iS3yqNhjCg=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "siderolabs";
    repo = "talos";

    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git describe --match=none --always --abbrev=8 > $out/COMMIT
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  ldflags = [
    "-s"
    "-w"
  ];

  GOEXPERIMENT = "loopvar";
  env.CGO_ENABLED = 0;

  subPackages = [ "cmd/${pname}" ];

  preBuild = ''
    cat COMMIT | tr -d "\n" > pkg/machinery/gendata/data/sha
    export GOWORK="off"
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/talosctl completion $shell > talosctl.$shell
      installShellCompletion talosctl.$shell
    done
  '';

  doCheck = false;

  meta = with lib; {
    # keep-sorted start
    description = "A CLI for out-of-band management of Kubernetes nodes created by Talos";
    homepage = "https://www.talos.dev/";
    license = [ licenses.mpl20 ];
    mainProgram = "talosctl";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
