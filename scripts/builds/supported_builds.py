# SPDX-License-Identifier: Apache-2.0

from builds.te0820_soms import *
from builds.oot_b import *

rwt_te0820_carrier_images = ["blank", "default", "gr-iio"]

supported_builds = { "oxygen"  : {
                                     "revisions" : ["rev3"],
                                     "images"    : rwt_te0820_carrier_images,
                                     "boards"    : te0820_boards,
                                     "som_rev"   : te0820_som_revisions,
                                    },
                   }

oot_builds.merge(supported_builds, oot_builds.supported_oot)
