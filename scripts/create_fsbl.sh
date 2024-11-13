#!/bin/bash

# SPDX-License-Identifier: Apache-2.0

if [[ $# -lt 2 ]]; then
    echo "Usage: create_fsbl.sh [path to xsa] [name of zipped fsbl]"
    exit 1
fi

xsa_path=$1
fsbl_zip=$2
tmp_dir=$(mktemp -d -t XXXXXXXXXX)

cp $xsa_path $tmp_dir/system.xsa

xsct scripts/create_fsbl.tcl $tmp_dir/system.xsa

zip -r $fsbl_zip my_fsbl
rm -rf my_fsbl
rm -rf $tmp_dir
