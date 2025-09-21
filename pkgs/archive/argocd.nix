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
  pname = "argocd";
  version = "3.1.6";
  sha256 = "sha256-RatNDFDLQ/qgnEbs9FnboQP6mGBpRpp9hUEOUulviAw=";
  vendorHash = "sha256-oI0N6V8enziJK21VCgQ4KUOWqbC5TcZd3QnWiTTeTHQ=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    argo = "github.com/argoproj/argo-cd/v2/common";
  };
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "argoproj";
    repo = "argo-cd";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" +'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE_EPOCH
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  proxyVendor = true;

  subPackages = [ "cmd" ];

  preBuild = ''
    ldflags+=" -X ${flag.argo}.buildDate=$(cat COMMIT)"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X ${flag.argo}.version=${version}"
    "-X ${flag.argo}.gitCommit=${src.rev}"
    "-X ${flag.argo}.gitTag=${src.rev}"
    "-X ${flag.argo}.gitTreeState=clean"
    "-X ${flag.argo}.kubectlVersion=v0.24.2"
  ];

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -Dm755 "$GOPATH/bin/cmd" -T $out/bin/argocd
    runHook postInstall
  '';

  doInstallCheck = true;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Declarative continuous deployment for Kubernetes";
    homepage = "https://github.com/argoproj/argo-cd";
    license = [ licenses.asl20 ];
    mainProgram = "argocd";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
