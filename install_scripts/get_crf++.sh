wget "http://downloads.sourceforge.net/crfpp/CRF%2B%2B-0.51.tar.gz?modtime=1215793886&big_mirror=0" -O crf++.tar.gz
tar xvfz crf++.tar.gz
rm crf++.tar.gz
cd CRF*
PREFIX=$(dirname $PWD)

if [ `uname -m` == 'x86_64' ]; then
  WITH_PIC='--with-pic';
else
  WITH_PIC=''
fi

./configure  --prefix=$PREFIX --exec-prefix=$PREFIX $WITH_PIC; 
make install
cd ruby

ruby extconf.rb  --with-opt-lib=$PREFIX/lib/ --with-opt-include=$PREFIX/include/
make
cc -shared -o CRFPP.so CRFPP_wrap.o ../../lib/libcrfpp.a  -L. -L/usr/lib  -L.  -rdynamic -Wl,-export-dynamic    -lruby -lpthread  -lpthread -ldl -lcrypt -lm   -lc -lstdc++

mkdir ../../ruby/
cp CRFPP.so ../../ruby/
cd ../../
rm -Rf CRF* include


