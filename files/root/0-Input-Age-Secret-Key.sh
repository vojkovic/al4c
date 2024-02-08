#!/bin/bash

# Asks user for age secret key and outputs file to /root/.config/sops/age/keys.txt

echo "Enter the age secret key:"
read AGE_KEY

# Create directory if it doesn't exist
mkdir -p /root/.config/sops/age

# Write age key to file
echo "$AGE_KEY" > /root/.config/sops/age/keys.txt
chmod 600 /root/.config/sops/age/keys.txt

echo "age secret key written to /root/.config/sops/age/keys.txt"

exit 0
