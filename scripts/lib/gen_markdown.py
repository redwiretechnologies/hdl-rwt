import os
import copy
from lib.file_ops import get_path_name

def gen_all_markdown(titles, fns, keys, root_path, file_infos, final_hiers, dry_run):
    if not dry_run:
        gen_base_file(root_path)
        for t, f, k, fh in zip(titles, fns, keys, final_hiers):
            iterative_link_files(t, f, k, root_path+'/markdown', file_infos, {}, "utilization", fh, depth=1)

def gen_base_file(root_path):
    with open(root_path+'/utilization.md', 'w') as f:
        f.write("# FPGA Utilization\n\n---\n\n")
        f.write("* [Carriers](markdown/carriers.md)\n")
        f.write("* [SOMs](markdown/soms.md)\n")
        f.write("* [Personalities](markdown/personalities.md)\n")

def iterative_link_files(title, fn, keys, base_directory, file_infos, filters, parent, final_hier, depth):
    d = base_directory
    k = keys[0]
    labels = []
    labels, fis = get_labels(file_infos, k, filters)
    gen_link_file(title, fn, sorted(labels), d, parent)
    if len(keys) > 1:
        for l in labels:
            d_temp = d + '/' + fn
            f = {}
            if isinstance(k, list):
                temp = l.split(" - ")
                for i in range(0, len(k)):
                    f.update({k[i]: temp[i]})
            else:
                f = {k: l}
            iterative_link_files(l, l, keys[1:], d_temp, fis, f, fn, final_hier, depth+1)
    else:
        for l in labels:
            d_temp = d + '/' + fn
            f = {k: l}
            gen_content_file(l, l, d_temp, fis, f, fn, final_hier, depth+1)


def gen_link_file(title, fn, labels, directory, parent):
    os.system('mkdir -p "{}"'.format(directory))
    with open(directory+'/'+fn+'.md', 'w') as f:
        f.write("# {}\n\n[Back](<../{}.md>)\n\n---\n\n".format(title, parent))
        for label in labels:
            f.write('* [{}](<{}.md>)\n'.format(label, fn+'/'+label))

def gen_content_file(title, fn, directory, file_infos, filters, parent, final_hier, depth):
    os.system('mkdir -p "{}"'.format(directory))
    with open(directory+'/'+fn+'.md', 'w') as f:
        f.write('# {}\n\n[Back](<../{}.md>)\n\n---\n\n'.format(title, parent))
        write_content(f, file_infos, filters, final_hier, 2, depth)

def write_content(f, file_infos, filters, final_hier, level, depth):
    labels, fis = get_labels(file_infos, final_hier[0], filters)
    for l in sorted(labels):
        f.write("{} {}\n".format('#'*level, l))
        if len(final_hier) > 1:
            write_content(f, fis, {final_hier[0]: l}, final_hier[1:], level+1, depth)
        else:
            write_link_paths(f, fis, {final_hier[0]: l}, depth)

def write_link_paths(f, file_infos, filters, depth):
    labels, fis = get_labels(file_infos, "name", filters)
    for t in fis:
        table_path = get_path_name("../"*depth, t, "images") + "table.jpg"
        graph_path = get_path_name("../"*depth, t, "images") + "graph.png"
        full_util  = get_path_name("./", t, "utilization") + t["fn"]
        f.write('\n<p align="center">\n\t<img src="{}" />\n</p>\n'.format(table_path))
        f.write('\n<p align="center">\n\t<img src="{}" />\n</p>\n'.format(graph_path))
        f.write('\n`/usr/bin/python ./scripts/gui.py {}`\n\n'.format(full_util))

def get_labels(file_infos, key, filters):
    labels = set()
    fis = []
    for f in file_infos:
        compare = True
        for k in filters.keys():
            if f[k] != filters[k]:
                compare = False
                break
        if compare:
            s = ""
            if isinstance(key, list):
                for k in key:
                    if s != "":
                        s = s + " - "
                    s = s + f[k]
            else:
                s = f[key]
            labels.add(s)
            fis.append(f)
    return labels, fis
