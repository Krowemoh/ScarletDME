# ScarletDME

This is a fork of [Gene's ScarletDME repo](https://github.com/geneb/ScarletDME).

## Installation

Installation should be straightforward. There is a 32 bit target as well but the default is 64bit.

```
git clone https://github.com/Krowemoh/ScarletDME.git
cd ScarletDME
make
sudo make install
```

Enable ScarletDME on boot:

```
sudo systemctl enable scarletdme
```

Start ScarletDME:

```
qm -start
cd /usr/qmsys
qm
```

You should now be at TCL.

## Platforms

I have tested this version on the following systems:

- Alpine Linux
- CentOS 7
- Debian 12
- Tiny Core Linux
- Ubuntu 20.04

## Fork Specific Changelog

This is a list of what I've done since forking.

```
31 JUL 2023 - Hardcoded the terminal type.  
05 AUG 2023 - Added BigNumber support.  
21 AUG 2023 - Updated the Makefile to be more similar to the 64bit version.  
27 SEP 2023 - Merge with upstream/dev to get 64 bit changes.
29 SEP 2023 - Simplify the Makefile and reorganize the project.
```
