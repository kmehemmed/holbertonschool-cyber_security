#!/bin/bash
# Scan auth.log and figure out which service the attackers used
# to try to gain access to the system.
# Usage: ./0-service.sh [logfile]
# If no logfile is given, ./auth.log is used by default.

if [ -z $1 ]
then
	logfile=auth.log
else
	logfile=$1
fi

grep sshd $logfile | awk -F'sshd\\[[0-9]*\\]: ' '{print $2}' | awk '{print $1}' | sort | uniq -c | sort -rn
