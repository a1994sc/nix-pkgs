{
  # keep-sorted start
  buildGoModule,
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
  version = "3.9.4";
  sha256 = "sha256-w2RMK1Fl/k8QXV68j0Kc6shtx4vQa07RCnpgHLM8c8Q=";
  vendorHash = "sha256-wxmSj3QaFChGE+/2my7Oe2mhprwi404izUxteecyggY=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
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
