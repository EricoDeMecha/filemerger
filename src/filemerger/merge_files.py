import os
import click
from pathlib import Path
from typing import List, Set, Optional, Dict
import fnmatch


class FileMerger:
    def __init__(
        self,
        extensions: Set[str],
        files_to_ignore: Set[str],
        folders_to_ignore: Set[str],
        files_to_merge: Optional[Set[str]] = None,
        folders_to_merge: Optional[Set[str]] = None,
    ):
        self.extensions = extensions
        self.files_to_ignore = files_to_ignore
        self.folders_to_ignore = folders_to_ignore
        self.files_to_merge = files_to_merge
        self.folders_to_merge = folders_to_merge
        self.processed_files: List[Path] = []
        self.skipped_folders: List[Path] = []

    def is_folder_allowed(self, folder_path: Path) -> bool:
        """Check if a folder should be processed."""
        if any(part in self.folders_to_ignore for part in folder_path.parts):
            return False

        if not self.folders_to_merge:
            return True

        # Check if this folder or any of its parents are in folders_to_merge
        current = folder_path
        while str(current) != '.':
            if str(current) in self.folders_to_merge:
                return True
            current = current.parent
        return False

    def is_file_allowed(self, file_path: Path) -> bool:
        """Check if a file should be processed."""
        if str(file_path) in self.files_to_ignore:
            return False

        return any(str(file_path).endswith(ext) for ext in self.extensions)

    def merge_files(self, output_file: Path) -> None:
        """Merge files from specified folders."""
        with open(output_file, 'w', encoding='utf-8') as outfile:
            for folder in self.folders_to_merge:
                folder_path = Path(folder)
                if not folder_path.exists():
                    continue

                for root, dirs, files in os.walk(folder_path):
                    current_path = Path(root)
                    
                    # Skip ignored folders
                    dirs[:] = [d for d in dirs if not any(
                        part in self.folders_to_ignore 
                        for part in (current_path / d).parts
                    )]

                    for file_name in sorted(files):
                        file_path = current_path / file_name
                        if self.is_file_allowed(file_path):
                            try:
                                content = file_path.read_text(encoding='utf-8')
                                outfile.write(f"\n\n--- {file_path} ---\n\n")
                                outfile.write(content)
                                self.processed_files.append(file_path)
                            except UnicodeDecodeError:
                                click.echo(f"Skipping binary file: {file_path}", err=True)
                            except Exception as e:
                                click.echo(f"Error processing {file_path}: {str(e)}", err=True)

    def print_summary(self) -> None:
        """Print merge summary to terminal."""
        click.echo("\nMerge Summary:")
        click.echo(f"Processed {len(self.processed_files)} files:")
        for file in self.processed_files:
            click.echo(f"- {file}")


@click.command()
@click.option(
    '-o', '--output',
    type=click.Path(dir_okay=False, path_type=Path),
    default=Path('merged_contents.txt'),
    help='Output file name'
)
@click.option(
    '-e', '--extensions',
    multiple=True,
    default=['.cpp', '.h', '.txt', '.json'],
    help='File extensions to include'
)
@click.option(
    '-i', '--ignore-files',
    multiple=True,
    default=[],
    help='Files to ignore'
)
@click.option(
    '-I', '--ignore-folders',
    multiple=True,
    default=['cmake-build-debug', 'build', 'mbed-os', 'cmake_build'],
    help='Folders to ignore'
)
@click.argument('folders', nargs=-1, required=True)
def main(
    output: Path,
    extensions: tuple,
    ignore_files: tuple,
    ignore_folders: tuple,
    folders: tuple
):
    """Merge files from specified folders into a single text file.
    
    Examples:
    
    \b
    # Merge all .cpp and .h files from specific folders
    filemerger -e .cpp .h hmi/gfx drivers/display
    
    \b
    # Merge with specific extensions and ignore patterns
    filemerger -e .cpp .h -I build test hmi/gfx drivers/display
    """
    # Normalize folder paths
    normalized_folders = set()
    for folder in folders:
        folder_path = Path(folder)
        if folder_path.is_dir():
            normalized_folders.add(str(folder_path))
        elif '*' in folder:
            # Handle wildcard patterns
            parent = Path(folder).parent
            for path in parent.glob(Path(folder).name):
                if path.is_dir():
                    normalized_folders.add(str(path))

    if not normalized_folders:
        click.echo("No valid folders specified for merging.", err=True)
        raise click.Abort()

    merger = FileMerger(
        extensions=set(extensions),
        files_to_merge=None,
        files_to_ignore=set(ignore_files),
        folders_to_ignore=set(ignore_folders),
        folders_to_merge=normalized_folders
    )

    try:
        merger.merge_files(output)
        click.echo(f"\nSuccessfully merged contents into {output}")
        merger.print_summary()
    except Exception as e:
        click.echo(f"Error: {str(e)}", err=True)
        raise click.Abort()


if __name__ == "__main__":
    main()