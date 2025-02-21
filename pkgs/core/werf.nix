{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  btrfs-progs,
  testers,
  werf,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "werf";
  version = "2.27.1";
  sha256 = "sha256-hfQIBN+7H23JgPuP9sApE5CBnjWMW61Z4/hwPEyMMV0=";
  vendorHash = "sha256-RqTuM2AirrH0jTlvJod52yR9S8eQiecusrkJhVIidMg=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "werf";
    repo = pname;
  };

  proxyVendor = true;

  subPackages = [ "cmd/werf" ];

  nativeBuildInputs = [ installShellFiles ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ btrfs-progs ]
    ++ lib.optionals stdenv.hostPlatform.isGnu [ stdenv.cc.libc.static ];

  env.CGO_ENABLED = if stdenv.hostPlatform.isLinux then 1 else 0;

  ldflags =
    [
      "-s"
      "-w"
      "-X github.com/werf/werf/v2/pkg/werf.Version=v${version}"
    ]
    ++ lib.optionals (env.CGO_ENABLED == 1) [
      "-extldflags=-static"
      "-linkmode external"
    ];

  tags =
    [
      "containers_image_openpgp"
      "dfrunmount"
      "dfrunnetwork"
      "dfrunsecurity"
      "dfssh"
    ]
    ++ lib.optionals (env.CGO_ENABLED == 1) [
      "cni"
      "exclude_graphdriver_devicemapper"
      "netgo"
      "no_devmapper"
      "osusergo"
      "static_build"
    ];

  preCheck =
    ''
      # Test all targets.
      unset subPackages

      # Remove tests that require external services.
      rm -rf \
        integration/suites \
        pkg/true_git/*test.go \
        test/e2e

      # errors attempting to write config to read-only $HOME
      export HOME=$TMPDIR
    ''
    + lib.optionalString (env.CGO_ENABLED == 0) ''
      # A workaround for osusergo.
      export USER=nixbld
    '';

  postInstall = ''
    installShellCompletion --cmd werf \
      --bash <($out/bin/werf completion --shell=bash) \
      --zsh <($out/bin/werf completion --shell=zsh)
  '';

  passthru.tests.version = testers.testVersion {
    package = werf;
    command = "werf version";
    version = src.rev;
  };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/werf/werf/releases/tag/${src.rev}";
    description = "GitOps delivery tool";
    homepage = "https://github.com/werf/werf";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    # keep-sorted end
    longDescription = ''
      The CLI tool gluing Git, Docker, Helm & Kubernetes with any CI system to
      implement CI/CD and Giterminism.
    '';
  };
}
