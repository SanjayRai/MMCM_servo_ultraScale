`timescale 1ps/1ps


module tb_filter ();

reg reset_in = 1'b1;
reg clk = 1'b0;
reg [31:0] count = 32'd0;
wire [31 :0] data_in;
wire [31:0] data_out;

filter #(.WIDTH(32), .SIZE(5)) U_filter (
    .reset_in(reset_in),
    .clk(clk),
    .CE(1'b1),
    .data_in(data_in),
    .data_out(data_out)

);


    initial begin
    #1000 reset_in <= 1'b0;

    end

    always 
    #6.400 clk <= ~clk; 


    always @(posedge clk) begin
        if (reset_in)
            count = 32'd0;
        else
            count <= count +1;

    end

    assign data_in = {16'd0, count[6], 15'd0};
        



endmodule

