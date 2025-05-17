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
  pname = "helmify";
  version = "0.4.18";
  sha256 = "sha256-yk+ST0W7HLlAe5NOaBrQvpG6AYgwWDkpK5/ml5TLAQw=";
  vendorHash = "sha256-ShX11hDA8oPkvT37vYArL8VzthfWdxbq9mvpYuL/0gE=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "arttor";
    repo = pname;
  };

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  doInstallCheck = true;

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/arttor/helmify/releases/tag/v${version}";
    description = "Creates Helm chart from Kubernetes yaml";
    homepage = "https://github.com/arttor/helmify";
    license = [ licenses.mit ];
    mainProgram = pname;
    # keep-sorted end
  };
}
