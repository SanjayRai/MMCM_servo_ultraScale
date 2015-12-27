# Created : 12:55:51, Mon Dec 21, 2015 : Sanjay Rai

source ../device_type.tcl

create_project project_X project_X -part [DEVICE_TYPE]


add_files -norecurse {
../IP/XAPP589_XAPP1241_picxo_test/XAPP589_XAPP1241_picxo_test.xci
../IP/picxo_ila/picxo_ila.xci
../IP/picxo_vio/picxo_vio.xci
../IP/MMCM_status_ILA/MMCM_status_ILA.xci
../IP/vio_PS_CTRL/vio_PS_CTRL.xci
../IP/mmcm_ps/mmcm_ps.xci
../IP/mmcm_300Mhz_in_Master/mmcm_300Mhz_in_Master.xci
../IP/pll_400Mhz_PSCLK/pll_400Mhz_PSCLK.xci
../src/filter.v
../src/MMCM_slave_test.sv
}
add_files -fileset constrs_1 {
../src/xdc/MMCM_slave_test.xdc
}
add_files -fileset sim_1 {
../src/tb_MMCM_slave_test.sv
}

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
if (1) {
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
