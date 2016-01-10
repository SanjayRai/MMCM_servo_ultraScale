create_clock -period 3.333 -name clk_in_300Mhz_p [get_ports clk_in_300Mhz_p]
create_clock -period 6.400 -name clk_in_156_25_mhz_p [get_ports clk_in_156_25_mhz_p]
set_clock_groups -name TIG_SRAI_1 -asynchronous -group [get_clocks -of_objects [get_pins U_mmcm_300Mhz_in_Master/inst/mmcme3_adv_inst/CLKOUT1]] -group [get_clocks -of_objects [get_pins U_mmcm_ps/inst/mmcme3_adv_inst/CLKOUT1]]
set_clock_groups -name TIG_SRAI_2 -asynchronous -group [get_clocks -of_objects [get_pins U_mmcm_300Mhz_in_Master/inst/mmcme3_adv_inst/CLKOUT1]] -group [get_clocks -of_objects [get_pins U_mmcm_ps/inst/mmcme3_adv_inst/CLKOUT0]]
set_false_path -from [get_pins {U_vio_PS_CTRL/inst/PROBE_OUT_ALL_INST/G_PROBE_OUT[*].*/*]/C}] -to [get_pins i0_MMCM_psen_pulse_reg/D]

# Bank  45 VCCO - VCC1V2_FPGA_3A - IO_L12P_T1U_N10_GC_45
set_property PACKAGE_PIN AK17            [get_ports "clk_in_300Mhz_p"]
set_property IOSTANDARD  DIFF_SSTL12     [get_ports "clk_in_300Mhz_p"] 
set_property ODT         RTT_48          [get_ports "clk_in_300Mhz_p"] 
#
# Bank  45 VCCO - VCC1V2_FPGA_3A - IO_L12N_T1U_N11_GC_45
set_property PACKAGE_PIN AK16            [get_ports "clk_in_300Mhz_n"] 
set_property IOSTANDARD  DIFF_SSTL12     [get_ports "clk_in_300Mhz_n"] 
set_property ODT         RTT_48          [get_ports "clk_in_300Mhz_n"]

set_property PACKAGE_PIN M25      [get_ports "clk_in_156_25_mhz_p"] 
set_property IOSTANDARD  LVDS_25  [get_ports "clk_in_156_25_mhz_p"]
set_property DIFF_TERM   TRUE     [get_ports "clk_in_156_25_mhz_p"]
set_property PACKAGE_PIN M26      [get_ports "clk_in_156_25_mhz_n"] 
set_property IOSTANDARD  LVDS_25  [get_ports "clk_in_156_25_mhz_n"]
set_property DIFF_TERM   TRUE     [get_ports "clk_in_156_25_mhz_n"] 

set_property PACKAGE_PIN AN8      [get_ports "reset_in"] 
set_property IOSTANDARD  LVCMOS18  [get_ports "reset_in"]

set_property PACKAGE_PIN G27      [get_ports "user_sma_master_sig"] 
set_property IOSTANDARD  LVCMOS25  [get_ports "user_sma_master_sig"]

set_property PACKAGE_PIN H27      [get_ports "user_sma_slave_sig"] 
set_property IOSTANDARD  LVCMOS25  [get_ports "user_sma_slave_sig"]
