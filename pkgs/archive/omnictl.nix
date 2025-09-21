{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "omnictl";
  version = "1.1.4";
  sha256 = "sha256-vWe3sop2m5S+Eed61ZkDMwZ/w+15FNo4IinZqKTlCnU=";
  vendorHash = "sha256-9BzR5ZjSoaPYxMhweNaOalFsvX5BM4EVX8HAR17Xzoc=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "siderolabs";
    repo = "omni";

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

  env.CGO_ENABLED = 0;
  env.GOWORK = "off";

  subPackages = [ "cmd/${pname}" ];

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
    homepage = "https://github.com/siderolabs/omni";
    license = [ licenses.mpl20 ];
    mainProgram = "omnictl";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
