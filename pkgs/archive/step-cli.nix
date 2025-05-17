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
  pname = "step-cli";
  version = "0.28.6";
  sha256 = "sha256-PQC6xXCJqf5CgXLTn+bOcf3GmNrvqZ94Y1tvEHW3ld0=";
  vendorHash = "sha256-+pHc2uBgQwMkJ7BTgHGHDPgfBpLlN0Yxf+6Enhb7cys=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "smallstep";
    repo = "cli";
  };

  ldflags = [
    "-w"
    "-s"
    "-X main.Version=${version}"
  ];

  env.CGO_ENABLED = 0;

  preCheck = ''
    # Tries to connect to smallstep.com
    rm command/certificate/remote_test.go
  '';

  checkFlags = [
    # requires networking
    "-skip=Test_healthAction"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd step \
      --bash <($out/bin/step completion bash) \
      --fish <($out/bin/step completion fish) \
      --zsh  <($out/bin/step completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/smallstep/cli/blob/v${version}/CHANGELOG.md";
    description = "A zero trust swiss army knife for working with X509, OAuth, JWT, OATH OTP, etc";
    homepage = "https://github.com/smallstep/cli";
    license = [ lib.licenses.asl20 ];
    mainProgram = "step";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
