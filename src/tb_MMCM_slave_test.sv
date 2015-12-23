`timescale 1ps/1ps


module tb_MMCM_slave_test ();

reg reset_in = 1'b1;
reg clk_in_300Mhz_p = 1'b0;
reg clk_in_300Mhz_n = 1'b1;
reg clk_in_156_25_mhz_p = 1'b0;
reg clk_in_156_25_mhz_n = 1'b1;

MMCM_slave_test U_MMCM_slave_test (
    .reset_in(reset_in),
    .clk_in_300Mhz_p(reset_in),
    .clk_in_300Mhz_n(reset_in),
    .clk_in_156_25_mhz_p(reset_in),
    .clk_in_156_25_mhz_n(clk_in_156_25_mhz_n)

);

endmodule
