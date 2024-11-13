# SPDX-License-Identifier: Apache-2.0

file mkdir $project_name.utilization
open_run impl_1
set reportLines [split [report_utilization -return_string] "\n"]
set csv_file $project_name.utilization/utilization.csv
set fh [open $csv_file w]
set writelines false
foreach line $reportLines {
	if {[regexp {\+[+-]+} $line]} {
		set writelines true
	}
	if {$writelines && [regexp {^\|} $line]} {
		puts $fh [regsub -all {\|} [regsub -all {.\|.} $line ","] ""]
	}
}
close $fh
report_utilization -file $project_name.utilization/utilization-full.rpt -hierarchical
