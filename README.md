# Arch Linux For Containers

An extremely minimal Arch Linux image as a base OS for me to run containers on vultr high frequency compute. Assumes a lot of things, like you're running on Vultr, you're using bgp, you have a single drive at /dev/vda, etc. This is not a general purpose Arch Linux image. 

TODO:
- [ ] Auto installs itself from an ISO with 0 human interaction.
- [ ] Automatic updates via cron.
- [ ] yay installed.
- [ ] OpenVPN preinstalled & running. client.ovpn in root home directory.
- [ ] Encrypted /var/log partition.
- [ ] SSHD harderned, started and loaded with public keys.
- [ ] Dummy network interface for BGP.
- [ ] BIRD installed & configured. (via Vultr API). Include static routes.
- [ ] dhcpcd installed & running.
- [ ] helm & helmfile installed.
- [ ] install misc basic utilities (mtr, btop, curl, vim, etc.)
- [ ] grub ready to go.
- [ ] xanmod v3 kernel