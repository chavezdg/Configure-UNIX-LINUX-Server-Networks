#!/bin/bash

# This script is for adding an SSH key to a server.
# Created by David C.

# Variable containing the SSH key:
key="<ADD KEY STRING HERE>"

mkdir -p /root/.ssh
echo "ssh-rsa $key dedicatedServer@siteName.com" >> /root/.ssh/authorized_keys
chmod -R og-rwx /root/.ssh

