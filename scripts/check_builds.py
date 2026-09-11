#!/usr/bin/env python3

# SPDX-License-Identifier: Apache-2.0

import os

def merge(a, b):
    a_keys = list(a.keys())
    b_keys = list(b.keys())
    for k1 in b_keys:
        if k1 not in a_keys:
            a[k1] = b[k1]
        elif type(a[k1]) is dict:
            merge(a[k1], b[k1])
        else:
            a[k1] = a[k1] + b[k1]

def print_dict(d):
    num_spaces = 4
    for p in sorted(d.keys()):
        print(' '*num_spaces, p)
        for c in sorted(d[p].keys()):
            for r in d[p][c].keys():
                print(' '*2*num_spaces, c, '-', r)
                soms = sorted(list(d[p][c][r].keys()))
                adjust = len(max(soms, key=len))
                for s in soms:
                    srs = list(d[p][c][r][s].keys())
                    print(' '*3*num_spaces, s.ljust(adjust), '-', srs)

path = "./projects"
xsafiles = [os.path.join(d, x)
            for d, dirs, files in os.walk(path)
            for x in files if x.endswith(".xsa")]
xprfiles = [os.path.join(d, x)
            for d, dirs, files in os.walk(path)
            for x in files if x.endswith(".xpr")]

completed = {}
failed = {}
project_only = {}

for s in xsafiles:
    l  = s.split("/")
    p  = l[2]
    c  = l[3]
    r  = l[4]
    s  = l[6]
    sr = l[7]
    path_string = "/".join(l[0:7])
    xprfiles = [i for i in xprfiles if path_string not in i]

    d = {p: {c: {r: {s: {sr: ""}}}}}

    if "bad_timing" in l[-1]:
	    merge(failed, d)
    else:
        merge(completed, d)

for s in xprfiles:
    l  = s.split("/")
    p  = l[2]
    c  = l[3]
    r  = l[4]
    s  = l[6]
    sr = l[7]

    d = {p: {c: {r: {s: {sr: ""}}}}}
    merge(project_only, d)

if completed:
    print("Successful Builds:")
    print_dict(completed)
    print("")
if failed:
    print("Failed Builds:")
    print_dict(failed)
    print("")
if project_only:
    print("Project Only:")
    print_dict(project_only)
    print("")
print("Total finished: {}".format(len(xsafiles)+len(xprfiles)))
