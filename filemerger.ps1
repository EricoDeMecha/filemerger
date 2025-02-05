param(
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Paths,
    
    [Parameter()]
    [string[]]$Extensions,
    
    [Parameter()]
    [Alias("I")]
    [string[]]$IgnoreDirs,
    
    [Parameter()]
    [Alias("i")]
    [string[]]$IgnoreFiles,
    
    [Parameter()]
    [Alias("o")]
    [string]$OutputFile = "merged_contents.txt",
    
    [Parameter()]
    [Alias("v")]
    [switch]$Verbose,
    
    [Parameter()]
    [switch]$Help
)

# Initialize arrays
$processedFiles = @()
$defaultExtensions = @(".cpp", ".h", ".txt")

function Show-Usage {
    Write-Host "Usage: filemerger [paths...] [-Extensions ext1,ext2,...] [-IgnoreDirs dir1,dir2,...] [-IgnoreFiles file1,file2,...] [-OutputFile file] [-Verbose]"
    Write-Host "  paths          Files or directories to process"
    Write-Host "  -Extensions    File extensions to include (without dot)"
    Write-Host "  -IgnoreDirs    Directories to ignore (with or without trailing slash)"
    Write-Host "  -IgnoreFiles   Specific files to ignore"
    Write-Host "  -OutputFile    Output file (default: merged_contents.txt)"
    Write-Host "  -Verbose       Verbose output"
    exit
}

if ($Help -or $Paths.Count -eq 0) {
    Show-Usage
}

# Clean path (remove trailing backslash)
function Clean-Path {
    param([string]$path)
    return $path.TrimEnd('\', '/')
}

# Initialize extensions
if ($Extensions.Count -eq 0) {
    $Extensions = $defaultExtensions
} else {
    $Extensions = $Extensions | ForEach-Object { if ($_ -match '^\.' ) { $_ } else { ".$_" } }
}

# Clean ignore directories
$IgnoreDirs = $IgnoreDirs | ForEach-Object { Clean-Path $_ }

# Function to check if file should be ignored
function Test-ShouldIgnoreFile {
    param([string]$file)
    $basename = Split-Path $file -Leaf
    return $IgnoreFiles -contains $basename
}

# Function to process a single file
function Process-File {
    param([string]$file)
    
    if (-not (Test-Path $file -PathType Leaf)) {
        if ($Verbose) { Write-Host "File does not exist or is not a file: $file" }
        return
    }
    
    $extension = [System.IO.Path]::GetExtension($file).ToLower()
    if (-not ($Extensions -contains $extension)) {
        if ($Verbose) { Write-Host "File does not have a valid extension: $file" }
        return
    }
    
    if (Test-ShouldIgnoreFile $file) {
        if ($Verbose) { Write-Host "Ignoring file: $file" }
        return
    }
    
    if ($Verbose) { Write-Host "Processing file: $file" }
    
    Add-Content -Path $OutputFile -Value "`n`n--- $file ---`n"
    Get-Content $file | Add-Content -Path $OutputFile
    $script:processedFiles += $file
}

# Clear output file
Set-Content -Path $OutputFile -Value ""

# Process all paths
foreach ($path in $Paths) {
    $path = Clean-Path $path
    
    if (Test-Path $path -PathType Leaf) {
        Process-File $path
    }
    elseif (Test-Path $path -PathType Container) {
        # Get all files recursively, excluding ignored directories
        Get-ChildItem -Path $path -File -Recurse | 
            Where-Object {
                $parent = $_.Directory
                -not ($IgnoreDirs | Where-Object { $parent.FullName -match [regex]::Escape($_) })
            } |
            ForEach-Object {
                Process-File $_.FullName
            }
    }
}

# Print summary
Write-Host "`nMerge Summary:"
Write-Host "Total files processed: $($processedFiles.Count)"
Write-Host "Extensions included: $($Extensions -join ', ')"
if ($IgnoreDirs.Count -gt 0) {
    Write-Host "Ignored directories: $($IgnoreDirs -join ', ')"
}
if ($IgnoreFiles.Count -gt 0) {
    Write-Host "Ignored files: $($IgnoreFiles -join ', ')"
}
Write-Host "`nProcessed files:"
$processedFiles | ForEach-Object { Write-Host "- $_" }
Write-Host "`nOutput saved to: $OutputFile"