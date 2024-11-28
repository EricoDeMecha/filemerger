# FileMerger

A command-line utility to merge multiple files into a single text file, with support for file filtering by extension and selective folder/file inclusion/exclusion.

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
filemerger [OPTIONS]
```

### Options
- `-r, --root`: Root directory (default: current directory)
- `-o, --output`: Output filename (default: merged_contents.txt)
- `-e, --extensions`: File extensions to include (default: .cpp .h .txt .json)
- `-m, --merge`: Specific files to merge (relative paths)
- `-i, --ignore_files`: Files to ignore
- `-I, --ignore_folders`: Folders to ignore (default: cmake-build-debug, build, mbed-os, cmake_build)
- `-M, --merge_folders`: Specific folders to merge

### Examples

```bash
# Merge all .cpp and .h files in current directory
filemerger -e .cpp .h

# Merge specific files from src directory
filemerger -r src -m main.cpp utils.h

# Merge files excluding test folder
filemerger -I tests -o merged.txt

# Merge only files in src and include folders
filemerger -M src include
```

## Development

```bash
git clone https://github.com/ericodemecha/filemerger.git
cd filemerger
pipx install -e .
```

## Requirements
- Python ≥ 3.6
- pipx or python3-venv (for installation)