#!/bin/sh

################################################################################
# Update a DaVinci Coders virtual machine with the latest settings.
if [ `id -u` -ne 0 ]; then
  echo "Please run this script using sudo.  For example:"
  echo "  sudo scripts/update.sh"
  exit 1
fi

################################################################################
if [ ! -r packages/aptitude.pkgs ]; then
  echo "Please run this from the top of the repository."
  exit 1
fi

################################################################################
message () {
  echo "==> $@"
}

################################################################################
die () {
  echo "==> !!! ERROR: $@ !!! <=="
  exit 1
}

################################################################################
force_date_fix () {
  if ! which ntpdate > /dev/null 2>&1; then
    apt-get -qy install ntpdate > /dev/null
  fi

  ntpdate 0.debian.pool.ntp.org > /dev/null
}

################################################################################
maybe_purge_debian_ruby () {
  if [ `aptitude search ruby | grep ^i | wc -l` -gt 0 ]; then
    message "Purging existing Ruby installation"

    for pkg in `aptitude search ruby| grep ^i|sed 's/^i A*//'|awk '{print $1}'`; do
      apt-get -qy --purge purge $pkg > /dev/null
    done

    apt-get -qy autoremove > /dev/null
  fi
}

################################################################################
update_packages () {
  message "Updating software packages"

  touch grunt/debian/apt/squeeze/*.pref
  touch packages/aptitude.pkgs

  (cd apt && make) > /dev/null \
    || die "updating apt files failed"

  (cd packages && make /etc/aptitude.pkgs-installed) > /dev/null \
    || die "updating packages failed"

  # This breaks the VM right now :(
  # apt-get -qy dist-upgrade > /dev/null \
  #   || die "dist-upgrade failed"
}

################################################################################
install_ruby () {
  if ! which ruby > /dev/null 2>&1; then
    message "Installing Ruby"
    grunt/generic/bin/build-ruby.sh || die "failed to install ruby"
  fi

  message "Updating Gems"
  (cd packages && make /etc/gem.pkgs-installed) > /dev/null 2>&1 \
    || die "failed to install all Ruby gems"
}

################################################################################
update_root_authorized_keys () {
  root_home=/root

  mkdir -p $root_home/.ssh
  cp /home/pjones/.ssh/authorized_keys $root_home/.ssh/authorized_keys
  chmod 750 $root_home/.ssh
  chmod 600 $root_home/.ssh/authorized_keys
}

################################################################################
update_other_files () {
  make > /dev/null
}

################################################################################
update_student_configs () {
  unix_starter_kit=/tmp/unix-starter-kit
  coders_vm=`pwd`
  script=scripts/install-user-configs.sh
  message "Updating student configuration files"

  if [ ! -d $unix_starter_kit ]; then
    (cd /tmp && git clone git://pmade.com/unix-starter-kit) > /dev/null 2>&1 \
      || die "failed to download the Unix starter kit"
  else
    (cd $unix_starter_kit && git pull) > /dev/null 2>&1 \
      || die "failed to update the Unix starter kit"
  fi

  for user in `ls /home`; do
    if [ -d /home/$user ]; then
      name=`getent passwd $user|awk -F: '{print $5}'|awk -F, '{print $1}'`
      message "Updating configuration for $name"
      su $user -c "(cd $coders_vm && sh $script)" > /dev/null
    fi
  done
}

################################################################################
message "Updating.  This may take some time, please be patient."

################################################################################
force_date_fix
maybe_purge_debian_ruby
update_packages
install_ruby
update_root_authorized_keys
update_other_files
update_student_configs

################################################################################
message "Update complete.  Please restart your virtual machine."
