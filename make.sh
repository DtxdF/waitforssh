#!/bin/sh

#
# Script designed to be run for development purposes only.
#

"${SUEXEC:-doas}" make WAITFORSSH_VERSION=`make -V WAITFORSSH_VERSION`+`git rev-parse HEAD`
