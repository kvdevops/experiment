#!/bin/bash -x

echo $cwd
. $cwd/toolparams.sh

gset=""
timelimit=""
examples=""
length=""
ellipsis="no"

accent="$wrkdir/accent/accent/accent"
ambersrc="$wrkdir/accent/amber/amber.c"
lex=$(which flex)
cc=$(which cc)

run_randomcfg() {
    rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    cwd=$(pwd)
    for randomsize in $randomcfgsizes
    do
        for g in $(seq 1 $nrandom)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${randomsize}_${g}.log"
            cd $tmp
            $accent $grandom/$randomsize/$g.acc || exit $?
            $lex $grandom/$randomsize/lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            $ambercmd 2> /dev/null > $glog
            cnt=$((cnt+1))
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$randomsize/$g," 
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="$randomsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            cd $cwd
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
}

run_lang() {
    rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${g}_${i}.log"
            cd $tmp
            $accent $glang/acc/$g.$i.acc || exit $?
            $lex $lexdir/$g.lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            #$ambercmd 2> /dev/null > $glog
            $ambercmd > $glog 2>&1
            cnt=$((cnt+1))
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$g.$i," 
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="$g.$i,yes"
            fi
            echo $out| tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            cd $cwd
            rm -Rf $tmp
        done
    done 
    print_summary $ambcnt $cnt > $rsltdir/summary 
}

run_mutlang() {
    clog="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/log"
    mkdir -p $resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')
    > $clog
    for type in $mutypes
    do
       for g in $mugrammars
       do
         rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
         mkdir -p $rsltdir
         echo "result ==> $rsltdir"
         ambcnt=0
         cnt=0
         gsetlog="$rsltdir/log"
         cp /dev/null $gsetlog
         glist=$(find $gmutlang/acc/$type/$g -name "*.acc" | cut -d_ -f2 | sort -h | cut -d. -f1 | head -${nmutations})
         for n in $glist
         do
             tmp=$(mktemp -d)
             glog="$rsltdir/${g}.0_${n}.log"
             cd $tmp
             $accent $gmutlang/acc/${type}/$g/$g.0_${n}.acc || exit $?
             $lex $lexdir/$g.lex || exit $?
             $cc -w -o amber -O3 yygrammar.c $ambersrc
             $ambercmd 2> /dev/null > $glog
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
             cd $cwd
             rm -Rf $tmp
         done
         cat $gsetlog | sed -e "s/^/${type}\//" >> $clog
         print_summary $ambcnt $cnt > $rsltdir/summary        
       done
    done
}

run_boltzcfg() {
    rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for boltzsize in $boltzcfgsizes
    do
        for g in $(seq 1 $nboltz)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${boltzsize}_${g}.log"
            cd $tmp
            $accent $gboltz/$boltzsize/$g.acc || exit $?
            $lex $gboltz/$boltzsize/lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            $ambercmd 2> /dev/null > $glog
            cnt=$((cnt+1))
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$boltzsize/$g,"
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="$boltzsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            cd $cwd
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
}

run_test() {
    rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for g in $testgrammars
    do
        tmp=$(mktemp -d)
        glog="$rsltdir/${g}_${g}.log"
        cd $tmp
        $accent $grammardir/test/$g/$g.acc || exit $?
        $lex $lexdir/general.lex || exit $?
        $cc -w -o amber -O3 yygrammar.c $ambersrc
        $ambercmd 2> /dev/null > $glog
        cnt=$((cnt+1))
        amb=$(grep -o 'Grammar ambiguity detected' $glog)
        out="$g,"
        if [ "$amb" != "" ]
        then
            ambcnt=$((ambcnt+1))
            out="$g,yes"
        fi
        echo "$out" | tee -a $gsetlog
        [ -f $glog ] && gzip -f $glog
        cd $cwd
        rm -Rf $tmp  
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
}

usage() {
  echo "$0 -t <time limit (secs)> -g <grammar set> <-n|-l> [-e]"
  exit 1
}

set -- $(getopt g:t:n:l:e "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -t) timelimit=$2 ; shift;;
     -n) examples=$2 ; shift;;
     -l) length="$2" ; shift;;
     -e) ellipsis="yes" ;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

options=""
if [ "$ellipsis" = "yes" ]; then
    options="${options} ellipsis"
fi

if [ "$examples" != "" ]; then
    options="${options} examples $examples"
fi

if [ "$length" != "" ]; then
    options="${options} length $length"
fi

if [ -z "$options" ] || [ -z "$timelimit" ]; then
    echo "Some of the options were not provided for running Amber. see usage"
    usage
fi

ambercmd="timeout ${timelimit}s ./amber $options"
echo "==> $(hostname -s)::($basename $0) [$gset] t=[$timelimit], options=[$options]"
cwd=$(pwd)
run_$gset

