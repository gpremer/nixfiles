#!/usr/bin/env bash

# Function to replace tags for a given ID
replace_tags() {
    local ids=$1
    local old_tag=$2
    local new_tag=$3

    echo timew untag "${ids}" "${old_tag}" && echo timew tag "${ids}" "${new_tag}"
}

# Print usage information
usage() {
    echo "Usage: $0 <start_time> <end_time> <old_tag> <new_tag>"
    echo "Example: $0 2023-12-21T00:00 2023-12-25T24:00 ELNG-2305 ELNG-3455"
}

# Check if all required arguments are provided
if [ "$#" -ne 4 ]; then
    usage
    exit 1
fi

# Main script
start_time="$1"
end_time="$2"
old_tag="$3"
new_tag="$4"

# Filter rows with the old tag and extract IDs
ids=$(timew sum "${start_time}" to "${end_time}" :ids "${old_tag}" | grep "@[0-9]" | sed -e 's/.*@/@/' | awk '{printf "%s ",$1}')

replace_tags "${ids}" "${old_tag}" "${new_tag}"

replacements_count=$(echo "${ids}" | wc -w)

echo "Tags replaced successfully. Total replacements: ${replacements_count}"
