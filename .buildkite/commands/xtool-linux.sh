#!/usr/bin/env bash

set -euo pipefail

XTOOL_VERSION=1.24.0

arch=$(uname -m)
case "$arch" in
  x86_64) sha256=dbfd9d7216f077c84c171b688c4173c37c23ca76bf7fd185d1a9ae8a53dab59f ;;
  aarch64) sha256=4bc0515fed71efb86e82564f358efa0c4c6d76bf1bcfd4c5f256727b53ec59c8 ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    exit 1
    ;;
esac

install_dir=$(mktemp -d)
appimage="$install_dir/xtool.AppImage"

echo "--- :arrow_down: Install xtool $XTOOL_VERSION"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends ca-certificates curl >/dev/null
curl -fsSL \
  "https://github.com/xtool-org/xtool/releases/download/$XTOOL_VERSION/xtool-$arch.AppImage" \
  -o "$appimage"
echo "$sha256  $appimage" | sha256sum --check
chmod +x "$appimage"

# Containers have no FUSE to mount the AppImage with.
export APPIMAGE_EXTRACT_AND_RUN=1

mkdir -p "$install_dir/bin"
ln -s "$appimage" "$install_dir/bin/xtool"
export PATH="$install_dir/bin:$PATH"

swift --version
xtool --version

echo "--- :swift: SDK status"
xtool sdk status

echo "--- :hammer: Build the demo"
cleanup() {
  rm -rf Demo/.build Demo/xtool Demo/.bsp
}
trap cleanup EXIT

cd Demo
# xtool polls stdin with epoll, which rejects /dev/null, so close it through a pipe.
true | xtool dev build
find xtool -maxdepth 2
