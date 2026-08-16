#!/bin/bash
# Scan auth.log and count how many distinct IP addresses
# successfully gained access to a compromised account. Each unique
# IP is considered a different attacker.
# Usage: ./3-ips.sh [logfile]
# If no logfile is given, ./auth.log is used by default.

if [ -z $1 ]
then
	logfile=auth.log
else
	logfile=$1
fi

tail -1000 $logfile > /tmp/3-ips.tmp

failed_users=$(grep "Failed password" /tmp/3-ips.tmp | sed -E 's/.*Failed password for (invalid user )?([^ ]+) from.*/\2/' | sort -u)

accepted_users=$(grep "Accepted password" /tmp/3-ips.tmp | sed -E 's/.*Accepted password for ([^ ]+) from.*/\1/' | sort -u)

compromised=$(for user in $accepted_users
do
	echo "$failed_users" | grep -qx $user
	if [ $? -eq 0 ]
	then
		echo $user
	fi
done)

for user in $compromised
do
	grep "Accepted password for $user " $logfile
done | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u | wc -l

rm -f /tmp/3-ips.tmp
