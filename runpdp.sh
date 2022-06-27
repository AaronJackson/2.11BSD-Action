#!/bin/bash

[ -f ci.dsk.gz ] && gzip -d ci.dsk.gz

PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
DATE=$(date +%y%m%d%H%M)
GW=$(ifconfig | grep "inet 10.0" | awk '{ print $2 }')
KERNCONF=${1:-GENERIC}

echo "2.11BSD root password will be set to $PASSWORD"
echo "Date will be set to $DATE"

cat - > pdp.expect <<EOF
#!/usr/bin/expect -f
spawn pdp11

expect "sim>" {send "set cpu 11/73 4M\n"}
expect "sim>" {send "set rq enabled\n"}
expect "sim>" {send "att rq0 ci.dsk\n"}
expect "sim>" {send "set clk 50hz\n"}
expect "sim>" {send "att xq nat:tcp=21:10.0.2.64:21,tcp=23:10.0.2.64:23,gateway=$GW\n"}
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

proc checkrun {cmd} {
  expect "# " { send "\$cmd\n" }
  expect "# " {send "echo \\\$?\n"}
  expect {
    "0" { }
    "1" { exit 1 }
  }
}

set timeout -1
expect "# " {send "cd /usr/src\n"}
expect "# " {send "while \[ ! -f FTP_LOCK \] ; do sleep 4 ; echo -n . ; done\n" }

checkrun "tar -xvf github.tar"
checkrun "rm github.tar"
checkrun "cd sys/conf"
checkrun "./config $KERNCONF"
checkrun "cd ../$KERNCONF"

checkrun "make clean"
checkrun "make"
EOF

chmod +x pdp.expect
./pdp.expect &
pdp=$!

while ! nc -z $GW 21 ; do
  sleep 5
done

# Note about ftp - because we are using simh nat (because we don't
# want privileged containers), the ftp connection has to "look like"
# it's coming form a public address, so it can connect back. We set
# the gateway in simh to be the docker address. The fact that the BSD
# installation is in the same subnet is just coincidental and nothing
# to worry about.

pushd github
tar -cf ../github.tar ./sys
popd
touch FTP_LOCK

ftp -invp $GW <<EOF
user root $PASSWORD
cd /usr/src
put github.tar
put FTP_LOCK
EOF

echo "Returning to PDP-11..."
wait $pdp
exit $?
