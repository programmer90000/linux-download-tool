#!/bin/bash

# Exit on error
set -e

LOG_FILE="extraction_log.txt"

# Wrap entire script body to capture all output into log file
{

# Function to extract supported archives
extract_file() {
    file="$1"
    case "$file" in
        *.zip) unzip "$file" ;;
        *.tar.gz|*.tgz) tar xvzf "$file" ;;
        *.tar.bz2|*.tbz2|*.tbz) tar xvjf "$file" ;;
        *.tar.xz|*.txz) tar xvJf "$file" ;;
        *) echo "Unsupported archive type for extraction: $file"; return 1;;
    esac
}

# Function to determine if file is supported archive based on extension
is_supported_archive_ext() {
    case "$1" in
        *.zip|*.tar.gz|*.tgz|*.tar.bz2|*.tbz2|*.tbz|*.tar.xz|*.txz)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to determine if file is supported archive based on MIME type
is_supported_mime() {
    mime_type=$(file --mime-type -b "$1")
    case "$mime_type" in
        application/zip|application/x-tar|application/gzip|application/x-bzip2|application/x-xz)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Prompt for target directory
read -rp "Enter the name of the directory to create: " target_dir
# Check if the directory exists, and log an error if it does
if [ -d "$target_dir" ]; then
    echo "[ERROR] Directory $target_dir already exists." >> "$LOG_FILE"
    echo "Directory $target_dir already exists. Exiting."
    exit 1
else
    mkdir -p "$target_dir"
    echo "Created directory $target_dir."
fi

cd "$target_dir"


# Prompt for file path or URL
read -rp "Enter the URL or local path of the file to download/extract: " file_input

# Download or copy the file
if [[ "$file_input" =~ ^https?:// ]]; then
    filename=$(basename "$file_input")
    echo "Downloading $filename..."
    wget -O "$filename" "$file_input"
else
    filename=$(basename "$file_input")
    echo "Copying $filename..."
    cp "$file_input" "$filename"
fi

# Decide what to do with the file
mime_type=$(file --mime-type -b "$filename")
if is_supported_archive_ext "$filename" && is_supported_mime "$filename"; then
    echo "Extracting archive $filename..."
    echo "[INFO] Extracting archive $filename (MIME: $mime_type)" >> "$LOG_FILE"
    extract_file "$filename"
elif [[ -f "$filename" || -d "$filename" ]]; then
    echo "$filename is a standalone file or folder. Keeping it as is."
    echo "[INFO] Kept standalone file/folder: $filename (MIME: $mime_type)" >> "$LOG_FILE"
else
    echo "Error: Unsupported file type."
    echo "File name: $filename"
    echo "File extension: ${filename##*.}"
    echo "Detected MIME type: $mime_type"
    echo "Deleting invalid file: $filename"
    echo "[ERROR] Deleted unsupported file: $filename | Extension: ${filename##*.} | MIME: $mime_type" >> "$LOG_FILE"
    rm -f "$filename"
    echo "File deleted. Exiting."
    exit 1
fi

echo "Done. All contents are in: $PWD"
echo "[INFO] Operation completed in directory: $PWD" >> "$LOG_FILE"

} 2>&1 | tee -a "$LOG_FILE"
