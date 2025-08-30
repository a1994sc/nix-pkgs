{
  # keep-sorted start
  asciiBuildGoModule,
  fetchFromGitHub,
  lib,
  # keep-sorted end
  ...
}:
let
  pname = "helm-dt";
  version = "0.4.6";
  sha256 = "sha256-SB1XjWB2vYUUT9EvUCZM0dt4Q9J38lh6x6RQWjZCQXU=";
  vendorHash = "sha256-aGFWyDq0HUlOF85VBRD7KN8/qm4iPsXau8W636h6meo=";
  rev = "v" + version;
in
asciiBuildGoModule rec {
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
