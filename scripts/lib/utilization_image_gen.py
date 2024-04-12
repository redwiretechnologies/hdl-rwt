import csv
import copy
import imgkit
import pandas as pd
import matplotlib.pyplot as plt
from prettytable import PrettyTable
from lib.file_ops import *

def gen_images(root_copy_dir, fi, verbose, dry_run, selected_properties, headers):
    data = {}
    util_file_path = get_path_name(root_copy_dir, fi, "utilization")
    image_file_path = get_path_name(root_copy_dir, fi, "images")
    if not dry_run:
        os.system('mkdir -p {}'.format(image_file_path))
        with open("{}utilization.csv".format(util_file_path)) as f:
            r = csv.reader(f)
            for row in r:
                new_row = [ s.strip() for s in row ]
                if new_row[0] in selected_properties.keys():
                    if new_row[0] not in data.keys():
                        del new_row[2:4]
                        data.update({selected_properties[new_row[0]]: new_row[1:]})

        p = PrettyTable(headers)
        for a,v in data.items():
            temp = copy.deepcopy(v)
            temp.insert(0, a)
            p.add_row(temp)

        p.format = True
        imgkit.from_string(p.get_html_string(attributes={"style":"margin-left:auto;margin-right:auto;width:500px"}), "{}table.jpg".format(image_file_path), options={'crop-x':'250', 'crop-w':'525', 'log-level':'none'})

        df = pd.DataFrame.from_dict(data, orient='index', columns=headers[1:])
        labels = [float(''.join(c for c in f if (c.isdigit() or c =='.'))) for f in df[headers[3]].values]
        fig, ax = plt.subplots()
        ax.bar(df.index.values, labels)
        ax.set_title('Resource Utilization')
        ax.set_xlabel('Resource')
        ax.set_ylabel('Utilization (%)')
        ax.set_xticks(ax.get_xticks())
        ax.set_xticklabels(df.index.values)
        ax.set_ylim([0, 108])
        rects = ax.patches
        for rect, label in zip(rects, labels):
            height = rect.get_height()
            ax.text(rect.get_x() + rect.get_width() / 2, height + 1, label,
                    ha='center', va='bottom')
        plt.savefig("{}graph.png".format(image_file_path))
        plt.close()
    if verbose:
        print("Created images for {}".format(image_file_path))
