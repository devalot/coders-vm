#!/bin/sh

################################################################################
coders_vm_dir=/tmp/coders-vm
coders_vm_url=git://github.com/devalot/coders-vm
log_file=/tmp/coders-vm-remote-update.log

################################################################################
exec 4>&1 # save STDOUT so we can restore in die()
exec > $log_file 2>&1
set -x

################################################################################
die () {
  exec 1>&4
  echo "==> !!! An error occurred while updating the VM !!! <=="
  echo -e "$@"
  echo "More information in $log_file"
  exit 1
}

################################################################################
if [ `id -u` -ne 0 ]; then
  die "Please run this script with sudo"
fi

################################################################################
echo "==> Preparing for virtual machine update..." 1>&4

################################################################################
if [ ! -d $coders_vm_dir ]; then
  (cd /tmp && git clone $coders_vm_url)                  || die "clone failed"
  (cd $coders_vm_dir && git submodule update --init)     || die "sb init failed"
else
  (cd $coders_vm_dir && git checkout master && git pull) || die "pull failed"
  (cd $coders_vm_dir && git submodule update --init)     || die "sb update failed"
fi

################################################################################
exec 1>&4
(cd $coders_vm_dir && scripts/update.sh)
