#!/usr/bin/env bash


# Base tooling needed
sudo pkg install -y ca_root_nss portshaker poudriere bash sudo git

# Config poudriere w/UFS 
sudo bash -c 'cat > /usr/local/etc/poudriere.conf <<EOF
NO_ZFS=yes
FREEBSD_HOST=ftp://ftp.freebsd.org
RESOLV_CONF=/etc/resolv.conf
BASEFS=/usr/local/poudriere
USE_PORTLINT=yes
USE_TMPFS=yes
DISTFILES_CACHE=/usr/ports/distfiles
CHECK_CHANGED_OPTIONS=yes
EOF'
sudo poudriere ports -c -F -f none -M /usr/local/poudriere/ports/default -p default

# Config portshaker to get our repo and merge w/latest fbsd ports
sudo bash -c 'cat > /usr/local/etc/portshaker.conf <<"EOF"
# vim:set syntax=sh:
#---[ Base directory for mirrored Ports Trees ]---
mirror_base_dir="/var/cache/portshaker"
#---[ Directories where to merge ports ]---
ports_trees="default"
use_zfs="no"
poudriere_ports_mountpoint="/usr/local/poudriere/ports"
default_poudriere_tree="default"
default_merge_from="freebsd custom"
EOF'
sudo bash -c 'cat > /usr/local/etc/portshaker.d/custom <<"EOF"
#!/bin/sh
shift
. /usr/local/share/portshaker/portshaker.subr
method="git"
git_clone_uri="https://github.com/kalw/beats-fbsd-port.git"
git_branch="master"
run_portshaker_command $*
EOF'
sudo bash -c 'cat > /usr/local/etc/portshaker.d/freebsd <<"EOF"
#!/bin/sh
shift
. /usr/local/share/portshaker/portshaker.subr
method="portsnap"
run_portshaker_command $*
EOF'
sudo bash -c 'chmod +x /usr/local/etc/portshaker.d/{custom,freebsd}'
sudo bash -c 'PORTSNAP_FLAGS="--interactive" portshaker -U'
sudo bash -c 'PORTSNAP_FLAGS="--interactive" portshaker -M'
sudo mkdir -p /usr/ports/distfiles