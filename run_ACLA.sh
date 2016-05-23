#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

gset=""
timelimit=""

run_randomcfg() {
    rsltdir="$resultsdir/acla/$gset/${timelimit}s"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0    
    for randomsize in $randomcfgsizes
    do
        for g in  $(seq 1 $nrandom)
        do
            tmp=$(mktemp -d)
            gacc="$grandom/$randomsize/$g.acc"
            gcfg="$tmp/${randomsize}_${g}.cfg"    
            glog="$rsltdir/${randomsize}_${g}.log"
            acc_to_cfg $gacc $gcfg
            $aclacmd $gcfg > $glog 2>&1
            ((cnt+=1))
            out="${randomsize}/$g,"
            amb=$(grep -o 'ambiguous string' $glog)
            if [ "$amb" != "" ]
            then
                ((ambcnt+=1))
                out="${randomsize}/$g,yes"
            fi
            echo $out | tee -a $gsetlog        
            gzip -f $glog
            rm -Rf $tmp            
        done
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
}

run_lang() {
    rsltdir="$resultsdir/acla/$gset/${timelimit}s"
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
            gacc="$glang/acc/$g.$i.acc"
            gcfg="$tmp/$g.$i.cfg"
            glog="$rsltdir/${g}_${i}.log"
            acc_to_cfg $gacc $gcfg
            $aclacmd $gcfg > $glog 2>&1
            ((cnt+=1))
            out="$g.$i,"
            amb=$(grep -o 'ambiguous string' $glog)
            if [ "$amb" != "" ]
            then
                ((ambcnt+=1))
                out="$g.$i,yes"
            fi
            echo $out | tee -a $gsetlog        
            gzip -f $glog
            rm -Rf $tmp 
        done
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
}

run_mutlang() {
    clog="$resultsdir/acla/$gset/${timelimit}s/log"
    mkdir -p $resultsdir/acla/$gset/${timelimit}s
    for type in $mutypes
    do
        for g in $mugrammars
        do
            rsltdir="$resultsdir/acla/$gset/${timelimit}s/$type/$g"
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
                gacc="$gmutlang/acc/$type/$g/$g.0_$n.acc"
                gcfg="$tmp/$g.0_$n.cfg"
                glog="$rsltdir/${g}.0_${n}.log"
                acc_to_cfg $gacc $gcfg
                $aclacmd $gcfg > $glog 2>&1
                ((cnt+=1))
                out="$g.0_$n,"
                amb=$(grep -o 'ambiguous string' $glog)
                if [ "$amb" != "" ]
                then
                    ((ambcnt+=1))
                    out="$g.0_$n,yes"
                fi
                echo $out | tee -a $gsetlog        
                gzip -f $glog
                rm -Rf $tmp 
            done
            cat $gsetlog | sed -e "s/^/${type}\//" >> $clog
            print_summary $ambcnt $cnt > $rsltdir/summary
        done
    done    
}

run_boltzcfg() {
    rsltdir="$resultsdir/acla/$gset/${timelimit}s"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for boltzsize in $boltzcfgsizes
    do    
        for g in  $(seq 1 $nboltz)
        do
            tmp=$(mktemp -d)
            gacc="$gboltz/$boltzsize/$g.acc"
            gcfg="$tmp/${boltzsize}_${g}.cfg"    
            glog="$rsltdir/${boltzsize}_${g}.log"
            acc_to_cfg $gacc $gcfg
            $aclacmd $gcfg > $glog 2>&1
            ((cnt+=1))
            out="${boltzsize}/$g,"
            amb=$(grep -o 'ambiguous string' $glog)
            if [ "$amb" != "" ]
            then
                ((ambcnt+=1))
                out="${boltzsize}/$g,yes"
            fi
            echo $out | tee -a $gsetlog        
            gzip -f $glog
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
}

run_test() {
    rsltdir="$resultsdir/acla/$gset/${timelimit}s"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0
    for g in $testgrammars
    do
        tmp=$(mktemp -d)
        gacc="$grammardir/test/$g/$g.acc"
        gcfg="$tmp/$g.cfg"
        glog="$rsltdir/${g}.log"
        acc_to_cfg $gacc $gcfg
        $aclacmd $gcfg > $glog 2>&1
        ((cnt+=1))
        out="$g,"
        amb=$(grep -o 'ambiguous string' $glog)
        if [ "$amb" != "" ]
        then
            ((ambcnt+=1))
            out="$g,yes"
        fi
        echo $out | tee -a $gsetlog        
        gzip -f $glog
        rm -Rf $tmp
    done
    print_summary $ambcnt $cnt > $rsltdir/summary
}

set -- $(getopt g:t: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -t) timelimit="$2" ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*)  break;;  
    esac
    shift
done

aclacmd="timeout ${timelimit}s java -Xmx$memlimit -jar $wrkdir/ACLA/grammar.modified.jar -k -a"
export aclacmd 
echo "==> $(hostname -s)::($basename $0) [$gset] t=$timelimit"
run_$gset

