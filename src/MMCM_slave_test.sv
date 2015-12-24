`timescale 1ps/1ps


module MMCM_slave_test (

    input reset_in,

    input clk_in_300Mhz_p,
    input clk_in_300Mhz_n,
    input clk_in_156_25_mhz_p,
    input clk_in_156_25_mhz_n

);

wire i_clk_in_156_25_mhz;
wire clk_in_156_25;
wire clk_156_25_PS;
wire psclk_416M;
wire clk_156_25Mhz_MASTER;
wire master_mmcm_locked;

wire[7:0] ila_input_C;
(*dont_touch = "true" *)wire MMCM_locked;
(*dont_touch = "true" *)wire PLL_locked;
(*dont_touch = "true" *)wire MMCM_psdone;
(*dont_touch = "true" *)wire MMCM_psen;
(*dont_touch = "true" *)wire MMCM_psincdec;
reg i0_MMCM_psincdec;
reg i1_MMCM_psincdec;
reg i2_MMCM_psincdec;

reg i0_MMCM_psen_pulse = 1'b0;
(*dont_touch = "true" *)reg MMCM_psen_pulse = 1'b0;

(*dont_touch = "true" *)wire reset_sampler;
(*dont_touch = "true" *)wire ACCUM_reset;
(*dont_touch = "true" *)reg dbg_PS = 1'b0;

reg signed [31:0]  slave_count = 32'd0;
reg signed [31:0]  sync_slave_count_A = 32'd0;
reg signed [31:0]  sync_slave_count_B = 32'd0;
(* dont_touch = "true" *)reg [31:0]  sync_slave_count_Y = 32'd0;
reg signed [31:0]  i0_VOLTAGE = 32'd0;
reg signed [31:0]  i0_dbg_SAMPLE_VOLT = 32'd0;
reg signed [31:0]  i1_dbg_SAMPLE_VOLT = 32'd0;
reg signed [31:0]  i0_dbg_SAMPLE_DELTA = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  dbg_SAMPLE_DELTA = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  dbg_DIFF_COUNT = 32'd0;
reg signed [31:0]  i1_VOLTAGE = 32'd0;
(* dont_touch = "true" *)reg [31:0]  PS_DELTA = 32'd0;
reg signed [31:0]  PS_DELTA_mov_ave_PIPE[0:511];
reg signed [31:0]  i0_PS_DELTA_mov_ave = 32'd0;
reg signed [31:0]  i1_PS_DELTA_mov_ave = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  PS_DELTA_mov_ave = 32'd0;
reg signed [31:0]  i0_PS_DELTA = 32'd0;
reg signed [31:0]  i1_PS_DELTA = 32'd0;
(* dont_touch = "true" *)reg [31:0]  accum_dbg = 32'd0;
reg signed [31:0]  i0_accum_dbg = 32'd0;
reg signed [31:0]  i1_accum_dbg = 32'd0;
reg signed [31:0]  diff_count = 32'd0;
reg signed [31:0]  accum = 32'd0; 
reg signed [31:0]  independent_count = 32'd0;
reg signed [31:0]  sampler_count = 32'd0;
reg signed [31:0]  i0_independent_count = 32'd0;
reg signed [31:0]  i1_independent_count = 32'd0;
reg signed [31:0]  i2_independent_count = 32'd0;
reg signed [31:0]  sync_independent_count_A = 32'd0;
reg signed [31:0]  sync_independent_count_B = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  sync_independent_count_Y = 32'd0;

(* dont_touch = "true" *)wire [3:0] NC_NA;
(* dont_touch = "true" *)wire [31:0] PS_STEP_SIZE;
(* dont_touch = "true" *)wire [31:0] SAMPLE_PERIOD;
reg unsigned [31:0] i0_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] i1_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] i2_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] ps_counter = 32'd0;
reg ps_pulse = 1'b0;
(* dont_touch = "true" *)reg PS_SEL = 1'b0;
(* dont_touch = "true" *)reg [2:0] ila_input_C_DBG = 4'd0;

reg sample_pulse = 1'b0;
reg i_sample_pulse = 1'b0;
reg i0_sample_pulse = 1'b0;
reg i1_sample_pulse = 1'b0;
reg i2_sample_pulse = 1'b0;
reg i3_sample_pulse = 1'b0;

reg unsigned [31:0] step_count = 32'd0;
(*dont_touch = "true" *)reg signed [31:0] DBG_step_count = 32'd0;

integer i;

mmcm_300Mhz_in_Master U_mmcm_300Mhz_in_Master (
.clk_in_300Mhz_p(clk_in_300Mhz_p),
.clk_in_300Mhz_n(clk_in_300Mhz_n),
.clk_out_156_25Mhz(clk_156_25Mhz_MASTER),     // output clk_out_156_25Mhz
.reset(reset_in),
.master_mmcm_locked(master_mmcm_locked));      // output master_mmcm_locked

IBUFGDS u_ibufgds(
    .I(clk_in_156_25_mhz_p),
    .IB(clk_in_156_25_mhz_n),
    .O(i_clk_in_156_25_mhz));

BUFG u_bufg ( .I(i_clk_in_156_25_mhz), .O(clk_in_156_25));

pll_400Mhz_PSCLK U_pll_400Mhz_PSCLK (
    .clk_in_156_25(clk_in_156_25),
    .clk_416M(psclk_416M),
    .reset(reset_in),
    .locked(PLL_locked)
);

mmcm_ps U_mmcm_ps (
    .clk_in156_25(clk_in_156_25),
    .clk_out_156_25(clk_156_25_PS),
    .psclk(psclk_416M),
    .psen(MMCM_psen_pulse),
    .psincdec(i2_MMCM_psincdec),
    .psdone(MMCM_psdone),
    .reset(reset_in),
    .locked(MMCM_locked)
);

always @ (posedge clk_156_25Mhz_MASTER) begin
    independent_count <= independent_count + 1;
end

always @ (posedge clk_156_25Mhz_MASTER) begin
    if (ACCUM_reset ) begin
        sampler_count <= 32'd0;
    end else if (i_sample_pulse ) begin
        sampler_count <= 32'd0;
    end else begin
        sampler_count <= sampler_count + 1;
    end
    if (sampler_count == SAMPLE_PERIOD)
        i_sample_pulse <= 1'b1;
    else
        i_sample_pulse <= 1'b0;
end

always @ (posedge clk_156_25_PS) begin
    i0_sample_pulse <= i_sample_pulse;
    i1_sample_pulse <= i0_sample_pulse;
    i2_sample_pulse <= i1_sample_pulse;
    i3_sample_pulse <= i2_sample_pulse;
    sample_pulse <= i3_sample_pulse;

    i0_independent_count <= independent_count;
    i1_independent_count <= i0_independent_count;
    i2_independent_count <= i1_independent_count;

    if (ACCUM_reset ) begin
        slave_count <= i2_independent_count;
    end else begin
        slave_count <= slave_count + 1;
    end
end

always @ (posedge clk_156_25_PS) begin
        if (ACCUM_reset ) begin
            sync_independent_count_A <= 32'd0; 
            sync_independent_count_B <= 32'd0; 
            sync_independent_count_Y <= 32'd0; 
            sync_slave_count_A <= 32'd0; 
            sync_slave_count_B <= 32'd0; 
            sync_slave_count_Y <= 32'd0; 
            i0_VOLTAGE <= 32'd0; 
            i1_VOLTAGE <= 32'd0; 
            i0_PS_DELTA <= 32'd0; 
            i1_PS_DELTA <= 32'd0; 
            PS_DELTA <= 32'd0; 
            accum <= 32'd0;
            i0_accum_dbg <=  32'd0;
            i1_accum_dbg <= 32'd0;
            diff_count <= 32'd0;
            accum_dbg <= 32'd0;
        end else begin
            sync_independent_count_A <= independent_count;
            sync_independent_count_B <= sync_independent_count_A;
            sync_independent_count_Y <= sync_independent_count_B;

            sync_slave_count_A <= slave_count;
            sync_slave_count_B <= sync_slave_count_A;
            sync_slave_count_Y <= sync_slave_count_B;

            i0_VOLTAGE <= (sync_slave_count_Y - sync_independent_count_Y);
            i1_VOLTAGE <= i0_VOLTAGE; 
            i0_PS_DELTA <= (i1_VOLTAGE - i0_VOLTAGE); 
            i1_PS_DELTA <= i0_PS_DELTA;
            PS_DELTA <= i1_PS_DELTA; 
            accum <= accum + PS_DELTA;
            accum_dbg <= accum; 
            i0_accum_dbg <= accum_dbg;
            if (i0_accum_dbg != accum_dbg) begin
                i1_accum_dbg <= (accum_dbg - i0_accum_dbg);
                diff_count <= diff_count+1;
            end
            dbg_SAMPLE_DELTA <= i1_accum_dbg;
            dbg_DIFF_COUNT <= diff_count;
            ila_input_C_DBG <= i1_VOLTAGE[15:13];
            PS_SEL <= accum_dbg[31];
        end

 end

always @ (posedge clk_156_25_PS) begin
    if (ACCUM_reset ) begin
        step_count <= 32'd0;
        PS_DELTA_mov_ave <= 32'd0; 
        for (i = 0; i < 512; i=i+1) begin
                PS_DELTA_mov_ave_PIPE[i] <= 32'd0; 
        end
    end else begin
        PS_DELTA_mov_ave_PIPE[0] <= PS_DELTA;
        for (i = 1; i < 512; i=i+1) begin
                PS_DELTA_mov_ave_PIPE[i] <= PS_DELTA_mov_ave_PIPE[i-1];
        end
        i0_PS_DELTA_mov_ave <= accum - PS_DELTA_mov_ave_PIPE[64];
        i1_PS_DELTA_mov_ave <= $signed($signed(i0_PS_DELTA_mov_ave) >>> 6); 
        if (sample_pulse) begin
            if (i1_PS_DELTA_mov_ave == 32'd0) begin 
                step_count <= step_count;
            end else begin 
                if (i1_PS_DELTA_mov_ave[31] == 1'b0) begin
                    if (step_count < 32'd1024)
                        step_count <= step_count + 1;
                    else
                        step_count <= 32'd1024; 
                end else begin
                    if (step_count > 0)
                        step_count <= step_count - 1;
                    else
                        step_count <= 32'd0;

                end
            end
        end
        PS_DELTA_mov_ave <= i1_PS_DELTA_mov_ave;
        //DBG_step_count <= (32'd1024 - step_count);
        DBG_step_count <=  step_count;
    end
end


assign ila_input_C = {ila_input_C_DBG, master_mmcm_locked, PLL_locked, PS_SEL, MMCM_locked, dbg_PS}; 

MMCM_status_ILA U_MMCM_status_ILA (
    .clk(clk_156_25_PS),
    .probe0(sync_independent_count_Y),
    .probe1(sync_slave_count_Y),
    .probe2(ila_input_C),
    .probe3(accum_dbg),
    .probe4(DBG_step_count),
    .probe5(PS_DELTA_mov_ave)
);

vio_PS_CTRL U_vio_PS_CTRL (
  .clk(clk_156_25_PS),
  .probe_out0({NC_NA, ACCUM_reset, MMCM_psincdec, MMCM_psen, reset_sampler}),
  .probe_out1(PS_STEP_SIZE),
  .probe_out2(SAMPLE_PERIOD)
);



always @ (posedge psclk_416M) begin
    if (MMCM_psdone)
        ps_counter <= 32'd0;
    else
        ps_counter <= ps_counter +1;

    i0_PS_COUNT_VAL <= DBG_step_count;
    //i0_PS_COUNT_VAL <= PS_STEP_SIZE;
    i1_PS_COUNT_VAL <= i0_PS_COUNT_VAL;
    i2_PS_COUNT_VAL <= i1_PS_COUNT_VAL;

    if (ps_counter < i2_PS_COUNT_VAL)
        ps_pulse <= 1'b0;
    else begin
        ps_counter <= 32'd0;
        ps_pulse <= 1'b1;
    end

     i0_MMCM_psen_pulse <= (ps_pulse & MMCM_psen);
     MMCM_psen_pulse <= i0_MMCM_psen_pulse;
     i0_MMCM_psincdec <= MMCM_psincdec;
     i1_MMCM_psincdec <= i0_MMCM_psincdec;
     i2_MMCM_psincdec <= i1_MMCM_psincdec;

end

always @ (posedge psclk_416M) begin
    if (MMCM_psen_pulse)
        dbg_PS <= 1'b1;
    if (MMCM_psdone)
        dbg_PS <= 1'b0;
end

endmodule
