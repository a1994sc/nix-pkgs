{
  # keep-sorted start
  asciiBuildGoModule,
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
  version = "0.4.1";
  sha256 = "sha256-M6G0Bp9s1XhgZL9BZDzbJmUmE+UHidpsGIaNt1i7CGw=";
  vendorHash = "sha256-NGwCTEh1/5dJWOCSe18FZYYu8v7Mj6MWVEWyNNA1T68=";
  # keep-sorted end
  rev = "v" + version;
in
asciiBuildGoModule rec {
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
