#!/bin/bash

# Download ambidexter grammars

echo -e "\\n===> Fetching ambidexter grammars\\n"

wget -O /tmp/grammars.zip http://sites.google.com/site/basbasten/files/grammars.zip
[ -d $glang ] && rm -rf $glang
mkdir $glang
td=$(mktemp -d)
unzip -q -d $td /tmp/grammars.zip
rsync -auz $td/grammars/* $glang
