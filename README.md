# FileMerger

A command-line utility to merge multiple files into a single text file, with support for file filtering by extension and recursive folder traversal.

## Installation

### Using pipx (Recommended)
```bash
# Install pipx if not installed
sudo apt install pipx
pipx ensurepath

# Install FileMerger
pipx install -e .
```

### Using Virtual Environment
```bash
# Install required package
sudo apt install python3-venv

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install package
pip install -e .
```

## Usage

```bash
filemerger [OPTIONS] FOLDERS...
```

### Options
- `-o, --output`: Output filename (default: merged_contents.txt)
- `-e, --extensions`: File extensions to include (default: .cpp .h .txt .json)
- `-i, --ignore-files`: Files to ignore
- `-I, --ignore-folders`: Folders to ignore (default: cmake-build-debug, build, mbed-os, cmake_build)

### Examples

```bash
# Merge all .cpp and .h files from specific folders
filemerger hmi/gfx drivers/display -e .cpp .h

# Merge using wildcards to include subfolders
filemerger hmi/gfx/* drivers/display/* -e .h .cpp .txt

# Merge with specific extensions and ignore patterns
filemerger src include -e .cpp .h -I build test

# Merge only header files from multiple folders
filemerger src/* include/* lib/* -e .h
```

## Features

- Recursive folder traversal
- Multiple file extension support
- Wildcard pattern support for folder paths
- Configurable file and folder exclusions
- Clear terminal output with merge summary
- UTF-8 file encoding support

## Requirements
- Python ≥ 3.7
- Click library
- pipx or python3-venv (for installation)

## Development

```bash
git clone https://github.com/ericodemecha/filemerger.git
cd filemerger
pipx install -e .
```

## Notes
- Binary files are automatically detected and skipped
- File paths in the output file are preserved relative to the source folders
- The merge summary is displayed in the terminal after successful execution