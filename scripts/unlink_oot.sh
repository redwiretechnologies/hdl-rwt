#!/bin/bash

files=$(find oot/ -name .git -type d -prune -o -name utilization -type d -prune -o -type f -print)
other_files=$(find . -xdev \( -path ./oot -o -name build -type d -o -name .git -type d -o -name *pycache* -type d -o -name utilization -type d \) -prune -o -type f -print)

for f in $files; do
    for nf in $other_files; do
        if [[ "$f" -ef "$nf" ]]; then
            rm -f "$nf"
        fi
    done
done

find . -type d -empty -delete
