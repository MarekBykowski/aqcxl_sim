#!/bin/bash -x

git clean -fdx

cd aqemu/lib/measure
make clean
make
cp libmeasure64.* ../
