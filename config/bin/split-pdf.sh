#!/usr/bin/env bash

set -eu

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <pdf_file>"
    exit 1
fi

pdf_file="$1"
page_count=$(mutool info "$pdf_file" | grep -oP 'Pages:\s*\K\d+')

if [ -z "$page_count" ]; then
    echo "Error retrieving page count for '$pdf_file'."
    exit 1
fi

base_name=$(basename "$pdf_file" .pdf)
output_prefix="${base_name}_"

for ((page = 1; page <= page_count; page++)); do
    output_file="${output_prefix}${page}.pdf"
    mutool draw -o "$output_file" "$pdf_file" $page
    echo "Page $page extracted to $output_file"
done
