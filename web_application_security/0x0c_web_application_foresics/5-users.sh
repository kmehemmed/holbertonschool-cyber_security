#!/bin/bash
# Scan auth.log and list all the user accounts that were created
# on the target system.
# Usage: ./5-users.sh [logfile]
# If no logfile is given, ./auth.log is used by default.

if [ -z $1 ]
then
	logfile=auth.log
else
	logfile=$1
fi

grep "new user" $logfile | sed -E 's/.*name=([^,]+),.*/\1/' | sort -u | paste -sd ','
