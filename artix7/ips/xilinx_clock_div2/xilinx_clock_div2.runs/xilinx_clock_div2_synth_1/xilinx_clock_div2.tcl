# 
# Synthesis run script generated by Vivado
# 

create_project -in_memory -part xc7a100tfgg484-2

set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.cache/wt [current_project]
set_property parent.project_path /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
read_ip /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.srcs/sources_1/ip/xilinx_clock_div2/xilinx_clock_div2.xci
set_property is_locked true [get_files /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.srcs/sources_1/ip/xilinx_clock_div2/xilinx_clock_div2.xci]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
synth_design -top xilinx_clock_div2 -part xc7a100tfgg484-2 -mode out_of_context
rename_ref -prefix_all xilinx_clock_div2_
write_checkpoint -noxdef xilinx_clock_div2.dcp
catch { report_utilization -file xilinx_clock_div2_utilization_synth.rpt -pb xilinx_clock_div2_utilization_synth.pb }
if { [catch {
  file copy -force /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.runs/xilinx_clock_div2_synth_1/xilinx_clock_div2.dcp /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.srcs/sources_1/ip/xilinx_clock_div2/xilinx_clock_div2.dcp
} _RESULT ] } { 
  error "ERROR: Unable to successfully create or copy the sub-design checkpoint file."
}
if { [catch {
  write_verilog -force -mode synth_stub /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.srcs/sources_1/ip/xilinx_clock_div2/xilinx_clock_div2_stub.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a Verilog synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}
if { [catch {
  write_vhdl -force -mode synth_stub /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.srcs/sources_1/ip/xilinx_clock_div2/xilinx_clock_div2_stub.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create a VHDL synthesis stub for the sub-design. This may lead to errors in top level synthesis of the design. Error reported: $_RESULT"
}
if { [catch {
  write_verilog -force -mode funcsim /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.srcs/sources_1/ip/xilinx_clock_div2/xilinx_clock_div2_funcsim.v
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the Verilog functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}
if { [catch {
  write_vhdl -force -mode funcsim /home/fyh/emmc_test/artix7-board/artix7/ips/xilinx_clock_div2/xilinx_clock_div2.srcs/sources_1/ip/xilinx_clock_div2/xilinx_clock_div2_funcsim.vhdl
} _RESULT ] } { 
  puts "CRITICAL WARNING: Unable to successfully create the VHDL functional simulation sub-design file. Post-Synthesis Functional Simulation with this file may not be possible or may give incorrect results. Error reported: $_RESULT"
}
