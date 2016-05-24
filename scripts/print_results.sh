#!/bin/sh

resultdir=""
exp=""

set -- $(getopt d:x: "$@")

while [ $# -gt 0 ]
do
    case "$1" in
     -d) resultdir=$2 ; shift;;
     -x) exp=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;
    esac
    shift
done

usage(){
    echo "$0 -d <results dir> -x <mini|main|validation>"
    exit 1
}

[ -z "$resultdir" ] && usage
[ -z "$exp" ] && usage

if [ ! -d $resultdir ]; then
    echo "results directory $resultdir does not exist"
    exit 1
fi

if [ ! -f ./${exp}_toolparams.sh ]; then
    echo "toolparams ./${exp}_toolparams.sh does not exist"
    exit 1
fi

. ./${exp}_toolparams.sh

print(){
    log="$1"
    total=$(wc -l $log | awk '{print $1}')
    ambcnt=$(grep -c yes $log)
    echo "$ambcnt [/$total]"
}

print_mutlang(){
    logdir=$1
    alllangstypes=$(mktemp)
    out=""
    for type in $mutypes; do
        alllangs=$(mktemp)
        outlangs=""
        for lang in $mugrammars; do
            cat $logdir/$type/$lang/log >> $alllangs
            cat $logdir/$type/$lang/log >> $alllangstypes
        done
        toutlangs=$(print $alllangs)
        outlangs="$outlangs,$toutlangs"
        rm $alllangs
        #echo "$(echo $alllangs | cut -d/ -f3),$outlangs"
    done
    tout=$(print $alllangstypes)
    out="$out,$tout"
    rm $alllangstypes
    echo "$out"
}

print_acla(){
    for g in boltzcfg lang; do
        echo "ACLA [$g]"
        out=""
        for t in $timelimits 120; do
            tout=$(print "$resultdir/acla/$g/${t}s/log")
            out="$out,$tout"
        done
        echo "$g,$out"
    done

    echo "ACLA [mutlang]"
    out=""
    for t in $timelimits 120; do 
        tout=$(print_mutlang "$resultdir/acla/mutlang/${t}s")
        out="$out,$tout"
    done
    echo "mutlang,$out"
}

print_ambidexter(){
    for g in boltzcfg lang; do
        echo "AmbiDexter [$g]"
        for ambilen in $ambidexter_n_length; do
            out=""
            for t in ${timelimits}; do
                tout=$(print "$resultdir/ambidexter/$g/${t}s_-k_${ambilen}/log")
                out="$out,$tout"
            done
            echo "k_${ambilen},$out"

            for filter in lr0 slr1 lalr1 lr1; do
                out=""
                for t in $timelimits;do
                    tout=$(print "$resultdir/ambidexter/$g/${t}s_-f_${filter}_-k_${ambilen}/log")
                    out="$out,$tout"
                done
                echo "${filter}_-k_${ambilen},$out"
            done
        done

        out=""
        for t in ${timelimits}; do
            tout=$(print "$resultdir/ambidexter/$g/${t}s_-i_0/log")
            out="$out,$tout"
        done
        echo "ik_0,$out"

        for filter in lr0 slr1 lalr1 lr1; do
            out=""
            for t in ${timelimits}; do
                tout=$(print "$resultdir/ambidexter/$g/${t}s_-f_${filter}_-i_0/log")
                out="$out,$tout"
            done
            echo "${filter}_-ik_0,$out"
        done
    done

    echo "AmbiDexter [mutlang]"
    for ambilen in $ambidexter_n_length; do
        outall=""
        for t in ${timelimits}; do
            outall="$outall,$(print_mutlang $resultdir/ambidexter/mutlang/${t}s_-k_${ambilen})"
        done
        echo "k_${ambilen},$outall"
                
        for filter in lr0 slr1 lalr1 lr1; do
            outall=""
            for t in ${timelimits}; do
                outall="$outall,$(print_mutlang $resultdir/ambidexter/mutlang/${t}s_-f_${filter}_-k_${ambilen})"
            done
            echo "k_${ambilen}_${filter},$outall"
        done
    done

    outall=""
    for t in ${timelimits}; do
        outall="$outall,$(print_mutlang $resultdir/ambidexter/mutlang/${t}s_-i_0)"
    done
    echo "ik_0,$outall"

    for filter in lr0 slr1 lalr1 lr1; do
        outall=""
        for t in ${timelimits}; do
            outall="$outall,$(print_mutlang $resultdir/ambidexter/mutlang/${t}s_-f_${filter}_-i_0)"
        done
        echo "ik_0_${filter},$outall"
    done
}

print_amber(){
    for g in boltzcfg lang
    do
        echo "AMBER [$g]"
        for amberex in $amber_n_examples; do
            out=""
            ellout=""
            for t in $timelimits; do
                tout=$(print "$resultdir/amber/$g/${t}s_examples_${amberex}/log")
                out="$out,$tout"
                tout=$(print "$resultdir/amber/$g/${t}s_examples_${amberex}_ellipsis/log")
                ellout="$ellout,$tout"
            done
            echo "examples_${amberex},$out"
            echo "examples_${amberex}_ellipsis,$ellout"
        done

        for amberlen in $amber_n_length; do
            out=""
            ellout=""
            for t in $timelimits;do
                tout=$(print "$resultdir/amber/$g/${t}s_length_${amberlen}/log")
                out="$out,$tout"
                tout=$(print "$resultdir/amber/$g/${t}s_length_${amberlen}_ellipsis/log")
                ellout="$ellout,$tout"
            done
            echo "length_${amberlen},$out"
            echo "length_${amberlen}_ellipsis,$ellout"
        done
    done
   
    echo "AMBER [mutlang]"
    for amberex in $amber_n_examples; do
        outall=""
        outallell=""
        for t in ${timelimits}; do
            outall="$outall,$(print_mutlang $resultdir/amber/mutlang/${t}s_examples_${amberex})"
            outallell="$outallell,$(print_mutlang $resultdir/amber/mutlang/${t}s_examples_${amberex}_ellipsis)"
        done
        echo "examples_${amberex},$outall"
        echo "examples_${amberex}_ellipsis,$outallell"
    done
       
    for amberlen in $amber_n_length; do
        outall=""
        outallell=""
        for t in ${timelimits}; do
            outall="$outall,$(print_mutlang $resultdir/amber/mutlang/${t}s_length_${amberlen})"
            outallell="$outallell,$(print_mutlang $resultdir/amber/mutlang/${t}s_length_${amberlen}_ellipsis)"
        done
        echo "length_${amberlen},$outall"
        echo "length_${amberlen}_ellipsis,$outallell"    
    done

}

print_sinbad(){
    for g in boltzcfg lang; do 
        echo "SinBAD [$g]"    
        out=""
        for t in $timelimits; do
            tout=$(print "$resultdir/sinbad/$g/${t}s_-b_purerandom/log")
            out="$out,$tout"
        done
        echo "purerandom, $out"
        for b in $backends; do 
            for d in $Tdepths; do 
                out=""
                for t in $timelimits; do 
                    tout=$(print "$resultdir/sinbad/$g/${t}s_-b_${b}_-d_${d}/log")
                    out="$out,$tout"
                done
                echo "${b}_-d_${d},$out"
            done
        done
        for b in $wgtbackends; do 
            for d in $Tdepths; do 
                for w in $weights; do 
                    out=""
                    for t in $timelimits; do 
                        tout=$(print "$resultdir/sinbad/$g/${t}s_-b_${b}_-d_${d}_-w_$w/log")
                        out="$out,$tout"
                    done
                    echo "${b}_-d_${d}_-w_${w},$out"
                done
            done
        done
    done

    echo "SinBAD [mutlang]"
    out=""
    for t in $timelimits; do 
        tout=$(print_mutlang "$resultdir/sinbad/mutlang/${t}s_-b_purerandom")
        out="$out,$tout"
    done
    echo "purerandom,$out"
   
    for b in $backends; do
        for d in 10; do 
            out=""
            for t in $timelimits; do 
                tout=$(print_mutlang "$resultdir/sinbad/mutlang/${t}s_-b_${b}_-d_$d")
                out="$out,$tout"
            done
            echo "${b}_-d_${d},$out"
        done
    done
    
    for b in $wgtbackends; do
        for d in $Tdepths; do 
            for w in $weights; do  
                out=""
                for t in $timelimits; do 
                    tout=$(print_mutlang "$resultdir/sinbad/mutlang/${t}s_-b_${b}_-d_${d}_-w_$w")
                    out="$out,$tout"
                done
                echo "${b}_-d_${d}_-w_$w,$out"
            done
        done
    done    
}

print_acla
print_ambidexter
print_amber
print_sinbad
