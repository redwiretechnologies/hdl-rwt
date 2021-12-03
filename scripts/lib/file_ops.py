import os

def find_files(ext, directory, my_filter, exclude, my_type=''):
    all_files = []
    for root, dirs, files in os.walk(directory):
        if my_type == 'd':
            t = dirs
        else:
            t = files
        for file in t:
            if file.lower().endswith(ext):
                temp = os.path.join(root, file)
                if my_filter in temp or my_filter == '':
                    if exclude not in temp or exclude == '':
                        all_files.append(temp)
    return all_files

def get_directory(subdir, base_dir='projects/'):
    script_path = os.path.abspath(__file__)
    script_dir = os.path.dirname(script_path)

    if subdir.endswith('/') or subdir == '':
        sd = subdir
    else:
        sd = subdir+'/'
    return "{}/../../{}{}".format(script_dir, base_dir, sd)

def get_file_info(file, base_dir='scripts/lib/../../projects/', format_string='pcr bs'):
    file_info = {}
    file_info["name"] = file
    if base_dir[-1] != '/':
        base_dir = base_dir+'/'
    f = file.split('{}'.format(base_dir))[1]
    a = f.split('/')
    file_info["personality"] = a[format_string.index('p')]
    file_info["carrier"] = a[format_string.index('c')]
    file_info["revision"] = a[format_string.index('r')]
    file_info["board"] = a[format_string.index('b')]
    file_info["som_rev"] = a[format_string.index('s')]
    file_info["fn"] = a[-1]
    return file_info

def copy_file(root_copy_dir, fi, verbose, dry_run, stem='', my_type='', force_rename=False, name='', style="crpbs"):
    file_copy_path = get_path_name(root_copy_dir, fi, stem, style)
    if my_type == 'd':
        if not dry_run:
            os.system('mkdir -p {}'.format(file_copy_path))
            os.system('cp {}/* {}'.format(fi["name"], file_copy_path))
        if verbose:
            print("Exported file {}/* to\n              {}".format(fi["name"], file_copy_path))
    else:
        if force_rename:
            file_copy_path_w_name = file_copy_path + name
        else:
            file_copy_path_w_name = file_copy_path + fi["fn"]
        if not dry_run:
            os.system('mkdir -p {}'.format(file_copy_path))
            os.system('cp {} {}'.format(fi["name"], file_copy_path_w_name))
        if verbose:
            print("Exported file {} to\n              {}".format(fi["name"], file_copy_path_w_name))

def copy_files_direct(files, root_path, directory_name):
    os.system('mkdir -p {}'.format(root_path+'/'+directory_name))
    for f in files:
        os.system('cp {} {}'.format(f, root_path+'/'+directory_name))

def get_path_name(root_copy_dir, fi, stem, style="crpbs"):
    if root_copy_dir.endswith('/'):
        copy_dir = root_copy_dir
    else:
        copy_dir = root_copy_dir+'/'
    s = build_string(fi, style)
    if stem != '':
        internal_path = "{}/{}".format(stem, s)
    else:
        internal_path = s
    return copy_dir + internal_path

def build_string(fi, style):
    s = ""
    for c in style:
        if c == "c":
            s = s+"{}/".format(fi["carrier"])
        elif c == "r":
            s = s+"{}/".format(fi["revision"])
        elif c == "p":
            s = s+"{}/".format(fi["personality"])
        elif c == "b":
            s = s+"{}/".format(fi["board"])
        elif c == "s":
            s = s+"{}/".format(fi["som_rev"])
    return s
