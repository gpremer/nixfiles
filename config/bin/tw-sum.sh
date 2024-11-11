#!/usr/bin/env bash

set -eu

# Default values if no parameters provided
if [ $# -eq 0 ]; then
    FIRST_DAY=$(date -dlast-monday -Iminutes)
    LAST_DAY=$(date -Iminutes)
elif [ $# -eq 1 ]; then
    # If one parameter, use it as first day and current time as last day
    FIRST_DAY=$(date -d"$1" -Iminutes)
    LAST_DAY=$(date -Iminutes)
else
    # If two parameters, use both
    FIRST_DAY=$(date -d"$1" -Iminutes)
    LAST_DAY=$(date -d"$2" -Iminutes)
fi

timew rc.reports.week.hours=auto week ${FIRST_DAY} to ${LAST_DAY}
for tag in $(timew tags ${FIRST_DAY} to ${LAST_DAY} | tail -n +4 | cut -f 1 -d ' ' | egrep -v '(awv|develop|meet)'); do
    echo ========== $tag ==========
    timew rc.reports.week.hours=auto week ${FIRST_DAY} to ${LAST_DAY} awv $tag
done
