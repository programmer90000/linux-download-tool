#!/bin/bash
set -e
exec > >(tee -i install.log) 2>&1
export PS4='[$(date "+%Y-%m-%d %H:%M:%S")] '

# Error handler
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Ensure the script is run with sudo or root privileges
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        error_exit "Please run this script with sudo or root privileges."
    fi
}

# Validate the source: check if it's a local file or a URL
validate_source() {
    local url="$1"
    if [[ -f "$url" ]]; then
        echo "Using local archive file: $url"
        TMP_ARCHIVE="$url"
    else
        HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$url")
        if [[ "$HTTP_STATUS" -lt 200 || "$HTTP_STATUS" -ge 400 ]]; then
            error_exit "Invalid or unreachable URL (HTTP $HTTP_STATUS): $url"
        fi
        TMP_ARCHIVE=$(mktemp "/tmp/${PROGRAM_NAME}.XXXXXX.tar.gz")
        echo "Downloading $PROGRAM_NAME from $url..."
        curl -fL -# "$url" -o "$TMP_ARCHIVE" || error_exit "Download failed."
    fi
}

# Extract the archive to the destination directory
extract_archive() {
    echo "Extracting $PROGRAM_NAME to $DEST_DIR"
    case "$TMP_ARCHIVE" in
        *.tar.gz)  tar -xvzf "$TMP_ARCHIVE" -C "$DEST_DIR" || error_exit "Extraction failed." ;;
        *.tar.bz2) tar -xvjf "$TMP_ARCHIVE" -C "$DEST_DIR" || error_exit "Extraction failed." ;;
        *.tar.xz)  tar -xvJf "$TMP_ARCHIVE" -C "$DEST_DIR" || error_exit "Extraction failed." ;;
        *.zip)     unzip -q "$TMP_ARCHIVE" -d "$DEST_DIR" || error_exit "Extraction failed." ;;
        *)         error_exit "Unsupported archive format: $TMP_ARCHIVE" ;;
    esac
}

# Confirm overwriting an existing directory and prepare destination
confirm_and_prepare_dest() {
    if [ -d "$DEST_DIR" ]; then
        echo "Directory $DEST_DIR already exists and contains:"
        ls -lah "$DEST_DIR"
        read -p "Do you want to overwrite it? (y/n): " response
        if [[ "$response" != "y" && "$response" != "Y" ]]; then
            echo "Operation cancelled."
            exit 0
        fi
        rm -rf "$DEST_DIR" || error_exit "Failed to remove existing directory."
        echo "Existing directory $DEST_DIR has been deleted."
    fi
    mkdir -p "$DEST_DIR" || error_exit "Failed to create directory $DEST_DIR."
}

# Cleanup temp files
clean_up() {
    [[ -f "$TMP_ARCHIVE" && ! -f "$DOWNLOAD_URL" ]] && rm -f "$TMP_ARCHIVE"
    echo "Temporary files cleaned up."
}
trap clean_up EXIT

### Main Script ###

check_sudo

# Validate input arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <program_name> <download_url_or_file> <destination_directory>"
    exit 1
fi

PROGRAM_NAME="$1"
DOWNLOAD_URL="$2"
BASE_DEST_DIR=$(realpath -m "$3")
DEST_DIR="$BASE_DEST_DIR/$PROGRAM_NAME"

# Ensure curl or wget is installed
if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    error_exit "Neither curl nor wget is installed. Please install one and try again."
fi

validate_source "$DOWNLOAD_URL"
confirm_and_prepare_dest
extract_archive

echo "$PROGRAM_NAME installed to $DEST_DIR"
