{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "talosctl";
  version = "1.10.5";
  sha256 = "sha256-cPBAygg3qYXJQDrR5ljTdolkMtuJUtivm36MiwIkwYA=";
  vendorHash = "sha256-0mW8WpfdLgbIEwICJfNuPz55p45tLQ2SgjLy/Ez7xWc=";
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

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  doCheck = false;

  meta = with lib; {
    # keep-sorted start
    description = "A CLI for out-of-band management of Kubernetes nodes created by Talos";
    homepage = "https://github.com/siderolabs/talos";
    license = [ licenses.mpl20 ];
    mainProgram = "talosctl";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
