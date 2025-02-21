{
  lib,
  fetchPypi,
  python3Packages,
}:
let
  pname = "lastversion";
  version = "3.5.7";
  sha256 = "sha256-H3cYFVLaoPNcxvgFSUbLgDG2q9vxicHvP5qeEL0Hrak=";
in
python3Packages.buildPythonApplication {
  inherit pname version;

  src = fetchPypi {
    inherit pname version sha256;
  };

  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    requests
    packaging
    cachecontrol
    cachecontrol.passthru.optional-dependencies.filecache
    appdirs
    feedparser
    python-dateutil
    pyyaml
    tqdm
    beautifulsoup4
    distro
    urllib3
  ];

  meta = with lib; {
    description = "Find the latest release version of an arbitrary project";
    license = [ licenses.bsd2 ];
    homepage = "https://github.com/dvershinin/lastversion";
    changelog = "https://github.com/dvershinin/lastversion/releases/tag/v${version}";
    platforms = platforms.linux;
  };
}
