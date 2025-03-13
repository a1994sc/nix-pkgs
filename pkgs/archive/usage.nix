{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  # keep-sorted start prefix_order=pname,version,sha256
  pname = "usage";
  version = "2.0.5";
  sha256 = "sha256-No/BDBW/NRnF81UOuAMrAs4cXEdzEAxnmkn67mReUcM=";
  cargoHash = "sha256-WD5N3WvndjUR8aUJGhsDe0Vlq9NWwYamXmpEsfvVgIA=";
  # keep-sorted end
  rev = "v" + version;
in
rustPlatform.buildRustPackage {
  inherit version pname cargoHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "jdx";
    repo = "usage";
  };

  checkFlags = [
    # reason for disabling test
    "--skip=complete_word_mounted"
  ];

  meta = with lib; {
    # keep-sorted start
    description = "A specification for CLIs";
    homepage = "https://github.com/jdx/usage";
    license = [ licenses.mit ];
    mainProgram = "usage";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
