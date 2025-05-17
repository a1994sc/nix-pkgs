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
  pname = "blocky";
  version = "0.25";
  hash = "sha256-yd9qncTuzf7p1hIYHzzXyxAx1C1QiuQAIYSKcjCiF0E=";
  vendorHash = "sha256-Ck80ym64RIubtMHKkXsbN1kFrB6F9G++0U98jPvyoHw=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
in
buildGoModule rec {
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
