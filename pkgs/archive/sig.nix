{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  # keep-sorted start prefix_order=pname,version,sha256
  pname = "sig";
  version = "0.1.4";
  sha256 = "sha256-685VBQ64B+IbSSyqtVXtOgs4wY85WZ/OceHL++v5ip4=";
  cargoHash = "sha256-x4/vCFbC+kxhne4iRjuJy4L6QRpRKrJU3r+TPpDh4Pw=";
  # keep-sorted end
  rev = "v" + version;
in
rustPlatform.buildRustPackage {
  inherit version pname cargoHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "ynqa";
    repo = "sig";
  };

  meta = with lib; {
    # keep-sorted start
    description = "Interactive grep (for streaming)";
    homepage = "https://github.com/ynqa/sig";
    license = [ licenses.mit ];
    mainProgram = "sig";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
