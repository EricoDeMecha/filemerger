import os
import click
from pathlib import Path
from typing import List, Set, Optional


class FileMerger:
    def __init__(
        self,
        extensions: List[str],
        files_to_ignore: Set[str],
        folders_to_ignore: Set[str],
        verbose: bool = False
    ):
        self.extensions = {ext if ext.startswith('.') else f'.{ext}' for ext in extensions}
        self.files_to_ignore = files_to_ignore
        self.folders_to_ignore = folders_to_ignore
        self.processed_files: List[Path] = []
        self.verbose = verbose

    def debug(self, message: str) -> None:
        if self.verbose:
            click.echo(f"DEBUG: {message}", err=True)

    def is_folder_allowed(self, folder_path: Path) -> bool:
        return not any(part in self.folders_to_ignore for part in folder_path.parts)

    def is_file_allowed(self, file_path: Path) -> bool:
        if str(file_path) in self.files_to_ignore:
            self.debug(f"File {file_path} is in ignore list")
            return False
        
        extension = file_path.suffix.lower()
        has_valid_extension = extension in self.extensions
        if not has_valid_extension:
            self.debug(f"File {file_path} does not have a valid extension {self.extensions}")
        return has_valid_extension

    def process_single_file(self, file_path: Path, outfile) -> None:
        self.debug(f"Processing single file: {file_path}")
        self.debug(f"File exists: {file_path.exists()}")
        self.debug(f"Is file: {file_path.is_file()}")
        self.debug(f"File extension: {file_path.suffix}")
        self.debug(f"Valid extensions: {self.extensions}")
        
        if not file_path.exists():
            self.debug(f"File does not exist: {file_path}")
            return
            
        if not file_path.is_file():
            self.debug(f"Not a file: {file_path}")
            return
            
        if not self.is_file_allowed(file_path):
            self.debug(f"File not allowed: {file_path}")
            return
            
        try:
            content = file_path.read_text(encoding='utf-8')
            outfile.write(f"\n\n--- {file_path} ---\n\n")
            outfile.write(content)
            self.processed_files.append(file_path)
            self.debug(f"Successfully processed file: {file_path}")
        except Exception as e:
            self.debug(f"Error processing file {file_path}: {str(e)}")

    def process_directory(self, dir_path: Path, outfile) -> None:
        self.debug(f"Processing directory: {dir_path}")
        for root, dirs, files in os.walk(dir_path):
            current_path = Path(root)
            
            dirs[:] = [d for d in dirs if not any(
                part in self.folders_to_ignore 
                for part in (current_path / d).parts
            )]

            for file_name in sorted(files):
                file_path = current_path / file_name
                if self.is_file_allowed(file_path):
                    self.process_single_file(file_path, outfile)

    def merge_paths(self, paths: List[str], output_file: Path) -> None:
        self.debug(f"Starting merge with paths: {paths}")
        self.debug(f"Valid extensions: {self.extensions}")
        
        with open(output_file, 'w', encoding='utf-8') as outfile:
            for path_str in paths:
                path = Path(path_str)
                self.debug(f"\nProcessing path: {path_str}")
                
                if not '*' in path_str and path.is_file():
                    self.debug(f"Processing as direct file: {path}")
                    self.process_single_file(path, outfile)
                    continue

                if '*' in path_str:
                    self.debug(f"Processing as wildcard pattern: {path_str}")
                    parent = path.parent
                    matches = list(parent.glob(path.name))
                    self.debug(f"Matched paths: {matches}")
                    for matched_path in matches:
                        if matched_path.is_file():
                            self.process_single_file(matched_path, outfile)
                        elif matched_path.is_dir():
                            self.process_directory(matched_path, outfile)
                elif path.is_dir():
                    self.debug(f"Processing as directory: {path}")
                    self.process_directory(path, outfile)

    def print_summary(self) -> None:
        click.echo("\nMerge Summary:")
        click.echo(f"Processed {len(self.processed_files)} files:")
        for file in sorted(self.processed_files):
            click.echo(f"- {file}")


def process_args(args):
    """Process command line arguments to separate paths and options."""
    paths = []
    extensions = []
    ignore_files = []
    ignore_folders = ['cmake-build-debug', 'build', 'mbed-os', 'cmake_build']
    output = Path('merged_contents.txt')
    verbose = False
    
    i = 0
    while i < len(args):
        arg = args[i]
        
        if arg == '-e':
            i += 1
            # Collect all arguments until the next flag
            while i < len(args) and not args[i].startswith('-'):
                ext = args[i]
                extensions.append(ext if ext.startswith('.') else f'.{ext}')
                i += 1
            continue
            
        elif arg == '-i':
            i += 1
            while i < len(args) and not args[i].startswith('-'):
                ignore_files.append(args[i])
                i += 1
            continue
            
        elif arg == '-I':
            i += 1
            ignore_folders = []  # Reset default folders
            while i < len(args) and not args[i].startswith('-'):
                ignore_folders.append(args[i])
                i += 1
            continue
            
        elif arg == '-o':
            i += 1
            if i < len(args):
                output = Path(args[i])
            i += 1
            continue
            
        elif arg == '-v':
            verbose = True
            i += 1
            continue
            
        elif not arg.startswith('-'):
            paths.append(arg)
            i += 1
            continue
            
        i += 1
    
    return {
        'paths': paths,
        'extensions': extensions or ['.cpp', '.h', '.txt'],  # Default if none specified
        'ignore_files': ignore_files,
        'ignore_folders': ignore_folders,
        'output': output,
        'verbose': verbose
    }


def main():
    """Merge contents from specified files and folders into a single text file."""
    import sys
    
    args = process_args(sys.argv[1:])
    
    if args['verbose']:
        click.echo(f"Using extensions: {args['extensions']}")
        click.echo(f"Ignoring files: {args['ignore_files']}")
        click.echo(f"Ignoring folders: {args['ignore_folders']}")
        click.echo(f"Output file: {args['output']}")
        click.echo(f"Processing paths: {args['paths']}")
    
    merger = FileMerger(
        extensions=args['extensions'],
        files_to_ignore=set(args['ignore_files']),
        folders_to_ignore=set(args['ignore_folders']),
        verbose=args['verbose']
    )

    try:
        merger.merge_paths(args['paths'], args['output'])
        click.echo(f"\nSuccessfully merged contents into {args['output']}")
        merger.print_summary()
    except Exception as e:
        click.echo(f"Error: {str(e)}", err=True)
        sys.exit(1)


if __name__ == "__main__":
    main()