#!/bin/bash

PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)
DATE=$(date +%y%m%d%H%M)

echo "Temporary password will be set to $PASSWORD"
echo "Date will be set to $DATE"

cat > pdp.expect <<EOF
#!/usr/bin/expect -f
spawn /pdp11

expect "sim>" {send "set cpu 11/73 4M\n"}
expect "sim>" {send "set rq enabled\n"}
expect "sim>" {send "att rq0 ci.dsk\n"}
expect "sim>" {send "set clk 50hz\n"}
expect "sim>" {send "att xq nat:\n"}
expect "sim>" {send "boot rq0\n"}

expect ": " {send "ra(0,0,0)unix\n"}

expect "# " {send \004}

expect "login: " {send "root\n"}

expect "# " {send "date $DATE\n"}
expect "# " {send "passwd\n"}
expect "New password:" {send "$PASSWORD\n"}
expect "Retype new password:" {send "$PASSWORD\n"}

expect "# " {send "sleep 100\n"}
interact
EOF

/sbin/ifconfig tap0 up

chmod +x pdp.expect
./pdp.expect
