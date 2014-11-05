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

if [[ "${OSTYPE}" == "darwin"* ]]
then
	export ARCHFLAGS="-Wno-error=unused-command-line-argument-hard-error-in-future"
#elif type gcov
#then
#	export CFLAGS="-pg -fprofile-arcs -ftest-coverage"
#        post='--debug --inplace --libraries z,bz2,gcov'
fi

ln -s khmer-fix-system-libs khmer

pushd khmer

sed -i 's%# libraries = z,bz2%libraries = z,bz2%g' setup.cfg
sed -i 's%include-dirs = lib:third-party/zlib:third-party/bzip2%include-dirs = lib%g' setup.cfg

easy_install -U setuptools
make install-dependencies
pip install wheel

./setup.py build_ext ${post}
./setup.py develop
make coverage.html
./setup.py bdist_wheel
make test
#make doc
make pylint

#make coverage-gcovr.xml || /bin/true
popd
nosetests khmer --attr '!known_failing'

archive

