{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  # keep-sorted start prefix_order=pname,version,sha256
  pname = "usage";
  version = "2.2.2";
  sha256 = "sha256-Hnq3ViMrNIo9m/1mePjEzMv87U24wY50UiYxnpJqHR8=";
  cargoHash = "sha256-Zj8Z88gYx+i0VN14HbO1LSlWjZX1EvrtyKvAwpnFMgs=";
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
