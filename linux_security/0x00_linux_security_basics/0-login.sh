#!/bin/bash
sudo last -F -n -5 | grep "$1"
