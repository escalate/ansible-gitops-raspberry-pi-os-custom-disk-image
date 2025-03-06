#!/bin/bash
set -eo pipefail

ARCH="$1"

echo "Customize ${ARCH}-bit version of Raspberry Pi OS Lite disk image"

if [ "${ARCH}" = "32" ]; then
  DOWNLOAD_DIR="$(curl --silent 'https://downloads.raspberrypi.org/raspios_lite_armhf/images/?C=M;O=D' | grep --extended-regexp --only-matching 'raspios_lite_armhf-[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)"
  DOWNLOAD_ZIP_FILE="$(curl --silent "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/" | grep --extended-regexp --only-matching '[0-9]{4}-[0-9]{2}-[0-9]{2}-raspios-[a-z]+-armhf-lite\.zip' | head -n 1)"
  DOWNLOAD_FILENAME="${DOWNLOAD_ZIP_FILE%%.*}"

  echo "Download latest disk image archive"
  wget --no-verbose --no-clobber "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/${DOWNLOAD_ZIP_FILE}"

  echo "Verify downloaded disk image archive"
  wget --no-verbose --no-clobber "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/${DOWNLOAD_ZIP_FILE}.sha256"
  sha256sum --check "${DOWNLOAD_ZIP_FILE}.sha256"
fi

if [ "${ARCH}" = "64" ]; then
  DOWNLOAD_DIR="$(curl --silent 'https://downloads.raspberrypi.org/raspios_lite_arm64/images/?C=M;O=D' | grep --extended-regexp --only-matching 'raspios_lite_arm64-[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)"
  DOWNLOAD_ZIP_FILE="$(curl --silent "https://downloads.raspberrypi.org/raspios_lite_arm64/images/${DOWNLOAD_DIR}/" | grep --extended-regexp --only-matching '[0-9]{4}-[0-9]{2}-[0-9]{2}-raspios-[a-z]+-arm64-lite\.zip' | head -n 1)"
  DOWNLOAD_FILENAME="${DOWNLOAD_ZIP_FILE%%.*}"

  echo "Download latest disk image archive"
  wget --no-verbose --no-clobber "https://downloads.raspberrypi.org/raspios_lite_arm64/images/${DOWNLOAD_DIR}/${DOWNLOAD_ZIP_FILE}"

  echo "Verify downloaded disk image archive"
  wget --no-verbose --no-clobber "https://downloads.raspberrypi.org/raspios_lite_arm64/images/${DOWNLOAD_DIR}/${DOWNLOAD_ZIP_FILE}.sha256"
  sha256sum --check "${DOWNLOAD_ZIP_FILE}.sha256"
fi

echo "Unarchive zip file"
unzip -qo "${DOWNLOAD_ZIP_FILE}"

echo "Append 512MB to disk image"
dd if=/dev/zero bs=512M count=1 >>"${DOWNLOAD_FILENAME}.img"

echo "Set up loop devices"
LOOP_DEVICE="$(sudo losetup --find --show --partscan "${DOWNLOAD_FILENAME}.img")"

echo "Resize rootfs partition"
DISK_IMAGE_END="$(sudo parted --machine "${LOOP_DEVICE}" print free | tail -1 | cut -d ":" -f 3)"
sudo parted "${LOOP_DEVICE}" resizepart 2 "${DISK_IMAGE_END}"

echo "Grow filesystem of rootfs partition"
sudo e2fsck -f "${LOOP_DEVICE}p2"
sudo resize2fs "${LOOP_DEVICE}p2"

echo "Mount loop devices"
mkdir --parents boot
sudo mount "${LOOP_DEVICE}p1" boot
mkdir --parents rootfs
sudo mount "${LOOP_DEVICE}p2" rootfs

echo "Customize disk image"
./customize.sh "${DOWNLOAD_ZIP_FILE}"

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

echo "Show customized disk image"
ls -lh ./*.img
