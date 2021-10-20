#!/bin/bash

PASSWORD=Password9
DATE=$(date +%y%m%d%H%M)
GW=$(ifconfig tap0 | grep "inet 10.0" | awk '{ print $2 }')

echo "2.11BSD root password will be set to $PASSWORD"
echo "Date will be set to $DATE"

cat - dump.expect > pdp.expect <<EOF
#!/usr/bin/expect -f
spawn /pdp11

expect "sim>" {send "set cpu 11/73 4M idle\n"}
expect "sim>" {send "set rq enabled\n"}
expect "sim>" {send "att rq0 ci.dsk\n"}
expect "sim>" {send "set clk 50hz\n"}
expect "sim>" {send "att xq nat:tcp=21:10.0.2.64:21,gateway=$GW\n"}
expect "sim>" {send "boot rq0\n"}

expect ": " {send "ra(0,0,0)unix\n"}

expect "# " {send \004}

expect "login: " {send "root\n"}

expect "# " {send "date $DATE\n"}
expect "# " {send "passwd\n"}
expect "New password:" {send "$PASSWORD\n"}
expect "Retype new password:" {send "$PASSWORD\n"}

expect "# " {send "echo 127.0.0.1 localhost > /etc/hosts\n"}
expect "# " {send "echo 10.0.2.64 simh >> /etc/hosts\n"}
expect "# " {send "> /etc/ftpusers\n"}
expect "# " {send "echo ALL: ALL: ALLOW >> /etc/hosts.allow\n"}
expect "# " {send "ifconfig qe0 inet netmask 255.255.255.0 simh broadcast 10.0.2.255 up\n"}

set timeout -1
expect "0123456789" {send "while true ; do sleep 100; done\n"}
EOF

chmod +x pdp.expect
./pdp.expect &

while ! nc -z $GW 21 ; do
  sleep 5
done

# Note about ftp - because we are using simh nat (because we don't
# want privileged containers), the ftp connection has to "look like"
# it's coming form a public address, so it can connect back. We set
# the gateway in simh to be the docker address. The fact that the BSD
# installation is in the same subnet is just coincidental and nothing
# to worry about.

# Verify ftp connection
ftp -invp $GW <<EOF
user root $PASSWORD
ls
EOF
