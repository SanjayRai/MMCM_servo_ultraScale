# Created : 12:55:51, Mon Dec 21, 2015 : Sanjay Rai

source ../device_type.tcl
create_project project_X project_X -part [DEVICE_TYPE] 

add_files -fileset sources_1 -norecurse {
../IP/MMCM_status_ILA/MMCM_status_ILA.xci
../IP/mmcm_300Mhz_in_Master/mmcm_300Mhz_in_Master.xci
../IP/mmcm_ps/mmcm_ps.xci
../IP/pll_400Mhz_PSCLK/pll_400Mhz_PSCLK.xci
../IP/vio_PS_CTRL/vio_PS_CTRL.xci
}

