#!/bin/bash

set -eu

arg_run="$1"
arg_path="$2"

[ -f ../ci.dsk.gz ] && gzip -d ../ci.dsk.gz

echo "Mounting 2.11BSD file system with retro-fuse"
sudo mkdir /bsd
sudo chown $USER /bsd
bsd211fs -o initfs,fssize=$(( 1024 * 100 )),overwrite ../scratch.dsk /bsd

echo "syncing sources"
rsync -a --safe-links --ignore-errors "$PWD/" "/bsd/" || true

echo "Unmounting retro-fuse file system"
sudo umount /bsd
sudo rmdir /bsd

DATE=$(date +%y%m%d%H%M)

echo "Date will be set to $DATE"

cat - > pdp.expect <<EOF
#!/usr/bin/expect -f
spawn pdp11

expect "sim>" {send "set cpu 11/73 4M\n"}
expect "sim>" {send "set rq enabled\n"}
expect "sim>" {send "att rq0 ../ci.dsk\n"}
expect "sim>" {send "att rq1 ../scratch.dsk\n"}
expect "sim>" {send "set clk 50hz\n"}
expect "sim>" {send "boot rq0\n"}

expect ": " {send "ra(0,0,0)unix\n"}

expect "# " {send \004}

expect "login: " {send "root\n"}

expect "# " {send "date $DATE\n"}

proc checkrun {cmd} {
  expect "# " { send "\$cmd\n" }
  expect "# " {send "echo \\\$?\n"}

  expect -re "(\\\\d+)" {
    set result \$expect_out(1,string)
  }

  if { \$result == 0 } {
  } elseif { \$result == 4 } {
  } else {
    exit \$result
  }
}

set timeout -1

expect "# " {send "mkdir -p $arg_path"}
expect "# " {send "mkdir /scratch"}
expect "# " {send "cd /dev"}
expect "# " {send "./MAKEDEV ra1"}
expect "# " {send "mount /dev/ra1a /scratch"}
expect "# " {send "cd /"}
expect "# " {send "cp -r /scratch/ $arg_path/"}
expect "# " {send "cd $arg_path"}
EOF

while IFS= read -r line; do
    cat >> pdp.expect <<EOF
checkrun "$line"
EOF
done <<< "$arg_run"

cat >> pdp.expect <<EOF
checkrun "sync"
checkrun "sleep 5"
expect "# " {send "shutdown now\n"}

expect "# "
checkrun "fsck -y -t fscratch"
checkrun "rm fscratch* || true"

send "halt"

set timeout 10
expect "sim>" {send "exit\n"}
EOF

chmod +x pdp.expect
./pdp.expect
exit $?
