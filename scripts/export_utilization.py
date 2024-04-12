#!/usr/bin/env python3

import argparse
from lib.utilization_image_gen import *
from lib.gen_markdown import *

file_ext = '.utilization'
selected_properties = { "CLB": "CLB",
                        "Block RAM Tile": "BRAM",
                        "LUT as Logic": "LUT",
                        "LUT as Memory": "LUTRAM",
                        "CLB Registers": "FF",
                        "DSPs": "DSP",
                      }
headers = [ "Resource", "Used", "Available", "% Utilized" ]

script_files = ['utils/vivado_rpt_parser.py', 'utils/gui.py']

titles = ["Carriers", "Personality", "SOM"]
fns = ["carriers", "personalities", "soms"]
keys = [["carrier", "revision", "board"],
        ["personality", "carrier", "revision", "board"],
        [["board", "som_rev"], "carrier", "revision"]
       ]
final_hiers = [['som_rev', 'personality'],
               ['som_rev'],
               ['personality']
              ]

def parse_args():
    parser = argparse.ArgumentParser(description='Export utilization to given directory')
    parser.add_argument("-p", "--path", help="Export path for all of the utilization files")
    parser.add_argument("-s", "--subdir", default='', help="Subdirectory of projects to look in such that a subsection may be updated")
    parser.add_argument("-d", "--dry_run", action="store_true", help="Don't actually perform the copy")
    parser.add_argument("-l", "--filter", default='', help="A string (or comma-separated list of strings) that must be contained in the filepath to the image")
    parser.add_argument("-x", "--exclude", default='', help="A string (or comma-separated list of strings) that must not be contained in the filepath to the image")
    parser.add_argument("-v", "--verbose", action="store_true", help="Print the exported files")
    args = parser.parse_args()
    return args

def main():
    args = parse_args()
    a = find_files(file_ext, get_directory(args.subdir), args.filter, args.exclude, 'd')
    all_file_infos = [get_file_info(s) for s in a]
    root_path = os.path.abspath(args.path)
    for fi in all_file_infos:
        copy_file(root_path, fi, args.verbose, args.dry_run, stem="utilization", my_type='d')
        gen_images(root_path, fi, args.verbose, args.dry_run, selected_properties, headers)
    a = find_files('.rpt', root_path, '', '', 'f')
    all_file_infos = [get_file_info(s, base_dir=root_path+'/utilization/', format_string='crpbs') for s in a]
    gen_all_markdown(titles, fns, keys, root_path, all_file_infos, final_hiers, args.dry_run)
    if not args.dry_run:
        copy_files_direct(script_files, root_path, 'scripts')

if __name__ == "__main__":
    main()
