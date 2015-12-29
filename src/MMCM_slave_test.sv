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

(*dont_touch = "true" *)wire reset_sampler;
(*dont_touch = "true" *)wire ACCUM_reset;
(*dont_touch = "true" *)reg dbg_PS = 1'b0;

reg signed [31:0]  slave_count = 32'd0;
reg unsigned [31:0]  slave_calc_count = 32'd0;
reg signed [31:0]  sync_slave_count_sample_A = 32'd0;
reg signed [31:0]  sync_slave_count_sample_B = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  count_diff = 32'd0;
reg signed [31:0]  i0_VOLTAGE = 32'd0;
reg signed [31:0]  i0_dbg_SAMPLE_VOLT = 32'd0;
reg signed [31:0]  i1_dbg_SAMPLE_VOLT = 32'd0;
reg signed [31:0]  i0_dbg_SAMPLE_DELTA = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  i1_VOLTAGE = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  PS_DELTA = 32'd0;
(* dont_touch = "true" *)wire signed [31:0]  accum_filter_out;
reg signed [31:0]  i0_PS_DELTA = 32'd0;
reg signed [31:0]  i1_PS_DELTA = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  accum_dbg = 32'd0;
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
reg signed [31:0]  i0_sync_master_count_sample_Y = 32'd0;
reg signed [31:0]  i1_sync_master_count_sample_Y = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  dbg_Y_samp_diff = 32'd0;

(* dont_touch = "true" *)wire [3:0] NC_NA;
(* dont_touch = "true" *)wire unsigned [31:0] VIO_PS_STEP_SIZE;
(* dont_touch = "true" *)wire unsigned [31:0] SAMPLE_PERIOD;
reg unsigned [31:0] PS_CALC_PERIOD = 32'd0;
reg unsigned [31:0] i0_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] i1_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] i2_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] ps_counter = 32'd0;
reg ps_pulse = 1'b0;

(*dont_touch = "true" *)reg DBG_MMCM_psincdec;
(*dont_touch = "true" *)reg DBG2_MMCM_psincdec;

reg signed [31:0] step_count = 32'd0;
(*dont_touch = "true" *)reg signed [31:0] DBG_step_count = 32'd0;

integer i;

reg  [7:0]  picxo_rst        ;
wire [3:0]  acc_step         ;
wire [4:0]  G1               ;
wire [4:0]  G2               ;
wire [15:0] R                ;
wire [15:0] V                ;
wire [15:0] ce_dsp_rate      ;
wire [21:0] Offset_ppm       ;
wire        Offset_en        ;
wire        hold             ;
wire [0:0]  don              ;
(* dont_touch = "true" *)wire [4:0] txpippmstepsize_int;
(* dont_touch = "true" *)reg dbg_mst_samp = 1'b0;
(* dont_touch = "true" *)reg dbg_slv_samp = 1'b0;

reg i0_slave_sample = 1'b0;
reg i1_slave_sample = 1'b0;
reg i2_slave_sample = 1'b0;
(* dont_touch = "true" *)reg slave_calc_CE = 1'b0;
reg i_slave_calc_CE = 1'b0;
reg i0_slave_calc_CE = 1'b0;
reg i1_slave_calc_CE = 1'b0;

reg unsigned [7:0] calc_start_count = 8'd0;

wire [6:0]  C = 7'b0         ;
wire [9:0]  P = 10'b0        ;
wire [9:0]  N = 10'b0        ;

wire [20:0] error            ;
wire [21:0] volt             ;        
wire        ce_pi            ; 
wire        ce_pi2           ; 
wire        ce_dsp           ; 
wire        ovf_pd           ; 
wire        ovf_ab           ; 
wire        ovf_volt         ; 
wire        ovf_int          ; 

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
        slave_calc_count <= 32'd0;
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
            if (slave_calc_count == PS_CALC_PERIOD) begin 
                slave_calc_count <= 32'd0;
                i_slave_calc_CE <= 1'b1;
            end else begin
                i_slave_calc_CE <= 1'b0;
                slave_calc_count <= slave_calc_count + 1;
            end
        end
        i0_slave_calc_CE <= i_slave_calc_CE;
        i1_slave_calc_CE <= i0_slave_calc_CE;
        slave_calc_CE <= (i0_slave_calc_CE & !i1_slave_calc_CE); 
    end

    // __SRAI (DEBUG)
    i0_sync_master_count_sample_Y <= sync_master_count_sample_Y;
    i1_sync_master_count_sample_Y <= i0_sync_master_count_sample_Y;
    if (i1_sync_master_count_sample_Y != i0_sync_master_count_sample_Y) begin
        dbg_Y_samp_diff = (i0_sync_master_count_sample_Y - i1_sync_master_count_sample_Y);
    end
end

always @ (posedge clk_156_25_PS) begin
        if (ACCUM_reset ) begin
            //PS_CALC_PERIOD <= (SAMPLE_PERIOD <<< 4);
            PS_CALC_PERIOD <= VIO_PS_STEP_SIZE;

            i0_VOLTAGE <= count_diff; 
            i1_VOLTAGE <= count_diff; 
            i0_PS_DELTA <= 32'd0; 
            i1_PS_DELTA <= 32'd0; 
            PS_DELTA <= 32'd0; 
            accum <= 32'd0;
            accum_dbg <= 32'd0;
        end else begin

            //PS_CALC_PERIOD <= (SAMPLE_PERIOD <<< 4);
            PS_CALC_PERIOD <= VIO_PS_STEP_SIZE;


            if (slave_calc_CE) begin
                    i0_VOLTAGE <= count_diff;
                    i1_VOLTAGE <= i0_VOLTAGE; 
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
            accum_dbg <= accum; 
        end

 end

filter #(.WIDTH(32), .SIZE(3)) U_filter (
    .reset_in(ACCUM_reset),
    .clk(clk_156_25_PS),
    //.CE(1'b1),
    .CE(slave_calc_CE),
    .data_in(accum),
    .data_out(accum_filter_out)

);

always @ (posedge clk_156_25_PS) begin
    if (ACCUM_reset) begin 
        DBG_step_count <= 32'd512;
        DBG_MMCM_psincdec <= 1'b0; 
        DBG2_MMCM_psincdec <= 1'b0; 
    end else begin
        if ($signed(accum_filter_out) >  $signed(32'd8192)) begin
            DBG_step_count <= 32'd8192;
        end else if ($signed(accum_filter_out) < $signed(32'd0)) begin
            DBG_step_count <= $signed(32'd0);
        end else begin 
            DBG_step_count <=  accum_filter_out;
        end
        DBG_MMCM_psincdec <= ~DBG_step_count[31]; 
        DBG2_MMCM_psincdec <= ~accum_filter_out[31];
    end
end


assign ALL_MMCM_PLL_locked = (master_mmcm_locked & MMCM_locked & PLL_locked);

assign ila_input_C = {2'b0, slave_calc_CE, DBG_MMCM_psincdec, ALL_MMCM_PLL_locked, dbg_mst_samp, DBG2_MMCM_psincdec, dbg_PS}; 

MMCM_status_ILA U_MMCM_status_ILA (
    .clk(clk_156_25_PS),
    .probe0(sync_master_count_sample_Y),
    .probe1(accum_dbg),
    .probe2(ila_input_C),
    .probe3(DBG_step_count),
    .probe4(accum_filter_out),
    .probe5(i1_VOLTAGE),
    .probe6(PS_DELTA),
    .probe7(dbg_Y_samp_diff)
);

vio_PS_CTRL U_vio_PS_CTRL (
  .clk(clk_156_25_PS),
  .probe_out0({NC_NA, ACCUM_reset, MMCM_psincdec, MMCM_psen, reset_sampler}),
  .probe_out1(VIO_PS_STEP_SIZE),
  .probe_out2(SAMPLE_PERIOD)
);



always @ (posedge psclk_416M) begin
    if (MMCM_psdone)
        ps_counter <= 32'd0;
    else
        ps_counter <= ps_counter +1;

    // __SRAI 
    i0_PS_COUNT_VAL <= DBG_step_count;
    //i0_PS_COUNT_VAL <= VIO_PS_STEP_SIZE;

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
     //i0_MMCM_psincdec <= MMCM_psincdec;
     i1_MMCM_psincdec <= i0_MMCM_psincdec;
     i2_MMCM_psincdec <= i1_MMCM_psincdec;

end

always @ (posedge psclk_416M) begin
    if (MMCM_psen_pulse)
        dbg_PS <= 1'b1;
    if (MMCM_psdone)
        dbg_PS <= 1'b0;
end

// __ SRAI (XAPP 1241 PICXO design)

//always@(posedge clk_156_25_PS)
//begin
//   if (ACCUM_reset) begin
//        picxo_rst[7:0]     <= 8'b11111111;
//   end
//   else begin
//        picxo_rst[7:0]     <=  {picxo_rst[6:0],ACCUM_reset};
//   end
//end 
//
//   picxo_vio picxo_vio_i (
//     .clk            (clk_156_25_PS  ),
//     .probe_out0     (G1              ),
//     .probe_out1     (G2              ),
//     .probe_out2     (R               ),
//     .probe_out3     (V               ),
//     .probe_out4     (acc_step        ),
//     .probe_out5     (ce_dsp_rate     ),
//     .probe_out6     (Offset_ppm      ),
//     .probe_out7     (Offset_en       ),
//     .probe_out8     (hold            ),
//     .probe_out9     (picxo_rst_in    ),
//     .probe_out10    (                ),
//     .probe_out11    (don             )
//   );                                
// picxo_ila picxo_ila_i (
//     .clk        ( clk_156_25_PS),
//     .probe0     ( error                     ),
//     .probe1     ( volt                      ),
//     .probe2     ( {3'b0, txpippmstepsize_int}),
//     .probe3     ( ce_pi                     ),
//     .probe4     ( ce_pi2                    ),
//     .probe5     ( ce_dsp                    ), 
//     .probe6     ( ovf_pd                    ), 
//     .probe7     ( ovf_ab                    ),
//     .probe8     ( ovf_volt                  ),
//     .probe9     ( ovf_int                   )
//   );       
//   
//   XAPP589_XAPP1241_picxo_test XAPP589_XAPP1241_picxo_test_i  (
//           .REF_CLK_I        ( clk_156_25Mhz_MASTER  ),
//           .RESET_I          ( picxo_rst[7]                  ),
//           .DRPEN_O          (                               ),
//           .DRPWEN_O         (                               ),
//           .DRPRDY_I         ( 1'b0                          ),
//           .DRPDO_I          ( 16'h0000                      ),
//           .DRPDATA_O        (                               ),
//           .DRPADDR_O        (                               ),
//           .DRPBUSY_O        (                               ),
//           .TXOUTCLK_I       ( clk_156_25_PS  ),
//           .RSIGCE_I         ( 1'b1                          ),
//           .VSIGCE_I         ( 1'b1                          ),
//           .VSIGCE_O         (                               ),
//           .ACC_STEP         ( acc_step                      ),
//           .G1               ( G1                            ),
//           .G2               ( G2                            ),
//           .R                ( R                             ),
//           .V                ( V                             ),
//           .C_I              ( C                             ),
//           .P_I              ( P                             ),
//           .N_I              ( N                             ),
//           .DON_I            ( don                           ),
//           .OFFSET_PPM       ( Offset_ppm                    ),
//           .OFFSET_EN        ( Offset_en                     ),
//           .HOLD             ( hold                          ),
//           .CE_DSP_RATE      ( ce_dsp_rate                   ),
//            //DRP USER PORT
//           .DRP_USER_REQ_I   ( 1'b0                          ),
//           .DRP_USER_DONE_I  ( 1'b0                          ),
//           .DRPEN_USER_I     ( 1'b0                          ),
//           .DRPWEN_USER_I    ( 1'b0                          ),
//           .DRPDATA_USER_I   ( 16'b0                         ),
//           .DRPDATA_USER_O   (                               ),
//           .DRPADDR_USER_I   ( 9'b0                          ),
//           .DRPRDY_USER_O    (                               ),
//           .ACC_DATA         ( txpippmstepsize_int           ),
//           //DEBUG PORT
//           .ERROR_O          ( error                         ),
//           .VOLT_O           ( volt                          ),
//           .DRPDATA_SHORT_O  (                               ),
//           .CE_PI_O          ( ce_pi                         ),
//           .CE_PI2_O         ( ce_pi2                        ),
//           .CE_DSP_O         ( ce_dsp                        ),
//           .OVF_PD           ( ovf_pd                        ),
//           .OVF_AB           ( ovf_ab                        ),
//           .OVF_VOLT         ( ovf_volt                      ),
//           .OVF_INT          ( ovf_int                       )
//         );      

endmodule

