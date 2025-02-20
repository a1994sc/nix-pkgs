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
  pname = "packer";
  version = "1.12.0";
  sha256 = "sha256-19eaQs2f4zM3lXuQrWoS2S/tXWe3HdxXesjtVG67LFE=";
  vendorHash = "sha256-BsYL0PEpujsXLjhFP05yK8Pr0tc0lrdsQqxzmKso3rw=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "hashicorp";
    repo = pname;
  };

  subPackages = [ "." ];

  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  postInstall = ''
    installShellCompletion --bash --name packer <(echo complete -C $out/bin/packer packer)
    installShellCompletion --zsh contrib/zsh-completion/_packer
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/hashicorp/packer/blob/v${version}/CHANGELOG.md";
    description = "A tool for creating identical machine images for multiple platforms from a single source configuration";
    homepage = "https://github.com/hashicorp/packer";
    # license = [ licenses.bsl11 ];
    platforms = platforms.linux;
    # keep-sorted end
  };
}
