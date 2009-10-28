#!/bin/bash

mkdir src
cd src
wget "http://garr.dl.sourceforge.net/sourceforge/biocreative/bc2GNandGMgold_Subs.tar.gz"
wget "http://switch.dl.sourceforge.net/sourceforge/biocreative/biocreative1task1a.tar.gz"
wget "http://kent.dl.sourceforge.net/sourceforge/biocreative/biocreative1task1b.tar.gz"
wget "http://mesh.dl.sourceforge.net/sourceforge/biocreative/biocreative1task2.tar.gz"
wget "http://garr.dl.sourceforge.net/sourceforge/biocreative/bc2geneMention.tar.gz"
wget "http://switch.dl.sourceforge.net/sourceforge/biocreative/bc2normal.1.4.tar.gz"
wget "http://kent.dl.sourceforge.net/sourceforge/biocreative/bc2GNtest.zip"

for f in *.gz; do tar xfz $f; done
unzip bc2GNtest.zip

cd ..

mkdir BC2GM
cp -R src/bc2geneMention/train/ BC2GM/
cp -R src/sourceforgeDistrib-22-Sept-07/genemention/BC2GM/test/ BC2GM/
mv BC2GM/train/alt_eval.perl BC2GM/

mkdir BC2GN
cp -R src/biocreative2normalization/* BC2GN/
mv BC2GN/noisyTrainingData/ BC2GN/NoisyTrain
mv BC2GN/trainingData/ BC2GN/Train
cp -R src/bc2GNtest/bc2GNtestdocs/ BC2GN/Test
mv BC2GN/NoisyTrain/noisytrain.genelist BC2GN/NoisyTrain/genelist
mv BC2GN/Train/training.genelist BC2GN/Train/genelist
cp src/sourceforgeDistrib-22-Sept-07/genenormalization/bc2test.genelist BC2GN/Test/genelist

mkdir BC1GN
cp -R src/biocreative1/bc1task1b/* BC1GN/
mv BC1GN/fly/FlyDevTest/ BC1GN/fly/devtest
mv BC1GN/fly/FlyEvaluation/ BC1GN/fly/test
mv BC1GN/fly/FlyNoisyTraining/ BC1GN/fly/train
mv BC1GN/fly/*.list  BC1GN/fly/synonyms.list
mv BC1GN/fly/test/*gene_list  BC1GN/fly/test/genelist
for f in BC1GN/fly/train/gene_list/*; do cat "$f" >> BC1GN/fly/train/genelist;done
for f in BC1GN/fly/devtest/gene_lists/*; do cat "$f" >> BC1GN/fly/devtest/genelist;done
mv BC1GN/mouse/MouseDevTest/ BC1GN/mouse/devtest
mv BC1GN/mouse/MouseEvaluation/ BC1GN/mouse/test
mv BC1GN/mouse/MouseNoisyTraining/ BC1GN/mouse/train
mv BC1GN/mouse/*.list  BC1GN/mouse/synonyms.list
mv BC1GN/mouse/test/*gene_list  BC1GN/mouse/test/genelist
for f in BC1GN/mouse/train/gene_list/*; do cat "$f" >> BC1GN/mouse/train/genelist;done
for f in BC1GN/mouse/devtest/gene_lists/*; do cat "$f" >> BC1GN/mouse/devtest/genelist;done
mv BC1GN/yeast/YeastDevTest/ BC1GN/yeast/devtest
mv BC1GN/yeast/YeastEvaluation/ BC1GN/yeast/test
mv BC1GN/yeast/YeastNoisyTraining/ BC1GN/yeast/train
mv BC1GN/yeast/*.list  BC1GN/yeast/synonyms.list
mv BC1GN/yeast/test/*gene_list  BC1GN/yeast/test/genelist
for f in BC1GN/yeast/train/gene_list/*; do cat "$f" >> BC1GN/yeast/train/genelist;done
for f in BC1GN/yeast/devtest/gene_lists/*; do cat "$f" >> BC1GN/yeast/devtest/genelist;done
# Fix a bug in the perl script! :-|
cat BC1GN/task1Bscorer.pl |grep -v 'else {EVALFILE = STDIN;}' >foo; mv foo BC1GN/task1Bscorer.pl



rm -Rf src












