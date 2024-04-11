#!/bin/bash

# Join node into the Tailnet (not required for anything in production, but useful for testing)

# Check /root/.config/age/key.txt exists
if [ ! -f /root/.config/age/key.txt ]; then
  echo "age secret key not found at /root/.config/age/key.txt"
  exit 1
fi

# Get Tailscale key from age encrypted file
TSKEY=$(cat /root/secrets/tailscale-key.age | age --decrypt -i /root/.config/age/key.txt)

tailscale up --authkey $TSKEY --hostname $ZONE --advertise-exit-node 

exit 0
