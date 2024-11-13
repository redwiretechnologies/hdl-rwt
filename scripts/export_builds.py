#!/usr/bin/python3

# SPDX-License-Identifier: Apache-2.0

import os
import argparse
from lib.file_ops import *

file_ext = '.xsa'

def parse_args():
    parser = argparse.ArgumentParser(description='Export all Vivado builds to given directory')
    parser.add_argument("-p", "--path", help="Export path for all of the images")
    parser.add_argument("-s", "--subdir", default='', help="Subdirectory of projects to look in such that a subsection may be updated")
    parser.add_argument("-f", "--force_rename", action="store_true", help="Force rename of files to a different name")
    parser.add_argument("-d", "--dry_run", action="store_true", help="Don't actually perform the copy")
    parser.add_argument("-n", "--name", default='system{}'.format(file_ext), help="Force rename of files to a different name")
    parser.add_argument("-l", "--filter", default='', help="A string (or comma-separated list of strings) that must be contained in the filepath to the image")
    parser.add_argument("-x", "--exclude", default='', help="A string (or comma-separated list of strings) that must not be contained in the filepath to the image")
    parser.add_argument("-v", "--verbose", action="store_true", help="Print the exported files")
    parser.add_argument("-c", "--convert", action="store_true", help="Convert to download.bin")
    parser.add_argument("-t", "--style", default='crpbs', help="A directory sorting order. The default value is crpbs representing the file hierarchy [carrier board]/[carrier board revision]/[personality]/[SOM]/[SOM revision]. Reordering the characters in the string will reorder the hierarchy accordingly.")
    args = parser.parse_args()
    return args


def main():
    args = parse_args()
    a = find_files(file_ext, get_directory(args.subdir), args.filter, args.exclude)
    all_file_infos = [get_file_info(s) for s in a]
    root_path = os.path.abspath(args.path)
    for fi in all_file_infos:
        if args.convert:
            os.system("./scripts/create_download_bin.sh {} > /dev/null 2> /dev/null".format(fi["name"]))
            fi["name"] = "download.bin"
            fi["fn"]   = "download.bin"
        copy_file(root_path, fi, args.verbose, args.dry_run, force_rename=args.force_rename, name=args.name, style=args.style)

if __name__ == "__main__":
    main()
