#!/usr/bin/env bash

set -eu

FIRST_DAY=$(date -dlast-monday -Iminutes)
LAST_DAY=$(date -Iminutes)

timew rc.reports.week.hours=auto week
for tag in $(timew tags ${FIRST_DAY} to ${LAST_DAY} | tail -n +4 | cut -f 1 -d ' ' | egrep -v '(awv|develop|meet)'); do
    echo ========== $tag ==========
    timew rc.reports.week.hours=auto week awv $tag
done
