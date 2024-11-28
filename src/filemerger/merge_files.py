import os
import glob
import argparse

def merge_files(root_dir, output_file, extensions, files_to_merge, files_to_ignore, folders_to_ignore, folders_to_merge):
    files_to_merge = files_to_merge or []
    files_to_ignore = files_to_ignore or []
    folders_to_ignore = folders_to_ignore or []
    folders_to_merge = folders_to_merge or []

    with open(output_file, 'w', encoding='utf-8') as outfile:
        for root, dirs, files in os.walk(root_dir):
            # Skip ignored folders
            dirs[:] = [d for d in dirs if d not in folders_to_ignore]
            
            # Process only merge folders if specified
            if folders_to_merge and os.path.relpath(root, root_dir) not in folders_to_merge:
                continue

            for filename in files:
                file_path = os.path.join(root, filename)
                relative_path = os.path.relpath(file_path, root_dir)

                # Check if file should be processed
                if files_to_merge and relative_path not in files_to_merge:
                    continue
                if relative_path in files_to_ignore:
                    continue
                if not any(filename.endswith(ext) for ext in extensions):
                    continue

                outfile.write(f"\n\n--- {relative_path} ---\n\n")
                try:
                    with open(file_path, 'r', encoding='utf-8') as infile:
                        outfile.write(infile.read())
                except UnicodeDecodeError:
                    outfile.write(f"Error: Unable to read {relative_path} - it may be a binary file.\n")

def main():
    parser = argparse.ArgumentParser(description="Merge contents of specific files into a single text file.")
    parser.add_argument("-r", "--root", default=".", help="Root directory to start searching from")
    parser.add_argument("-o", "--output", default="merged_contents.txt", help="Output file name")
    parser.add_argument("-e", "--extensions", nargs="+", default=[".cpp", ".h", ".txt", ".json"], help="File extensions to include")
    parser.add_argument("-m", "--merge", nargs="*", default=[], help="Specific files to merge (relative paths)")
    parser.add_argument("-i", "--ignore_files", nargs="*", default=[], help="Files to ignore (relative paths)")
    parser.add_argument("-I", "--ignore_folders", nargs="*", default=["cmake-build-debug", "build", "mbed-os", "cmake_build"], help="Folders to ignore")
    parser.add_argument("-M", "--merge_folders", nargs="*", default=[], help="Specific folders to merge (relative paths)")

    args = parser.parse_args()

    merge_files(args.root, args.output, args.extensions, args.merge, args.ignore_files, args.ignore_folders, args.merge_folders)
    print(f"Merged contents have been written to {args.output}")

if __name__ == "__main__":
    main()