# Created : 12:55:51, Mon Dec 21, 2015 : Sanjay Rai

source ../device_type.tcl

create_project project_X project_X -part [DEVICE_TYPE]


add_files -norecurse {
../IP/MMCM_status_ILA/MMCM_status_ILA.xci
../IP/vio_PS_CTRL/vio_PS_CTRL.xci
../IP/mmcm_ps/mmcm_ps.xci
../IP/mmcm_300Mhz_in_Master/mmcm_300Mhz_in_Master.xci
../IP/pll_400Mhz_PSCLK/pll_400Mhz_PSCLK.xci
../src/MMCM_slave_test.sv
}
add_files -fileset constrs_1 {
../src/xdc/MMCM_slave_test.xdc
}
add_files -fileset sim_1 {
../src/tb_MMCM_slave_test.sv
}

if (1) {
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_runs synth_1
wait_on_run synth_1
open_run synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
open_run impl_1
}


proc run_sim {} {
    open_wave_config {../src/tb_MMCM_slave_test_behav.wcfg}
    restart
    run 1 us
    add_force {/tb_MMCM_slave_test/U_MMCM_slave_test/DBG_step_count} -radix unsigned 10
    add_force {/tb_MMCM_slave_test/U_MMCM_slave_test/MMCM_psen} -radix hex 1
    add_force {/tb_MMCM_slave_test/U_MMCM_slave_test/ACCUM_reset} -radix hex 1
    run 1 us
    add_force {/tb_MMCM_slave_test/U_MMCM_slave_test/ACCUM_reset} -radix hex 0
    run 1 us
}
proc run_hw {} {
open_hw
connect_hw_server -url mcmicro:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210251893419]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210251893419]
open_hw_target
set_property PROGRAM.FILE {./project_X/project_X.runs/impl_1/MMCM_slave_test.bit} [lindex [get_hw_devices] 0]
set_property PROBES.FILE {./project_X/project_X.runs/impl_1/debug_nets.ltx} [lindex [get_hw_devices] 0]
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
display_hw_ila_data [ get_hw_ila_data hw_ila_data_1 -of_objects [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_MMCM_status_ILA"}]]
set_property PROBES.FILE {./project_X/project_X.runs/impl_1/debug_nets.ltx} [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {./project_X/project_X.runs/impl_1/MMCM_slave_test.bit} [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
set_property OUTPUT_VALUE 00000100 [get_hw_probes SAMPLE_PERIOD -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_vio_PS_CTRL"}]]
commit_hw_vio [get_hw_probes {SAMPLE_PERIOD} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_vio_PS_CTRL"}]]
set_property OUTPUT_VALUE 1 [get_hw_probes MMCM_psen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_vio_PS_CTRL"}]]
commit_hw_vio [get_hw_probes {MMCM_psen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_vio_PS_CTRL"}]]
set_property OUTPUT_VALUE 1 [get_hw_probes ACCUM_reset -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_vio_PS_CTRL"}]]
commit_hw_vio [get_hw_probes {ACCUM_reset} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_vio_PS_CTRL"}]]
set_property OUTPUT_VALUE 0 [get_hw_probes ACCUM_reset -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_vio_PS_CTRL"}]]
commit_hw_vio [get_hw_probes {ACCUM_reset} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_vio_PS_CTRL"}]]
run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_MMCM_status_ILA"}]
wait_on_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_MMCM_status_ILA"}]
display_hw_ila_data [upload_hw_ila_data [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"U_MMCM_status_ILA"}]]
}
