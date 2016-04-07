#!/bin/bash

set -e

# Init

FILES=("libccl_curl_drl.so" "libcrypto.so.1.0.0" "libcurl.so.4" "libssl.so.1.0.0" "libstdc++.so" "libstdc++.so.6")

QUARTUS_DIR="/opt/altera_lite/15.1/quartus"

PACKAGES="gtk2-engines-pixbuf"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

echo "Installing additional packages ..."
apt-get update && apt-get install --reinstall -f -y ${PACKAGES}

echo "Installation successful !!"

if [[ -e ${QUARTUS_DIR} ]]; then
  echo "Renaming files that cause problems..."
  for FILE in "${FILES[@]}"; do
   if [[ -e ${QUARTUS_DIR}/linux64/${FILE} ]]; then
     mv -v ${QUARTUS_DIR}/linux64/${FILE} ${QUARTUS_DIR}/linux64/${FILE}.bak
   fi
  done
  echo "Renaming successful !!"
fi

exit 0

