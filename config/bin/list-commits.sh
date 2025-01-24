#!/usr/bin/env bash

# Function to get commits not by a specific author
get_commits_not_by_author() {
    local base_commit="$1"
    local author_to_exclude="$2"
    local branch="$3"
    local verbose="$4"

    local log_format="%h %ae"
    if [[ "$verbose" == "-vv" ]]; then
        log_format="%h %ae %s"
    fi

    # Use git log to get commit hashes and authors
    commits=$(git log --format="$log_format" "$base_commit..$branch" | while read -r line; do
        hash=$(echo "$line" | cut -d' ' -f1)
        author=$(echo "$line" | cut -d' ' -f2)
        if [[ "$author" != "$author_to_exclude" ]]; then
            if [[ "$verbose" ]]; then
                echo "$line"
            else
                echo "$hash" # Only output the hash in non-verbose mode
            fi
        fi
    done)

    if [[ -z "$commits" ]]; then
        if [[ "$verbose" ]]; then
            echo "No commits found not by $author_to_exclude since $base_commit on branch $branch"
        fi
        return 1
    fi
    echo "$commits"
    return 0

}

# Check for correct number of arguments
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 [-v|-vv] <base_commit> <author_to_exclude> <branch>"
    exit 1
fi

verbose=""
if [[ "$1" == "-v" || "$1" == "-vv" ]]; then
    verbose="$1"
    shift
fi

base_commit="$1"
author_to_exclude="$2"
branch="$3"

# Call the function and handle output
if commits=$(get_commits_not_by_author "$base_commit" "$author_to_exclude" "$branch" "$verbose"); then
    if [[ "$verbose" ]]; then
        echo "Commits not by $author_to_exclude since $base_commit on branch $branch:"
    fi
    echo "$commits"
else
    # get_commits_not_by_author already prints an error message if verbose is given
    exit 1
fi

# Pipe door tac en xargs om te cherrypicken
