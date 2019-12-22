# Server Setup

This directory contains my common home server setup scripts.

I run `bootstrap.sh` on a clean debian install to get things configured,
after installing git and cloning this repo.

These scripts assume my user is `bentheelder`.

TODO:
- automate configuring grub with timeout = 0
- automate installing nvidia drivers
 - make sure to install `libnvidia-encode1`
- automate mounting storage disks?
- automate plex configuration

## Notes

- Gnome Disks was used to configure the first storage disk to mount to /mnt/storage

### ZFS Setup

```
# identify disks for creating the pool
/sbin/fdisk -l

# create the pool (raidz ~= RAID 5)
zpool create -o ashift=12 tank raidz \
  /dev/disk/by-id/ata-WDC_WD100EMAZ-00WJTA0_1EGEEYKZ \
  /dev/disk/by-id/ata-WDC_WD100EMAZ-00WJTA0_1EGG2RVZ \
  /dev/disk/by-id/ata-WDC_WD100EMAZ-00WJTA0_JEK6RT9N

# create filesystem and set mountpoint
zfs create -o mountpoint=/mnt/storage tank/storage

# enable compression
zfs set compression=lz4 tank
```
