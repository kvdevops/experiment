#!/bin/bash

filter=""
length=""
inclength=""
log=""

set -- $(getopt t:g:f:k:l:i: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) g=$2 ; shift;;
     -t) timelimit=$2 ; shift;;
     -f) filter=$2 ; shift;;
     -k) length=$2 ; shift;;
     -l) log=$2 ; shift;;
     -i) inclength=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

options=""

[ "$length" != "" ] && options="$options -k $length"
[ "$inclength" != "" ] && options="$options -ik $inclength"

if [ -z "$filter" ]
then
    $ambdxtcmd -q -pg $options $g > $log 2>&1 || exit $?
else
    sfilter=$(date +%s%N | cut -b1-13)
    $ambdxtcmd -h -$filter -oy $g > $log 2>&1 || exit $?
    efilter=$(date +%s%N | cut -b1-13)
    echo "filter time (millisecs): $(($efilter-$sfilter))" >> $log
    exportstr="Exporting grammar to"
    exported=$(cat $log | grep "$exportstr" | sed -e "s/${exportstr} //")
    if [ "$exported" != "" ]
    then
        $ambdxtcmd -q -pg $options $exported >> $log 2>&1 || exit $?
    fi
fi

