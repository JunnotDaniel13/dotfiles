# Arch Installations
[Official installation guide](https://wiki.archlinux.org/title/Installation_guide)

## Change the root password 
on the arch installation befor `ssh`ing in the installation using this command
```bash 
passwd
```

## Verify the boot mode
```bash 
cat /sys/firmware/efi/fw_platform_size
```
## Update the system clock
```bash 
timedatectl
```

## Partition the disks
- list the disk on the systems
```bash
lsblk
```
- Partition the disk
```bash
fdisk /dev/name_of_the_disk
```

one partion for the booting and the rest of the space for LVM

## Encrypt the LVM partition
Encrypt it with dm_crypt with LUKS encryption container with cryptsetup with this 

```bash
cryptsetup luksFormat /dev/nvme0n1p2
```

to initialize a LUKS partition

after that open the encrypted partion with this command

```bash
cryptsetup open /dev/nvme0n1p2 cryptlvm
```

Now create a physical volume on top of the open LUKS container

```bash
pvcreate /dev/mapper/cryptlvm 
```

We've created a physical volume now we have to create a volume group

```bash
vgcreate <name_of_the_volume> /dev/mapper/cryptlvm
```

you can also rename it

```bash
vgrename /dev/<actual_name> <new_name>
```

then create the logical volume for the system

- swap memory

```bash
lvcreate -L 16G mimir -n swap
```

- root storage

```bash
lvcreate -L 200G mimir -n root
```

- home storage

```bash
lvcreate -l 100%FREE mimir -n home
```

next is to setup file system for each logical volume

```bash
mkfs.ext4 /dev/mimir/root
```
```bash
mkfs.ext4 /dev/mimir/home
```
```bash
mkswap /dev/mimir/swap
```
mount them

```bash
mount /dev/mimir/root /mnt
```

```bash
mount --mkdir /dev/mimir/home /mnt/home
```

```bash
swapon /dev/mimir/swap
```



Now, we have to prepare the boot partition. Setup the file system for it

```bash
mkfs.fat -F32 /dev/nvme0n1p1
```

then mount it to boot

```bash
mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

resize the home partition

```bash
resize2fs /dev/mimir/home
```

# Install essential packages

```bash
pacstrap -K /mnt base linux linux-firmware 
```

# Configure the system

generate a fstab


```bash
genfstab -U /mnt >> /mnt/etc/fstab 
```

# Chroot
Change root into the new system
```bash
arch-chroot /mnt
```

# Time
Set the time zone

```bash
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
```

Run hwclock(8) to generate /etc/adjtime:
```bash
hwclock --systohc
``` 

Localization
Edit `/etc/locale.gen` and uncomment `en_US.UTF-8 UTF-8` and other needed UTF-8 locales. Generate the locales by running:
```bash
locale-gen
```

```bash
/etc/locale.conf
LANG=en_US.UTF-8
```

install base packages 

```bash
pacman -Syu vim which sudo man-db man-pages texinfo intel-ucode lvm2 
```


## networking

enable networkd 
```bash
systemctl enable systemd-networkd.service
``` 

enable resolved 
```bash
systemctl enable systemd-resolved.service
``` 

Wired adapter using DHCP
create this file `/etc/systemd/network/20-wired.network`
and put this in it
```ts
[Match]
Name=enp1s0

[Link]
RequiredForOnline=routable

[Network]
DHCP=yes
```

setup the Host name
edit this file `/etc/hostname` and put your desired hostname 


# Configuring mkinitcpio
If using a systemd-based initramfs, instead add the keyboard and sd-encrypt hooks. If you use a non-US console keymap or a non-default console font, additionally add the sd-vconsole hook.
```bash
HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```

setup the font

edit /etc/vconsole.conf

Add 
```bash
FONT=latarcyrheb-sun32
```