{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  lndir,
  testers,
  regclient,
}:
let
  # keep-sorted start prefix_order=pname,version,sha256
  pname = "regclient";
  version = "0.8.2";
  sha256 = "sha256-/I6RPiDSMzc+6O7FnKQKLHofJvtnH4Dt2ZMxjPj9lJ4=";
  vendorHash = "sha256-SWkrPpjAA32XkToh7ujSPaRNvHtf2ymvx5E7iGD5B8k=";
  # keep-sorted end
  rev = "v" + version;
  bins = [
    "regbot"
    "regctl"
    "regsync"
  ];
in
buildGoModule rec {
  inherit version pname vendorHash;
  tag = rev;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "regclient";
    repo = "regclient";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" +'%Y-%m-%dT%H:%M:%SZ' > $out/SOURCE_DATE_EPOCH
      find $out -name .git -print0 | xargs -0 rm -rf
    '';
  };

  outputs = [ "out" ] ++ bins;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/regclient/regclient/internal/version.vcsTag=${tag}"
    "-X github.com/regclient/regclient/internal/version.vcsRef=${tag}"
  ];

  preBuild = ''
    ldflags+=" -X github.com/regclient/regclient/internal/version.vcsCommit=$(cat COMMIT)"
    ldflags+=" -X github.com/regclient/regclient/internal/version.vcsDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  nativeBuildInputs = [
    installShellFiles
    lndir
  ];

  postInstall = lib.concatMapStringsSep "\n" (bin: ''
    export bin=''$${bin}
    export outputBin=bin

    mkdir -p $bin/bin
    mv $out/bin/${bin} $bin/bin

    installShellCompletion --cmd ${bin} \
      --bash <($bin/bin/${bin} completion bash) \
      --fish <($bin/bin/${bin} completion fish) \
      --zsh <($bin/bin/${bin} completion zsh)

    lndir -silent $bin $out

    unset bin outputBin
  '') bins;

  checkFlags = [
    # touches network
    "-skip=^ExampleNew$"
  ];

  passthru.tests = lib.mergeAttrsList (
    map (bin: {
      "${bin}Version" = testers.testVersion {
        package = regclient;
        command = "${bin} version";
        version = tag;
      };
    }) bins
  );

  meta = with lib; {
    description = "Docker and OCI Registry Client in Go and tooling using those libraries";
    homepage = "https://github.com/regclient/regclient";
    license = [ licenses.asl20 ];
  };
}
