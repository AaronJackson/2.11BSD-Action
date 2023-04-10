#!/bin/bash

set -eu

arg_run="$1"
arg_path="$2"

[ -f ../ci.dsk.gz ] && gzip -d ../ci.dsk.gz

echo "Mounting 2.11BSD file system with retro-fuse"
sudo mkdir /bsd
sudo chown $USER /bsd
bsd211fs ../ci.dsk /bsd

echo "syncing sources"
mkdir -p "/mnt/$arg_path"
rsync -a --safe-links --ignore-errors "$PWD/" "/bsd/$arg_path" || true

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

  expect -re "(\\d+)" {
    set result $expect_out(1,string)
  }

  if { \$result != 0 ) {
    exit \$result
  }
}

set timeout -1

checkrun "cd $arg_path"
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

expect "erase, kill"
expect "# "
checkrun "fsck -y -t fscratch"
checkrun "rm fscratch* || true"

checkrun "sync"
checkrun "sleep 5"

send "halt"

set timeout 10
expect "sim>" {send "exit\n"}
EOF

chmod +x pdp.expect
./pdp.expect
exit $?
