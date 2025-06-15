{
  # keep-sorted start
  buildGoModule,
  fetchFromGitHub,
  lib,
  # keep-sorted end
  ...
}:
let
  # keep-sorted start prefix_order=pname,version,
  pname = "helm-values-schema-json";
  version = "2.0.0";
  sha256 = "sha256-rF9w5PRL9d2X+/TlrfbIUmYghW0Xgu84mhi94T4J90k=";
  vendorHash = "sha256-JXg1ngqTOi2/f+1JuPTGA0lNPiYAsw8loKZ+CFv4sBM=";
  # keep-sorted end
  rev = "v" + version;
in
buildGoModule rec {
  inherit version pname vendorHash;

  src = fetchFromGitHub {
    inherit rev sha256;
    owner = "losisin";
    repo = pname;
  };

  # NOTE: Remove the install and upgrade hooks.
  postPatch = ''
    sed -i '/^hooks:/,+2 d' plugin.yaml
  '';

  doCheck = false;

  ldflags = [ "-X 'main.GitCommit=v${version}'" ];

  buildPhase =
    let
      args = builtins.concatStringsSep " " ldflags;
    in
    ''
      go build -o schema -buildvcs=false -ldflags "${args}"
    '';

  installPhase = ''
    install -dm755 $out/helm-values-schema-json
    mv schema $out/helm-values-schema-json/schema
    install -m644 -Dt $out/helm-values-schema-json plugin.yaml
  '';

  env.CGO_ENABLED = 0;

  meta = with lib; {
    # keep-sorted start
    description = "Helm plugin for generating values.schema.json from multiple values files ";
    homepage = "https://github.com/losisin/helm-values-schema-json";
    license = [ licenses.mit ];
    # keep-sorted end
  };
}
