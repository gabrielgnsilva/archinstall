# Arch Install

This document is a guide and script developed for my own use for installing Arch Linux.
Please, refer to the [Official Installation Guide](https://wiki.archlinux.org/title/Installation_guide), but feel free to use any information in this repository as you see fit.

## Pre-Installation

### Notes

Arch Linux installation images do not support Secure Boot. If desired, Secure Boot can be set up after completing the installation.

### Keyboard Layout (Optional)

To set the keyboard layout to "us-acentos" use:

```bash
#!/bin/bash
$ loadkeys us-acentos
```

### Update the system clock

Use timedatectl(1) to ensure the system clock is accurate:

```bash
#!/bin/bash
$ timedatectl
```

### Partitions

Use `fdisk` or to modify partition tables:

```bash
#!/bin/bash
$ fdisk /dev/DEVICE
```

Set the following size for each partition:

```text
/         - "112690M"
/boot/efi - "807M"
/swap     - "16434"
/home     - "*M"
```

#### Partition Layouts

```bash
#!/bin/bash
$ mkfs.ext4   -L ROOT             /dev/PARTITION
$ mkfs.fat    -n BOOT-EFI -F 32   /dev/PARTITION
$ mkswap      -L SWAP             /dev/PARTITION
$ mkfs.ext4   -L HOME             /dev/PARTITION
```

#### Mount The File Systems

Mount the partitions volumes to `/mnt`:

```bash
#!/bin/bash
$ mount --mkdir /dev/ROOT-PARTITION /mnt
$ mount --mkdir /dev/BOOT-PARTITION /mnt/boot/efi
$ mount --mkdir /dev/HOME-PARTITION /mnt/home
$ swapon /dev/SWAP-PARTITION
```

## Installation

### Select The Mirrors

Use `reflector` to automatically update `/etc/pacman.d/mirrorlist`:

```bash
#!/bin/bash
$ reflector --country Brazil,
```

### Install Essential Packages

Use pacstrap to install the base package, Linux kernel,firmware for common hardware and other packages:

```bash
#!/bin/bash
$ pacstrap -K /mnt base base-devel linux linux-firmware linux-firmware-qlogic sof-firmware micro git dhcpcd
```

## Configure The System

### Generate fstab

Generate an fstab file (use -U or -L to define by UUID or labels, respectively):

```bash
#!/bin/bash
$ genfstab -L /mnt >> /mnt/etc/fstab
```

### Chroot

Change root into the new system:

```bash
#!/bin/bash
$ arch-chroot /mnt
```

### Scripted Configuration

Use the file `./install` to automatically configure Arch Linux, or follow the [Official Installation Guide](https://wiki.archlinux.org/title/Installation_guide).
