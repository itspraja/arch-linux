#!/bin/bash

# Exit on any error
set -e

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Check if a hostname is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi
HOSTNAME=$1

# --- Time and Localization ---
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime  # Change this as required
hwclock --systohc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# --- Hostname ---
echo "$HOSTNAME" > /etc/hostname
cat >> /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF


# --- Root Password ---
echo "Setting ROOT Password"
while true; do
    read -s -p "Root Password: " root_pass
    echo
    read -s -p "Confirm Root Password: " root_pass_confirm
    echo
    if [[ "$root_pass" == "$root_pass_confirm" ]]; then
        echo "root:$root_pass" | chpasswd
        break
    else
        echo "Password Mismatch."
    fi
done


# --- Install Packages ---
echo "Installing Packages"
pacman -S --needed --noconfirm \
    grub efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools avahi xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils \
    dnsmasq dnsutils ethtool iwd modemmanager nss-mdns openssh usb_modeswitch wpa_supplicant xl2tpd pacman-contrib pkgfile rebuild-detector reflector \
    python python-pip nano jdk-openjdk libwnck3 mesa-utils \
    alsa-firmware alsa-plugins alsa-utils \
    pavucontrol pipewire-pulse wireplumber pipewire-alsa pipewire-jack sof-firmware \
    rtkit dmidecode dmraid hdparm hwdetect lsscsi mtools sg3_utils \
    accountsservice bash-completion bluez bluez-utils ffmpegthumbnailer gst-libav gst-plugin-pipewire gst-plugins-bad gst-plugins-ugly libdvdcss libgsf libopenraw plocate \
    poppler-glib xdg-user-dirs xdg-utils efitools haveged nfs-utils nilfs-utils ntp smartmontools unrar unzip xz zip cantarell-fonts \
    hplip python-pillow python-pyqt5 python-reportlab sane cups cups-browsed cups-filters cups-pdf \
    duf findutils glances hwinfo inxi meld nano nano-syntax-highlighting \
    pv python-defusedxml python-packaging rsync wget curl 

# --- GRUB Bootloader ---
echo "Configuring GRUB"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# --- Enable Services ---
echo "Enabling Services"
systemctl enable NetworkManager.service
systemctl enable sshd.service

# --- Create User ---
while true; do
    read -p "Username: " USERNAME
    if [[ ! -z "$USERNAME" ]]; then
        break;
    else
        echo "Username Can Not be Empty!"
    fi
done

while true; do
    read -s -p "Password For $USERNAME: " PASSWORD
    echo
    read -s -p "Confirm Password For $USERNAME: " PASSWORD_CONFIRM
    echo
     if [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]]; then
        break;
    else
        echo "Password Mismatch."
    fi
done

echo "Creating User -> '$USERNAME'..."
useradd -m "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

# --- Sudo Permissions ---
echo "Configuring sudo"
echo "%$USERNAME ALL=(ALL:ALL) ALL" > /etc/sudoers.d/"$USERNAME"
chmod 0440 /etc/sudoers.d/"$USERNAME"


echo "Arch Linux Base Install Complete."
echo "Exit chroot, Unmount partitions, and Reboot."
