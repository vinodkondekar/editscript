#! /bin/sh
#set -x
###############################################################################
#
#                Copyright (c) 2009 eScription, Inc.
#                         All rights reserved
#                    Confidential and Proprietary
#
#    Warning:  This product is protected by United States copyright law.
#              Unauthorized use or duplication of this software, in whole 
#              or in part, is prohibited.
#
#      Author: Ed Brody
#     Created: August 2009
#
# Description: Helper script to create mount points and set directory
#              permissions for the IntelliScript SNT Installer
#
###############################################################################

ESCDIR=$1

# This is where the work is done.
# Any error will set retval to 1
main() {
  retval=0

  info "ESCDIR:  ${ESCDIR:-<Not Set>}"

#            AppName       Directory  Mount         rwx Directories
#            ------------  ---------  -----------   ---------------    
  mountperms EDT           "$ESCDIR"  /eScription   /eScription

 
  exit $retval
}

# Logging functions.  If logging isn't desired, or we want to write
# to stderr, these will be easy to change.
info() {
  echo "mountperms.sh: INFO: $1"
}

warn() {
  echo "mountperms.sh: WARNING: $1"
}

error() {
  echo "mountperms.sh: ERROR: $1"
}

# The mountperms() function:
#  1. Creates the mount directory (not strictly necessary)
#  2. Mounts the Windows directory to the mount directory
#  3. Changes the permissions on specificed directories to be rwx for
#     all users.  This avoids problems when installed by an
#     administrator who is different than the watchdog user.
mountperms() {
  app=$1
  winDir=$2
  mountDir=$3
  shift 3
  rwDirs="$@"

  if [ ! -n "$winDir" ] ; then
    warn "$app directory not defined; skipping directory processing"
    return
  fi

  info "Preparing mounts and permissions for $mountDir = $winDir"

  if [ ! -d "$winDir" ] ; then
    error "$app is not installed at $winDir; skipping"
    retval=1
    return
  fi

  if [ ! -d "$mountDir" ] ; then 
    info "Creating $mountDir"
    /bin/mkdir "$mountDir"
    if [ $? != 0 ] ; then
      error "Error creating $mountDir directory"
      retval=1
    fi
  fi

  /bin/mount -f "$winDir" "$mountDir"
  info "Mounting $mountDir"
  if [ $? != 0 ] ; then
    error "Error mounting $mountDir to $winDir directory"
    retval=1
  fi

  for rwDir in $rwDirs ; do
    info "Changing permissions on $rwDir"
    /bin/chmod -R a+rwX "$rwDir"
    if [ $? != 0 ] ; then
      error "Error changing directory permissions for $rwDir"
      retval=1
    fi
  done
}

# Run the program
main

#############  End of File  ###################################################

