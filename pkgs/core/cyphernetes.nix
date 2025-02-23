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
  pname = "cyphernetes";
  version = "0.16.0";
  sha256 = "sha256-BxeKA+y5kehk8mj72ZCSjp9JAtnfFa1JqUL/bX0hmBs=";
  vendorHash = "sha256-QthLrLhi+hWngtc11nyFPU63exHZ0mh3IWWa8YHXFPA=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "AvitalTamir";
    repo = pname;
  };

  subPackages = [ "cmd/cyphernetes" ];

  ldflags = [
    "-w"
    "-s"
  ];

  doCheck = false;

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  meta = with lib; {
    # keep-sorted start
    description = "A Kubernetes Query Language ";
    homepage = "https://github.com/AvitalTamir/cyphernetes";
    license = [ lib.licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
