#!/usr/bin/env sh

unameOut="$(uname -s)"

case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    MSYS_NT*)   machine=Git;;
    *)          machine="UNKNOWN:${unameOut}"
esac

if [[ "$machine" == "Linux" ]]; then
    echo "Please use the Linux install script: utils/install.sh"
    exit 0
fi

if [[ "$machine" != "Mac" ]]; then
    echo "This version of ScarletDME hasn't been set up for: $machine"
    exit 0
fi

INSTROOT=/usr/local/qmsys

# Create /usr/local/bin if it doesn't exist

mkdir -p -m 775 /usr/local/bin

# Create QM Group

if dscl . -list /Groups | grep qmusers > /dev/null 2>&1; then
    echo "Group qmusers already exists."
else
    echo "Creating group: qmusers"

    LastGroupID=`dscl . -list /Groups PrimaryGroupID | awk '{print $2}' | sort -n | tail -1`
    NextGroupID=$((LastGroupID + 1))

    dscl . create /Groups/qmusers
    dscl . create /Groups/qmusers RealName qmusers
    dscl . create /Groups/qmusers gid $NextGroupID
fi

# Create QM User

if dscl . -list /Users | grep qm > /dev/null 2>&1; then
    echo "User qmsys already exists."
else
    echo "Creating user: qmsys"

    LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
    NextID=$((LastID + 1))

    GroupID=`dscl . -list /Groups PrimaryGroupID | grep qmusers | awk '{print $2}' | sort -n | tail -1`

    dscl . create /Users/qmsys
    dscl . create /Users/qmsys RealName qmsys
    dscl . create /Users/qmsys UniqueID $NextID
    dscl . create /Users/qmsys PrimaryGroupID $GroupID
fi

# Create systemd service

# Create xinetd service

# Create terminfo

echo "Building qmsys/terminfo"
mkdir -p qmsys/terminfo
(cd qmsys && ../zig-out/bin/qmtic -pterminfo ../utils/terminfo.src > /dev/null)

# Set up master QM account

echo "Setting up $INSTROOT"
rm -Rf "$INSTROOT"
cp -R qmsys "$INSTROOT"
chown -R qmsys:qmusers "$INSTROOT"
chmod -R 664 "$INSTROOT"
find "$INSTROOT" -type d -print0 | xargs -0 chmod 775

# Copy binaries to the qm account

echo "Installing binaries to $INSTROOT"
mkdir "$INSTROOT/bin"
cp zig-out/bin/* "$INSTROOT/bin"
cp utils/pcode "$INSTROOT/bin/pcode"
chown qmsys:qmusers "$INSTROOT/bin" $INSTROOT/bin/*
chmod 775 "$INSTROOT/bin" $INSTROOT/bin/*

mkdir "$INSTROOT/gplsrc"
cp gplsrc/err.h "$INSTROOT/gplsrc"
cp gplsrc/opcodes.h "$INSTROOT/gplsrc"
cp gplsrc/revstamp.h "$INSTROOT/gplsrc"

# Copy QM configuration to /etc

echo "Creating /etc/scarlet.conf"
cp utils/scarlet.conf /etc/scarlet.conf
chmod 644 /etc/scarlet.conf

# Make qm available to all users

echo "Adding qm to /usr/local/bin"
ln -sf /usr/local/qmsys/bin/qm /usr/local/bin/qm
