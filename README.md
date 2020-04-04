# beats-fbsd-port

```
vagrant init freebsd/FreeBSD-11.2-RELEASE \
  --box-version 2018.06.22
vagrant up
vagrant ssh
$ sudo pkg install -y git golang gmake
$ git clone https://github.com/kalw/beats-fbsd-port.git
$ cd beats-fbsd-port
$ make package
```
