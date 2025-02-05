#!/bin/bash

output_file="merged_contents.txt"
extensions=()
ignore_dirs=()
ignore_files=()
paths=()
verbose=false
processed_files=()

# Print usage
usage() {
    echo "Usage: $0 [paths...] [-e extensions...] [-I ignore_dirs...] [-i ignore_files...] [-o output] [-v]"
    echo "  paths          Files or directories to process"
    echo "  -e            File extensions to include (without dot)"
    echo "  -I            Directories to ignore (with or without trailing slash)"
    echo "  -i            Specific files to ignore"
    echo "  -o            Output file (default: merged_contents.txt)"
    echo "  -v            Verbose output"
    exit 1
}

# Function to clean directory path (remove trailing slash)
clean_path() {
    echo "${1%/}"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e)
            shift
            while [[ $# -gt 0 && ! $1 =~ ^- ]]; do
                extensions+=(".$1")
                shift
            done
            ;;
        -I)
            shift
            while [[ $# -gt 0 && ! $1 =~ ^- ]]; do
                # Remove trailing slash if present and add to ignore_dirs
                cleaned_dir=$(clean_path "$1")
                ignore_dirs+=("-not -path '*/$cleaned_dir/*'")
                shift
            done
            ;;
        -i)
            shift
            while [[ $# -gt 0 && ! $1 =~ ^- ]]; do
                ignore_files+=("$(clean_path "$1")")
                shift
            done
            ;;
        -o)
            shift
            output_file="$1"
            shift
            ;;
        -v)
            verbose=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            paths+=("$(clean_path "$1")")
            shift
            ;;
    esac
done

# Check if we have any paths
if [ ${#paths[@]} -eq 0 ]; then
    echo "Error: No input paths specified"
    usage
fi

# If no extensions specified, use defaults
if [ ${#extensions[@]} -eq 0 ]; then
    extensions=(".cpp" ".h" ".txt")
fi

# Create extension pattern for find
ext_pattern=$(printf " -o -name '*%s'" "${extensions[@]}")
ext_pattern=${ext_pattern:4}  # Remove initial " -o "

# Function to check if file should be ignored
should_ignore_file() {
    local file="$1"
    local basename=$(basename "$file")
    
    for ignore in "${ignore_files[@]}"; do
        if [[ "$basename" == "$(basename "$ignore")" ]]; then
            return 0  # true, should ignore
        fi
    done
    return 1  # false, should not ignore
}

# Function to process a single file
process_file() {
    local file="$1"
    if should_ignore_file "$file"; then
        $verbose && echo "Ignoring file: $file"
        return
    fi
    
    if $verbose; then
        echo "Processing file: $file"
    fi
    echo -e "\n\n--- $file ---\n" >> "$output_file"
    cat "$file" >> "$output_file"
    processed_files+=("$file")
}

# Clear output file
> "$output_file"

# Process direct file paths first
for path in "${paths[@]}"; do
    if [ -f "$path" ]; then
        process_file "$path"
    fi
done

# Process directories
find_cmd="find"
for path in "${paths[@]}"; do
    if [ -d "$path" ]; then
        find_cmd+=" $path"
    fi
done

# Only run find if we have directories to process
if [[ ${#find_cmd} -gt 5 ]]; then  # More than just "find"
    find_cmd+=" -type f \( $ext_pattern \)"
    
    # Add ignore patterns
    for ignore in "${ignore_dirs[@]}"; do
        find_cmd+=" $ignore"
    done

    if $verbose; then
        echo "Executing: $find_cmd"
    fi

    # Execute find and process each file
    while IFS= read -r file; do
        process_file "$file"
    done < <(eval "$find_cmd" | sort)
fi

# Print summary
echo -e "\nMerge Summary:"
echo "Total files processed: ${#processed_files[@]}"
echo "Extensions included: ${extensions[*]}"
if [ ${#ignore_dirs[@]} -gt 0 ]; then
    # Clean up the ignore_dirs display for the summary
    cleaned_ignores=()
    for ignore in "${ignore_dirs[@]}"; do
        # Extract directory name from the -not -path pattern
        dir_name=$(echo "$ignore" | sed -n "s/.*'\*\/\(.*\)\/\*'.*/\1/p")
        cleaned_ignores+=("$dir_name")
    done
    echo "Ignored directories: ${cleaned_ignores[*]}"
fi
if [ ${#ignore_files[@]} -gt 0 ]; then
    echo "Ignored files: ${ignore_files[*]}"
fi
echo -e "\nProcessed files:"
printf '%s\n' "${processed_files[@]}" | sed 's/^/- /'
echo -e "\nOutput saved to: $output_file"