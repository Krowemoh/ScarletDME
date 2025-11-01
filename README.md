# ScarletDME

ScarletDME is a multivalue database that is an open source version of OpenQM 2.6.

This is a fork of [geneb's ScarletDME repo](https://github.com/geneb/ScarletDME).

The goal of this fork is to develop future features in Zig instead of C.

## Installation

ScarletDME is built with zig. There is a install script that is included in the utils directory that will install ScarletDME.

```
git clone https://github.com/Krowemoh/ScarletDME.git
cd ScarletDME
zig build
sudo utils/install.sh
```

There is an installation script for mac specifically:

```
sudo utils/install-mac.sh
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

## Zig Installation

This project uses Zig 0.15.0.

Linux:

```
wget https://ziglang.org/download/0.15.1/zig-x86_64-linux-0.15.1.tar.xz
tar xvf zig-x86_64-linux-0.15.1.tar.xz
ln -s /root/zig-x86_64-linux-0.15.1/zig /usr/bin/zig
```

Mac:

```
wget https://ziglang.org/download/0.15.1/zig-aarch64-macos-0.15.1.tar.xz
tar xvf zig-aarch64-macos-0.15.1.tar.xz
ln -s /Users/username/bp/zig-aarch64-macos-0.15.1/zig /usr/local/bin/zig
```

## Links

The manual for OpenQM is available on the wiki.

[Wiki](https://scarlet.deltasoft.com/index.php/Documentation)

[Discord](https://discord.gg/H7MPapC2hK)

[ScarletDME Google Group](https://groups.google.com/g/scarletdme/)


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
04 NOV 2023 - Added new mode, TIME.MS, to get time with milliseconds
08 NOV 2023 - Added secure sockets using mbedtls
13 NOV 2023 - Added forking support
03 DEC 2023 - Added support for MacBook
03 MAY 2024 - Removed forking
15 JUL 2024 - Upgraded from Zig 0.11.0 to 0.12.0
08 AUG 2024 - Upgraded from Zig 0.12.0 to 0.13.0
11 SEP 2024 - BP created and NPM, NSH and EVA are loaded for new accounts
04 SEP 2025 - Removed secure sockets and mbedtls dependency
            - Upgraded from Zig 0.13.0 to 0.14.0
            - Upgraded from Zig 0.14.0 to 0.15.0
17 SEP 2025 - Set SIGPIPE to be ignored globlly
19 SEP 2025 - Set SIGPIPE to be ignored locally
01 NOV 2025 - Cherry picked from geneb and mbuller to change filenames to '%0' 
```


