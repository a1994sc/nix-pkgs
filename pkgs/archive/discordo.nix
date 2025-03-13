{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  makeWrapper,
  xsel,
  wl-clipboard,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "discordo";
  version = "0-unstable-2025-02-23";
  hash = "sha256-dg/hyF8Lg0fQdEdDG3LLICFZVyjp3LK5SSurKK1eCVM=";
  vendorHash = "sha256-vvKvU0mZ4pB0pog7rA0busnNRMhllOSd0/LINQaYSPk=";
  # keep-sorted end
  rev = "eeb54e0577144eacc371f5bc3859faaa59ddf750";
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "ayn2op";
    repo = pname;
  };

  env.CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
  ];

  # Clipboard support on X11 and Wayland
  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/discordo \
      --prefix PATH : ${
        lib.makeBinPath [
          xsel
          wl-clipboard
        ]
      }
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    # keep-sorted start
    description = "Lightweight, secure, and feature-rich Discord terminal client";
    homepage = "https://github.com/ayn2op/discordo";
    license = [ licenses.mit ];
    mainProgram = "discordo";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
