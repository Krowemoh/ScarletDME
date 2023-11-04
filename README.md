# ScarletDME

ScarletDME is a multivalue database that is an open source version of OpenQM 2.6.

This is a fork of [geneb's ScarletDME repo](https://github.com/geneb/ScarletDME).

## Installation

ScarletDME is built with zig. There is a install script that is included in the utils directory that will install ScarletDME.

```
git clone https://github.com/Krowemoh/ScarletDME.git
cd ScarletDME
zig build
sudo utils/install.sh
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

## Links

The manual for OpenQM is available on the wiki.

[Wiki](https://scarlet.deltasoft.com/index.php/Documentation)

[Discord](https://discord.gg/H7MPapC2hK)


## Fork Specific Changelog

This is a list of what I've done since forking:

```
31 JUL 2023 - Hardcoded the terminal type.  
05 AUG 2023 - Added BigNumber support.  
21 AUG 2023 - Updated the Makefile to be more similar to the 64bit version.  
27 SEP 2023 - Merge with upstream/dev to get 64 bit changes.
29 SEP 2023 - Simplify the Makefile and reorganize the project.
30 SEP 2023 - Added interop with Zig.
26 OCT 2023 - BigNumber support is now in Zig.
27 OCT 2023 - Changed mark_mapping to be a byte instead of a bitfield.
03 NOV 2023 - Rewrote op_time (TIME()) in Zig
```

## Zig Installation

A very quick guide to getting zig installed. This project uses Zig v11.

```
wget https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz
tar xvf zig-linux-x86_64-0.11.0.tar.xz
ln -s /root/zig-linux-x86_64-0.11.0/zig /usr/bin/zig
```


