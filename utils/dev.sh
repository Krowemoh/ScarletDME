#!/usr/bin/sudo bash

utils/install.sh

qm -stop && qm -start

cd /usr/qmsys

qm -Internal "BASIC GPL.BP BCOMP"
