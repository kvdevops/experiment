#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

echo "$(hostname)::($basename $0) $cwd $wrkdir"

gset=""
timelimit=""
filter=""
length=""
inclength=""

print_filter_summary() {
    logdir="$1"
    tot=0.0
    cnt=0
    fltcnt=0
    unambcnt=0
    totflttime=0
    for log in $(ls $logdir/*.log.gz)
    do
        flttime=$(zgrep "^filter time" $log | cut -d: -f2)
        if [ ! -z "$flttime" ]
        then
            totflttime=$(echo $totflttime+$flttime | bc)
            ((fltcnt+=1))
            ratio=$(zgrep "^Harmless productions" $log | cut -d: -f2)
            if [ ! -z "$ratio" ]
            then 
                hfrac=$(echo $ratio | bc -l)
                tot=$(echo $tot+$hfrac | bc -l)
                unamb=$(echo $ratio | bc)
                [ $unamb == 1 ] && ((unambcnt+=1))
            fi
        fi
        cnt=$((cnt+1))
    done
    avgratio="n/a"
    avgflttime="n/a"
    if [ $fltcnt != 0 ]; then
        avgratio=$(echo "scale=4;($tot/$fltcnt)*100" | bc -l)
        avgflttime=$(echo "scale=4;$totflttime/$fltcnt" | bc -l)
    fi
    summary="no of filtered grammars=$fltcnt [of $cnt]\
    \navg harmless [%]=${avgratio}\
    \nno of unambiguous grammars=$unambcnt [of $cnt]\
    \navg filter time [millisecs]=$avgflttime"
    echo -e "$summary \n--"
}

run_randomcfg() {
    rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0    
    for randomsize in $randomcfgsizes
    do
        for g in $(seq 1 $nrandom)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${randomsize}_${g}.log"
            gacc="$grandom/$randomsize/$g.acc"
            gy="$tmp/$g.y"
            cnt=$((cnt+1))
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "$randomsize/$g,yes" | tee -a $gsetlog
                ambcnt=$((ambcnt+1))
                rm -Rf $tmp
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "$randomsize/$g," | tee -a $gsetlog
                rm -Rf $tmp
                continue
            fi
            out="$randomsize/$g,"
            timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="$randomsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
    print_filter_summary $rsltdir >> $rsltdir/summary
}

run_lang() {
    rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${g}_${i}.log"
            gacc="$glang/acc/$g.$i.acc"
            gy="$tmp/$g.$i.y"
            cnt=$((cnt+1))
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "$g.$i,yes" | tee -a $gsetlog
                ambcnt=$((ambcnt+1))
                rm -Rf $tmp
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "$g.$i," | tee -a $gsetlog
                rm -Rf $tmp
                continue
            fi
            out="$g.$i,"
            timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="$g.$i,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
    print_filter_summary $rsltdir >> $rsltdir/summary
}


run_mutlang() {
    clog="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/log"
    mkdir -p $resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')
    > $clog
    for type in $mutypes
    do
       for g in $mugrammars
       do
           rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
           mkdir -p $rsltdir
           echo "result ==> $rsltdir"
           gsetlog="$rsltdir/log"
           cp /dev/null $gsetlog
           cnt=0
           ambcnt=0
           glist=$(find $gmutlang/acc/$type/$g -name "*.acc" | cut -d_ -f2 | sort -h | cut -d. -f1 | head -${nmutations})
           for n in $glist
           do
               tmp=$(mktemp -d)
               glog="$rsltdir/${g}.0_${n}.log"
               gacc="$gmutlang/acc/$type/$g/$g.0_$n.acc"
               gy="$tmp/$g.0_$n.y"
               cnt=$((cnt+1))
               acc_to_yacc $gacc $gy
               $ambdxtcmd -s $gy > $glog 2>&1
               msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
               if [ "$msg" != "" ]
               then
                   echo "$g.0_$n,yes" | tee -a $gsetlog
                   ambcnt=$((ambcnt+1))
                   rm -Rf $tmp
                   continue
               fi
               msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
               if [ "$msg" != "" ]
               then
                   echo "$g.0_$n," | tee -a $gsetlog
                   rm -Rf $tmp
                   continue
               fi
               out="$g.0_$n,"
               timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
               amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
               if [ "$amb" != "" ]
               then
                   ambcnt=$((ambcnt+1))
                   out="$g.0_$n,yes"
               fi
               echo $out | tee -a $gsetlog
               [ -f $glog ] && gzip -f $glog
               rm -Rf $tmp
           done
           cat $gsetlog | sed -e "s/^/${type}\//" >> $clog
           print_summary $ambcnt $cnt > $rsltdir/summary
           print_filter_summary $rsltdir >> $rsltdir/summary
       done
    done
}

run_boltzcfg() {
    rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0
    for boltzsize in $boltzcfgsizes
    do
        for g in $(seq 1 $nboltz)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${boltzsize}_${g}.log"
            gacc="$gboltz/$boltzsize/$g.acc"
            gy="$tmp/$g.y"
            cnt=$((cnt+1))
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "$boltzsize/$g,yes" | tee -a $gsetlog
                ambcnt=$((ambcnt+1))
                rm -Rf $tmp
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "$boltzsize/$g," | tee -a $gsetlog
                rm -Rf $tmp
                continue
            fi
            out="$boltzsize/$g,"
            timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="$boltzsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
    print_filter_summary $rsltdir >> $rsltdir/summary
}


run_test() {
    rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0
    tmp=$(mktemp -d)
    for g in $testgrammars
    do
        gacc="$grammardir/test/$g/$g.acc"
        gy="$tmp/$g.y"
        glog="$rsltdir/${g}_${g}.log"
        acc_to_yacc $gacc $gy
        timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
        amb=$(grep -o 'Ambiguous string found' $glog)
        cnt=$((cnt+1))
        out="$g,"
        if [ "$amb" != "" ]
        then
            ambcnt=$((ambcnt+1))
            out="$g,yes"
        fi
        echo $out | tee -a $gsetlog
    done
    [ -f $glog ] && gzip -f $glog
    rm -Rf $tmp
    print_summary $ambcnt $cnt > $rsltdir/summary
    print_filter_summary $rsltdir >> $rsltdir/summary
}

usage() {
  echo "$0 -t <time limit (secs)> [-f (lr0|slr1|lalr1|lr1)] <-i 0|-k N> -g <grammar>"
  exit 1
}

set -- $(getopt g:t:f:k:i: "$@")

inclength=""

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -t) timelimit=$2 ; shift;;
     -f) filter=$2 ; shift;;
     -k) length=$2 ; shift;;
     -i) inclength=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

options=""
[ "$filter" != "" ] && options="$options -f $filter"
[ "$length" != "" ] && options="$options -k $length"
[ "$inclength" != "" ] && options="$options -i $inclength"

if [ -z "$options" ] || [ -z "$timelimit" ]; then
  echo "Some of the options are missing. See usage"
  usage
fi

ambdxtcmd="java -Xss8m -Xmx$memlimit -jar $wrkdir/ambidexter/build/AmbiDexter.jar"
export ambdxtcmd 
echo "==> [$gset] t=$timelimit,options=$options"
run_$gset
