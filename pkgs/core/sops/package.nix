{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  nix-update-script,
  runCommand,
  stdenv,
  versionCheckHook,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "sops";
  version = "3.10.2";
  sha256 = "sha256-IdQnxVBMAQpSAYB2S3D3lSULelFMBpjiBGOxeTgC10I=";
  vendorHash = "sha256-7aHUIERVSxv3YGAMteGbqkAZQXXDVziV0rhUhjwch3U=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "getsops";
    repo = pname;
  };

  subPackages = [ "cmd/sops" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/getsops/sops/v3/version.Version=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd sops --bash ${./bash_autocomplete}
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/getsops/sops/blob/v${version}/CHANGELOG.rst";
    description = "Simple and flexible tool for managing secrets";
    homepage = "https://github.com/getsops/sops";
    license = [ licenses.mpl20 ];
    mainProgram = "sops";
    # keep-sorted end
  };
}
