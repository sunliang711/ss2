#!/bin/bash

if ! command -v pacman >/dev/null 2>&1;then
    echo "Only support archlinux currently!"
    exit 1
fi

#step 1
sudo cp rc.local /etc/rc.local

#step 2
sudo cp rc-local.service /usr/lib/systemd/system/rc-local.service

#step 3 enable service
sudo systemctl enable rc-local
