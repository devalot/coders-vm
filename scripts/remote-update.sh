#!/bin/sh

################################################################################
coders_vm_dir=/tmp/coders-vm
coders_vm_url=git://github.com/devalot/coders-vm

################################################################################
if [ `id -u` -ne 0 ]; then
  echo "Please run this script with sudo"
  exit 1
fi

################################################################################
if [ ! -d $coders_vm_dir ]; then
  (cd /tmp && git clone $coders_vm_url) || exit 1
  (cd $coders_vm_dir && git submodule update --init) || exit 1
else
  (cd $coders_vm_dir && git checkout master && git pull) || exit 1
  (cd $coders_vm_dir && git submodule update --init)     || exit 1
fi

################################################################################
(cd $coders_vm_dir && scripts/update.sh)
