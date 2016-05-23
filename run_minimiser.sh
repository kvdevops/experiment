#!/bin/bash

# modify the below settings before launch
ambiminp="${HOME}/codespace/sinbad/src/AmbiMin.py"
bolzdir="${HOME}/codespace/experiment/grammars/boltzcfg"
langdir="${HOME}/codespace/experiment/grammars/lang/acc"
mutdir="${HOME}/codespace/experiment/grammars/mutlang/acc"
lexdir="${HOME}/codespace/experiment/grammars/lex"
backend=""
depth=""
weight=""
minimiser=""
gset=""
nmin=""
tmin=""
ambijarp=""
heap=""
fltr=""
outf=""
tout="180"

set -- $(getopt b:m:g:n:t:d:w:f:o:j:x:T: "$@")

# Check for ACCENT_DIR
[ -z $ACCENT_DIR ] && echo "ACCENT_DIR is not set. exiting..." && exit 1

usage(){
    echo "$0 
            -b <backend> 
            -d <depth> 
            -w <weight> 
            -m <minimiser> 
            -g <grammar set> 
            -n <no of minimisations>
            -t <time to search for ambiguity (accent)>
            -T <time to search for ambiguity (ambidexter)>
            -j <path to ambidexter jar>
            -x <heap size for ambidexter>
            -f <filter to apply>
            -o <output format for minimised grammar>"
    exit 1
}

while [ $# -gt 0 ]
do
    case "$1" in 
     -b) backend=$2 ; shift;;
     -d) depth=$2 ; shift;;
     -w) weight=$2 ; shift;;
     -m) minimiser=$2 ; shift;;
     -g) gset=$2 ; shift;;
     -n) nmin=$2 ; shift;;
     -t) tmin=$2 ; shift;;
     -T) ambiT=$2 ; shift;;
     -j) ambijarp=$2 ; shift;;
     -x) heap=$2 ; shift;;
     -f) fltr=$2 ; shift;;
     -o) outf=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; usage; exit 1;;
     (*) break;;  
    esac
    shift
done

[ -z "$backend" ] && usage
[ -d "$depth" ] && usage
[ -z "$minimiser" ] && usage
[ -z "$gset" ] && usage

cmd="timeout ${tout}s python $ambiminp -b $backend -w $weight -d $depth -m $minimiser -s"
logd="$(pwd)/log/$minimiser/$gset"
[ ! -d $logd ] && mkdir -p $logd

case "$minimiser" in
    min1) 
      if [ -z "$nmin" ]; then
        echo "min1 requires -n <no of minimisations>"
        usage
      fi
      cmd="$cmd -n $nmin"
    ;;
    min1a) 
      # TO DO
    ;;
    min2|minad) 
      if [ -z "$tmin" ]; then
        echo "min{2|ad} requires -t <time to search for ambiguity>"
        usage
      fi
      cmd="$cmd -t $tmin"
    ;;
    min2a|min3a)
      if [ -z "$tmin" ]; then
        echo "min[23]a requires -t <time to search for ambiguity (accent)>"
        usage
      fi
      if [ -z "$ambiT" ]; then
        echo "min[23]a requires -T <time to search for ambiguity (ambidexter)>"
        usage
      fi
      if [ -z "$ambijarp" ]; then
        echo "min[23]a requires -j <path to ambidexter jar>"
        usage
      fi
      if [ -z "$heap" ]; then
        echo "min[23]a requires -x <heap size for ambidexter>"
        usage
      fi
      cmd="$cmd -j $ambijarp -x $heap -t $tmin -T $ambiT"
    ;;
    min3) 
      if [ -z "$tmin" ]; then
        echo "min3 requires -t <time to search for ambiguity>"
        usage
      fi
      cmd="$cmd -t $tmin"
    ;;
    min4) 
      if [ -z "$ambijarp" ]; then
        echo "min4 requires -j <path to ambidexter jar>"
        usage
      fi
      if [ -z "$nmin" ]; then
        echo "min4 requires -n <no of minimisations>"
        usage
      fi
      if [ -z "$tmin" ]; then
        echo "min4 requires -t <time to search for ambiguity>"
        usage
      fi
      if [ -z "$heap" ]; then
        echo "min4 requires -x <heap size for ambidexter>"
        usage
      fi
      cmd="$cmd -j $ambijarp -n $nmin -t $tmin -x $heap"
    ;;
    min5|min6)
      if [ -z "$nmin" ]; then
        echo "min[56] requires -n <no of minimisations>"
        usage
      fi
      if [ -z "$tmin" ]; then
        echo "min[56] requires -t <time to search for ambiguity>"
        usage
      fi
      if [ -z "$ambijarp" ]; then
        echo "min[56] requires -j <path to ambidexter jar>"
        usage
      fi
      if [ -z "$fltr" ]; then
        echo "min[56] requires -f <filter to apply for ambidexter>"
        usage
      fi
      if [ -z "$outf" ]; then
        echo "min[56] requires -t <output format for ambidexter>"
        usage
      fi
      if [ -z "$heap" ]; then
        echo "min4 requires -x <heap size for ambidexter>"
        usage
      fi
      cmd="$cmd -n $nmin -t $tmin -j $ambijarp -x $heap -f $fltr -o $outf"
    ;;
esac

print_stats() {
  _g=$1
  log=$2
  size0=$(head -1 $log)
  nlines=$(wc -l $log | awk '{print $1}')
  sizen=",,,,,,"
  case "${minimiser}" in
    min2a|min3a|min4)
      # get the final accent grammar, followed by the grammar
      # from ambidexter
      if [ $nlines -gt 1 ]; then
        ambil=$(grep ^* $log)
        if [ -z "${ambil}" ]; then
          # ambidexter didn't find anyting
          sizen="$(tail -1 $log)"
        else
          # ambidexter did find something
          sizen="$(tail -2 $log | head -1),,$ambil"
        fi
      fi
    ;;
    min1|min2|min3)
      [ $nlines -gt 1 ] && sizen=$(tail -1 $log)
    ;;
  esac
  echo "${_g},${size0},,${sizen}"
}

boltz() {
  for g in $(seq 10 75); do
    for i in $(seq 10); do 
      gacc="$bolzdir/$g/${i}.acc"
      lex="$bolzdir/$g/lex"
      log="/tmp/${g}_${i}.${minimiser}"
      stats=$($cmd -l $log $gacc $lex)
      print_stats "$g/${i}" "$log"
      rm $log
    done
  done
}

lang() {
  for l in Pascal SQL Java C; do 
    for i in $(seq 5); do
      gacc="$langdir/${l}.${i}.acc"
      lex="$lexdir/${l}.lex"
      log="/tmp/${l}_${i}.${minimiser}"
      stats=$($cmd -l $log $gacc $lex)
      print_stats "${l}.${i}" "$log"
      rm $log
    done
  done
}

mutlang() {
  for t in empty add mutate delete switch; do 
    mkdir -p $logd/$t
    for l in Pascal SQL Java C CSS; do 
      for i in $(seq 1); do
        gacc="$mutdir/$t/${l}/${l}.0_${i}.acc"
        lex="$lexdir/${l}.lex"
        log="/tmp/${t}_${l}_${i}.${minimiser}"
        stats=$($cmd -l $log $gacc $lex)
        print_stats "$t/${l}.${i}" "$log"
        rm $log
      done
     done
  done
}

case "$gset" in
    boltz)
      boltz | tee boltz.${minimiser}.csv
      ;;
    lang)
      lang | tee lang.${minimiser}.csv
      ;;
    mutlang)
      mutlang | tee mutlang.${minimiser}.csv
      ;;
esac

