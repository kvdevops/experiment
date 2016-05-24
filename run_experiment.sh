#!/bin/bash -x

wrkdir=""
exp=""

set -- $(getopt d:x: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -d) wrkdir=$2 ; shift;;
     -x) exp=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

usage(){
    echo "$0 -d <work dir> -x <travis|mini|main|validation>"
    exit 1
}

[ -z "$wrkdir" ] && usage
[ -z "$exp" ] && usage

cwd=$(pwd)
echo -e "===> Tools are setup in $wrkdir"
mkdir -p $wrkdir
export cwd wrkdir

ln -sf $cwd/scripts/${exp}_toolparams.sh $cwd/toolparams.sh
> $cwd/env.sh
echo "export cwd=$cwd" >> $cwd/env.sh
echo "export wrkdir=$wrkdir" >> $cwd/env.sh

# now run build.sh to build your tools
./build.sh $wrkdir || exit $?

# sets up values for our experiment
. ./toolparams.sh

if [ "$exp" == "travis" ]; then
  $scriptsdir/run_ACLA.sh -g test -t 10
  [ $(grep -c yes $resultsdir/acla/test/10s/log) == 1 ] || exit 1  

  $scriptsdir/run_Amber.sh -g test -t 10 -n 1000000
  [ $(grep -c yes $resultsdir/amber/test/10s_examples_1000000/log) == 1 ] || exit 1  

  $scriptsdir/run_Amber.sh -g test -t 10 -l 10
  [ $(grep -c yes $resultsdir/amber/test/10s_length_10/log) == 1 ] || exit 1  

  $scriptsdir/run_AmbiDexter.sh -g test -t 10 -k 10
  [ $(grep -c yes $resultsdir/ambidexter/test/10s_-k_10/log) == 1 ] || exit 1  

  $scriptsdir/run_AmbiDexter.sh -g test -t 10 -f slr1 -k 10
  [ $(grep -c yes $resultsdir/ambidexter/test/10s_-f_slr1_-k_10/log) == 1 ] || exit 1  

  $scriptsdir/run_AmbiDexter.sh -g test -t 10 -i 0
  [ $(grep -c yes $resultsdir/ambidexter/test/10s_-i_0/log) == 1 ] || exit 1  

  $scriptsdir/run_AmbiDexter.sh -g test -t 10 -f slr1 -i 0
  [ $(grep -c yes $resultsdir/ambidexter/test/10s_-f_slr1_-i_0/log) == 1 ] || exit 1  

  $scriptsdir/run_SinBAD.sh -g test -b dynamic1 -t 10 -d 10
  [ $(grep -c yes $resultsdir/sinbad/test/10s_-b_dynamic1_-d_10/log) == 1 ] || exit 1  

  $scriptsdir/run_SinBAD.sh -g test -b dynamic4 -t 10 -d 10 -w 0.1
  [ $(grep -c yes $resultsdir/sinbad/test/10s_-b_dynamic4_-d_10_-w_0.1/log) == 1 ] || exit 1  

  exit 0
fi

# download grammars from ambidexter
$scriptsdir/dowload_grammars.sh

[ ! -d $resultsdir ] && mkdir $resultsdir

scriptlist="$cwd/scriptlist"
> $scriptlist

for g in $gset; do  
  for timelimit in $timelimits; do
      echo "$scriptsdir/run_ACLA.sh -g $g -t $timelimit || exit \$?" >> $scriptlist
  done
done

for g in $gset; do
  for timelimit in $timelimits; do
    for amberex in $amber_n_examples; do
      echo "$scriptsdir/run_Amber.sh -g $g -t $timelimit -n $amberex || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_Amber.sh -g $g -t $timelimit -n $amberex -e || exit \$?" >> $scriptlist
    done

    for amberlen in $amber_n_length; do
      echo "$scriptsdir/run_Amber.sh -g $g -t $timelimit -l $amberlen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_Amber.sh -g $g -t $timelimit -l $amberlen -e || exit \$?" >> $scriptlist
    done
  done
done

for g in $gset; do
  for timelimit in $timelimits; do
    for ambilen in $ambidexter_n_length; do
      echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -k $ambilen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -f slr1 -k $ambilen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -f lalr1 -k $ambilen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -f lr0 -k $ambilen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -f lr1 -k $ambilen || exit \$?" >> $scriptlist
    done
         
    echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -i 0 || exit \$?" >> $scriptlist
    echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -f slr1 -i 0 || exit \$?" >> $scriptlist
    echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -f lalr1 -i 0 || exit \$?" >> $scriptlist
    echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -f lr0 -i 0 || exit \$?" >> $scriptlist
    echo "$scriptsdir/run_AmbiDexter.sh -g $g -t $timelimit -f lr1 -i 0 || exit \$?" >> $scriptlist
  done
done

for g in $gset; do
  for timelimit in $timelimits; do
    echo "$scriptsdir/run_SinBAD.sh -g $g -b purerandom -t $timelimit || exit \$?" >> $scriptlist

    for backend in $backends; do
      for d in $Tdepths; do
        echo "$scriptsdir/run_SinBAD.sh -g $g -b $backend -t $timelimit -d $d || exit \$?" >> $scriptlist
      done
    done

    for backend in $wgtbackends; do
      for d in $Tdepths; do
        for wgt in $weights; do
          echo "$scriptsdir/run_SinBAD.sh -g $g -b $backend -t $timelimit -d $d -w $wgt || exit \$?" >> $scriptlist
        done
      done
    done

  done
done

echo "$scriptlist generated. Running them in parallel ..."

[ ! -f ~/machinefile ] && echo "I need ~/machinefile with list of hosts to run jobs"
nodelist=""
for host in $(cat ~/machinefile)
do
    nodelist="$cores_per_host/$host,$nodelist"
done
pllnodes=$(echo $nodelist | sed -e 's/,$//')

echo $pllnodes

expstart=$(date +%s)
cat $scriptlist | parallel -u -S $pllnodes
expend=$(date +%s)
expelapsed=$(($expend - $expstart))

echo -e "\\n===> experiment complete in $expelapsed seconds \n"
cd $cwd
tar czf results.tar.gz results
echo -e "\\n===> results - results.tar.gz \\n"
echo -e "\\n pretty printing results to $ppresults \\n"
./ppresults.sh > $ppresults 2>&1
