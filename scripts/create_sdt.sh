#!/bin/bash

# SPDX-License-Identifier: Apache-2.0

if [[ $# -lt 2 ]]; then
    echo "Usage: create_sdt.sh [path to xsa] [name of zipped sdt]"
    exit 1
fi

xsa_path=$1
sdt_zip=$2
tmp_dir=$(mktemp -d -t XXXXXXXXXX)

cp $xsa_path $tmp_dir/system.xsa

sdtgen -xsa $tmp_dir/system.xsa -dir sdt_dir

zip -r $sdt_zip sdt_dir
rm -rf sdt_dir
rm -rf $tmp_dir
