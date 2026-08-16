#!/bin/bash
# Scan the last 1000 lines of auth.log to find an account that had
# multiple failed login attempts followed by at least one successful
# login. This is the most likely compromised account.
# Usage: ./2-accounts.sh [logfile]
# If no logfile is given, ./auth.log is used by default.

if [ -z $1 ]
then
	logfile=auth.log
else
	logfile=$1
fi

tail -1000 $logfile > /tmp/2-accounts.tmp

failed_users=$(grep "Failed password" /tmp/2-accounts.tmp | sed -E 's/.*Failed password for (invalid user )?([^ ]+) from.*/\2/' | sort -u)

accepted_users=$(grep "Accepted password" /tmp/2-accounts.tmp | sed -E 's/.*Accepted password for ([^ ]+) from.*/\1/' | sort -u)

for user in $accepted_users
do
	echo "$failed_users" | grep -qx $user
	if [ $? -eq 0 ]
	then
		echo $user
	fi
done

rm -f /tmp/2-accounts.tmp
