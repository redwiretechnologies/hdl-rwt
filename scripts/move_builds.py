#!/usr/bin/python3

import os
import argparse
from lib.file_ops import *

file_ext = '.xsa'

def parse_args():
    parser = argparse.ArgumentParser(description='Export all Vivado builds to given directory')
    parser.add_argument("-p", "--path", help="Path to the proper meta directory")
    parser.add_argument("-i", "--imagedir", default='', help="Directory of XSA")
    parser.add_argument("-d", "--dry_run", action="store_true", help="Don't actually perform the copy")
    parser.add_argument("-l", "--filter", default='', help="A string (or comma-separated list of strings) that must be contained in the filepath to the image")
    parser.add_argument("-x", "--exclude", default='', help="A string (or comma-separated list of strings) that must not be contained in the filepath to the image")
    parser.add_argument("-v", "--verbose", action="store_true", help="Print the exported files")
    parser.add_argument("-n", "--newest", action="store_true", help="Use newest SOM rev")
    parser.add_argument("-s", "--personality", default='blank', help="Personality to use for boot")
    parser.add_argument("-b", "--boot", default='2cg', help="Board to use for main.xsa")
    parser.add_argument("-c", "--carrier", default='oxygen-bd', help="Carrier directory in meta build tree")

    args = parser.parse_args()
    return args

def is_eq(a, b):
    comp_list = ["personality", "carrier", "revision", "board"]
    for c in comp_list:
        if a[c] != b[c]:
            return False
    return True

def main():
    args = parse_args()
    a = find_files(file_ext, args.imagedir, args.filter, args.exclude)
    all_file_infos = [get_file_info(s, base_dir=args.imagedir, format_string='crpbs') for s in a]
    equivalents = { "gr-iio": "griio" }
    root_path = os.path.abspath(args.path)
    temp_list = all_file_infos
    i = 0
    while (i < len(all_file_infos)):
        temp1 = all_file_infos[i]
        j = i+1
        while (j < len(all_file_infos)):
            temp2 = all_file_infos[j]
            if is_eq(temp1, temp2):
                if not args.newest:
                    if float(temp1["som_rev"]) < float(temp2["som_rev"]):
                        del all_file_infos[j]
                        j = j-1
                    else:
                        del all_file_infos[i]
                        i = i-1
                        break
                else:
                    if float(temp1["som_rev"]) < float(temp2["som_rev"]):
                        del all_file_infos[i]
                        i = i-1
                        break
                    else:
                        del all_file_infos[j]
                        j = j-1
            j = j+1
        i = i+1

    a_dir = root_path+"/recipes-bsp/bitfiles/"
    bitfile_dirs = [name for name in os.listdir(a_dir) if os.path.isdir(os.path.join(a_dir, name))]
    for fi in all_file_infos:
        if fi["personality"] == args.personality:
            if fi["board"] == args.boot:
                copy_file(root_path+"/recipes-bsp/boot-xilinx-tools/"+args.carrier, fi, args.verbose, args.dry_run, style="", force_rename=True, name="main.xsa")
            copy_file(root_path+"/recipes-bsp/boot-xilinx-tools/"+args.carrier, fi, args.verbose, args.dry_run, style="b")
        for b in bitfile_dirs:
            equivalent = False
            if fi["personality"] in equivalents:
                equivalent = equivalents[fi["personality"]] in b
            if fi["personality"] in b or equivalent:
                copy_file(root_path+"/recipes-bsp/bitfiles/{}".format(b), fi, args.verbose, args.dry_run, style="b")

if __name__ == "__main__":
    main()
