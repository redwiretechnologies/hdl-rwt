#!/bin/bash

subdircount=$(find "$PWD/oot" -maxdepth 1 -type d | wc -l)

if [[ "$subdircount" -eq 1 ]]
then
    echo "No OOT directories found"
else
    cp -anl "$PWD/oot/"**/* ./
fi
