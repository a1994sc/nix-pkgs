{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  mockgen,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "terragrunt";
  version = "0.90.0";
  sha256 = "sha256-tc+3+H/u/6IpkmvlwObzVjUnJzBzElme0tT+zktGfkw=";
  vendorHash = "sha256-+4mDmC1B4YmExOJqS/vlTxBiI5/rKcn3Vyw53BfvAxA=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "gruntwork-io";
    repo = pname;
  };

  preBuild = ''
    make generate-mocks
  '';

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/gruntwork-io/go-commons/version.Version=v${version}"
  ];

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/terragrunt --help
    $out/bin/terragrunt --version | grep "v${version}"
    runHook postInstallCheck
  '';

  nativeBuildInputs = [
    installShellFiles
    mockgen
  ];

  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --bash --name terragrunt <(echo complete -C $out/bin/terragrunt terragrunt)
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/gruntwork-io/terragrunt/releases/tag/v${version}";
    description = "A thin wrapper for Terraform that supports locking for Terraform state and enforces best practices";
    homepage = "https://github.com/gruntwork-io/terragrunt";
    license = [ licenses.mit ];
    mainProgram = "terragrunt";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
