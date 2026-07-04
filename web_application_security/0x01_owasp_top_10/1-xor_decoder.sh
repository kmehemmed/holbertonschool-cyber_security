#!/bin/bash

input_hash="${1#\{xor\}}"
decoded_base64=$(echo -n "$input_hash" | base64 -d 2>/dev/null)

echo -n "$decoded_base64" | od -An -v -t x1 | tr -d '\n' | awk '{
    for(i=1; i<=NF; i++) {
        printf "%c", xor(strtonum("0x"$i), 0x5f)
    }
    print ""
}'
