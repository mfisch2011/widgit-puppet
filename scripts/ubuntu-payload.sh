#!/bin/bash

$HOSTNAME=$1

#bootstrap chroot
debootstrap focal /mnt

#set hostname for chroot
echo HOSTNAME > /mnt/etc/hostname

#update host names for chroot
echo "127.0.1.1    $HOSTNAME" >> /mnt/etc/hosts

#TODO:how to reliabily parse out network adapter name???
#ip addr show
NETWORK_ADAPTER="wlp3s0"
DHCP4="true"
cat > /mnt/etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    $NETWORK_ADAPTER:
      dhcp4: $DHCP4
EOF

#setup apt sources
cat > /mnt/etc/apt/sources.list << EOF
deb http://archive.ubuntu.com/ubuntu focal main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu focal-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu focal-security main restricted universe multiverse
EOF

#put stage2 into chroot
mv payload-stage2.sh /mnt

$setup devices in chroot
mount --rbind /dev  /mnt/dev
mount --rbind /proc /mnt/proc
mount --rbind /sys  /mnt/sys
chroot /mnt /usr/bin/env DISK=$DISK UUID=$UUID bash --login
