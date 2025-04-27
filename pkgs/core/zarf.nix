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
  pname = "zarf";
  version = "0.53.0";
  sha256 = "sha256-Qfpr1/OH2y9jIIQpFOC0SS4PRRFWYoAHPk4H1HBS4Qs=";
  vendorHash = "sha256-WaHtQJ2bhafkftdsw/4VBKPK7A5cdtjyIdYENmZj0Kg=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    zarf = "github.com/zarf-dev/zarf/src";
    helm = "helm.sh/helm/v3/pkg";
    k9s = "github.com/derailed/k9s";
    k8s = "k8s.io/component-base";
    google = "github.com/google/go-containerregistry/cmd/crane";
  };
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "zarf-dev";
    repo = pname;
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" +'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE_EPOCH
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  preBuild = ''
    mkdir -p build/ui
    touch build/ui/index.html
    ldflags+=" -X ${flag.k8s}/version.gitCommit=$(cat COMMIT)"
    ldflags+=" -X ${flag.k8s}/version.buildDate=$(cat SOURCE_DATE_EPOCH)"
    # set k8s version to client-go version, to match upstream
    K8S_MODULES_VER="$(go list -f '{{.Version}}' -m k8s.io/client-go)"
    K8S_MODULES_MAJOR_VER="$(($(cut -d. -f1 <<<"$K8S_MODULES_VER") + 1))"
    K8S_MODULES_MINOR_VER="$(cut -d. -f2 <<<"$K8S_MODULES_VER")"
    ldflags+=" -X ${flag.helm}/lint/rules.k8sVersionMajor=''${K8S_MODULES_MAJOR_VER}"
    ldflags+=" -X ${flag.helm}/lint/rules.k8sVersionMinor=''${K8S_MODULES_MINOR_VER}"
    ldflags+=" -X ${flag.helm}/chartutil.k8sVersionMajor=''${K8S_MODULES_MAJOR_VER}"
    ldflags+=" -X ${flag.helm}/chartutil.k8sVersionMinor=''${K8S_MODULES_MINOR_VER}"
    ldflags+=" -X ${flag.k9s}/cmd.version=$(go list -f '{{.Version}}' -m github.com/derailed/k9s)"
    ldflags+=" -X ${flag.google}/cmd.Version=$(go list -f '{{.Version}}' -m github.com/google/go-containerregistry)"
    ldflags+=" -X ${flag.zarf}/cmd/tools.syftVersion=$(go list -f '{{.Version}}' -m github.com/anchore/syft)"
    ldflags+=" -X ${flag.zarf}/cmd/tools.archiverVersion=$(go list -f '{{.Version}}' -m github.com/mholt/archiver/v3)"
    ldflags+=" -X ${flag.zarf}/cmd/tools.helmVersion=$(go list -f '{{.Version}}' -m helm.sh/helm/v3)"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X '${flag.zarf}/config.CLIVersion=v${version}'"
    "-X '${flag.k8s}/version.gitVersion=v0.0.0+zarfv${version}'"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    export K9S_LOGS_DIR=$(mktemp -d)
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  subPackages = [ "." ];

  env.CGO_ENABLED = 0;

  meta = with lib; {
    # keep-sorted start
    description = "DevSecOps for Air Gap & Limited-Connection Systems. https://zarf.dev";
    homepage = "https://github.com/zarf-dev/zarf";
    license = [ licenses.asl20 ];
    mainProgram = "zarf";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
