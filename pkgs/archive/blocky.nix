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
  pname = "blocky";
  version = "0.26.2";
  hash = "sha256-yo21f12BLINXb8HWdR3ZweV5+cTZN07kxCxO1FMJq/4=";
  vendorHash = "sha256-cIDKUzOAs6XsyuUbnR2MRIeH3LI4QuohUZovh/DVJzA=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "0xERR0R";
    repo = pname;
  };

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/0xERR0R/blocky/util.Version=${version}"
  ];

  # needs network connection and fails at
  # https://github.com/0xERR0R/blocky/blob/development/resolver/upstream_resolver_test.go
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/${pname} version | grep "${version}"

    runHook postInstallCheck
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/0xERR0R/blocky/releases/tag/v${version}";
    description = "Fast and lightweight DNS proxy as ad-blocker for local network with many features";
    homepage = "https://github.com/0xERR0R/blocky";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    # keep-sorted end
  };
}
