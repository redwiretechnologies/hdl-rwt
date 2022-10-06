source "$script_dir/../../../common/scripts/common_functions.tcl"
set no_project_run 0

if {$argc < 1} {
    puts "Project directory must be specified"
    exit 1
}

set AD_PROJ_DIR [lindex $argv 0]
source $AD_PROJ_DIR/scripts/adi_env.tcl

set my_list [ split $script_dir / ]
set hdl_rwt [ lsearch -exact $my_list "hdl-rwt" ]
set personality [ lindex $my_list $hdl_rwt+2 ]
set carrier [ lindex $my_list $hdl_rwt+3 ]
set carrier_rev [ lindex $my_list $hdl_rwt+4 ]

set project_name $carrier\_$personality

source "$script_dir/../../../common/$carrier/$carrier_rev/scripts/supported_boards.tcl"
source "$script_dir/../../../common/scripts/$supported_boards/boards.tcl"
source "$script_dir/../../../common/scripts/common_project_files.tcl"
source "$script_dir/../../../common/scripts/$supported_boards/common_constraints.tcl"
source "$script_dir/../../../common/$carrier/$carrier_rev/scripts/project_files.tcl"
if {[info exists som_format] != 0} {
    lappend project_files \
        "$script_dir/../../common/$supported_boards/$som_format/$personality\_constraints.xdc"
} else {
    lappend project_files \
        "$script_dir/../../common/$supported_boards/$personality\_constraints.xdc"
}

if {$argc > 3} {
    if { [lindex $argv 3] eq "--project-only" } {
        set no_project_run 1
    }
}

puts "Usage: system_project.tcl <AD_PROJ_DIR> <BOARD> <--project-only>"
puts "  AnalogDevices HDL Dir: $AD_PROJ_DIR"
puts "  Board: $board"
puts " --project-only : Create "

set ad_ghdl_dir $script_dir/../../../../

set_param board.repoPaths $script_dir/../../../../board_files

set tpd $p_device
set tpb $p_board
set tsz $sys_zynq

source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

exec ln -s $script_dir/system_bd.tcl

set p_device $tpd
set p_board  $tpb
set sys_zynq $tsz

adi_project_create $project_name 0 {} "" $tpb

adi_project_files $project_name $project_files

set file_name "$script_dir/../../../common/$carrier/$carrier_rev/vivado_directives.tcl"
if { [file exists $file_name] == 1} {
    source $file_name
}

set file_name "$script_dir/../../scripts/vivado_directives.tcl"
if { [file exists $file_name] == 1} {
    source $file_name
}

set file_name "$script_dir/vivado_directives.tcl"
if { [file exists $file_name] == 1} {
    source $file_name
}

if { $no_project_run != 1 } {
    adi_project_run $project_name;
    source "$script_dir/../../../common/scripts/utilization.tcl"
    if {[info exists NO_ADI9361] == 0} {
        source $ad_hdl_dir/library/axi_ad9361/axi_ad9361_delay.tcl
    }
}
