{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
let
  # keep-sorted start prefix_order=pname,version,sha256
  pname = "wasm-pkg-tools";
  version = "0.11.0";
  sha256 = "sha256-l8ArzujFirquSKMDkcoP8KukLFCRB7U8BejzMGUD59Y=";
  cargoHash = "sha256-ngVnF2eLZfa4ziliAaJOmu5YbnetEovH66kWXp2w1gY=";
  # keep-sorted end
  rev = "v" + version;
in
rustPlatform.buildRustPackage {
  inherit version pname cargoHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "bytecodealliance";
    repo = "wasm-pkg-tools";
  };

  checkFlags = [
    # network required
    "--skip=publish_and_fetch_smoke_test"
    "--skip=fetch_with_custom_config"
    "--skip=test_build_wit"
    "--skip=check"
    "--skip=build_and_publish_with_metadata"
    "--skip=test_fetch::case_1::output_1_OutputType__Wasm"
    "--skip=test_fetch::case_1::output_2_OutputType__Wit"
    "--skip=test_fetch::case_2::output_1_OutputType__Wasm"
    "--skip=test_fetch::case_2::output_2_OutputType__Wit"
    "--skip=test_nested_local::output_1_OutputType__Wasm"
    "--skip=test_nested_local::output_2_OutputType__Wit"
  ];

  RUST_BACKTRACE = 1;

  meta = with lib; {
    # keep-sorted start
    description = "Tools to package up Wasm Components";
    homepage = "https://github.com/bytecodealliance/wasm-pkg-tools";
    license = [ licenses.asl20 ];
    mainProgram = "wkg";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
