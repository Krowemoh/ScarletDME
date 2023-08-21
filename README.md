# ScarletDME

ScarletDME is a fork of OpenQM 2.6.

This fork is one where I am adding and modifying things to work for me. The changes are listed below.

## Installation

```
git clone https://github.com/geneb/ScarletDME.git
cd ScarletDME
make
make install
make datafiles
cp scarlet.conf /etc/
```

You will need to create the group and user for qm. Any users you want to have use qm will also need to be added to the qmusers group.

```
groupadd qmusers
useradd -c "qmsys" -d /home/qmsys -s /bin/sh qmsys
usermod -a -G qmusers qmsys
usermod -a -G qmusers root
```

The start up command:

```
/usr/qmsys/bin/qm -start
```

To make qm available globally, you can add `/usr/qmsys/bin/` to the PATH.

## Changes

I have added BigNumber support.

```
SADD()
SSUB()
SMUL()
SDIV()
```
