#!/bin/bash

# Download ambidexter grammars

echo -e "\\n===> Fetching ambidexter grammars\\n"

lang_dir="$grammardir/lang"
wget -O /tmp/grammars.zip http://sites.google.com/site/basbasten/files/grammars.zip
[ -d $lang_dir ] && rm -rf $lang_dir
unzip -q -d $lang_dir grammars.zip
