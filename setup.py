from setuptools import setup, find_packages

setup(
    name="filemerger",
    version="0.1.0",
    package_dir={"": "src"},
    packages=find_packages(where="src"),
    entry_points={
        'console_scripts': [
            'filemerger=filemerger.merge_files:main',
        ],
    },
    description="A utility to merge contents of specific files into a single text file",
    author="EricoDeMecha",
    author_email="techcider4134@gmail.com",
    python_requires=">=3.6",
)