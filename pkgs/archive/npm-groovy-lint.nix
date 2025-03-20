{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jdk,
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "npm-groovy-lint";
  version = "15.1.0";
  npmDepsHash = "sha256-qvao/iJ3njcdrEXsH3jgNh0LuaAPrO2bLVOeiUdTwVM=";
  sha256 = "sha256-BLR709MCzq3t9+7v4vfBzojd0tARG/pvhCxob5A7Xxk=";
  # keep-sorted end
  rev = "v" + version;
in
# borrowed from:
# https://github.com/nix-community/nur-combined/blob/e9afebc4a815a22c337f10b0150519d9fdb63f27/repos/wolfangaukang/pkgs/npm-groovy-lint/default.nix#L7
buildNpmPackage rec {
  inherit version pname npmDepsHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    repo = pname;
    owner = "nvuillam";
  };

  postFixup = ''
    wrapProgram $out/bin/npm-groovy-lint --add-flags "--javaexecutable ${jdk}/bin/java"
  '';

  meta = {
    # keep-sorted start
    changelog = "https://github.com/nvuillam/npm-groovy-lint/releases/tag/${src.rev}";
    description = "Lint, format and auto-fix your Groovy/Jenkinsfile/Gradle files using command line";
    homepage = "https://github.com/nvuillam/npm-groovy-lint";
    license = [ lib.licenses.gpl3Plus ];
    mainProgram = pname;
    # keep-sorted end
  };
}
