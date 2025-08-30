{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "helmper";
  version = "0.3.0";
  sha256 = "sha256-THJFMR14L3j8D5s+F+I1K5K+R9SzR95NCSOXjIslayw=";
  vendorHash = "sha256-/BwXWvumPR9j/hCqoGX5xIYdjQvZ7DyxgNqla9bXOBQ=";
  # keep-sorted end
  rev = "v" + version;
  flag.helmper = "github.com/ChristofferNissen/helmper";
in
asciiBuildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "ChristofferNissen";
    repo = pname;
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" +'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE_EPOCH
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  ldflags = [
    "-w"
    "-s"
    "-X ${flag.helmper}/internal.version=${rev}"
  ];

  env.CGO_ENABLED = 0;

  preBuild = ''
    ldflags+=" -X ${flag.helmper}/internal.commit=$(cat COMMIT)"
    ldflags+=" -X ${flag.helmper}/internal.date=$(cat SOURCE_DATE_EPOCH)"
  '';

  doCheck = false;

  meta = with lib; {
    # keep-sorted start
    description = "Import Helm Charts to OCI registries, optionally with vulnerability patching ";
    homepage = "https://github.com/ChristofferNissen/helmper";
    license = [ lib.licenses.asl20 ];
    mainProgram = "helmper";
    platforms = platforms.linux;
    # keep-sorted end
  };
}
