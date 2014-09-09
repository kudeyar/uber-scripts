#!/usr/bin/env bash
# Description:
# Author:
TMPA=$(mktemp --tmpdir=/tmp pglb.XXXX)
TMPB=$(mktemp --tmpdir=/tmp pglb.XXXXX)
inputLog=$1
date=$(head -n1 $inputLog |awk '{print $1}')
hourStart=$(head -n1 $inputLog |awk '{print $2}' |cut -d: -f1)
hourEnd=$(tail -n1 $inputLog |awk '{print $2}' |cut -d: -f1)

for hour in $(eval echo {$hourStart..$hourEnd}); do
  for minute in {00..60}; do
     sed -n -e "/^$date $hour\:$minute/p" $inputLog > $TMPB
     calls=$(cat $TMPB |wc -l)
     totalTime=$(grep -oE 'duration: [0-9\.]+ ms' $TMPB |awk '{sum += $2} END {print sum}')
     echo -n "$hour:$minute query count: $calls; "
     echo "query average duration: $(echo |awk -v c=$calls -v t=$totalTime '{print t / c}') ms"
  done
done |grep -vE 'query count: 0|average duration: \-nan' > $TMPA

cat $TMPA
echo "--- statistics ---"
echo "max query count at: $(cat $TMPA |sort -nk4 |tail -n1)"
echo "max average duration at: $(cat $TMPA |sort -nk8 |tail -n1)"
rm $TMPA $TMPB