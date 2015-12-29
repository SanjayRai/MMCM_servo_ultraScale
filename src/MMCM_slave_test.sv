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
wire MMCM_locked;
wire PLL_locked;
(*dont_touch = "true" *)wire ALL_MMCM_PLL_locked;
wire[7:0] ila_input_C;
(*dont_touch = "true" *)wire MMCM_psdone;
(*dont_touch = "true" *)wire MMCM_psen;
(*dont_touch = "true" *)wire MMCM_psincdec;
reg i0_MMCM_psincdec;
reg i1_MMCM_psincdec;
reg i2_MMCM_psincdec;

reg i0_MMCM_psen_pulse = 1'b0;
(*dont_touch = "true" *)reg MMCM_psen_pulse = 1'b0;

(*dont_touch = "true" *)wire ACCUM_reset;
(*dont_touch = "true" *)reg dbg_PS = 1'b0;

reg signed [31:0]  slave_count = 32'd0;
reg signed [31:0]  sync_slave_count_sample_A = 32'd0;
reg signed [31:0]  sync_slave_count_sample_B = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  count_diff = 32'd0;
reg signed [31:0]  i0_VOLTAGE = 32'd0;
reg signed [31:0]  i0_dbg_SAMPLE_VOLT = 32'd0;
reg signed [31:0]  i1_dbg_SAMPLE_VOLT = 32'd0;
reg signed [31:0]  i0_dbg_SAMPLE_DELTA = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  i1_VOLTAGE = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  PS_DELTA = 32'd0;
reg signed [31:0]  i0_PS_DELTA = 32'd0;
reg signed [31:0]  i1_PS_DELTA = 32'd0;
reg signed [31:0]  accum = 32'd0; 
reg signed [31:0]  master_count = 32'd0;
reg signed [31:0]  master_count_sample = 32'd0;
reg signed [31:0]  slave_count_sample = 32'd0;
reg unsigned [31:0]  master_sampler_count = 32'd0;
reg unsigned [31:0]  slave_sampler_count = 32'd0;
reg signed [31:0]  sync_master_count_sample_A = 32'd0;
reg signed [31:0]  sync_master_count_sample_B = 32'd0;
reg signed [31:0]  sync_master_count_sample_C = 32'd0;
reg signed [31:0]  sync_master_count_sample_D = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  sync_master_count_sample_Y = 32'd0;

(* dont_touch = "true" *)wire unsigned [31:0] SAMPLE_PERIOD;
reg unsigned [31:0] i0_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] i1_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] i2_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] ps_counter = 32'd0;
reg ps_pulse = 1'b0;

(*dont_touch = "true" *)reg DBG_MMCM_psincdec;
(*dont_touch = "true" *)reg DBG2_MMCM_psincdec;

(*dont_touch = "true" *)reg signed [31:0] DBG_step_count = 32'd0;

(* dont_touch = "true" *)reg dbg_mst_samp = 1'b0;

(* dont_touch = "true" *)reg slave_calc_CE = 1'b0;
(* dont_touch = "true" *)reg i_slave_calc_CE = 1'b0;
reg i0_slave_calc_CE = 1'b0;
reg i1_slave_calc_CE = 1'b0;

reg unsigned [7:0] calc_start_count = 8'd0;
reg unsigned [31:0] servo_LOCKED_count = 8'd0;
(* dont_touch = "true" *)reg servo_LOCKED = 1'b0;
reg signed [31:0] servo_locked_detector = 32'd0; 
reg signed [31:0] i0_servo_lock_det =  32'd0;
reg signed [31:0] i1_servo_lock_det =  32'd0;

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
    if (ACCUM_reset ) begin
        master_count <= master_count; 
    end else begin
        master_count <= master_count + 1;
    end
end

always @ (posedge clk_156_25Mhz_MASTER) begin
    if (ACCUM_reset ) begin
        master_sampler_count <= 32'd0;
        dbg_mst_samp <= 1'b0;
        master_count_sample <= 32'd0;
    end else if (master_sampler_count == SAMPLE_PERIOD) begin
        master_count_sample <= master_count;
        master_sampler_count <= master_sampler_count + 1;
        dbg_mst_samp <= 1'b1;
    end else if (master_sampler_count == (SAMPLE_PERIOD+4)) begin
        master_sampler_count <= 32'd0;
        dbg_mst_samp <= 1'b0;
    end else begin
        master_sampler_count <= master_sampler_count + 1;
    end
end

always @ (posedge clk_156_25_PS) begin
    if (ACCUM_reset ) begin
        slave_count <= 32'd0;
    end else begin
        slave_count <= slave_count + 1;
    end

end

always @ (posedge clk_156_25_PS) begin
    if (ACCUM_reset ) begin
        calc_start_count <= 32'd0;
    end else begin
        if (slave_calc_CE) begin 
            if (calc_start_count < 8'd10) begin
                calc_start_count <= calc_start_count + 1;
            end 
        end
    end

end

always @ (posedge clk_156_25_PS) begin
    if (ACCUM_reset ) begin
        i_slave_calc_CE <= 1'b0;
        i0_slave_calc_CE <= 1'b0;
        i1_slave_calc_CE <= 1'b0;
    end else begin
        sync_master_count_sample_A <= master_count_sample;
        sync_master_count_sample_B <= sync_master_count_sample_A;
        sync_master_count_sample_C <= sync_master_count_sample_B;
        sync_master_count_sample_D <= sync_master_count_sample_C;
        if ((sync_master_count_sample_D == sync_master_count_sample_C) && (sync_master_count_sample_C == sync_master_count_sample_B) && (sync_master_count_sample_D != sync_master_count_sample_A)) begin
            sync_master_count_sample_Y <= sync_master_count_sample_D;
            count_diff <= (slave_count - sync_master_count_sample_Y);
            i_slave_calc_CE <= 1'b1;
        end else begin
            i_slave_calc_CE <= 1'b0;
        end
        i0_slave_calc_CE <= i_slave_calc_CE;
        i1_slave_calc_CE <= i0_slave_calc_CE;
        slave_calc_CE <= (i0_slave_calc_CE & !i1_slave_calc_CE); 
    end
end

always @ (posedge clk_156_25_PS) begin
        if (ACCUM_reset ) begin
            i0_VOLTAGE <= 32'd0; 
            i1_VOLTAGE <= 32'd0; 
            i0_PS_DELTA <= 32'd0; 
            i1_PS_DELTA <= 32'd0; 
            PS_DELTA <= 32'd0; 
            accum <= 32'd0;
            servo_LOCKED <= 1'b0;
            servo_LOCKED_count <= 8'd0;
            servo_locked_detector <= 1'b0;
            i0_servo_lock_det <= 1'b0;
            i1_servo_lock_det <= 1'b0;
        end else begin
            if (slave_calc_CE) begin
                    i0_VOLTAGE <= count_diff;
                    i1_VOLTAGE <= i0_VOLTAGE; 
                    if (servo_LOCKED_count == $unsigned(100000)) begin
                        servo_LOCKED_count <= 32'd0;
                        i0_servo_lock_det <= i1_VOLTAGE;
                        i1_servo_lock_det <= i0_servo_lock_det;
                    end else begin
                        servo_LOCKED_count <= servo_LOCKED_count + 1'b1;
                    end
                if (calc_start_count > 8'd5) begin
                    i0_PS_DELTA <= (i1_VOLTAGE - i0_VOLTAGE); 
                    i1_PS_DELTA <= i0_PS_DELTA;
                    PS_DELTA <= i1_PS_DELTA; 
                    //accum <= accum + PS_DELTA;
                    if (PS_DELTA > $signed(32'd0)) begin
                        accum <= accum + $signed(32'd1);
                    end else if (PS_DELTA == $signed(32'd0)) begin
                        accum <= accum;
                    end else begin
                        accum <= accum - $signed(32'd1);
                    end

                end
            end
            servo_locked_detector <= (i0_servo_lock_det - i1_servo_lock_det);
            if (($signed(servo_locked_detector) > $signed(-32'd2)) && ($signed(servo_locked_detector) < $signed(32'd2)))
                servo_LOCKED <= 1'b1;
            else
                servo_LOCKED <= 1'b0;

        end

 end


always @ (posedge clk_156_25_PS) begin
    if (ACCUM_reset) begin 
        DBG_step_count <= 32'd0;
        DBG_MMCM_psincdec <= 1'b0; 
        DBG2_MMCM_psincdec <= 1'b0; 
    end else begin
        if ($signed(accum) >  $signed(32'd8192)) begin
            DBG_step_count <= 32'd8192;
        end else if ($signed(accum) < $signed(32'd0)) begin
            DBG_step_count <= $signed(32'd0);
        end else begin 
            DBG_step_count <=  accum;
        end
        DBG_MMCM_psincdec <= ~DBG_step_count[31]; 
        DBG2_MMCM_psincdec <= ~accum[31];
    end
end


assign ALL_MMCM_PLL_locked = (master_mmcm_locked & MMCM_locked & PLL_locked);

assign ila_input_C = {servo_LOCKED, i_slave_calc_CE, slave_calc_CE, DBG_MMCM_psincdec, ALL_MMCM_PLL_locked, dbg_mst_samp, DBG2_MMCM_psincdec, dbg_PS}; 

MMCM_status_ILA U_MMCM_status_ILA (
    .clk(clk_156_25_PS),
    .probe0(sync_master_count_sample_Y),
    .probe1({servo_LOCKED_count}),
    .probe2(ila_input_C),
    .probe3(DBG_step_count),
    .probe4(PS_DELTA),
    .probe5(i1_VOLTAGE)
);

vio_PS_CTRL U_vio_PS_CTRL (
  .clk(clk_156_25_PS),
  .probe_out0({ACCUM_reset, MMCM_psincdec, MMCM_psen}),
  .probe_out1(SAMPLE_PERIOD)
);



    // __SRAI (** __SRAI Try with 156_25 as opposed to 416) 
always @ (posedge psclk_416M) begin
    if (MMCM_psdone)
        ps_counter <= 32'd0;
    else
        ps_counter <= ps_counter +1;

    // __SRAI (** __SRAI Add Debound Sync from 156.25 to 416 Domain) 
    i0_PS_COUNT_VAL <= DBG_step_count;
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
     i0_MMCM_psincdec <= DBG_MMCM_psincdec;
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

