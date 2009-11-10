#!/bin/bash
function norm(){
    organism=$1
    shift
    dataset=$1
    shift
    ner=$1
    shift

    CMD="rm results/${organism}_$dataset; rake results/${organism}_$dataset.eval ner=$ner $@ > ${organism}_$dataset.log_$ner; tail results/${organism}_$dataset.eval"
    echo $CMD
    $CMD
}


function norm_2(){
    ner=$1
    shift

    CMD="rm results/bc2gn; rake results/bc2gn.eval ner=$ner $@ > bc2gn.log_$ner; tail results/bc2gn.eval"
    echo $CMD
    $CMD
}
