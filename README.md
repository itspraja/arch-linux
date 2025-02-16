# arch-linux
Arch Linux Installation Scripts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

*   Boot from the ISO.
    *   Partition your disk (creating an EFI System Partition).
    *   Format and mount partitions.
    *   Install the base system: `pacstrap /mnt base base-devel linux linux-firmware linux-headers git intel-ucode vim'
    *   Generate fstab: `genfstab -U /mnt >> /mnt/etc/fstab`
    *   Chroot: `arch-chroot /mnt`
    *   Clone this repository:
    ```bash
        git clone https://github.com/itspraja/arch-linux.git
        cd arch-linux
        chmod +x install-base-arch.sh
        ./install-base-arch.sh <HOSTNAME>
    ```
    *   Exit chroot, unmount, and reboot.
  
