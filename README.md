# beats-fbsd-port

```
vagrant init freebsd/FreeBSD-11.2-RELEASE \
  --box-version 2018.06.22
vagrant up
vagrant ssh
$ sudo pkg install -y golang gmake
$ sudo portsnap fetch extract
$ fetch https://github.com/kalw/beats-fbsd-port/archive/master.zip
$ unzip master.zip 
$ cd beats-fbsd-port*
$ sudo DALLOW_UNSUPPORTED_SYSTEM=yes BATCH=yes make package
```
