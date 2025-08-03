{
  # keep-sorted start
  buildGoModule,
  darwin ? null,
  fetchFromGitHub,
  lazysql,
  lib,
  stdenv,
  testers,
  xorg ? null,
# keep-sorted end
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "lazysql";
  version = "0.4.0";
  sha256 = "sha256-XQjdMmHVrNzfQN/uFQFxGK9LwnRh1IkAvRQSDcAYWXo=";
  vendorHash = "sha256-LLOUTml/mz7edCUy82k+S5PfpFovgUTQr0BoQQXiVGs=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "jorgerojas26";
    repo = "lazysql";
  };

  ldflags = [
    "-X main.version=${version}"
  ];

  env.CGO_ENABLED = 0;

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [ xorg.libX11 ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ darwin.apple_sdk.frameworks.Cocoa ];

  passthru.tests.version = testers.testVersion {
    package = lazysql;
    command = "lazysql version";
  };

  meta = with lib; {
    # keep-sorted start
    description = "A cross-platform TUI database management tool written in Go";
    homepage = "https://github.com/jorgerojas26/lazysql";
    license = [ licenses.mit ];
    mainProgram = "lazysql";
    # keep-sorted end
  };
}
