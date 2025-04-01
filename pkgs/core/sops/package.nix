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
  version = "3.10.1";
  sha256 = "sha256-LdsuN243oQ/L6LYgynb7Kw60alXn5IfUfhY0WaZFVCU=";
  vendorHash = "sha256-I+iwimrNdKABZFP2etZTQJAXKigh+0g/Jhip86Cl5Rg=";
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
