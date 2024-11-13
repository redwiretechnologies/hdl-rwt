# SPDX-License-Identifier: Apache-2.0

import numpy as np
data = np.fromfile('raw_iq.capture', dtype=np.float32)
data = data * 2048
data_int = data.astype(int)
for i in range(0, len(data_int), 2):
    print(data_int[i], " ", data_int[i+1])
