#!/bin/bash

# SPDX-License-Identifier: Apache-2.0

if [[ $# -lt 2 ]]; then
    echo "Usage: create_pmufw.sh [path to xsa] [name of zipped pmufw]"
    exit 1
fi

xsa_path=$1
pmufw_zip=$2
tmp_dir=$(mktemp -d -t XXXXXXXXXX)

cp $xsa_path $tmp_dir/system.xsa

xsct scripts/create_pmufw.tcl $tmp_dir/system.xsa

zip -r $pmufw_zip my_pmufw
rm -rf my_pmufw
rm -rf $tmp_dir
