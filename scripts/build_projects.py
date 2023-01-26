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

def get_all_selections(all_carriers=False, all_revisions=False, all_personalities=False, all_boards=False, all_som_revisions=False):
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
        for rev in revs:
            deeper_selections = {}
            if "special" in supported_builds[car].keys():
                if rev in supported_builds[car]["special"].keys():
                    personalities = supported_builds[car]["special"][rev]["images"]
                    boards = supported_builds[car]["special"][rev]["boards"]
                    som_revisions = supported_builds[car]["special"][rev]["som_rev"]
                else:
                    personalities = supported_builds[car]["images"]
                    boards = supported_builds[car]["boards"]
                    som_revisions = supported_builds[car]["som_rev"]
            else:
                personalities = supported_builds[car]["images"]
                boards = supported_builds[car]["boards"]
                som_revisions = supported_builds[car]["som_rev"]
            persons = get_item_selection(personalities, "Personality", " for Revision {} of Carrier {}".format(rev, car), all_personalities)
            if not all_personalities:
                print("")
            for person in persons:
                deepest_selections = {}
                if "special" in supported_builds[car].keys():
                    if person in supported_builds[car]["special"].keys():
                        boards = supported_builds[car]["special"][person]["boards"]
                        som_revisions = supported_builds[car]["special"][person]["som_rev"]
                    else:
                        boards = supported_builds[car]["boards"]
                        som_revisions = supported_builds[car]["som_rev"]
                else:
                    boards = supported_builds[car]["boards"]
                    som_revisions = supported_builds[car]["som_rev"]
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
def make_library(clean, dry_run, n=1):
    print("Making library")
    if dry_run:
        ret = 0
        if clean:
            print("make -j {} clean-libs | sed 's/^/  /'".format(n))
        else:
            print("make -j {} lib | sed 's/^/  /'".format(n))
    else:
        try:
            if clean:
                proc = subprocess.Popen(["make", "-j", str(n), "clean-libs"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            else:
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
def create_board_list(boards, projects_only, clean):
    interm_board_list = []
    for board, srevs in boards.items():
        for srev in srevs:
            interm_board_list.append("{}-{}".format(board, srev))
    board_list = []
    projects = ""
    clean_str = ""
    if projects_only:
        projects = "proj-"
    if clean:
        clean_str = "clean-"
    for b in interm_board_list:
        board_list.append(projects+clean_str+b)
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
def iterate_selections(selections, projects_only, clean, clean_lib, dry_run):
    lib_list = []
    build_list = []
    for carrier, val in selections.items():
        for revision, val2 in val.items():
            for personality, boards in val2.items():
                lib_list.append([carrier, revision, personality, clean_lib, dry_run])
                for b in create_board_list(boards, projects_only, clean):
                    build_list.append([carrier, revision, personality, b, dry_run])
    return lib_list, build_list

# cd to an individual carrier, revision, personality combination and make the library
def cd_and_make_lib(arguments, n):
    cwd = os.getcwd()
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)

    stripped_lib = arguments[0:3]
    stripped_lib.append(arguments[-1])

    cd_to_dir(script_dir, *stripped_lib)

    ret = make_library(arguments[-2], arguments[-1], n)
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
    print("Completed "+" ".join(arguments[0:-1]))
    return True

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
    r = pool.imap(cd_and_make_board, builds)
    pool.close()
    pool.join()

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c", "--carriers", help="Automatically select all carriers", action="store_true")
    parser.add_argument("-r", "--revisions", help="Automatically select all revisions", action="store_true")
    parser.add_argument("-p", "--personalities", help="Automatically select all personalities", action="store_true")
    parser.add_argument("-b", "--boards", help="Automatically select all boards", action="store_true")
    parser.add_argument("-s", "--som_revisions", help="Automatically select all som_revisions", action="store_true")
    parser.add_argument("-o", "--only_projects", help="Only create projects", action="store_true")
    parser.add_argument("--clean", help="Clean instead of creating projects", action="store_true")
    parser.add_argument("--clean_lib", help="Clean libraries instead of creating projects", action="store_true")
    parser.add_argument("-d", "--dry_run", help="Don't actually run any commands. Just print them", action="store_true")
    parser.add_argument("-n", "--num_builds", type=int, default=1, help="Number of simultaneous make commands to run.")
    parser.add_argument("-g", "--git_log", help="Create a log of the git repos to put into each xsa file", action="store_true")
    args = parser.parse_args()
    return args

def create_git_log():
    cwd = os.getcwd()
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)
    os.system(script_dir + "/create_git_log.sh")

# Create the list of builds to be done
def git_log_iterate_selections(selections):
    build_list = []
    for carrier, val in selections.items():
        for revision, val2 in val.items():
            for personality, val3 in val2.items():
                for board, som_rev in val3.items():
                    for s in som_rev:
                        build_list.append([str(personality), str(carrier), str(revision), "build", str(board), str(s)])
    return build_list

def add_git_log(selections):
    cwd = os.getcwd()
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)

    build_list = git_log_iterate_selections(selections)

    for b in build_list:
        build_dir = script_dir + "/../projects/" + '/'.join(b)
        subprocess.call("/bin/bash -c 'zip -u {}/*.sdk/*.xsa git_log.txt > /dev/null'".format(build_dir), shell=True)

def main():
    args = parse_args()
    try:
        if args.git_log:
            create_git_log()
        selections = get_all_selections(args.carriers, args.revisions, args.personalities, args.boards, args.som_revisions)
    except KeyboardInterrupt:
        print("")
        print("Received keyboard interrupt. Terminating")
        exit(1)
    lib_list, build_list = iterate_selections(selections, args.only_projects, args.clean, args.clean_lib, args.dry_run)
    multi_process_builds(args.num_builds, lib_list, build_list)
    if args.git_log:
        add_git_log(selections)

if __name__=="__main__":
    main()
