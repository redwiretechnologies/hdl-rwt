#!/usr/bin/python3
import os
import argparse
import subprocess
import multiprocessing
from builds.supported_builds import *

# Get a selection from a list
def get_item_selection(selection_list, item_name, extra_text="", select_all = False):
    selecting = True
    valid_selections = [i for i in range(0, len(selection_list)+1)]
    if int(len(selection_list)) == 1:
        s = [1]
    else:
        while selecting and not select_all:
            print("Select {}(s){}".format(item_name, extra_text))
            for i, x in enumerate(selection_list):
                print("  {}: {}".format(i, x))
            print("  {}: All".format(len(selection_list)))
            print("")
            selection = input("Selection(s): ")
            s = [int(i) for i in selection.split()]
            selecting = False
            for a in s:
                if a not in valid_selections:
                    selecting = True
                    print("Invalid selection {}".format(a))
    if select_all:
        s = [int(len(selection_list))]
    selected = []
    for a in s:
        if a == len(selection_list):
            for b in selection_list:
                if b not in selected:
                    selected.append(b)
        else:
            if selection_list[a] not in selected:
                selected.append(selection_list[a])
    return selected

def get_all_selections(all_carriers=False, all_revisions=False, all_personalities=False, all_boards=False, all_som_revisions=False, assume_same=False):
    sc = get_item_selection([key for key in supported_builds.keys()], "Carrier", "", all_carriers)
    if not all_carriers:
        print("")

    all_selections = {}
    first_car = ""
    for car in sc:
        selections = {}
        revisions = supported_builds[car]["revisions"]
        revs = get_item_selection(revisions, "Revision", " for Carrier {}".format(car), all_revisions)
        if not all_revisions:
            print("")
        personalities = supported_builds[car]["images"]
        boards = supported_builds[car]["boards"]
        som_revisions = supported_builds[car]["som_rev"]

        if assume_same:
            if first_car == "":
                persons = get_item_selection(personalities, "Personality", " for all selected revisions of all selected carriers", all_personalities)
                if not all_personalities:
                    print("")
                bs = get_item_selection(boards, "Board", " for all personalities on all revisions of all selected carriers", all_boards)
                deepest_selections = {}
                for b in bs:
                    srevs = get_item_selection(som_revisions[b], "SOM Revision", " for board {} for all personalities on all revisions of all selected carriers".format(b), all_som_revisions)
                    if not all_som_revisions:
                        print("")
                    deepest_selections[b] = srevs
                if not all_boards:
                    print("")
                deeper_selections = {}
                for person in persons:
                    deeper_selections[person] = deepest_selections
                for rev in revs:
                    selections[rev] = deeper_selections
                first_car = car
                first_rev = revs[0]
            else:
                for rev in revs:
                    selections[rev] = all_selections[first_car][first_rev]
        else:
            for rev in revs:
                deeper_selections = {}
                persons = get_item_selection(personalities, "Personality", " for Revision {} of Carrier {}".format(rev, car), all_personalities)
                if not all_personalities:
                    print("")
                for person in persons:
                    deepest_selections = {}
                    bs = get_item_selection(boards, "Board", " for Personality {} on Revision {} of Carrier {}".format(person, rev, car), all_boards)
                    if not all_boards:
                        print("")
                    for b in bs:
                        srevs = get_item_selection(som_revisions[b], "SOM Revision", " for Board {} for Personality {} on Revision {} of Carrier {}".format(b, person, rev, car), all_som_revisions)
                        if not all_som_revisions:
                            print("")
                        deepest_selections[b] = srevs
                    deeper_selections[person] = deepest_selections
                selections[rev] = deeper_selections
        all_selections[car] = selections
    return all_selections

# cd to the proper directory defined by the parameters
def cd_to_dir(script_dir, carrier, revision, personality, dry_run):
    if dry_run:
        print("cd {}/../projects/{}/{}/{}".format(script_dir, personality, carrier, revision))
    else:
        os.chdir("{}/../projects/{}/{}/{}".format(script_dir, personality, carrier, revision))
    print("Moved to directory {}/{}/{}".format(personality, carrier, revision))

# Make a singular library
def make_library(dry_run, n=1):
    print("Making library")
    if dry_run:
        ret = 0
        print("make -j {} lib | sed 's/^/  /'".format(n))
    else:
        try:
            proc = subprocess.Popen(["make", "-j", str(n), "lib"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            proc2 = subprocess.Popen(["sed", 's/^/  /'], stdin=proc.stdout, stdout=subprocess.PIPE)
            ret = proc.wait()
            if ret != 0:
                for l in proc2.stdout:
                    print(l.decode("utf-8").rstrip())
            proc = None
        except KeyboardInterrupt:
            if proc != None:
                proc.kill()
            ret = 1
    if ret != 0:
        print("ERROR: Failed to make library!!")

    return ret

# Construct the proper argument to pass to make for the given boards
def create_board_list(boards, projects_only):
    interm_board_list = []
    for board, srevs in boards.items():
        for srev in srevs:
            interm_board_list.append("{}-{}".format(board, srev))
    board_list = []
    projects = ""
    if projects_only:
        projects = "proj-"
    for b in interm_board_list:
        board_list.append(projects+b)
    return board_list

# Make a singular board
def make_board(carrier, revision, personality, b, dry_run):
    print("Making board {}".format(b))
    if dry_run:
        ret = 0
        print("make {} | sed 's/^/  /'".format(b))
    else:
        try:
            proc = subprocess.Popen(['make', b], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            proc2 = subprocess.Popen(["sed", 's/^/  /'], stdin=proc.stdout, stdout=subprocess.PIPE)
            ret = proc.wait()
            if ret != 0:
                for l in proc2.stdout:
                    print(l.decode("utf-8").rstrip())
            proc = None
        except KeyboardInterrupt:
            if proc != None:
                proc.kill()
            print("")
            print("Received keyboard interrupt. Terminating")
            exit(1)

    if ret != 0:
        print("ERROR: Failed to make Personality {} for Carrier {} {} and Board {}!!".format(personality, carrier, revision, b))

# Function originally intended for single core usage
def cd_and_make(carrier, revision, personality, board_list, dry_run):
    cwd = os.getcwd()
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)

    cd_to_dir(script_dir, personality, carrier, revision, dry_run)

    if make_library(dry_run) != 0:
        os.chdir(cwd)
        return

    for b in board_list:
        make_board(personality, carrier, revision, b, dry_run)
        if dry_run:
            print("Returning to CWD")
        else:
            os.chdir(cwd)

# Create the list of builds to be done
def iterate_selections(selections, projects_only, dry_run):
    lib_list = []
    build_list = []
    for carrier, val in selections.items():
        for revision, val2 in val.items():
            for personality, boards in val2.items():
                lib_list.append([carrier, revision, personality, dry_run])
                for b in create_board_list(boards, projects_only):
                    build_list.append([carrier, revision, personality, b, dry_run])
    return lib_list, build_list

# cd to an individual carrier, revision, personality combination and make the library
def cd_and_make_lib(arguments, n):
    cwd = os.getcwd()
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)

    cd_to_dir(script_dir, *arguments)

    ret = make_library(arguments[-1], n)
    os.chdir(cwd)

    return ret

# cd to an individual carrier, revision, personality and make a given board
def cd_and_make_board(arguments):
    cwd = os.getcwd()
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)

    stripped_board = arguments[0:3]
    stripped_board.append(arguments[-1])

    cd_to_dir(script_dir, *stripped_board)

    make_board(*arguments)
    os.chdir(cwd)

def multi_process_builds(n, libs, builds):
    pool = multiprocessing.Pool(n)
    results = []
    for lib in libs:
        results.append(cd_and_make_lib(lib, n))
    for lib, result in zip(libs, results):
        if result != 0:
            print("ERROR: Failed to make libraries for Personality {} for Carrier {}".format(lib[2], lib[0]+" "+lib[1]))
            for b in builds:
                if lib[0:3] == b[0:3]:
                    builds.remove(b)
    pool.map(cd_and_make_board, builds)

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--carriers", help="Automatically select all carriers", action="store_true")
    parser.add_argument("-r", "--revisions", help="Automatically select all revisions", action="store_true")
    parser.add_argument("-p", "--personalities", help="Automatically select all personalities", action="store_true")
    parser.add_argument("-b", "--boards", help="Automatically select all boards", action="store_true")
    parser.add_argument("-s", "--som_revisions", help="Automatically select all som_revisions", action="store_true")
    parser.add_argument("-o", "--only_projects", help="Only create projects", action="store_true")
    parser.add_argument("-a", "--assume_same", help="Assume the same personality and board choices for each selected carrier and revision", action="store_true")
    parser.add_argument("-d", "--dry_run", help="Don't actually run any commands. Just print them", action="store_true")
    parser.add_argument("-n", "--num_builds", type=int, default=1, help="Number of simultaneous make commands to run.")
    args = parser.parse_args()
    return args

def main():
    args = parse_args()
    try:
        selections = get_all_selections(args.carriers, args.revisions, args.personalities, args.boards, args.som_revisions, False)
    except KeyboardInterrupt:
        print("")
        print("Received keyboard interrupt. Terminating")
        exit(1)
    lib_list, build_list = iterate_selections(selections, args.only_projects, args.dry_run)
    multi_process_builds(args.num_builds, lib_list, build_list)

if __name__=="__main__":
    main()
