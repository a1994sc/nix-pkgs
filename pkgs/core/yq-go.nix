{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  runCommand,
  stdenv,
  yq-go,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "yq-go";
  version = "4.48.1";
  sha256 = "sha256-cY+z4im2pB2ehV8AXNUHzzTjPvopd7KX8aRE8oYIgE0=";
  vendorHash = "sha256-p+7dD3NVXg3XZowIgDaGs1MSaxXY5OPLmnw44p4m4A4=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "mikefarah";
    repo = "yq";
  };

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd yq \
      --bash <($out/bin/yq completion bash) \
      --fish <($out/bin/yq completion fish) \
      --zsh  <($out/bin/yq completion zsh)
  '';

  passthru.tests = {
    simple = runCommand "${pname}-test" { } ''
      echo "test: 1" | ${yq-go}/bin/yq eval -j > $out
      [ "$(cat $out | tr -d $'\n ')" = '{"test":1}' ]
    '';
  };

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/mikefarah/yq/raw/v${version}/release_notes.txt";
    description = "Portable command-line YAML processor";
    homepage = "https://github.com/mikefarah/yq";
    license = [ licenses.mit ];
    mainProgram = "yq";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
