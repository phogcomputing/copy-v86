#!/usr/bin/env bash
set -veu

OUT_ROOTFS_TAR=$(dirname "$0")/../vendor/github.com/copy/v86/images/debian-9p-rootfs.tar
OUT_ROOTFS_FLAT=$(dirname "$0")/../vendor/github.com/copy/v86/images/debian-9p-rootfs-flat
OUT_FSJSON=$(dirname "$0")/../vendor/github.com/copy/v86/images/debian-base-fs.json
CONTAINER_NAME=phog-computer-debian
IMAGE_NAME=i386/phog-computer-debian

if [ "$1" = "" ]; then
  #docker build . --rm --tag "$IMAGE_NAME"
  DOCKER_BUILDKIT=0 docker build --platform linux/i386 --progress=plain . --tag "$IMAGE_NAME"
  docker rm "$CONTAINER_NAME" || true
  docker create -t -i --name "$CONTAINER_NAME" "$IMAGE_NAME" bash
else
 CONTAINER_NAME="$1"
fi
set -x
docker export "$CONTAINER_NAME" > "$OUT_ROOTFS_TAR"

$(dirname "$0")/../vendor/github.com/copy/v86/tools/fs2json.py --out "$OUT_FSJSON" "$OUT_ROOTFS_TAR"

# Note: Not deleting old files here
mkdir -p "$OUT_ROOTFS_FLAT"
$(dirname "$0")/../vendor/github.com/copy/v86/tools/copy-to-sha256.py "$OUT_ROOTFS_TAR" "$OUT_ROOTFS_FLAT"

echo "$OUT_ROOTFS_TAR", "$OUT_ROOTFS_FLAT" and "$OUT_FSJSON" created.
