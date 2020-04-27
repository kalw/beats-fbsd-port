*** vendor/github.com/insomniacslk/dhcp/dhcpv4/bindtodevice_bsd.go      Tue Mar 31 07:10:01 2020
--- other       Wed Dec 31 19:00:00 1969
***************
*** 1,18 ****
- // +build freebsd openbsd netbsd
-
- package dhcpv4
-
- import (
-       "net"
-       "syscall"
- )
-
- // BindToInterface emulates linux's SO_BINDTODEVICE option for a socket by using
- // IP_RECVIF.
- func BindToInterface(fd int, ifname string) error {
-       iface, err := net.InterfaceByName(ifname)
-       if err != nil {
-               return err
-       }
-       return syscall.SetsockoptInt(fd, syscall.IPPROTO_IP, syscall.IP_RECVIF, iface.Index)
- }
--- 0 ----
