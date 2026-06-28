#!/bin/bash
curl -X POST -H "Host: $1" --data "$3" "$2"
