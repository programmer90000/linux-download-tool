# Archive Extractor Script

## Description
This Bash script automates the process of downloading or copying an archive file, verifying its type, extracting its contents (if supported), and logging all actions to a file. It supports common archive formats like .zip, .tar.gz, .tar.bz2, and .tar.xz.

## Features
Prompts user to create a new working directory
Fails if an existing directory is provided to avoid overwriting
Accepts a local file path or remote URL (via HTTP/HTTPS) to download
Detects supported archive formats based on both file extension and MIME type
Extracts supported archives
Logs all output to extraction_log.txt inside the working directory
Cleans up unsupported or invalid files automatically

## Supported Archive Formats
.zip, .tar.gz, .tgz, .tar.bz2, .tbz2, .tbz, .tar.xz, .txz

## Requirements
Bash shell
wget (for URL downloads)
unzip, tar, file utilities

## Usage
```
cd ~/
mkdir -p ~/bin
export PATH="$HOME/bin:$PATH"
cd bin/
touch download-files.bat
nano download-files.bat 
PASTE THE CONTENTS OF BASH-SCRIPT.BASH INTO THIS FILE
```

Command to run to make script executable:
```
chmod +x download-files.sh
```
Command to run the script:
```
./download-files.sh
```
This will begin the script. The script will ask for a new directory name. If the directory name already exists, the script will fail and provide an error message.

### Provide either:
A local file path to an archive
A URL to download an archive

The script will extract the archive if valid, or keep it untouched if it's a standalone file/folder. Unsupported file types are deleted with a logged error.

### Logging
All stdout and stderr are recorded to: `<your_target_directory>/extraction_log.txt`

## Example
```
$ ./extract_script.sh
Enter the name of the directory to create: test_extract
Created directory test_extract.
Enter the URL or local path of the file to download/extract: https://example.com/archive.zip
Downloading archive.zip...
Extracting archive archive.zip...
Done. All contents are in: /full/path/to/test_extract
```

## Notes
The script fails fast (set -e) on critical errors.

MIME and extension detection are both used for better format validation.

Avoid using this script on untrusted input—no sandboxing is implemented.