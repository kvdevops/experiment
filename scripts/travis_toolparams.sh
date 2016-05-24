#!/bin/bash

. $cwd/env.sh

export scriptsdir="$cwd/scripts"
export gset="test"
export grammardir="$cwd/grammars"
export lexdir="$grammardir/lex"

export testgrammars="amb2"
export memlimit="512m"
export resultsdir="$cwd/results"

export glang="$grammardir/lang"
export lgrammars="Pascal"
export nlang="1"

export accentdir="$wrkdir/accent"
export ACCENT_DIR=$accentdir

print_summary() {
    summary="Ambiguous count=$1 [of $2]"
    echo -e "\nSummary: $summary \n--"
}

acc_to_cfg(){
    gacc="$1"
    gcfg="$2"
    cat $gacc | egrep -v "^\s*;|^%nodefault|^%token " | sed -e 's/;$//g' -e "s/'/\"/g" > $gcfg
    tokenlist=$(grep '%token' $gacc | sed -e 's/%token //' | tr -d ';,')
    for token in $tokenlist
    do
       sed -i -e "s/\b${token}\b/\"${token}\"/g" -e "s/'/\"/g" $gcfg
    done    
}

acc_to_yacc(){
    gacc="$1"
    gy="$2"
    cat $gacc | grep  "%token" | sed -e 's/,//g' -e 's/;$//' > $gy
    echo "" >> $gy
    cat $gacc | grep -v '%token' | sed -e 's/%nodefault/\n%%/' >> $gy
}
