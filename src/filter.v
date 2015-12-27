`timescale 1ps/1ps


module filter #(
    parameter WIDTH = 32,
    parameter SIZE = 5
)(

    input reset_in,
    input clk,
    input signed [(WIDTH-1) :0] data_in,
    output signed [(WIDTH-1) :0] data_out

);

localparam DEPTH = 2**SIZE;

reg signed [(WIDTH-1):0]  accum = 32'd0;
reg signed [(WIDTH-1):0]  i_data_out = 32'd0;
reg signed [(WIDTH-1):0]  mov_ave = 32'd0;
reg signed [(WIDTH-1):0]  mov_ave_PIPE[0:(DEPTH-1)];

integer i;

always @ (posedge clk) begin
    if (reset_in ) begin
        accum <= 32'd0;
        mov_ave <= 32'd0; 
        for (i = 0; i < DEPTH; i=i+1) begin
                mov_ave_PIPE[i] <= 32'd0; 
        end
    end else begin
        mov_ave_PIPE[0] <= data_in;
        for (i = 1; i < DEPTH; i=i+1) begin
                mov_ave_PIPE[i] <= mov_ave_PIPE[i-1];
        end
        accum <= accum + data_in - mov_ave_PIPE[(DEPTH-1)];
        i_data_out <= $signed($signed(accum) >>> SIZE); 
    end
end

assign data_out = i_data_out;

endmodule
