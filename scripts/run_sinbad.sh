#!/bin/bash -x

echo $cwd
. $cwd/toolparams.sh

gset=""
backend=""
timelimit=""
depth=""
wgt=""
sinbaddir="$wrkdir/sinbad/src"

run_randomcfg() {
    rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for randomsize in $randomcfgsizes
    do
        tmp=$(mktemp -d)
        _lex="$grandom/$randomsize/lex"
        for g in $(seq 1 $nrandom)
        do
            _acc="$grandom/$randomsize/$g.acc"
            glog="$rsltdir/${randomsize}_${g}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            cnt=$((cnt+1))
            out="$randomsize/$g,"
            if [ "$amb" != "" ]
            then 
                ambcnt=$((ambcnt+1))
                out="$randomsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip $glog
        done
        rm -Rf $tmp
    done
    print_summary $ambcnt $cnt
}

run_mutlang(){
    clog="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/log"
    mkdir -p $resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')
    > $clog
    for type in $mutypes
    do
       for g in $mugrammars
       do
         rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
         mkdir -p $rsltdir
         echo "result ==> $rsltdir"
         tmp=$(mktemp -d)
         ambcnt=0
         cnt=0
         gsetlog="$rsltdir/log"
         cp /dev/null $gsetlog
         _lex="$lexdir/$g.lex"
         glist=$(find $gmutlang/acc/$type/$g -name "*.acc" | cut -d_ -f2 | sort -h | cut -d. -f1 | head -${nmutations})
         for n in $glist
         do
            _acc="$gmutlang/acc/$type/$g/${g}.0_${n}.acc"
            glog="$rsltdir/${g}.0_${n}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            cnt=$((cnt+1))
            out="${g}.0_${n},"
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="${g}.0_${n},yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
         done
         cat $gsetlog | sed -e "s/^/${type}\//" >> $clog
         rm -Rf $tmp
         print_summary $ambcnt $cnt        
       done
    done
}

run_boltzcfg(){
    rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for boltzsize in $boltzcfgsizes
    do
        tmp=$(mktemp -d)
        _lex="$gboltz/$boltzsize/lex"
        for g in $(seq 1 $nboltz)
        do
            _acc="$gboltz/$boltzsize/$g.acc"
            glog="$rsltdir/${boltzsize}_${g}.log"
            $sinbadcmd ${_acc} ${_lex}  > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            cnt=$((cnt+1))
            out="$boltzsize/$g,"
            if [ "$amb" != "" ]
            then 
                ambcnt=$((ambcnt+1))
                out="$boltzsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
        done
        rm -Rf $tmp        
    done
    print_summary $ambcnt $cnt   
}

run_lang() {
    rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    tmp=$(mktemp -d)
    for g in $lgrammars
    do
        _lex="$lexdir/$g.lex"
        for i in $(seq 1 $nlang)
        do
            _acc="$glang/acc/$g.$i.acc"
            glog="$rsltdir/${g}_${i}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            cnt=$((cnt+1))
            out="$g.$i,"
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="$g.$i,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
        done
    done
    rm -Rf $tmp
    print_summary $ambcnt $cnt    
}

run_test() {
    rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    tmp=$(mktemp -d)
    _lex="$lexdir/general.lex"
    for g in $testgrammars
    do
        _acc="$grammardir/test/$g/$g.acc"
        glog="$rsltdir/${g}_${g}.log"
        $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
        amb=$(grep -o 'Grammar ambiguity detected' $glog)
        cnt=$((cnt+1))
        out="$g,"
        if [ "$amb" != "" ]
        then
            ambcnt=$((ambcnt+1))
            out="$g,yes"
        fi
        echo $out | tee -a $gsetlog
        [ -f $glog ] && gzip -f $glog
    done
    rm -Rf $tmp
    print_summary $ambcnt $cnt   
}

usage() {
  echo "$0 -t <time limit (secs)> -g <grammar> -b <backend> [-d <depth>] [-w <weight>]>>"
  exit 1
}

set -- $(getopt g:b:t:d:w: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -b) backend=$2 ; shift;;
     -t) timelimit="$2" ; shift;;
     -d) depth=$2 ; shift;;
     -w) wgt=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*)  break;;  
    esac
    shift
done

options="-b $backend"
[ "$depth" != "" ] && options="$options -d $depth"
[ "$wgt" != "" ] && options="${options} -w $wgt"

echo $options

sinbadcmd="timeout ${timelimit}s $PYTHON $sinbaddir/sinbad $options"

echo "==> $(hostname -s)::($basename $0) [$gset] t=$timelimit,options=$options"
run_$gset

