#!/usr/bin/expect
set timeout 30
spawn ./seafile.sh start
expect eof

spawn ./seahub.sh start
expect "\\\[ admin email \\\]"
send "{{ config.admin }}\n"
expect "\\\[ admin password \\\]"
send "{{ config.password }}\n"
expect "\\\[ admin password again \\\]"
send "{{ config.password }}\n"
expect "Done."

sleep 30

spawn ./seahub.sh stop
expect eof
spawn ./seafile.sh stop
expect eof