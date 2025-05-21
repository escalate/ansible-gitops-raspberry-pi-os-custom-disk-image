#!/bin/bash
set -eo pipefail

ARCH="$1"

echo "Customize ${ARCH}-bit version of Raspberry Pi OS Lite disk image"

echo "Create working directory"
mkdir --parent "workspace/${ARCH}"

if [ "${ARCH}" = "32" ]; then
  DOWNLOAD_DIR="$(curl --silent 'https://downloads.raspberrypi.org/raspios_lite_armhf/images/?C=M;O=D' | grep --extended-regexp --only-matching 'raspios_lite_armhf-[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)"
  DOWNLOAD_IMAGE_ARCHIVE="$(curl --silent "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/" | grep --extended-regexp --only-matching '[0-9]{4}-[0-9]{2}-[0-9]{2}-raspios-[a-z]+-armhf-lite\.img\.xz' | head -n 1)"
  DOWNLOAD_FILENAME="${DOWNLOAD_IMAGE_ARCHIVE%%.*}"

  echo "Download latest disk image archive"
  wget \
    --no-verbose \
    --show-progress \
    --no-clobber \
    --directory-prefix "workspace/${ARCH}" \
    "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/${DOWNLOAD_IMAGE_ARCHIVE}"

  echo "Verify downloaded disk image archive"
  wget \
    --no-verbose \
    --show-progress \
    --no-clobber \
    --directory-prefix "workspace/${ARCH}" \
    "https://downloads.raspberrypi.org/raspios_lite_armhf/images/${DOWNLOAD_DIR}/${DOWNLOAD_IMAGE_ARCHIVE}.sha256"

  echo "EDITBASE_ARCH=armv7l" >"workspace/${ARCH}/config.local"
fi

if [ "${ARCH}" = "64" ]; then
  DOWNLOAD_DIR="$(curl --silent 'https://downloads.raspberrypi.org/raspios_lite_arm64/images/?C=M;O=D' | grep --extended-regexp --only-matching 'raspios_lite_arm64-[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -n 1)"
  DOWNLOAD_IMAGE_ARCHIVE="$(curl --silent "https://downloads.raspberrypi.org/raspios_lite_arm64/images/${DOWNLOAD_DIR}/" | grep --extended-regexp --only-matching '[0-9]{4}-[0-9]{2}-[0-9]{2}-raspios-[a-z]+-arm64-lite\.img\.xz' | head -n 1)"
  DOWNLOAD_FILENAME="${DOWNLOAD_IMAGE_ARCHIVE%%.*}"

  echo "Download latest disk image archive"
  wget \
    --no-verbose \
    --show-progress \
    --no-clobber \
    --directory-prefix "workspace/${ARCH}" \
    "https://downloads.raspberrypi.org/raspios_lite_arm64/images/${DOWNLOAD_DIR}/${DOWNLOAD_IMAGE_ARCHIVE}"

  echo "Verify downloaded disk image archive"
  wget \
    --no-verbose \
    --show-progress \
    --no-clobber \
    --directory-prefix "workspace/${ARCH}" \
    "https://downloads.raspberrypi.org/raspios_lite_arm64/images/${DOWNLOAD_DIR}/${DOWNLOAD_IMAGE_ARCHIVE}.sha256"

  echo "EDITBASE_ARCH=aarch64" >"workspace/${ARCH}/config.local"
fi

sed -i "s/ ${DOWNLOAD_IMAGE_ARCHIVE}/ workspace\/${ARCH}\/${DOWNLOAD_IMAGE_ARCHIVE}/" "workspace/${ARCH}/${DOWNLOAD_IMAGE_ARCHIVE}.sha256"
sha256sum --check "workspace/${ARCH}/${DOWNLOAD_IMAGE_ARCHIVE}.sha256"

echo "Unarchive disk image archive"
xz --decompress --keep "workspace/${ARCH}/${DOWNLOAD_IMAGE_ARCHIVE}"
mv "workspace/${ARCH}/${DOWNLOAD_FILENAME}.img" "workspace/${ARCH}/input.img"

echo "Copy customization scripts and files"
rm --recursive --force "workspace/${ARCH}/scripts/"
cp --recursive "scripts/" "workspace/${ARCH}/"
cp "workspace/${ARCH}/${DOWNLOAD_IMAGE_ARCHIVE}" "workspace/${ARCH}/scripts/files/"
cp "workspace/${ARCH}/${DOWNLOAD_IMAGE_ARCHIVE}.sha256" "workspace/${ARCH}/scripts/files/"

echo "Define customization environment variables"
{
  echo "DOWNLOAD_IMAGE_ARCHIVE=${DOWNLOAD_IMAGE_ARCHIVE}"
  echo "ANSIBLE_HOSTNAME=${ANSIBLE_HOSTNAME}"
  echo "ANSIBLE_REPOSITORY_URL=${ANSIBLE_REPOSITORY_URL}"
  echo "ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD}"
} >"workspace/${ARCH}/gitops-config.env"

echo "Build CustoPiZer Docker image"
if [ ! -d "CustoPiZer" ]; then
  git clone https://github.com/OctoPrint/CustoPiZer.git
fi

docker build \
  --tag custopizer:local \
  CustoPiZer/src/

echo "Customize disk image with CustoPiZer"
{
  echo "EDITBASE_DISTRO=raspbian"
  echo "EDITBASE_IMAGE_ENLARGEROOT=1024"
} >>"workspace/${ARCH}/config.local"

docker run \
  --rm \
  --privileged \
  --env-file "workspace/${ARCH}/gitops-config.env" \
  --mount "type=bind,source=./workspace/${ARCH},destination=/CustoPiZer/workspace" \
  --mount "type=bind,source=./workspace/${ARCH}/config.local,destination=/CustoPiZer/config.local" \
  custopizer:local

echo "Show customized disk image"
ls -lh "./workspace/${ARCH}/output.img"
