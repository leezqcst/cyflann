#!/bin/bash
# the Travis "install" step: see http://docs.travis-ci.com/ and ../.travis.yml
set -e

os=$(uname)

if [[ "$os" == "Darwin" ]]; then
    rvm get stable
    # hack around travis bug https://github.com/travis-ci/travis-ci/issues/6307
fi

if [[ "$SYSTEM_PYTHON" ]]; then
    if [[ "$os" == "Linux" ]]; then
        export sudo='sudo'
        export python='/usr/bin/python'
        sudo apt-get install libflann-dev python-{pip,setuptools,numpy,nose}
        sudo pip install cython
        export FLANN_DIR=/usr
    elif [[ "$os" == "Darwin" ]]; then
        export sudo=''
        export python='/usr/local/bin/python'

        brew update
        brew install python homebrew/science/flann
        pip install -U pip setuptools
        pip install -U nose cython
        brew install homebrew/python/numpy

        export FLANN_DIR=$(brew --prefix)
    else
        echo "unknown os '$os'"
        exit 1
    fi

    $sudo $python setup.py install

    # pyflann is needed for testing, and not easily packaged
    FLANN_VERSION=${FLANN_VERSION:-1.9.1}
    wget https://github.com/mariusmuja/flann/archive/$FLANN_VERSION.tar.gz
    tar xf $FLANN_VERSION.tar.gz
    cd flann-$FLANN_VERSION/src/python
    cat <<EOF >setup.py
#!/usr/bin/env python2
from distutils.core import setup

setup(name='flann',
      version='$FLANN_VERSION',
      description='Fast Library for Approximate Nearest Neighbors',
      author='Marius Muja',
      author_email='mariusm@cs.ubc.ca',
      license='BSD',
      url='http://www.cs.ubc.ca/~mariusm/flann/',
      packages=['pyflann'],
)
EOF
    $sudo $python setup.py install
    cd -
    rm -rf $v
else
    if [[ "$os" == "Linux" ]]; then
        wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh \
            -O miniconda.sh
    elif [[ "$os" == "Darwin" ]]; then
        wget https://repo.continuum.io/miniconda/Miniconda2-latest-MacOSX-x86_64.sh \
            -O miniconda.sh
    else
        echo "unknown os '$os'"
        exit 1
    fi
    chmod +x miniconda.sh
    ./miniconda.sh -b -p $HOME/miniconda

    conda=$HOME/miniconda/bin/conda
    $conda update --yes --quiet conda
    $conda create --yes -c conda-forge -n env \
        python=$PYTHON_VERSION pip nose setuptools cython \
        numpy=$NUMPY_VERSION flann=$FLANN_VERSION pyflann

    export PATH="$HOME/miniconda/envs/env/bin:$PATH"
    export PKG_CONFIG_PATH="$HOME/miniconda/envs/env/lib/pkgconfig:$PKG_CONFIG_PATH"
    export sudo=''
    export python='python'

    $python setup.py install
fi
