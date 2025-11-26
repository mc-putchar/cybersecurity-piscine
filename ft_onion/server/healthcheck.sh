#!/bin/sh
set -e

# Check if nginx is running
nginx_pid=$(pgrep nginx)
if [ -z "$nginx_pid" ]; then
	exit 1
fi
# Check if nginx can serve requests
if ! wget -q --spider http://localhost/health > /dev/null; then
	exit 1
fi

# Check if sshd is running
sshd_pid=$(pgrep sshd)
if [ -z "$sshd_pid" ]; then
	exit 1
fi
# Check if sshd is listening
if ! netstat -tln | grep -q ':22[[:space:]]'; then
	exit 1
fi

exit 0
