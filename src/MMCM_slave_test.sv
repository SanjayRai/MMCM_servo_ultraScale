`timescale 1ps/1ps


module MMCM_slave_test (

    input reset_in,

    input clk_in_300Mhz_p,
    input clk_in_300Mhz_n,
    input clk_in_156_25_mhz_p,
    input clk_in_156_25_mhz_n,
    output user_sma_master_sig,
    output user_sma_slave_sig

);
localparam BIT_DEPTH = 32;
wire i_clk_in_156_25_mhz;
wire clk_in_156_25;
wire clk_156_25_PS;
wire clk_312_50_PS;
wire clk_156_25Mhz_MASTER;
wire clk_312_50Mhz_MASTER;
wire master_mmcm_locked;
wire MMCM_locked;
(*dont_touch = "true" *)wire ALL_MMCM_PLL_locked;
wire[7:0] ila_input_C;
(*dont_touch = "true" *)wire MMCM_psdone;
(*dont_touch = "true" *)wire MMCM_psen;
(*dont_touch = "true" *)reg MMCM_psincdec = 1'b1;

reg i0_MMCM_psen_pulse = 1'b0;
(*dont_touch = "true" *)reg MMCM_psen_pulse = 1'b0;

(*dont_touch = "true" *)wire ACCUM_reset;

reg signed [(BIT_DEPTH-1):0]  slave_count = 'd0;
reg signed [(BIT_DEPTH-1):0]  sync_slave_count_sample_A = 'd0;
reg signed [(BIT_DEPTH-1):0]  sync_slave_count_sample_B = 'd0;
(* dont_touch = "true" *)reg signed [(BIT_DEPTH-1):0]  count_diff = 'd0;
reg signed [(BIT_DEPTH-1):0]  i0_VOLTAGE = 'd0;
reg signed [(BIT_DEPTH-1):0]  i0_dbg_SAMPLE_VOLT = 'd0;
reg signed [(BIT_DEPTH-1):0]  i1_dbg_SAMPLE_VOLT = 'd0;
reg signed [(BIT_DEPTH-1):0]  i0_dbg_SAMPLE_DELTA = 'd0;
(* dont_touch = "true" *)reg signed [(BIT_DEPTH-1):0]  i1_VOLTAGE = 'd0;
(* dont_touch = "true" *)reg signed [(BIT_DEPTH-1):0]  PS_DELTA = 'd0;
(* dont_touch = "true" *)reg signed [(BIT_DEPTH-1):0]  accum = 'd0; 
reg signed [(BIT_DEPTH-1):0]  master_count = 'd0;
reg signed [(BIT_DEPTH-1):0]  master_count_sample = 'd0;
reg signed [(BIT_DEPTH-1):0]  slave_count_sample = 'd0;
reg unsigned [(BIT_DEPTH-1):0]  master_sampler_count = 'd0;
reg unsigned [(BIT_DEPTH-1):0]  slave_sampler_count = 'd0;
reg signed [(BIT_DEPTH-1):0]  sync_master_count_sample_A = 'd0;
reg signed [(BIT_DEPTH-1):0]  sync_master_count_sample_B = 'd0;
reg signed [(BIT_DEPTH-1):0]  sync_master_count_sample_C = 'd0;
reg signed [(BIT_DEPTH-1):0]  sync_master_count_sample_D = 'd0;
(* dont_touch = "true" *)reg signed [(BIT_DEPTH-1):0]  sync_master_count_sample_Y = 'd0;

(* dont_touch = "true" *)wire unsigned [(BIT_DEPTH-1):0] SAMPLE_PERIOD;
reg unsigned [(BIT_DEPTH-1):0] ps_counter = 'd0;
reg ps_pulse = 1'b0;
(* dont_touch = "true" *)reg acc_neg = 1'b0;

(*dont_touch = "true" *)reg DBG_MMCM_psincdec;
reg i0_MMCM_psincdec = 1'b1;

reg signed [(BIT_DEPTH-1):0] step_count = 'd0;

(* dont_touch = "true" *)reg dbg_mst_samp = 1'b0;

reg unsigned [7:0] calc_start_count = 8'd0;
(* dont_touch = "true" *)reg servo_LOCKED = 1'b1; //__SRAI (needs implementation)
//__SRAI (needs implementation)(* dont_touch = "true" *)reg signed [(BIT_DEPTH-1):0] servo_locked_detector = 'd0; 

(* dont_touch = "true" *)reg dbg_calc_Start = 1'b0;
(* dont_touch = "true" *)reg wait_for_ps_done = 1'b0;

mmcm_300Mhz_in_Master U_mmcm_300Mhz_in_Master (
.clk_in_300Mhz_p(clk_in_300Mhz_p),
.clk_in_300Mhz_n(clk_in_300Mhz_n),
.clk_out_156_25Mhz(clk_156_25Mhz_MASTER),     // output clk_out_156_25Mhz
.clk_out_312_50Mhz(clk_312_50Mhz_MASTER),
.reset(reset_in),
.master_mmcm_locked(master_mmcm_locked));      // output master_mmcm_locked

IBUFGDS u_ibufgds(
    .I(clk_in_156_25_mhz_p),
    .IB(clk_in_156_25_mhz_n),
    .O(i_clk_in_156_25_mhz));

BUFG u_bufg ( .I(i_clk_in_156_25_mhz), .O(clk_in_156_25));

mmcm_ps U_mmcm_ps (
    .clk_in156_25(clk_in_156_25),
    .clk_out_156_25(clk_156_25_PS),
    .clk_out_312_50(clk_312_50_PS),
    .psclk(clk_312_50_PS),
    .psen(MMCM_psen_pulse),
    .psincdec(MMCM_psincdec),
    .psdone(MMCM_psdone),
    .reset(reset_in),
    .locked(MMCM_locked)
);


assign user_sma_master_sig = master_count[16];
assign user_sma_slave_sig  = slave_count[15];

//always @ (posedge clk_156_25Mhz_MASTER) begin
always @ (posedge clk_312_50Mhz_MASTER) begin
    if (ACCUM_reset ) begin
        master_count <= master_count; 
    end else begin
        master_count <= master_count + 1;
    end
end

always @ (posedge clk_312_50Mhz_MASTER) begin
    if (ACCUM_reset ) begin
        master_sampler_count <= 'd0;
        dbg_mst_samp <= 1'b0;
        master_count_sample <= 'd0;
    end else if (master_sampler_count == SAMPLE_PERIOD) begin
        master_count_sample <= master_count;
        master_sampler_count <= master_sampler_count + 1;
        dbg_mst_samp <= 1'b1;
    end else if (master_sampler_count == (SAMPLE_PERIOD+8)) begin
        master_sampler_count <= 'd0;
        dbg_mst_samp <= 1'b0;
    end else begin
        master_sampler_count <= master_sampler_count + 1;
    end
end

always @ (posedge clk_312_50_PS) begin
    if (ACCUM_reset ) begin
        slave_count <= {BIT_DEPTH{1'b0}};
    end else begin
        slave_count <= slave_count + 1;
    end

end

//always @ (posedge clk_156_25_PS) begin
always @ (posedge clk_312_50_PS) begin
    sync_master_count_sample_A <= master_count_sample;
    sync_master_count_sample_B <= sync_master_count_sample_A;
    sync_master_count_sample_C <= sync_master_count_sample_B;
    sync_master_count_sample_D <= sync_master_count_sample_C;
    if ((sync_master_count_sample_D == sync_master_count_sample_C) && (sync_master_count_sample_C == sync_master_count_sample_B) && (sync_master_count_sample_D != sync_master_count_sample_A)) begin
        sync_master_count_sample_Y <= sync_master_count_sample_D;
        count_diff <= (slave_count - sync_master_count_sample_Y);
    end
end

always @ (posedge clk_312_50_PS) begin
        if (ACCUM_reset ) begin
            i0_VOLTAGE <= 'd0; 
            i1_VOLTAGE <= 'd0; 
            PS_DELTA <= 'd0; 
            accum <= 'd0;
            acc_neg <= 1'b0;
            calc_start_count <= 8'd0;
            dbg_calc_Start <= 1'b0;
            servo_LOCKED = 1'b0; //__SRAI (needs implementation)
        end else begin
            servo_LOCKED = 1'b1; //__SRAI (needs implementation)
            i0_VOLTAGE <= count_diff;
            i1_VOLTAGE <= i0_VOLTAGE; 
            PS_DELTA <= (i1_VOLTAGE - i0_VOLTAGE); 

            // __SRAI : wait for 10 differential voltages to register (settle time)  before starting the accumulator
            //if (i1_VOLTAGE != i0_VOLTAGE) begin
            if (PS_DELTA != 'd0) begin
                if (calc_start_count < 8'd10) begin
                    calc_start_count <= calc_start_count + 1;
                    dbg_calc_Start <= 1'b0;
                end else begin
                    dbg_calc_Start <= 1'b1;
                    accum <= accum + PS_DELTA; 
                    if (accum < $signed({BIT_DEPTH{1'b0}})) begin
                        acc_neg <= 1'b1;
                    end
                end
            end
        end

 end


//always @ (posedge clk_156_25_PS) begin
always @ (posedge clk_312_50_PS) begin
    if (ACCUM_reset) begin 
        step_count <= 'd0;
        i0_MMCM_psincdec <= 1'b0; 
    end else begin
        if ($signed(accum) >  $signed('d8192)) begin
            step_count <= 'd8192;
            i0_MMCM_psincdec <= 1'b1; // __SRAI Increment Phase 
        end else if ($signed(accum) < $signed({BIT_DEPTH{1'b0}})) begin
            step_count <= 'd2; 
            i0_MMCM_psincdec <= 1'b1; // __SRAI Decrement Phase (KCU105 at hand Always increment - such are the crystals on my KCU105!!) 
        end else begin 
            i0_MMCM_psincdec <= 1'b1; // __SRAI Increment Phase 
            step_count <=  accum;
        end
    end
end


assign ALL_MMCM_PLL_locked = (master_mmcm_locked & MMCM_locked);

assign ila_input_C = {acc_neg, dbg_calc_Start, MMCM_psincdec, ALL_MMCM_PLL_locked, dbg_mst_samp, wait_for_ps_done, MMCM_psen_pulse, MMCM_psdone}; 

MMCM_status_ILA U_MMCM_status_ILA (
    .clk(clk_312_50_PS),
    .probe0(accum),
    .probe1(PS_DELTA),
    .probe2(ila_input_C),
    .probe3(i1_VOLTAGE),
    .probe4(step_count),
    .probe5(sync_master_count_sample_Y)
);

vio_PS_CTRL U_vio_PS_CTRL (
  .clk(clk_156_25_PS),
  .probe_out0({ACCUM_reset, DBG_MMCM_psincdec, MMCM_psen}),
  .probe_out1(SAMPLE_PERIOD)
);



always @ (posedge clk_312_50_PS) begin
    if (ACCUM_reset) begin
        ps_counter <= 'd0;
        wait_for_ps_done <= 1'b0;
    end else if (MMCM_psdone) begin
        ps_counter <= 'd0;
        wait_for_ps_done <= 1'b0;
    //end else if (!wait_for_ps_done && (ps_counter < step_count)) begin
    end else if ((ps_counter < step_count)) begin
        ps_counter <= ps_counter +1;
    end else begin
        ps_counter <= 'd0;
        wait_for_ps_done <= 1'b1;
    end

     i0_MMCM_psen_pulse <= ((ps_counter == step_count) & MMCM_psen & ~ACCUM_reset);
     MMCM_psen_pulse <= i0_MMCM_psen_pulse;
     MMCM_psincdec <= i0_MMCM_psincdec;

end

endmodule

