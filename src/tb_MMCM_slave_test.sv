`timescale 1ps/1ps


module tb_MMCM_slave_test ();

reg reset_in = 1'b1;
wire clk_in_300Mhz_p;
wire clk_in_300Mhz_n;
wire clk_in_156_25_mhz_p;
wire clk_in_156_25_mhz_n;

MMCM_slave_test U_MMCM_slave_test (
    .reset_in(reset_in),
    .clk_in_300Mhz_p(clk_in_300Mhz_p),
    .clk_in_300Mhz_n(clk_in_300Mhz_n),
    .clk_in_156_25_mhz_p(clk_in_156_25_mhz_p),
    .clk_in_156_25_mhz_n(clk_in_156_25_mhz_n)

);
reg clk_in_300Mhz = 1'b0;
reg clk_in_156_25_mhz = 1'b0;

assign clk_in_300Mhz_p = clk_in_300Mhz;
assign clk_in_300Mhz_n = ~clk_in_300Mhz;
assign clk_in_156_25_mhz_p = clk_in_156_25_mhz;
assign clk_in_156_25_mhz_n = ~clk_in_156_25_mhz;

    initial begin
    #1000 reset_in <= 1'b0;

    end

    always 
    #2.533 clk_in_300Mhz <= ~clk_in_300Mhz ;

    always 
    #6.400 clk_in_156_25_mhz <= ~clk_in_156_25_mhz; 



endmodule
