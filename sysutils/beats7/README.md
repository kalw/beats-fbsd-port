# beats-fbsd-port [![Build Status](https://api.cirrus-ci.com/github/kalw/beats-fbsd-port.svg)](https://cirrus-ci.com/github/kalw/beats-fbsd-port)

## Quick way
```
# get the box version you aim to build 
vagrant init freebsd/FreeBSD-11.4-RELEASE \
  --box-version 2018.06.22
vagrant up
vagrant ssh

# install build tools
$ sudo pkg install -y go gmake ca_root_nss mage git

# get ports
$ sudo portsnap fetch extract

# fetch the latest port version 
$ git clone https://github.com/elastic/beats.git

# build and package
$ cd beats/sysutils/beats7
$ sudo ALLOW_UNSUPPORTED_SYSTEM=yes BATCH=yes make package
```

## Proper way
```
# Get the box version you aim to build 
vagrant init freebsd/FreeBSD-11.3-STABLE
vagrant up
vagrant ssh

# Install build tools
sudo pkg install -y go gmake ca_root_nss portshaker poudriere bash sudo git

# Config poudriere
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

# Get ports
sudo poudriere ports -c -F -f none -M /usr/local/poudriere/ports/default -p default

# Config options for beats7-7.6.2
sudo bash -c 'mkdir -p /usr/local/etc/poudriere.d/options/sysutils_beats7/'
sudo bash -c 'cat > /usr/local/etc/poudriere.d/options/sysutils_beats7/options <<EOF
_OPTIONS_READ=beats7-7.6.2
_FILE_COMPLETE_OPTIONS_LIST=AUDITBEAT FILEBEAT HEARTBEAT METRICBEAT PACKETBEAT
OPTIONS_FILE_SET+=AUDITBEAT
OPTIONS_FILE_SET+=FILEBEAT
OPTIONS_FILE_SET+=HEARTBEAT
OPTIONS_FILE_SET+=METRICBEAT
OPTIONS_FILE_SET+=PACKETBEAT
EOF'

# Config portshaker to merge ports trees
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

# Merge port trees
sudo bash -c 'chmod +x /usr/local/etc/portshaker.d/{beat7,freebsd}'
sudo bash -c 'PORTSNAP_FLAGS="--interactive" portshaker -U'
sudo bash -c 'PORTSNAP_FLAGS="--interactive" portshaker -M'
sudo mkdir -p /usr/ports/distfiles

# Play with your port
$ cd /usr/local/poudriere/ports/default/sysutils/beat7
```

Lint your port with poudriere example
```
sudo bash -c 'echo "BATCH=yes" > /usr/local/etc/poudriere.d/112amd64-make.conf'
sudo bash -c 'echo "ALLOW_UNSUPPORTED_SYSTEM=yes" >> /usr/local/etc/poudriere.d/112amd64-make.conf'
sudo poudriere jail -c -j 112amd64 -v 11.2-RELEASE -a amd64
sudo poudriere testport -j 112amd64 -p default sysutils/beats7
sudo poudriere bulk -j 112amd64 -p default sysutils/beats7
sudo mkdir -p ${CIRRUS_WORKING_DIR}/artefacts/11.2-RELEASE
sudo bash -c 'cd /usr/local/poudriere/ports/default/ ; shar $(find sysutils/beats7/ ) > /usr/local/poudriere/data/packages/*/All/ '

# Get packages and shar
sudo ls /usr/local/poudriere/data/packages/*/All/ 
```
