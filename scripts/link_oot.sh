#!/bin/bash

subdircount=$(find "$PWD/oot" -maxdepth 1 -type d | wc -l)
files=$(find "$PWD/oot" -maxdepth 2 -mindepth 2 -type d | grep -Ev utilization | grep -Ev ".git")

if [[ "$subdircount" -eq 1 ]]
then
    echo "No OOT directories found"
else
    for f in $files; do
        cp -anl "$f" ./
    done
fi
