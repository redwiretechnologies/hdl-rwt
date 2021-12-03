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

supported_oot = {}
