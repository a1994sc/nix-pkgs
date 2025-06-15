{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "talhelper";
  version = "3.0.29";
  sha256 = "sha256-D0cvYOaZZDXNknMlTwBjcJKkkkvCUoo05ozZaWUAilE=";
  vendorHash = "sha256-k9gYJpg9wb0w5TLP15sY9SD6S7v8+pBSdeDyAzME0us=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    talhelper = "github.com/budimanjojo/talhelper";
  };
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "budimanjojo";
    repo = pname;
  };

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
    "-X ${flag.talhelper}/cmd.version=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  postInstall = ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh <($out/bin/${pname} completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "A tool to help creating Talos kubernetes cluster";
    homepage = "https://github.com/budimanjojo/talhelper";
    license = [ licenses.bsd3 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
