#!/bin/bash

# Prequisite: virtualenv-* directory expanded from https://pypi.python.org/packages/source/v/virtualenv/virtualenv-X.Y[.Z].tar.gz
# and khmer-* directory expanded from https://github.com/ged-lab/khmer/archive/vX.Y.Z.tar.gz

startDir=$PWD

function archive {
	signal=$?
	cd ${startDir}
	mkdir -p env
	tar czf results.tar.gz env khmer*
	exit ${signal}
}

trap archive ERR 

set -e
set -x


cd virtualenv-*
python virtualenv.py -p python2.7 ../env || python virtualenv.py -p python2 ../env || python virtualenv.py ../env
cd ..

source env/bin/activate
pip2 install --upgrade nose

ln -s khmer-*/ khmer

pushd khmer
#if type gcov && [[ "$OSTYPE" != "darwin"* ]]
#then
#	export CFLAGS="-pg -fprofile-arcs -ftest-coverage"
#        post='--debug --inplace --libraries gcov'
#else
#        echo "gcov was not found, skipping coverage check"
#fi
easy_install -U setuptools
#./setup.py build_ext ${post}
./setup.py develop
#make coverage.html
#./setup.py bdist_wheel
#make doc
#make pylint
make
make test || /bin/true
#gcovr --xml > coverage-gcovr.xml || /bin/true
popd

archive

