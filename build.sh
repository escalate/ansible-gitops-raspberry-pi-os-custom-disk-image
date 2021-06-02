#!/bin/bash
set -eo pipefail

DOWNLOAD_DIR="$(curl --silent 'https://downloads.raspberrypi.org/raspios_lite_armhf/images/?C=M;O=D' | grep --extended-regexp --only-matching 'raspios_lite_armhf-[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)"
DOWNLOAD_ZIP_FILE="$(curl --silent "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/" | grep --extended-regexp --only-matching '[0-9]{4}-[0-9]{2}-[0-9]{2}-raspios-buster-armhf-lite\.zip' | head -n 1)"
DOWNLOAD_FILENAME="${DOWNLOAD_ZIP_FILE%%.*}"

echo "Download latest image archive"
wget --no-verbose --no-clobber "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/${DOWNLOAD_ZIP_FILE}"

echo "Verify downloaded image archive"
wget --no-verbose --no-clobber "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/${DOWNLOAD_ZIP_FILE}.sha256"
sha256sum --check "${DOWNLOAD_ZIP_FILE}.sha256"

echo "Unarchive zip file"
unzip -qo "${DOWNLOAD_ZIP_FILE}"

echo "Set up loop devices"
LOOP_DEVICE="$(sudo losetup --find --show --partscan "${DOWNLOAD_FILENAME}.img")"

echo "Mount loop devices"
mkdir --parents boot
sudo mount "${LOOP_DEVICE}p1" boot
mkdir --parents rootfs
sudo mount "${LOOP_DEVICE}p2" rootfs

echo "Customize image"
./customize.sh

echo "Flush write cache"
sync

echo "Umount loop devices"
# Wait 5 secs to get rid of "target is busy" error
sleep 5
sudo umount boot
rm --recursive --force boot
sudo umount rootfs
rm --recursive --force rootfs

echo "Detach loop devices"
sudo losetup --detach-all

if [ -n "${GITHUB_ACTIONS}" ]; then
  echo "Compress custom image"
  tar --create --bzip2 --file "${DOWNLOAD_FILENAME}-custom.tar.bz2" "${DOWNLOAD_FILENAME}.img"

  echo "Hash custom image archive"
  sha256sum "${DOWNLOAD_FILENAME}-custom.tar.bz2" > "${DOWNLOAD_FILENAME}-custom.tar.bz2.sha256"
fi

echo "Show final artifacts"
ls -lh ./*.img
if [ -n "${GITHUB_ACTIONS}" ]; then
  ls -lh ./*-custom.tar.bz2*
fi
