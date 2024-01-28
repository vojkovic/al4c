#!/bin/bash

init=runit

trap "" EXIT
buildiso -i $init -p base -x


buildiso -i $init -p base -sc
buildiso -i $init -p base -bc
buildiso -i $init -p base -zc || exit 1
