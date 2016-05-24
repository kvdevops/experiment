#!/bin/bash

. $cwd/toolparams.sh

pp_acla() {
    g="$1"
    aclarow=""
    for timelimit in $timelimits
    do
        if [ ! -z "$2" ]; then
            type="$2"
            n_amb_acla=$(cat $resultsdir/acla/$g/${timelimit}s/$type/*/log | grep -c yes)
        else
            n_amb_acla=$(cat $resultsdir/acla/$g/${timelimit}s/log | grep -c yes)
        fi
        aclarow="$aclarow | ($timelimit,$n_amb_acla) "
    done
    printf '%-20s %-200s\n' "ACLA [$g ${2}]" "$aclarow"
}

pp_amber_ex() {
    g="$1"
    for amberex in $amber_n_examples
    do
        amberexrow=""
        amberellexrow=""
        for timelimit in $timelimits
        do
            result="$resultsdir/amber/$g/${timelimit}s_$(echo "examples $amberex" | sed -e 's/\s/_/g')/log"
            [ ! -z "$2" ] && result="$resultsdir/amber/$g/${timelimit}s_$(echo "examples $amberex" | sed -e 's/\s/_/g')/$2/*/log"
            result_ell="$resultsdir/amber/$g/${timelimit}s_$(echo "examples $amberex ellipsis" | sed -e 's/\s/_/g')/log"
            [ ! -z "$2" ] && result_ell="$resultsdir/amber/$g/${timelimit}s_$(echo "examples $amberex ellipsis" | sed -e 's/\s/_/g')/$2/*/log"
            n_amb_amber_ex=$(cat $result | grep -c "yes")
            n_amb_amber_ell_ex=$(cat $result_ell | grep -c "yes")
            amberexrow="$amberexrow | ($timelimit,$n_amb_amber_ex)"
            amberellexrow="$amberellexrow | ($timelimit,$n_amb_amber_ell_ex)"
        done
        printf '%-20s %-200s\n' "Amber [$g ${2}] [ex $amberex]" "$amberexrow"
        printf '%-20s %-200s\n' "Amber [$g ${2}] [ell ex $amberex]" "$amberellexrow"
    done
}

pp_amber_len() {
    g="$1"
    for amberlen in $amber_n_length
    do
        amberlenrow=""
        amberelllenrow=""
        for timelimit in $timelimits
        do
            result="$resultsdir/amber/$g/${timelimit}s_$(echo "length $amberlen" | sed -e 's/\s/_/g')/log"
            [ ! -z "$2" ] && result="$resultsdir/amber/$g/${timelimit}s_$(echo "length $amberlen" | sed -e 's/\s/_/g')/$2/*/log"
            result_ell="$resultsdir/amber/$g/${timelimit}s_$(echo "length $amberlen ellipsis" | sed -e 's/\s/_/g')/log"
            [ ! -z "$2" ] && result_ell="$resultsdir/amber/$g/${timelimit}s_$(echo "length $amberlen ellipsis" | sed -e 's/\s/_/g')/$2/*/log"
            n_amb_amber_len=$(cat $result | grep -c "yes")
            n_amb_amber_ell_len=$(cat $result_ell | grep -c "yes")
            amberlenrow="$amberlenrow | ($timelimit,$n_amb_amber_len)"
            amberelllenrow="$amberelllenrow | ($timelimit,$n_amb_amber_ell_len)"
        done
        printf '%-20s %-200s\n' "Amber [$g ${2}] [len $amberlen]" "$amberlenrow"
        printf '%-20s %-200s\n' "Amber [$g ${2}] [ell len $amberlen]" "$amberelllenrow"        
    done
}

pp_ambidexter_len() {
    g="$1"
    for ambilen in $ambidexter_n_length
    do
        frow=""
        slr1frow=""
        lr0frow=""
        lr1frow=""
        lalr1frow=""
        koptions="-k_${ambilen}"
        for timelimit in $timelimits
        do
            result="$resultsdir/ambidexter/$g/${timelimit}s_${koptions}/log"
            [ ! -z "$2" ] && result="$resultsdir/ambidexter/$g/${timelimit}s_${koptions}/$2/*/log"
            n_amb_ambidexter_k=$(cat $result | grep -c "yes")

            result_slr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_slr1_${koptions}/log"
            [ ! -z "$2" ] && result_slr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_slr1_${koptions}/$2/*/log"
            n_amb_ambidexter_slr1f_k=$(cat $result_slr1 | grep -c "yes")

            result_lr0="$resultsdir/ambidexter/$g/${timelimit}s_-f_lr0_${koptions}/log"
            [ ! -z "$2" ] && result_lr0="$resultsdir/ambidexter/$g/${timelimit}s_-f_lr0_${koptions}/$2/*/log"
            n_amb_ambidexter_lr0f_k=$(cat $result_lr0 | grep -c "yes")

            result_lr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_lr1_${koptions}/log"
            [ ! -z "$2" ] && result_lr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_lr1_${koptions}/$2/*/log"
            n_amb_ambidexter_lr1f_k=$(cat $result_lr1 | grep -c "yes")

            result_lalr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_lalr1_${koptions}/log"
            [ ! -z "$2" ] && result_lalr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_lalr1_${koptions}/$2/*/log"
            n_amb_ambidexter_lalr1f_k=$(cat $result_lalr1 | grep -c "yes")

            frow="$frow | ($timelimit,$n_amb_ambidexter_k)"
            slr1frow="$slr1frow | ($timelimit,$n_amb_ambidexter_slr1f_k)"
            lr0frow="$lr0frow | ($timelimit,$n_amb_ambidexter_lr0f_k)"
            lr1frow="$lr1frow | ($timelimit,$n_amb_ambidexter_lr1f_k)"
            lalr1frow="$lalr1frow | ($timelimit,$n_amb_ambidexter_lalr1f_k)"                
        done
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: n/a]" "$frow"
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: slr1]" "$slr1frow"
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: lr0]" "$lr0frow"
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: lr1]" "$lr1frow"
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: lalr1]" "$lalr1frow"             
    done
}

pp_ambidexter_inclen() {
    g="$1"
    i_frow=""
    i_slr1frow=""
    i_lr0frow=""
    i_lr1frow=""
    i_lalr1frow=""
    ioptions="-i_0"
    for timelimit in $timelimits
    do
        result="$resultsdir/ambidexter/$g/${timelimit}s_${ioptions}/log"
        [ ! -z "$2" ] && result="$resultsdir/ambidexter/$g/${timelimit}s_${ioptions}/$2/*/log"
        n_amb_ambidexter_i=$(cat $result | grep -c "yes")

        result_slr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_slr1_${ioptions}/log"
        [ ! -z "$2" ] && result_slr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_slr1_${ioptions}/$2/*/log"
        n_amb_ambidexter_slr1f_i=$(cat $result_slr1 | grep -c "yes")

        result_lr0="$resultsdir/ambidexter/$g/${timelimit}s_-f_lr0_${ioptions}/log"
        [ ! -z "$2" ] && result_lr0="$resultsdir/ambidexter/$g/${timelimit}s_-f_lr0_${ioptions}/$2/*/log"
        n_amb_ambidexter_lr0f_i=$(cat $result_lr0 | grep -c "yes")

        result_lr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_lr1_${ioptions}/log"
        [ ! -z "$2" ] && result_lr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_lr1_${ioptions}/$2/*/log"
        n_amb_ambidexter_lr1f_i=$(cat $result_lr1 | grep -c "yes")

        result_lalr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_lalr1_${ioptions}/log"
        [ ! -z "$2" ] && result_lalr1="$resultsdir/ambidexter/$g/${timelimit}s_-f_lalr1_${ioptions}/$2/*/log"
        n_amb_ambidexter_lalr1f_i=$(cat $result_lalr1 | grep -c "yes")

        i_frow="$i_frow | ($timelimit,$n_amb_ambidexter_i)"
        i_slr1frow="$i_slr1frow | ($timelimit,$n_amb_ambidexter_slr1f_i)"
        i_lr0frow="$i_lr0frow | ($timelimit,$n_amb_ambidexter_lr0f_i)"
        i_lr1frow="$i_lr1frow | ($timelimit,$n_amb_ambidexter_lr1f_i)"
        i_lalr1frow="$i_lalr1frow | ($timelimit,$n_amb_ambidexter_lalr1f_i)"            
    done
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: n/a)"   "$i_frow"
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: slr1)"  "$i_slr1frow"
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: lr0)"   "$i_lr0frow"
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: lr1)"   "$i_slr1frow"
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: lalr1)" "$i_lalr1frow"
}

pp_sinbad() {
    g="$1"
    type=""
    [ ! -z "$2" ] && type="$2"
    wgt=""
    [ ! -z "$3" ] && wgt="$3"
    prrow=""
    for timelimit in $timelimits
    do
        result="$resultsdir/sinbad/$g/${timelimit}s_-b_purerandom/log"
        [ ! -z "$type" ] && result="$resultsdir/sinbad/$g/${timelimit}s_-b_purerandom/$type/*/log"
        n_amb_sinbad_purerandom=$(cat $result | grep -c "yes")
        prrow="$prrow | ($timelimit,$n_amb_sinbad_purerandom)"
    done
    printf '%-20s %-200s\n' "sinbad [$g ${2}] [purerandom]" "$prrow"

    for dyn in $backends
    do
        for d in $Tdepths
        do
            d_options="-d_$d"
            prrow=""
            for timelimit in $timelimits
            do
                result="$resultsdir/sinbad/$g/${timelimit}s_-b_${dyn}_${d_options}/log"
                [ ! -z "$type" ] && result="$resultsdir/sinbad/$g/${timelimit}s_-b_${dyn}_${d_options}/$type/*/log"
                n_amb_sinbad_dyn=$(cat $result | grep -c "yes")
                prrow="$prrow | ($timelimit,$n_amb_sinbad_dyn)"
            done
            printf '%-20s %-200s\n' "sinbad [$g ${2}] [$dyn d=$d]" "$prrow"
        done
    done

    for dyn in $wgtbackends
    do
        for d in $Tdepths
        do
            d_options="-d_$d"
            for w in $weights
            do
                w_options="-w_$w"
                prrow=""
                for timelimit in $timelimits
                do
                    result="$resultsdir/sinbad/$g/${timelimit}s_-b_${dyn}_${d_options}_${w_options}/log"
                    [ ! -z "$type" ] && result="$resultsdir/sinbad/$g/${timelimit}s_-b_${dyn}_${d_options}_${w_options}/$type/*/log"
                    n_amb_sinbad_dyn=$(cat $result | grep -c "yes")
                    prrow="$prrow | ($timelimit,$n_amb_sinbad_dyn)"
                done
                printf '%-20s %-200s\n' "sinbad [$g ${2}] [$dyn d=$d w=$w]" "$prrow"
            done
        done
    done
}

for g in $gset
do  
    ##########  ACLA ###########
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_acla $g $type
         done
    else
        pp_acla $g
    fi

    ##########  AMBER - EXAMPLES ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_amber_ex $g $type
         done
    else
        pp_amber_ex $g
    fi
    
    ##########  AMBER - LENGTH ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_amber_len $g $type
         done
    else
        pp_amber_len $g
    fi

    ##########  AMBIDEXTER  ########### 

    ##### LENGTH #####
   if [ "$g" == "mutlang" ]
   then
       for type in $mutypes
       do
           pp_ambidexter_len $g $type
        done
   else
       pp_ambidexter_len $g
   fi

   ##### INCREMENTAL LENGTH #####
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_ambidexter_inclen $g $type
        done
    else
        pp_ambidexter_inclen $g
    fi
                

    ##########  SINBAD ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_sinbad $g $type
         done
    else
        pp_sinbad $g
    fi
            
done
