# SPDX-License-Identifier: Apache-2.0

if {$argc > 1} {
    set board [lindex $argv 1]
} else {
    set board "2cg"
}

if {$argc > 2} {
    set som_rev [lindex $argv 2]
} else {
    set som_rev "1.0"
}

switch $board {
    2cg -
    2eg -
    3cg -
    4cg -
    4ev -
    3eg {
        puts "Building for board $board"
    }
    default {
        puts "Unrecognized board $board: Must be 2cg, 2eg, 3cg, 3eg, 4cg, or 4ev"
        exit 1
    }
}

set p_device "xczu${board}-sfvc784-1-e"
set p_board "trenz.biz:te0820_${board}_1e:part0:${som_rev}"
set sys_zynq 2
