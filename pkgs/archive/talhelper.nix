{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "talhelper";
  version = "3.0.32";
  sha256 = "sha256-pLVR/vD7wMH/8UziWe5nwL/fBrexg1BtiJouRb73L4E=";
  vendorHash = "sha256-zmB1XEU6k6PPuz3J9btDJmP0wpj//Ya1xDtkdv+7P24=";
  # keep-sorted end
  rev = "v" + version;
  flag = {
    talhelper = "github.com/budimanjojo/talhelper";
  };
in
asciiBuildGoModule rec {
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
