{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  go-mockery,
  installShellFiles,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "terragrunt";
  version = "0.73.8";
  sha256 = "sha256-bYE1Mfj3Wypy7kfHVQg7RWt/ruX1PpPdz42XZuM1UGE=";
  vendorHash = "sha256-fsKFq9iXEOSDj2AJMEio+nvzB+PHemKQtXrJm9xwmGk=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
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
    go-mockery
  ];

  env.CGO_ENABLED = 0;

  postInstall = ''
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
