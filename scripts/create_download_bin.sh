#!/bin/bash

# SPDX-License-Identifier: Apache-2.0

if [ "$#" -ne 1 ]; then
    echo "Missing XSA file"
    echo "usage: create_download_bin.sh <xsa>"
    exit 1
fi

set -e

bitfile=$(unzip -l $1 | awk '{print $NF}' | grep ".bit$")
unzip -o $1 ${bitfile} -d /tmp/
mv /tmp/${bitfile} /tmp/download.bit

cat > /tmp/bootgen.bif <<EOL
all:
{
  [destination_device = pl] download.bit
}
EOL


(cd /tmp && bootgen -image bootgen.bif -arch zynqmp -w -o download.bin)

rm /tmp/bootgen.bif
rm /tmp/download.bit
mv /tmp/download.bin .
