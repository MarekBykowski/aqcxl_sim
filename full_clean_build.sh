#!/bin/bash -x


if [[ $1 =~ git ]]; then
    git clean -fdx
elif [[ $1 =~ build ]]; then
    git clean -fdx
    cd aqemu/lib/measure
    make clean
    make
    cp libmeasure64.* ../
else
    echo "Run $0 git or build"
fi
