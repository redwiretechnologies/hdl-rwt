#!/bin/bash

if [[ $# -lt 3 ]]; then
    echo "Usage: git_log_pers.sh [file to write] [project name] [repo list]"
    exit 1
fi

if [ ! -f git_log_compressed.txt ]; then
    ./scripts/create_git_log.sh
fi


tmpfile=$(mktemp /tmp/git-script.XXXXXX)

all_args=("$@")
fw=$1
pn=$2
rs=("${all_args[@]:2}")

echo -n "$pn|" > $tmpfile
head -n1 git_log_compressed.txt >> $tmpfile
for val in ${rs[@]}; do
    grep "~$val|" git_log_compressed.txt >> $tmpfile
done

tr -d '\n' < $tmpfile > $fw

truncate -s 4K $fw

echo "memory_initialization_radix=16;" > $fw.coe
echo "memory_initialization_vector=" >> $fw.coe
xxd -p -c 4 $fw | sed 's/$/,/g' | sed '$s/,/;/' >> $fw.coe

rm -f $tmpfile
