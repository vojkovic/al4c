# Install linux-xanmod as a prebuilt binary
yay -S --answerclean All --answerdiff None --noconfirm linux-xanmod-bin

# initramfs
mkinitcpio -P

# boot loader
grub-mkconfig -o /boot/grub/grub.cfg
