#!/bin/sh

if [ ! -r scripts/remote-update.sh ]; then
  echo "Whoa! I don't see the scripts/remote-update.sh file"
  exit 1
fi

mussh -H config/ip-addresses -l root -C scripts/remote-update.sh
