# Created : 12:55:51, Mon Dec 21, 2015 : Sanjay Rai

source ../device_type.tcl

create_project project_X project_X -part [DEVICE_TYPE]


add_files -norecurse {
../IP/MMCM_status_ILA/MMCM_status_ILA.xci
../IP/vio_PS_CTRL/vio_PS_CTRL.xci
../IP/mmcm_ps/mmcm_ps.xci
../IP/mmcm_300Mhz_in_Master/mmcm_300Mhz_in_Master.xci
../IP/pll_400Mhz_PSCLK/pll_400Mhz_PSCLK.xci
../src/MMCM_slave_test.v
}
add_files -fileset constrs_1 {
../src/xdc/MMCM_slave_test.xdc
}
add_files -fileset sim_1 {
../src/tb_MMCM_slave_test.v
}

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
if (0) {
launch_runs synth_1
wait_on_run synth_1
open_run synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
open_run impl_1
}
