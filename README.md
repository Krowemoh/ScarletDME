# ScarletDME

ScarletDME is a fork of OpenQM 2.6.

This fork is one where I am adding and modifying things to work for me. The changes are listed below.

## Installation

<<<<<<< HEAD
Below are the prerequisite packages you may need to install as this version of ScarletDME is 32 bit.

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

Add a user to the qmusers group to allow access to ScarletDME:

```
sudo usermod -a -G qmusers username
```

## Prerequisites

### Debian and Ubuntu

```
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install gcc-multilib libcrypt-dev:i386 libssl-dev:i386
```

### CentOS and Red Hat

```
yum install openssl-devel.i686
```

## Platforms

I have tested this version on the following systems:

- CentOS 7
- Ubuntu 20.04

These platforms require some work as the Makefile doesn't support them.

- Alpine Linux
- Tiny Core Linux

## changelog

```
31 JUL 2023 - Hardcoded the terminal type.  
05 AUG 2023 - Added BigNumber support.  
21 AUG 2023 - Updated the Makefile to be more similar to the 64bit version.  
```
