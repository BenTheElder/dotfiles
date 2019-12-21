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

- Gnome Disks was used to configure the storage disk to mount to /mnt/storage