#!/bin/bash
# Scan dmesg and figure out the operating system version
# of the targeted system.
# Usage: ./1-operating.sh [dmesgfile]
# If no dmesgfile is given, ./dmesg is used by default.

if [ -z $1 ]
then
	dmesgfile=dmesg
else
	dmesgfile=$1
fi

grep "Linux version" $dmesgfile
