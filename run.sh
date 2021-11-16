#!/bin/sh

echo "Poor implementation - exiting"
exit 0

#Get distro
distro=`lsb_release -is`
release=`lsb_release -rs`
here=`pwd`
folder="${here}/src-distro/${distro}${release}"

# TODO: Add check if distro don't exists
cd ${folder} 
./install.sh