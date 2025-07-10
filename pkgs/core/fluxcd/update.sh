#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=github:NixOS/nixpkgs/nixos-unstable-small -i bash -p curl jq common-updater-scripts

set -x -eu -o pipefail

NIXPKGS_PATH="$(git rev-parse --show-toplevel)"
LATEST_VERSION=$(curl ${GITHUB_TOKEN:+" -u \":$GITHUB_TOKEN\""} --fail -sSL https://api.github.com/repos/fluxcd/flux2/releases/latest | jq -r '.tag_name | sub("^v"; "")')


update_version_and_hashes() {
  local version=$1

  SRC_SHA256=$(nix-prefetch-url --quiet --unpack "https://github.com/fluxcd/flux2/archive/refs/tags/v${version}.tar.gz")
  SRC_HASH=$(nix hash convert --hash-algo sha256 --to sri "$SRC_SHA256")
  MANIFESTS_SHA256=$(nix-prefetch-url --quiet --unpack "https://github.com/fluxcd/flux2/releases/download/v${version}/manifests.tar.gz")
  MANIFESTS_HASH=$(nix hash convert --hash-algo sha256 --to sri "$MANIFESTS_SHA256")

  setKV () {
      sed -i "s|$1 = \".*\"|$1 = \"${2:-}\"|" "package.nix"
  }

  setKV version "${LATEST_VERSION}"
  setKV sha256 "${SRC_HASH}"
  setKV manifestsSha256 "${MANIFESTS_HASH}"
  setKV vendorHash "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" # The same as lib.fakeHash

  set +e
  VENDOR_SHA256=$(nix build --no-link $NIXPKGS_PATH#fluxcd 2>&1 >/dev/null | grep "got:" | cut -d':' -f2 | sed 's| ||g')
  VENDOR_HASH=$(nix hash convert --hash-algo sha256 --to sri "$VENDOR_SHA256")
  set -e

  if [ -n "${VENDOR_HASH:-}" ]; then
      setKV vendorHash "${VENDOR_HASH}"
  else
      echo "Update failed. VENDOR_HASH is empty."
      exit 1
  fi
}

update_version_and_hashes $LATEST_VERSION
