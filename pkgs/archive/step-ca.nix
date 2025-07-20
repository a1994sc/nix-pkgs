{
  # keep-sorted start
  buildGoModule,
  coreutils,
  darwin,
  fetchFromGitHub,
  hsmSupport ? true,
  installShellFiles,
  lib,
  pcsclite,
  pkg-config,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "step-ca";
  version = "0.28.4";
  sha256 = "sha256-pN+zvLZuBfw40KCegh7J5RzDOXgbLHNhhFJRFSKhlYc=";
  vendorHash = "sha256-gGPrrl5J8UrjUpof2DaSs1fAQsMSsyAMlC67h5V75+k=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "smallstep";
    repo = "certificates";
  };

  ldflags = [
    "-w"
    "-X main.Version=${version}"
  ];

  buildInputs =
    lib.optionals (hsmSupport && stdenv.hostPlatform.isLinux) [ pcsclite ]
    ++ lib.optionals (hsmSupport && stdenv.hostPlatform.isDarwin) [ darwin.apple_sdk.frameworks.PCSC ];

  postPatch = ''
    substituteInPlace authority/http_client_test.go --replace-fail 't.Run("SystemCertPool", func(t *testing.T) {' 't.Skip("SystemCertPool", func(t *testing.T) {'
    substituteInPlace systemd/step-ca.service --replace "/bin/kill" "${coreutils}/bin/kill"
  '';

  preBuild = ''
    ${lib.optionalString (!hsmSupport) "export CGO_ENABLED=0"}
  '';

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  # Tests need to run in a reproducible order, otherwise they run unreliably on
  # (at least) x86_64-linux.
  checkFlags = [ "-p 1" ];

  nativeBuildInputs = [ installShellFiles ] ++ lib.optionals hsmSupport [ pkg-config ];

  postInstall = ''
    install -Dm444 -t $out/lib/systemd/system systemd/step-ca.service
  '';

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/smallstep/certificates/releases/tag/v${version}";
    description = "Private certificate authority (X.509 & SSH) & ACME server for secure automated certificate management, so you can use TLS everywhere & SSO for SSH";
    homepage = "https://github.com/smallstep/certificates";
    license = [ lib.licenses.asl20 ];
    mainProgram = "step";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
