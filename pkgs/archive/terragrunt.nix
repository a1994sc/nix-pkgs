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
  version = "0.87.4";
  sha256 = "sha256-HaTm9Rgf/VmI+9s3ab5SrgO3HZhzzherKwHHR+WZVGM=";
  vendorHash = "sha256-HE2BDUO9gpsGQ8YaABjEx6LRcZo+436B/dh00Od2P7w=";
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
