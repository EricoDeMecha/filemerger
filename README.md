# FileMerger

A cross-platform command-line utility to merge multiple files into a single text file, with support for file filtering by extension and recursive folder traversal.

## Installation

### Linux/Unix

#### Using Install Script (Recommended)
```bash
# Install
./install.sh install

# Remove
./install.sh remove
```

#### Manual Installation
```bash
# Copy script to your bin directory
mkdir -p ~/bin
cp filemerger.sh ~/bin/filemerger
chmod +x ~/bin/filemerger

# Add to your shell configuration (.bashrc or .zshrc)
export PATH="$HOME/bin:$PATH"
alias fmerge="filemerger"
```

### Windows

#### Using Install Script (Recommended)
```powershell
# Run PowerShell as Administrator
.\install.ps1 -Action install

# To remove
.\install.ps1 -Action remove
```

#### Manual Installation
```powershell
# Create bin directory in user profile
New-Item -ItemType Directory -Path "$env:USERPROFILE\bin" -Force

# Copy script
Copy-Item filemerger.ps1 "$env:USERPROFILE\bin\filemerger.ps1"

# Add to PATH (requires admin privileges)
[Environment]::SetEnvironmentVariable(
    "Path",
    [Environment]::GetEnvironmentVariable("Path", "User") + ";$env:USERPROFILE\bin",
    "User"
)
```

## Usage

### Linux/Unix
```bash
filemerger [paths...] [-e extensions...] [-I ignore_dirs...] [-i ignore_files...] [-o output] [-v]
```

### Windows
```powershell
filemerger [paths...] [-Extensions ext1,ext2,...] [-IgnoreDirs dir1,dir2,...] [-IgnoreFiles file1,file2,...] [-OutputFile file] [-Verbose]
```

## Basic Examples

### Process Specific Files
```bash
# Linux/Unix
filemerger setup.py README.md src/main.cpp

# Windows
filemerger setup.py,README.md,src/main.cpp
```

### Process Directory with Extensions
```bash
# Linux/Unix
filemerger . -e js ts css

# Windows
filemerger . -Extensions js,ts,css
```

### Ignore Specific Directories
```bash
# Linux/Unix
filemerger . -I node_modules dist build

# Windows
filemerger . -IgnoreDirs node_modules,dist,build
```

## Advanced Use Cases

### 1. Web Project Files
```bash
# Linux/Unix
filemerger . -e js ts jsx tsx css scss -I node_modules .next dist build -i package-lock.json

# Windows
filemerger . -Extensions js,ts,jsx,tsx,css,scss -IgnoreDirs node_modules,.next,dist,build -IgnoreFiles package-lock.json
```

### 2. C/C++ Project Files with Multiple Directories
```bash
# Linux/Unix
filemerger src/* include/* lib/* -e cpp hpp h -I build cmake_build test -o project_source.txt

# Windows
filemerger src/*,include/*,lib/* -Extensions cpp,hpp,h -IgnoreDirs build,cmake_build,test -OutputFile project_source.txt
```

### 3. Documentation Files Only
```bash
# Linux/Unix
filemerger . -e md txt rst doc docx -I node_modules vendor -v

# Windows
filemerger . -Extensions md,txt,rst,doc,docx -IgnoreDirs node_modules,vendor -Verbose
```

### 4. Specific Files with Different Extensions
```bash
# Linux/Unix
filemerger config/* src/core/* -e json yaml yml -i secrets.yaml private.json

# Windows
filemerger config/*,src/core/* -Extensions json,yaml,yml -IgnoreFiles secrets.yaml,private.json
```

### 5. Mixed Files and Directories
```bash
# Linux/Unix
filemerger README.md docs/* src/examples/* -e md py js -I __pycache__ -o documentation.txt

# Windows
filemerger README.md,docs/*,src/examples/* -Extensions md,py,js -IgnoreDirs __pycache__ -OutputFile documentation.txt
```

## Features

- Cross-platform support (Linux/Unix and Windows)
- Recursive directory traversal
- Multiple file extension filtering
- Directory and file ignoring
- Wildcard pattern support
- Clear merge summary output
- UTF-8 encoding support
- Path trailing slash handling
- Case-insensitive extension matching

## Output Format

The merged file contains:
```
--- path/to/file1 ---
[content of file1]

--- path/to/file2 ---
[content of file2]

...
```

## Summary Output

After merging, displays:
```
Merge Summary:
Total files processed: X
Extensions included: [list of extensions]
Ignored directories: [list of ignored dirs]
Ignored files: [list of ignored files]

Processed files:
- file1
- file2
...

Output saved to: [output filename]
```

## Notes

- File paths are preserved relative to the source
- Binary files are automatically skipped
- Symlinks are followed
- Directory ignoring is applied recursively
- Extensions are case-insensitive
- Paths work with both forward and backward slashes
- Empty files are included but noted in verbose output

## Error Handling

- Invalid paths are skipped with warning (verbose mode)
- Inaccessible files are noted in verbose output
- Binary files are automatically detected and skipped
- UTF-8 encoding errors are handled gracefully
- Permission errors are reported clearly

## Best Practices

1. Use verbose mode (-v) when first running to verify file selection
2. Quote paths containing spaces
3. Use absolute paths when merging from different locations
4. Check output file location before running with large directories
5. Use appropriate ignore patterns to avoid unnecessary processing