# Arch Linux For Containers

An extremely minimal Arch Linux image as a base OS for me to run containers on vultr high frequency compute. Assumes a lot of things, like you're running on Vultr, you're using bgp, you have a single drive at /dev/vda, etc. This is not a general purpose Arch Linux image. 

## Checklist
- [-] Auto installs itself from an ISO with 0 human interaction.
- [-] Automatic updates via systemd.
- [-] yay installed.
- [-] SSHD harderned, started and loaded with public keys.
- [-] Dummy network interface for BGP.
- [-] BIRD installed & configured. Include static routes.
- [-] dhcpcd installed & running.
- [-] install misc basic utilities (mtr, btop, curl, vim, etc.)
- [-] grub ready to go.
- [-] xanmod v3 kernel

