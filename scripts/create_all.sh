#!/bin/bash

# SPDX-License-Identifier: Apache-2.0

if [[ $# -lt 1 ]]; then
    echo "Usage: create_all.sh [build_directory]"
    exit 1
fi

for f in $(find $1 -name *.xsa | grep "/default/")
do
    xsa_file=$f
    xsa_path=$(dirname -- "$xsa_file")
    echo "Operating on $xsa_file"
    ./scripts/create_dts.sh   "$xsa_file" "$xsa_path"/dts.zip
    ./scripts/create_fsbl.sh  "$xsa_file" "$xsa_path"/fsbl.zip
    ./scripts/create_pmufw.sh "$xsa_file" "$xsa_path"/pmufw.zip
done
