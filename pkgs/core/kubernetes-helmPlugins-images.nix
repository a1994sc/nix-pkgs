{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "helm-images";
  version = "0.1.7";
  sha256 = "sha256-nO5zxzO/USdcn6yTdXE/KP76z5stAljFtbASCUSK6zw=";
  vendorHash = "sha256-oWf4y/5bp1gaDd2UmW0QCNEF7jiLVEYwhMlyJhBLH9Q=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "nikhilsbhat";
    repo = "helm-images";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" +'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE_EPOCH
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  ldflags = [
    "-s"
    "-w"
    "-X 'github.com/nikhilsbhat/helm-images/version.Version=${version}'"
    "-X 'github.com/nikhilsbhat/helm-images/version.BuildDate=$(cat SOURCE_DATE_EPOCH)'"
    "-X 'github.com/nikhilsbhat/helm-images/version.Revision=$(cat COMMIT)'"
    "-X 'github.com/nikhilsbhat/helm-images/version.Platform=$(go env GOOS)/$(go env GOARCH)'"
    "-X 'github.com/nikhilsbhat/helm-images/version.GoVersion=$( go version | awk '{printf $3}')'"
    "-X 'github.com/nikhilsbhat/helm-images/version.Env=production'"
  ];

  # NOTE: Remove the install and upgrade hooks.
  postPatch = ''
    sed -i '/^hooks:/,+2 d' plugin.yaml
  '';

  env.CGO_ENABLED = 0;

  doCheck = false;

  buildPhase =
    let
      args = builtins.concatStringsSep " " ldflags;
    in
    ''
      go build -o image -buildvcs=false -trimpath -ldflags "${args}"
    '';

  installPhase = ''
    install -dm755 $out/helm-images/bin
    mv image $out/helm-images/bin/helm-images
    install -m644 -Dt $out/helm-images plugin.yaml
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Helm plugin to fetch all possible images from the chart before deployment or from a deployed release";
    homepage = "https://github.com/nikhilsbhat/helm-images";
    license = [ licenses.mit ];
    # keep-sorted end
  };
}
