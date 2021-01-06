#!/bin/bash

while true
do
sleep 1
val=""
#val=$(tvservice -a)
val=$(tvservice -s)
if [ -z "$val" ]; then
echo "Fail"
else
echo "Pass ": $val
fi
done
