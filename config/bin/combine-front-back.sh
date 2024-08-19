#!/usr/bin/env bash

set -eu

# Script to combine 2 scan sets of a number of single page, 2-sided documents.
# The first set contains all front pages and a second one all back pages. This
# script splits the sets and combines the matching pages. Default match is 1-1,
# 2-2 and so on, but it --reverse is given and there are, for instance, 7 pages,
# then we get 1-7, 2-6, etc. This allows for just putting the stack in the
# scanner without reordering the pages manually.

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 [--reverse] <front_pages_file> <back_pages_file> <output_prefix>"
    exit 1
fi

# Check for --reverse flag and remove it from arguments if present
reverse_flag=0
if [ "$1" == "--reverse" ]; then
    reverse_flag=1
    shift
fi

front_file="$1"
back_file="$2"
output_prefix="$3"

# extract the number of pages
front_page_count=$(mutool info "$front_file" | grep -oP 'Pages:\s*\K\d+')
back_page_count=$(mutool info "$back_file" | grep -oP 'Pages:\s*\K\d+')

if [ "$front_page_count" -ne "$back_page_count" ]; then
    echo "Error: Front and back files do not have the same number of pages."
    exit 1
fi

for ((page = 1; page <= front_page_count; page++)); do
    if [ "$reverse_flag" -eq 1 ]; then
        back_page=$((back_page_count - page + 1))
    else
        back_page="$page"
    fi

    output_file="${output_prefix}_${page}.pdf"
    mutool merge -o "$output_file" "$front_file" $page "$back_file" $back_page
done

mutool merge -o "${output_prefix}.pdf" "${output_prefix}_"*.pdf
rm "${output_prefix}_"*.pdf
echo "Combined front ${front_file} and back ${back_file} into ${output_prefix}"
