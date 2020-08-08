#!/bin/bash

DISK=/dev/disk/by-id/ata???

zpool create -o ashift=12 -d -o feature@async_destroy=enabled -o feature@bookmarks=enabled -o feature@embedded_data=enabled -o feature@empty_bpobj=enabled -o feature@enabled_txg=enabled -o feature@extensible_dataset=enabled -o feature@filesystem_limits=enabled -o feature@hole_birth=enabled -o feature@large_blocks=enabled -o feature@lz4_compress=enabled -o feature@spacemap_histogram=enabled -o feature@zpool_checkpoint=enabled -O acltype=posixacl -O canmount=off -O compression=lz4 -O devices=off -O normalization=formD -O relatime=on -O xattr=sa -O mountpoint=/boot -R /mnt bpool ${DISK}-part3

zpool create -o ashift=12 -O acltype=posixacl -O canmount=off -O compression=lz4 -O dnodesize=auto -O normalization=formD -O relatime=on -O xattr=sa -O mountpoint=/ -R /mnt rpool ${DISK}-part4

zfs create -o canmount=off -o mountpoint=none rpool/ROOT
zfs create -o canmount=off -o mountpoint=none bpool/BOOT

UUID=$(dd if=/dev/urandom of=/dev/stdout bs=1 count=100 2>/dev/null | tr -dc 'a-z0-9' | cut -c-6)

zfs create -o canmount=noauto -o mountpoint=/ -o com.ubuntu.zsys:bootfs=yes -o com.ubuntu.zsys:last-used=$(date +%s) rpool/ROOT/ubuntu_$UUID
zfs mount rpool/ROOT/ubuntu_$UUID

zfs create -o canmount=noauto -o mountpoint=/boot bpool/BOOT/ubuntu_$UUID
zfs mount bpool/BOOT/ubuntu_$UUID 

zfs create -o com.ubuntu.zsys:bootfs=no rpool/ROOT/ubuntu_$UUID/srv
zfs create -o com.ubuntu.zsys:bootfs=no -o canmount=off rpool/ROOT/ubuntu_$UUID/usr
zfs create rpool/ROOT/ubuntu_$UUID/usr/local
zfs create -o com.ubuntu.zsys:bootfs=no -o canmount=off rpool/ROOT/ubuntu_$UUID/var
zfs create rpool/ROOT/ubuntu_$UUID/var/games
zfs create rpool/ROOT/ubuntu_$UUID/var/lib
zfs create rpool/ROOT/ubuntu_$UUID/var/lib/AccountsService
zfs create rpool/ROOT/ubuntu_$UUID/var/lib/apt
zfs create rpool/ROOT/ubuntu_$UUID/var/lib/dpkg
zfs create rpool/ROOT/ubuntu_$UUID/var/lib/NetworkManager
zfs create rpool/ROOT/ubuntu_$UUID/var/log
zfs create rpool/ROOT/ubuntu_$UUID/var/mail
zfs create rpool/ROOT/ubuntu_$UUID/var/snap
zfs create rpool/ROOT/ubuntu_$UUID/var/spool
zfs create rpool/ROOT/ubuntu_$UUID/var/www

zfs create -o canmount=off -o mountpoint=/ rpool/USERDATA
zfs create -o com.ubuntu.zsys:bootfs-datasets=rpool/ROOT/ubuntu_$UUID -o canmount=on -o mountpoint=/root rpool/USERDATA/root_$UUID
zfs create -o com.ubuntu.zsys:bootfs=no rpool/ROOT/ubuntu_$UUID/tmp
chmod 1777 /mnt/tmp

