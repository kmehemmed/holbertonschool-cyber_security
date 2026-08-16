#!/bin/bash
# Scan auth.log and count how many firewall rules were added
# to the system using iptables (the -A flag appends a new rule).
# Usage: ./4-firewall.sh [logfile]
# If no logfile is given, ./auth.log is used by default.

if [ -z $1 ]
then
	logfile=auth.log
else
	logfile=$1
fi

grep "iptables" $logfile | grep -c -- "-A"
