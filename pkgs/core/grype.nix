{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  git,
  installShellFiles,
  lib,
  openssl,
  stdenv,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "grype";
  version = "0.92.0";
  hash = "sha256-DwPKhUIBQYbFEYi3EmDQ4hWDLksexTOoPZCL4G+VXks=";
  vendorHash = "sha256-4yE8NIFVMikGXd44K9ysXKGzoMyW8sQcAzy61RNR/Jo=";
  # keep-sorted end
  rev = "refs/tags/v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev hash;
    owner = "anchore";
    repo = "grype";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      # 0000-00-00T00:00:00Z
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  proxyVendor = true;

  nativeBuildInputs = [ installShellFiles ];

  env.CGO_ENABLED = 0;

  nativeCheckInputs = [
    git
    openssl
  ];

  subPackages = [ "cmd/grype" ];

  excludedPackages = "test/integration";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${version}"
    "-X=main.gitDescription=v${version}"
    "-X=main.gitTreeState=clean"
  ];

  preBuild = ''
    # grype version also displays the version of the syft library used
    # we need to grab it from the go.sum and add an ldflag for it
    SYFT_VERSION="$(grep "github.com/anchore/syft" go.sum -m 1 | awk '{print $2}')"
    ldflags+=" -X main.syftVersion=$SYFT_VERSION"
    ldflags+=" -X main.gitCommit=$(cat COMMIT)"
    ldflags+=" -X main.buildDate=$(cat SOURCE_DATE_EPOCH)"
  '';

  preCheck = ''
    # test all dirs (except excluded)
    unset subPackages
    # test goldenfiles expect no version
    unset ldflags

    # patch utility script
    patchShebangs grype/db/test-fixtures/tls/generate-x509-cert-pair.sh

    # remove tests that depend on docker
    substituteInPlace test/cli/cmd_test.go \
      --replace-fail "TestCmd" "SkipCmd"
    substituteInPlace grype/pkg/provider_test.go \
      --replace-fail "TestSyftLocationExcludes" "SkipSyftLocationExcludes"
    substituteInPlace test/cli/cmd_test.go \
      --replace-fail "Test_descriptorNameAndVersionSet" "Skip_descriptorNameAndVersionSet"
    # remove tests that depend on git
    substituteInPlace test/cli/db_validations_test.go \
      --replace-fail "TestDBValidations" "SkipDBValidations"
    substituteInPlace test/cli/registry_auth_test.go \
      --replace-fail "TestRegistryAuth" "SkipRegistryAuth"
    substituteInPlace test/cli/sbom_input_test.go \
      --replace-fail "TestSBOMInput_FromStdin" "SkipSBOMInput_FromStdin" \
      --replace-fail "TestSBOMInput_AsArgument" "SkipSBOMInput_AsArgument"
    substituteInPlace test/cli/subprocess_test.go \
      --replace-fail "TestSubprocessStdin" "SkipSubprocessStdin"
    substituteInPlace grype/internal/packagemetadata/names_test.go \
      --replace-fail "TestAllNames" "SkipAllNames"
    substituteInPlace test/cli/version_cmd_test.go \
      --replace-fail "TestVersionCmdPrintsToStdout" "SkipVersionCmdPrintsToStdout"
    substituteInPlace grype/presenter/sarif/presenter_test.go \
      --replace-fail "Test_SarifIsValid" "SkipTest_SarifIsValid"

    # May fail on NixOS, probably due bug in how syft handles tmpfs.
    # See https://github.com/anchore/grype/issues/1822
    substituteInPlace grype/distro/distro_test.go \
      --replace-fail "Test_NewDistroFromRelease_Coverage" "SkipTest_NewDistroFromRelease_Coverage"

    # segfault
    rm grype/db/v5/namespace/cpe/namespace_test.go
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${pname} \
      --bash <($out/bin/${pname} completion bash) \
      --fish <($out/bin/${pname} completion fish) \
      --zsh  <($out/bin/${pname} completion zsh)
  '';

  doCheck = false;

  meta = with lib; {
    # keep-sorted start
    changelog = "https://github.com/anchore/grype/releases/tag/v${version}";
    description = "Vulnerability scanner for container images and filesystems";
    homepage = "https://github.com/anchore/grype";
    license = [ licenses.asl20 ];
    mainProgram = pname;
    platforms = platforms.linux;
    # keep-sorted end
  };
}
