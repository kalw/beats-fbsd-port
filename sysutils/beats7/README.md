# beats-fbsd-port [![Build Status](https://api.cirrus-ci.com/github/kalw/beats-fbsd-port.svg)](https://cirrus-ci.com/github/kalw/beats-fbsd-port)

## Quick way
```
# get the box version you aim to build 
vagrant init freebsd/FreeBSD-11.2-RELEASE \
  --box-version 2018.06.22
vagrant up
vagrant ssh

# install build tools
$ sudo pkg install -y go gmake ca_root_nss

# get ports
$ sudo portsnap fetch extract

# fetch the latest port version 
$ fetch https://github.com/kalw/beats-fbsd-port/archive/master.zip
$ unzip master.zip 

# build and package
$ cd beats-fbsd-port*/sysutils/beats7
$ sudo ALLOW_UNSUPPORTED_SYSTEM=yes BATCH=yes make package
```

## Proper way
```
# get the box version you aim to build 
vagrant init freebsd/FreeBSD-11.3-STABLE
vagrant up
vagrant ssh

# install build tools
sudo pkg install -y go gmake ca_root_nss portshaker poudriere bash sudo git
sudo bash -c 'cat > /usr/local/etc/poudriere.conf <<EOF
NO_ZFS=yes
FREEBSD_HOST=ftp://ftp.freebsd.org
RESOLV_CONF=/etc/resolv.conf
BASEFS=/usr/local/poudriere
USE_PORTLINT=no
USE_TMPFS=yes
DISTFILES_CACHE=/usr/ports/distfiles
CHECK_CHANGED_OPTIONS=yes
EOF'
sudo poudriere ports -c -F -f none -M /usr/local/poudriere/ports/default -p default
sudo bash -c 'mkdir -p /usr/local/etc/poudriere.d/options/sysutils_beats7/'
sudo bash -c 'cat > /usr/local/etc/poudriere.d/options/sysutils_beats7/options <<EOF
# Options for beats7-7.6.2
_OPTIONS_READ=beats7-7.6.2
_FILE_COMPLETE_OPTIONS_LIST=AUDITBEAT FILEBEAT HEARTBEAT METRICBEAT PACKETBEAT
OPTIONS_FILE_SET+=AUDITBEAT
OPTIONS_FILE_SET+=FILEBEAT
OPTIONS_FILE_SET+=HEARTBEAT
OPTIONS_FILE_SET+=METRICBEAT
OPTIONS_FILE_SET+=PACKETBEAT
EOF'
sudo bash -c 'cat > /usr/local/etc/portshaker.conf <<"EOF"
# vim:set syntax=sh:
#---[ Base directory for mirrored Ports Trees ]---
mirror_base_dir="/var/cache/portshaker"
#---[ Directories where to merge ports ]---
ports_trees="default"
use_zfs="no"
poudriere_ports_mountpoint="/usr/local/poudriere/ports"
default_poudriere_tree="default"
default_merge_from="freebsd beat7"
EOF'
sudo bash -c 'cat > /usr/local/etc/portshaker.d/beat7 <<"EOF"
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
sudo bash -c 'chmod +x /usr/local/etc/portshaker.d/{beat7,freebsd}'
sudo bash -c 'PORTSNAP_FLAGS="--interactive" portshaker -U'
sudo bash -c 'PORTSNAP_FLAGS="--interactive" portshaker -M'
sudo mkdir -p /usr/ports/distfiles
# play with it
$ cd /usr/local/poudriere/ports/default/sysutils/beat7
```
