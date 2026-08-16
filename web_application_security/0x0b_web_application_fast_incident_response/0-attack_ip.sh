#!/bin/bash
# Extract IP addresses from a log file, count how many requests each
# IP made, and print the IP address responsible for the most
# requests (the likely source of a DoS attack).
# Usage: ./0-attack_ip.sh [logfile]
# If no logfile is given, ./logs.txt is used by default.

if [ -z $1 ]
then
	logfile=logs.txt
else
	logfile=$1
fi

awk '{print $1}' $logfile | sort | uniq -c | sort -rn | head -n 1 | awk '{print $2}'
