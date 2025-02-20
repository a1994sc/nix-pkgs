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
  pname = "step-cli";
  version = "0.28.3";
  sha256 = "sha256-q+HLqk4rBhzHEuUL5Dg+H3FuRMHQURiWAM1+qYm0NsQ=";
  vendorHash = "sha256-+HDdrm7N8weEX/hMt2vsxEQq1CNZP9Jj2UKA+7JN1Io=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "smallstep";
    repo = "cli";
  };

  ldflags = [
    "-w"
    "-s"
    "-X main.Version=${version}"
  ];

  env.CGO_ENABLED = 0;

  preCheck = ''
    # Tries to connect to smallstep.com
    rm command/certificate/remote_test.go
  '';

  checkFlags = [
    # requires networking
    "-skip=Test_healthAction"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/step completion $shell > step.$shell
      installShellCompletion step.$shell
    done
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/smallstep/cli/blob/v${version}/CHANGELOG.md";
    description = "A zero trust swiss army knife for working with X509, OAuth, JWT, OATH OTP, etc";
    homepage = "https://github.com/smallstep/cli";
    license = [ lib.licenses.asl20 ];
    mainProgram = "step";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
