#!/bin/bash

bdir=$(dirname $0)
. $bdir/env.sh

gset="test"
grammardir="$cwd/grammars"
lexdir="$grammardir/lex"
export gset grammardir lexdir

testgrammars="amb2"
export testgrammars

memlimit="512m"
timelimits="10"
cores_per_host="1"
export memlimit timelimits cores_per_host


### SETTING VALUES FOR EACH TOOL ###

#ACLA

#Amber
amber_n_examples="10000000000"
amber_n_length="30"
export amber_n_examples amber_n_length

#AmbiDexter
ambidexter_n_length="10"
export ambidexter_n_length 

#SinBAD
backends="dynamic1 dynamic3"
wgtbackends="dynamic4 dynamic7 dynamic11 dynamic12"
weights="0.1"
Tdepths="10"
export backends wgtbackends weights Tdepths 

resultsdir="$cwd/results"
ppresults="$cwd/ppresults.txt"
export resultsdir ppresults

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
