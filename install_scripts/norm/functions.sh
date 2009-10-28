#!/bin/bash
function norm(){
    o=$1
    shift
    s=$1
    shift
    n=$1
    shift

    echo "rm results/${o}_$s; rake results/${o}_$s.eval ner=$n $@ > ${o}_$s.log_$n; tail results/${o}_$s.eval"
    rm results/${o}_$s; rake results/${o}_$s.eval ner=$n $@ > ${o}_$s.log_$n; tail results/${o}_$s.eval
}


function norm_2(){
    n=$1
    shift

    echo "rm results/bc2gn; rake results/bc2gn.eval ner=$n $@ > bc2gn.log_$n; tail results/bc2gn.eval"
    rm results/bc2gn; rake results/bc2gn.eval ner=$n $@ > bc2gn.log_$n; tail results/bc2gn.eval
}
