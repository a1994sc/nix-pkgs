{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  lib,
  # keep-sorted end
  ...
}:
let
  pname = "helm-dt";
  version = "0.4.5";
  sha256 = "sha256-/TRhi4YgEB5RwRZXuwGCCqHz3SoBfs1SdKLBWg1yed0=";
  vendorHash = "sha256-54QB8dZSqSpDb4z7di5K6d8/fFbXftKfQJAljV50/Jk=";
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "vmware-labs";
    repo = "distribution-tooling-for-helm";
  };

  ldflags = [
    "-s"
    "-w"
    "-X 'main.BuildDate=1970-01-01 00:00:00 UTC'"
    "-X 'main.Commit=v${version}'"
  ];

  # NOTE: Remove the install and upgrade hooks.
  postPatch = ''
    sed -i '/^hooks:/,+2 d' plugin.yaml
  '';

  doCheck = false;
  env.CGO_ENABLED = 1;

  postInstall = ''
    install -dm755 $out/helm-dt/bin
    mv $out/bin/dt $out/helm-dt/bin/dt
    rmdir $out/bin
    install -m644 -Dt $out/helm-dt plugin.yaml
  '';

  meta = with lib; {
    # keep-sorted start
    description = "Helm Distribution plugin is is a set of utilities and Helm Plugin for making offline work with Helm Charts easier.";
    homepage = "https://github.com/vmware-labs/distribution-tooling-for-helm";
    license = [ licenses.mit ];
    # keep-sorted end
  };
}
