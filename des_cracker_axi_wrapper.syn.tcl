#
# Copyright (C) Telecom ParisTech
# Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paristech.fr)
# 
# This file must be used under the terms of the CeCILL. This source
# file is licensed as described in the file COPYING, which you should
# have received as part of this distribution. The terms are also
# available at:
# http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
#

# EDIT THIS

array set ios {
  # data   { V12 LVCMOS33 }
  led[0] { M14 LVCMOS33 }
  led[1] { M15 LVCMOS33 }
  led[2] { G14 LVCMOS33 }
  led[3] { D18 LVCMOS33 }
}
set frequency_mhz 100
# set start_us 20000
# set warm_us 1000000

# DO NOT MODIFY ANYTHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING

set board [get_board_parts digilentinc.com:zybo*]
set part xc7z010clg400-1

proc usage {} {
  puts "
usage: vivado -mode batch -source <script> [-tclargs <design>]
  <script>: TCL script
  <design>: name of top entity and basename of the VHDL source file
            optional, defaults to basename of <script>"
  exit -1
}

set script [file normalize [info script]]
set src [file dirname [file dirname $script]]
regsub {\..*} [file tail $script] "" design

if { $argc == 1 } {
  set design [lindex $argv 0]
} elseif { $argc != 0 } {
  usage
}

puts "*********************************************"
puts "Summary of build parameters"
puts "*********************************************"
puts "Board: $board"
puts "Part: $part"
puts "Source directory: $src"
puts "Design name: $design"
puts "Frequency: $frequency_mhz MHz"
# puts "Start delay: $start_us µs"
# puts "Warm-up delay: $warm_us µs"
puts "*********************************************"

#############
# Create IP #
#############
set_part $part
set_property board_part $board [current_project]
read_vhdl $src/lab02/sr.vhd
read_vhdl $src/lab02/timer.vhd
read_vhdl $src/lab03/edge.vhd
read_vhdl $src/lab04/counter.vhd
read_vhdl $src/lab04/dht11_pkg.vhd
read_vhdl $src/lab04/dht11_ctrl.vhd
read_vhdl $src/lab06/dht11_ctrl_axi_wrapper.vhd
ipx::package_project -import_files -root_dir $design -vendor www.telecom-paristech.fr -library DS -force $design
close_project

############################
## Create top level design #
############################
set_part $part
set_property board_part $board [current_project]
set_property ip_repo_paths [list ./$design] [current_fileset]
update_ip_catalog
create_bd_design $design
set ip [create_bd_cell -type ip -vlnv [get_ipdefs *www.telecom-paristech.fr:DS:$design:*] $design]
set_property -dict [list CONFIG.frequency_mhz $frequency_mhz CONFIG.start_us $start_us CONFIG.warm_us $warm_us] $ip
set ps7 [create_bd_cell -type ip -vlnv [get_ipdefs *xilinx.com:ip:processing_system7:*] ps7]
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" } $ps7
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $frequency_mhz] $ps7
set_property -dict [list CONFIG.PCW_USE_M_AXI_GP0 {1}] $ps7
set_property -dict [list CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {1}] $ps7

# Interconnections
# Primary IOs
create_bd_port -dir IO -type data data
connect_bd_net [get_bd_pins /$design/data] [get_bd_ports data]
create_bd_port -dir O -type data -from 3 -to 0 led
connect_bd_net [get_bd_pins /$design/led] [get_bd_ports led]
# ps7 - ip
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/ps7/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins /$ip/s0_axi]

# Addresses ranges
set_property offset 0x40000000 [get_bd_addr_segs -of_object [get_bd_intf_pins /ps7/M_AXI_GP0]]
set_property range 4K [get_bd_addr_segs -of_object [get_bd_intf_pins /ps7/M_AXI_GP0]]

# Synthesis flow
validate_bd_design
save_bd_design
generate_target all [get_files $design.bd]
synth_design -top $design

# IOs
foreach io [ array names ios ] {
  set pin [ lindex $ios($io) 0 ]
  set std [ lindex $ios($io) 1 ]
  set_property package_pin $pin [get_ports $io]
  set_property iostandard $std [get_ports [list $io]]
}

# Clocks and timing
set clock [get_clocks]
set_false_path -from $clock -to [get_ports data]
set_false_path -from $clock -to [get_ports led[*]]
set_false_path -from [get_ports data] -to $clock

# Implementation
opt_design
place_design
route_design
write_bitstream $design

# Reports
report_utilization -file $design.utilization.rpt
report_timing_summary -file $design.timing.rpt

# Messages
puts ""
puts "*********************************************"
puts "\[VIVADO\]: done"
puts "*********************************************"
puts "Summary of build parameters"
puts "*********************************************"
puts "Board: $board"
puts "Part: $part"
puts "Source directory: $src"
puts "Design name: $design"
puts "Frequency: $frequency_mhz MHz"
puts "Start delay: $start_us µs"
puts "Warm-up delay: $warm_us µs"
puts "*********************************************"
puts "  bitstream in $design.bit"
puts "  resource utilization report in $design.utilization.rpt"
puts "  timing report in $design.timing.rpt"
puts "*********************************************"

# Quit
quit
