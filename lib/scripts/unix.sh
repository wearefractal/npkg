if [ ! -f "$BASE/node/node" ]; then
        echo 'Installing NodeJS - Unix'
        cd $BASE/node
        curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
        JOBS=${JOBS:-8} ./configure --prefix=$BASE/node
        JOBS=${JOBS:-8} make
        make install
        wait
else
        echo 'NodeJS already installed locally, skipping.'
        echo 'If you would like to reinstall NodeJS for this application, uninstall it before running this installer'
fi

cd $BASE
chmod 0777 run.sh
echo 'Installation finished!'

