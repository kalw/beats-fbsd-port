# beats-fbsd-port

## quicker way
```
vagrant init freebsd/FreeBSD-11.2-RELEASE \
  --box-version 2018.06.22
vagrant up
vagrant ssh
$ sudo pkg install -y go gmake ca_root_nss
$ sudo portsnap fetch extract
$ fetch https://github.com/kalw/beats-fbsd-port/archive/master.zip
$ unzip master.zip 
$ cd beats-fbsd-port*
$ sudo ALLOW_UNSUPPORTED_SYSTEM=yes BATCH=yes make package
```

## Proper way
```
vagrant init freebsd/FreeBSD-11.3-STABLE
vagrant up
vagrant ssh
$ sudo pkg install -y go gmake ca_root_nss portshaker poudriere bash sudo git
# heredoc needed
$ sudo -i
$ bash
# configure the merged port tree to work with poudriere and create the apropriate jail test env 
$ cat > /usr/local/etc/poudriere.conf <<EOF
NO_ZFS=yes
FREEBSD_HOST=ftp://ftp.freebsd.org
RESOLV_CONF=/etc/resolv.conf
BASEFS=/usr/local/poudriere
USE_PORTLINT=no
USE_TMPFS=yes
DISTFILES_CACHE=/usr/ports/distfiles
CHECK_CHANGED_OPTIONS=yes
EOF
$ poudriere ports -c -F -f none -M /usr/local/poudriere/ports/default -p default
$ echo "BATCH=yes" > /usr/local/etc/poudriere.d/112amd64-make.conf
$ echo "ALLOW_UNSUPPORTED_SYSTEM=yes" >> /usr/local/etc/poudriere.d/112amd64-make.conf
$ poudriere jail -c -j 112amd64 -v 11.2-RELEASE -a amd64
# create a merged port tree with your port
$ cat > /usr/local/etc/portshaker.conf <<"EOF"
# vim:set syntax=sh:
#---[ Base directory for mirrored Ports Trees ]---
mirror_base_dir="/var/cache/portshaker"
#---[ Directories where to merge ports ]---
ports_trees="default"
use_zfs="no"
poudriere_ports_mountpoint="/usr/local/poudriere/ports"
default_poudriere_tree="default"
default_merge_from="freebsd beat7"
EOF

$ cat > /usr/local/etc/portshaker.d/beat7 <<"EOF"
#!/bin/sh
shift
. /usr/local/share/portshaker/portshaker.subr
method="git"
git_clone_uri="https://github.com/kalw/beats-fbsd-port.git"
git_branch="master"
run_portshaker_command $*
EOF

$ cat > /usr/local/etc/portshaker.d/freebsd <<"EOF"
#!/bin/sh
shift
. /usr/local/share/portshaker/portshaker.subr
method="portsnap"
run_portshaker_command $*
EOF

$ chmod +x /usr/local/etc/portshaker.d/{beat7,freebsd}
$ portshaker -U 
$ portshaker -M

# test it !
$ poudriere testport -j 112amd64 -p default sysutils/beat7
# play with it
$ cd /usr/local/poudriere/ports/default/sysutils/beat7
```
