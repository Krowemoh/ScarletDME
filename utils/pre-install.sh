#!/usr/bin/sh

# Create QM Group

if getent group qmusers > /dev/null 2>&1; then
    echo "Group qmusers already exists."
else
    echo "Creating group: qmusers"

    if command -v groupadd > /dev/null 2>&1; then
        groupadd --system qmusers
        usermod -a -G qmusers root

    elif command -v addgroup > /dev/null 2>&1; then
        addgroup --system qmusers
        adduser root qmusers
    else
        echo "Failed to create qmusers group."
    fi 
fi

# Create QM User

if getent passwd qmsys > /dev/null 2>&1; then
    echo "User qmsys already exists."
else 
    echo "Creating user: qmsys."

    if command -v useradd > /dev/null 2>&1; then
        useradd --system qmsys -G qmusers
    elif command -v adduser > /dev/null 2>&1; then
        adduser --system qmsys -G qmusers
    else
        echo "Failed to create qmsys user."
    fi
fi

# Create systemd service

SYSTEMDPATH=/usr/lib/systemd/system

if [ -f  "$SYSTEMDPATH" ]; then
    if [ -f "$SYSTEMDPATH/scarletdme.service" ]; then
        echo "ScarletDME systemd service is already installed."
    else
        echo "Installing scarletdme.service for systemd."

        cp utils/scarletdme* $SYSTEMDPATH

        chown root:root $SYSTEMDPATH/scarletdme.service
        chown root:root $SYSTEMDPATH/scarletdmeclient.socket
        chown root:root $SYSTEMDPATH/scarletdmeclient@.service
        chown root:root $SYSTEMDPATH/scarletdmeserver.socket
        chown root:root $SYSTEMDPATH/scarletdmeserver@.service

        chmod 644 $SYSTEMDPATH/scarletdme.service
        chmod 644 $SYSTEMDPATH/scarletdmeclient.socket
        chmod 644 $SYSTEMDPATH/scarletdmeclient@.service
        chmod 644 $SYSTEMDPATH/scarletdmeserver.socket
        chmod 644 $SYSTEMDPATH/scarletdmeserver@.service
    fi
fi

# Create xinetd service

if [ -f  "/etc/xinetd.d" ]; then
    if [ -f "/etc/xinetd.d/qmclient" ]; then
        echo "qmclient is already in /etc/xinetd.d/"
    else
        cp utils/qmclient /etc/xinetd.d
        cp utils/qmserver /etc/xinetd.d
    fi

    if cat /etc/services | grep -q qmclient; then
        echo "qmclient is already in services"
    else
        cat utils/services >> /etc/services
    fi
fi
