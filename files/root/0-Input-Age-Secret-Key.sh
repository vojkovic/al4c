#!/bin/bash

# Asks user for age secret key and outputs file to /root/.config/age/key.txt

echo "Enter the age secret key:"
read AGE_KEY

# Create directory if it doesn't exist
mkdir -p /root/.config/sops/age

# Write age key to file
echo "$AGE_KEY" > /root/.config/age/key.txt
chmod 600 /root/.config/age/key.txt

echo "age secret key written to /root/.config/age/key.txt"

exit 0
