#!/bin/sh

################################################################################
unix_starter_kit=/tmp/unix-starter-kit
students_config=students

if [ ! -d $unix_starter_kit ]; then
  echo "Whoa! Where is ${unix_starter_kit}?"
  exit 1
fi

if [ ! -d $students_config ]; then
  echo "Whoa! Where is ${students_config}?"
  exit 1
fi

################################################################################
# Fix a few broken things with Emacs.
if [ -d ~/.emacs.d/rhtml/rhtml ]; then
  # An older version of update.sh didn't update the Unix starter kit
  # submodules and we ended up creating empty directories.
  rm -rf ~/.emacs.d/rhtml
fi

################################################################################
(cd $unix_starter_kit && make)
(cd $students_config  && make)
