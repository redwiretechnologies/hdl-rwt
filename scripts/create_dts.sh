#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: create_dts.sh [path to xsa] [name of zipped dts]"
    exit 1
fi

xsa_path=$1
dts_zip=$2
tmp_dir=$(mktemp -d -t XXXXXXXXXX)

cp $xsa_path $tmp_dir/system.xsa

xsct scripts/create_dts.tcl $tmp_dir/system.xsa

zip -r $dts_zip my_dts
rm -rf my_dts
rm -rf $tmp_dir
