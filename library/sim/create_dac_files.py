#!/usr/bin/env python2

# SPDX-License-Identifier: Apache-2.0

import numpy as np
import struct

t = np.arange(0,200) / (3*np.pi)

a=(np.sin(t) * 2**14).astype('int')
b=(np.cos(t) * 2**14).astype('int')
c=(-np.sin(t) * 2**14).astype('int')
d=(-np.cos(t) * 2**14).astype('int')

with open('input_dac.txt', 'w') as fp:
    for i,_ in enumerate(t):
        fp.write("%d,%d,%d,%d\n" % (a[i], b[i], c[i], d[i]))

with open('input_dac.bin', 'w') as fp:
    for i,_ in enumerate(t):
        fp.write(struct.pack("!rwtrwt", a[i], b[i], c[i], d[i]))
