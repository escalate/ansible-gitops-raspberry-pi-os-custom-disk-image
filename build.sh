#!/bin/bash
set -eo pipefail

DOWNLOAD_DIR="$(curl --silent 'https://downloads.raspberrypi.org/raspios_lite_armhf/images/?C=M;O=D' | grep --extended-regexp --only-matching 'raspios_lite_armhf-[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)"
DOWNLOAD_ZIP_FILE="$(curl --silent https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/ | grep --extended-regexp --only-matching '[0-9]{4}-[0-9]{2}-[0-9]{2}-raspios-buster-armhf-lite\.zip' | head -n 1)"
DOWNLOAD_FILENAME="${DOWNLOAD_ZIP_FILE%%.*}"

echo "Download latest image archive and checksum"
wget --no-verbose "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/${DOWNLOAD_ZIP_FILE}"
wget --no-verbose "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/${DOWNLOAD_ZIP_FILE}.sha256"

echo "Verify downloaded image archive"
sha256sum --check ${DOWNLOAD_ZIP_FILE}.sha256

echo "Unarchive zip file"
unzip -q ${DOWNLOAD_ZIP_FILE}

echo "Set up loop devices"
LOOP_DEVICE="$(sudo losetup --find --show --partscan ${DOWNLOAD_FILENAME}.img)"

echo "Mount loop devices"
mkdir boot
sudo mount "${LOOP_DEVICE}p1" boot
mkdir rootfs
sudo mount "${LOOP_DEVICE}p2" rootfs

echo "Customize image"
./customize.sh

echo "Flush write cache"
sync

echo "Umount loop devices"
sudo umount boot
sudo umount rootfs

echo "Detach loop devices"
sudo losetup --detach-all

echo "Compress custom image"
tar --create --bzip2 --file "${DOWNLOAD_FILENAME}-custom.tar.bz2" "${DOWNLOAD_FILENAME}.img"

echo "Hash custom image archive"
sha256sum "${DOWNLOAD_FILENAME}-custom.tar.bz2" > "${DOWNLOAD_FILENAME}-custom.tar.bz2.sha256"

echo "Show final artifacts"
ls -l *-custom.tar.bz2*
