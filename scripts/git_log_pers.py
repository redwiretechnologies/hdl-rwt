#!/usr/bin/python3
import sys

with open(sys.argv[1], 'w') as f:
    for i in sys.argv[2].split('&'):
        f.write(i)
        f.write('\n')
    f.write('\n')
    temp_l = sys.argv[3:]
    with open("git_log.txt", 'r') as g:
        flag = True
        lines = g.readlines()
        for line in lines:
            if line.strip() in temp_l:
                flag = True
            if flag:
                f.write(line)
                if "---------" in line:
                    flag = False
                    f.write('\n')
