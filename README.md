# ScarletDME

This is a heavily reorganized fork of [Gene's ScarletDME repo](https://github.com/geneb/ScarletDME).

## Installation

Installation should be straightforward. There is a 32 bit target as well but the default is 64bit.

```
git clone https://github.com/Krowemoh/ScarletDME.git
cd ScarletDME
make
sudo make install
```

To start and enable ScarletDME on boot:

```
sudo systemctl start scarletdme
sudo systemctl enable scarletdme
```

To test:

```
cd /usr/qmsys
qm
```

This should put you at the tcl.

## Platforms

I have tested this version on the following systems:

- CentOS 7
- Ubuntu 20.04

These platforms require some work as the Makefile doesn't support them.

- Alpine Linux
- Tiny Core Linux

## Fork Specific Changelog

This is a list of what I've done since forking.

```
31 JUL 2023 - Hardcoded the terminal type.  
05 AUG 2023 - Added BigNumber support.  
21 AUG 2023 - Updated the Makefile to be more similar to the 64bit version.  
27 SEP 2023 - Merge with upstream/dev to get 64 bit changes.
29 SEP 2023 - Simplify the Makefile and reorganize project
```
