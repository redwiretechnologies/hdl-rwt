#!/bin/bash

git_print () {
    git fetch > /dev/null
    a=$(git status --porcelain)
    c=$(git rev-parse HEAD)
    s=$(git show --no-notes --no-patch --format=medium $c | grep -Ev Author)
    echo "------------------------------------------------------------------------------------------" >> $2
    echo "$1" | sed 's/\///g' >> $2
    echo "" >> $2
    echo "$s" | sed 's/^/  /g' >> $2
    echo "" >> $2
    if [ ! -z "$a" ]
    then
        tmpfile=$(mktemp /tmp/git-script.XXXXXX)
        echo "" >> $tmpfile
        echo "" >> $tmpfile
        echo "Current Modifications" >> $tmpfile
        echo "$a" | sed 's/^/  /g' >> $tmpfile
        echo "$1 - $c" | sed 's/\///g' >> $tmpfile
        ${VISUAL:-${EDITOR:-vi}} $tmpfile 1>&2
        a=$(head -n -1 $tmpfile)
        echo "$a" | sed 's/^/    /g' >> $2
        echo "" >> $2
        rm $tmpfile
    fi
    echo "------------------------------------------------------------------------------------------" >> $2
}

d=$(date)
echo "Build date: $d" > git_log.txt
echo "" >> git_log.txt
echo "------------------------------------------------------------------------------------------" >> git_log.txt
./scripts/unlink_oot.sh
git_print $(basename "$PWD") git_log.txt
builtin cd oot
for f in $(ls)
do
    builtin cd $f
    git_print $f ../../git_log.txt
    builtin cd ..
done
builtin cd ..
echo "------------------------------------------------------------------------------------------" >> git_log.txt
./scripts/link_oot.sh
