#!/bin/bash

set -eu

[ -f ci.dsk.gz ] && gzip -d ci.dsk.gz

echo "Mounting 2.11BSD file system with retro-fuse"
/retro-fuse/bsd211fs /ci.dsk /mnt

echo "syncing kernel sources"
rsync -a --safe-links --ignore-errors /github/ /mnt/usr/src/ || true

echo "Unmounting retro-fuse file system"
umount /mnt

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
expect "sim>" {send "boot rq0\n"}

expect ": " {send "ra(0,0,0)unix\n"}

expect "# " {send \004}

expect "login: " {send "root\n"}

expect "# " {send "date $DATE\n"}
expect "# " {send "passwd\n"}
expect "New password:" {send "$PASSWORD\n"}
expect "Retype new password:" {send "$PASSWORD\n"}

proc checkrun {cmd} {
  expect "# " { send "\$cmd\n" }
  expect "# " {send "echo \\\$?\n"}
  expect {
    "0" { }
    "1" { exit 1 }
  }
}

set timeout -1

checkrun "cd sys/conf"
checkrun "./config $KERNCONF"
checkrun "cd ../$KERNCONF"

checkrun "make clean"
checkrun "make"
EOF

chmod +x pdp.expect
./pdp.expect &
pdp=$!

echo "Returning to PDP-11..."
wait $pdp
exit $?
