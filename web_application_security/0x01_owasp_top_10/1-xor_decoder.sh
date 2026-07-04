#!/bin/bash
input_hash="${1#\{xor\}}"
decoded_hex=$(echo -n "$input_hash" | base64 -d 2>/dev/null | od -An -v -t x1)

for hex in $decoded_hex; do
    dec=$((16#$hex))
    xor_dec=$((dec ^ 95))
    printf "\\$(printf '%03o' $xor_dec)"
done
echo ""
