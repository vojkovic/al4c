# Arch Linux For Containers

An extremely minimal Arch Linux image as a base OS for me to run containers on vultr high frequency compute. Assumes a lot of things, like you're running on Vultr, you're using bgp, you have a single drive at /dev/vda, etc. This is not a general purpose Arch Linux image. 

## Checklist
- [x] Auto installs itself from an ISO with 0 human interaction.
- [x] Automatic updates via systemd.
- [x] yay installed.
- [x] k3s installation.
- [x] Tailscale automatic installation and onboarding.
- [x] Under 180 packages installed.
- [x] Dummy network interface for BGP.
- [x] BIRD installed & configured. Include static routes.
- [x] dhcpcd installed & running.
- [x] install misc basic utilities (mtr, btop, curl, vim, etc.)
- [x] grub ready to go.
- [x] xanmod v3 kernel

