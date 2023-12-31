# Arch Install

The content of this document and accompanying script is a personal guide developed for installing Arch Linux. While it is recommended to refer to the [Official Installation Guide](https://wiki.archlinux.org/title/Installation_guide), you are free to utilize any information provided here in a manner that suits your needs.

- [Arch Install](#arch-install)
  - [Pre-Installation](#pre-installation)
    - [Notes](#notes)
    - [Keyboard Layout (Optional)](#keyboard-layout-optional)
    - [Update the system clock](#update-the-system-clock)
    - [Partitions (Encrypted with LVM on LUKS)](#partitions-encrypted-with-lvm-on-luks)
      - [Erase all data on disk (Optional)](#erase-all-data-on-disk-optional)
      - [Preparing the disk](#preparing-the-disk)
      - [Preparing the logical volumes](#preparing-the-logical-volumes)
      - [Preparing the boot partition](#preparing-the-boot-partition)
      - [Continue the installation](#continue-the-installation)
      - [Configuring mkinitcpio](#configuring-mkinitcpio)
      - [Configuring the boot loader](#configuring-the-boot-loader)
        - [GRUB](#grub)
        - [Systemd-boot](#systemd-boot)
  - [Installation](#installation)
    - [Select The Mirrors](#select-the-mirrors)
    - [Install Essential Packages](#install-essential-packages)
    - [Generate fstab](#generate-fstab)
    - [Chroot](#chroot)
    - [Scripted Installation](#scripted-installation)

## Pre-Installation

Before proceeding with the installation of Arch Linux, it is important to follow a series of preliminary steps to ensure a smooth and successful installation process.

### Notes

The Arch Linux installation images do not include built-in support for Secure Boot. However, you can manually set up Secure Boot after completing the installation if desired.

### Keyboard Layout (Optional)

To configure the keyboard layout, (e.g., us-acentos), use the following command:

```bash
#!/bin/bash

loadkeys us-acentos
```

### Update the system clock

To ensure the system clock is accurate use timedatectl command in Linux:

```bash
#!/bin/bash

timedatectl set-ntp on
```

### Partitions (Encrypted with LVM on LUKS)

By utilizing LVM (Logical Volume Manager) within a single LUKS (Linux Unified Key Setup) encrypted partition, you can achieve enhanced partitioning flexibility. This approach allows you to dynamically manage and resize logical volumes within the encrypted container, providing greater control over your storage allocation. With LVM, you can create multiple logical volumes, such as for the root filesystem, home directory, and other data partitions, all securely housed within the LUKS encryption. This setup enables easier management and resizing of partitions without compromising the overall security provided by LUKS encryption.

#### Erase all data on disk (Optional)

Prior to encrypting the partition or entire device, it is recommended to create a temporary encrypted container to wipe all data still in the disk. You can consider changing the cipher used from the standard aes-cbc to aes-xts, as it may provide improved performance. It's advisable to verify the performance comparison using the `cryptsetup benchmark` command.

```bash
#!/bin/bash

cryptsetup open --type plain -d /dev/urandom /dev/<block-device> to_be_wiped
```

Wipe the container with zeros. A use of `if=/dev/urandom` is not required as the encryption cipher is used for randomness.

```bash
#!/bin/bash

dd if=/dev/zero of=/dev/mapper/to_be_wiped status=progress
```

Finally, close the temporary container:

```bash
#!/bin/bash

cryptsetup close to_be_wiped
```

#### Preparing the disk

Use `fdisk` or to modify partition tables. Create a partition to be mounted at `/boot` with a size of 512 MiB or more and another partition (Linux LVM) which will later contain the encrypted container.

```bash
#!/bin/bash

fdisk /dev/nvme0n1
```

Create the LUKS encrypted container at the designated partition. Enter the chosen password twice.

```bash
#!/bin/bash

cryptsetup luksFormat /dev/nvme0n1p2
```

Open the container and the decrypted container will be available at `/dev/mapper/lvm`:

```bash
#!/bin/bash

cryptsetup open /dev/nvme0n1p2 lvm
```

#### Preparing the logical volumes

Create a physical volume on top of the opened LUKS container:

```bash
#!/bin/bash

pvcreate /dev/mapper/lvm
```

Create a volume group (e.g., vg0) and add the previously created physical volume to it:

```bash
#!/bin/bash

vgcreate vg0 /dev/mapper/lvm
```

Create all your logical volumes on the volume group:

```bash
#!/bin/bash

lvcreate -L 8G vg0 -n swap
lvcreate -L 32G vg0 -n root
lvcreate -l 100%FREE vg0 -n home

# leave at least 256 MiB free space in the volume group to allow using e2scrub

lvreduce -L -256M vg0/home
```

Format your file systems on each logical volume:

```bash
#!/bin/bash

mkfs.ext4 -L ROOT /dev/vg0/root
mkfs.ext4 -L HOME /dev/vg0/home
mkswap -L SWAP /dev/vg0/swap
```

Mount your file systems:

```bash
#!/bin/bash

mount /dev/vg0/root /mnt
mount --mkdir /dev/vg0/home /mnt/home
swapon /dev/vg0/swap
```

#### Preparing the boot partition

Create a file system on the partition intended for /boot and mount the partition to /mnt/boot:

```bash
#!/bin/bash

mkfs.fat -n BOOT-EFI -F 32 /dev/nvme0n1p1
mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

#### Continue the installation

At this point resume the common [Installation steps](#installation) and return to the [next section](#configuring-mkinitcpio) to customize the Initramfs and Boot loader steps.

#### Configuring mkinitcpio

Make sure the `lvm2` package is installed and add the `keyboard`, `encrypt` and `lvm2` hooks to mkinitcpio.conf.

```bash
#!/bin/bash

EDITOR /etc/mkinitcpio.conf
```

```markdown
HOOKS=(base `udev` autodetect modconf kms `keyboard` `keymap` `consolefont` block `encrypt` `lvm2` filesystems fsck)
```

Regenerate the initramfs after saving the changes.

```bash
#!/bin/bash

mkinitcpio -p linux  # Or linux-lts
```

#### Configuring the boot loader

In order to unlock the encrypted root partition at boot, the following kernel parameter needs to be set on the boot loader `cryptdevice=UUID=DEVICE_UUID:lvm`:

##### GRUB

```bash
#!/bin/bash
$ blkid | grep "nvme0n1p2"
/dev/nvme0n1p1: LABEL="ROOT" UUID="e8bdb9ea-134f-47aa-9c4f-459a4a60acaa"...

# GRUB
$ cat /etc/default/grub
[...]
GRUB_CMDLINE_LINUX="cryptdevice=UUID=e8bdb9ea-134f-47aa-9c4f-459a4a60acaa:lvm root=LABEL=ROOT"
[...]

$ grub-mkconfig -o /boot/grub/grub.cfg
```

##### Systemd-boot

```bash
#!/bin/bash
$ cat /boot/loader/entries/arch.conf

title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options cryptdevice=UUID=e8bdb9ea-134f-47aa-9c4f-459a4a60acaa:lvm root=LABEL=ROOT rw

$ cat /boot/loader/entries/arch-fallback.conf

title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux-fallback.img
options cryptdevice=UUID=e8bdb9ea-134f-47aa-9c4f-459a4a60acaa:lvm root=LABEL=ROOT rw
```

## Installation

The following section provides guidance on installing Arch Linux. It covers the necessary steps and instructions to successfully install the operating system on your system.

### Select The Mirrors

Use `reflector` to automatically update `/etc/pacman.d/mirrorlist`:

```bash
#!/bin/bash

reflector --country COUNTRY,
```

### Install Essential Packages

Use pacstrap to install the base package, Linux kernel, firmware for common hardware and other packages. If you encrypted your device or partition, make sure to also install `lvm2`:

```bash
#!/bin/bash

pacstrap -K /mnt base base-devel linux linux-firmware linux-firmware-qlogic sof-firmware vim git dhcpcd openssh lvm2
```

### Generate fstab

Generate an fstab file (use -U or -L to define by UUID or labels, respectively):

```bash
#!/bin/bash

genfstab -L /mnt >> /mnt/etc/fstab
```

### Chroot

Change root into the new system:

```bash
#!/bin/bash

arch-chroot /mnt
```

### Scripted Installation

Use the file `./install` to automatically configure Arch Linux, or follow the [Official Installation Guide#Configure the system](https://wiki.archlinux.org/title/Installation_guide#Configure_the_system).
