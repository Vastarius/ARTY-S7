################ Initialization ############################################################
# Name of the project (project repo will be named with that name)
set design_name myproject
# Name of the xdc used 	
set design_xdc blink.xdc 
# Name of the top	
set design_top blink.vhd 	
# Name of the top tb
set design_tb_top tb_blink 
################# Only the parameters above have to be changed from one project to another
# Set the reference directory to where the script is
set origin_dir [file dirname [info script]]
# Create project in a folder with the name of the project
create_project $design_name $origin_dir/$design_name -part xc7s50csga324-1
# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]
# Set project properties
set obj [current_project]
set_property -name "board_part" -value "digilentinc.com:arty-s7-50:part0:1.0" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/$design_name.cache/ip" -objects $obj
set_property -name "platform.board_id" -value "arty-s7-50" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj

########### Scan repos to properly add sources, constraints, testbenches... #################

####### Source files repo
# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}
# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property top_file {$origin_dir/src/hdl/$design_top} $obj
# Add sources repository (include all sources in the repo)
add_files $origin_dir/src/hdl


####### Constraints files repo
# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}
# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]
add_files  -fileset constrs_1 $origin_dir/constraints/$design_xdc
# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]

####### IP files repo
# Set IP repository and update IP catalog
set_property ip_repo_paths $origin_dir/ip_repo [current_project]
update_ip_catalog

####### Simulation files repo
# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}
# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Add testbenches repository (include all tb in the repo)
add_files -fileset sim_1 $origin_dir/src/testbench
# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property top $design_tb_top [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
#set_property top_file {$origin_dir/src/testbench/$design_tb_top} $obj [current_fileset]

####### Synth files repo
# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7s50csga324-1 -flow {Vivado Synthesis 2019} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2019" [get_runs synth_1]
}
set obj [get_runs synth_1]
# set the current synth run
current_run -synthesis [get_runs synth_1]

####### Implementation files repo
# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7s50csga324-1 -flow {Vivado Implementation 2019} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2019" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj
# set the current impl run
current_run -implementation [get_runs impl_1]



puts "INFO: Project succesfully created: ${design_name}"

# Create block design
#source $origin_dir/src/bd/design_1.tcl

# Generate the wrapper
#make_wrapper -files [get_files *${design_name}.bd] -top
#add_files -norecurse ${design_name}/${design_name}.srcs/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.v

# Update the compile order
#update_compile_order -fileset sources_1
#update_compile_order -fileset sim_1

# Ensure parameter propagation has been performed
#close_bd_design [current_bd_design]
#open_bd_design [get_files ${design_name}.bd]
#validate_bd_design -force
#save_bd_design