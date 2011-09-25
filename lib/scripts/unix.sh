echo 'Installing NodeJS - Unix'
cd $BASE/node
curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
./configure --prefix=$BASE/node
make
make install
wait
echo 'Installation finished!'