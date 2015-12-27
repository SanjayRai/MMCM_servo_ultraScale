create_clock -period 6.40 -name clk_in_156_25_mhz_p -waveform {0.000 3.20} [get_ports clk_in_156_25_mhz_p]
set_clock_groups -name TIG_SRAI_1 -asynchronous -group [get_clocks -of_objects [get_pins U_pll_400Mhz_PSCLK/inst/clkout1_buf/O]] -group [get_clocks -of_objects [get_pins U_mmcm_ps/inst/clkout1_buf/O]]


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
