#!/bin/bash

wget "http://downloads.sourceforge.net/banner/BANNER_v02.zip?modtime=1196955449&big_mirror=0"
wget "http://downloads.sourceforge.net/banner/gene_model_v02.bin?modtime=1196955509&big_mirror=0"
mv BANNER_v02.zip BANNER.zip
mv gene_model_v02.bin gene_model.bin
unzip BANNER.zip
cd BANNER
libs=`find libs/ -name "*.jar"`
mkdir classes
javac -classpath `echo $libs|sed s/\ /:/g` -d classes `find src/ -name "*.java"`
cd classes
for f in ../libs/*.jar; do jar xf "$f";done
jar cf banner.jar *
mv banner.jar ../..
cd ..
cp -R nlpdata/ ../
cd ..
rm BANNER.zip
rm -Rf BANNER





