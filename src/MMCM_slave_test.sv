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
(* dont_touch = "true" *)reg signed [31:0]  i1_VOLTAGE = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  PS_DELTA = 32'd0;
(* dont_touch = "true" *)wire signed [31:0]  accum_filter_out;
reg signed [31:0]  i0_PS_DELTA = 32'd0;
reg signed [31:0]  i1_PS_DELTA = 32'd0;
(* dont_touch = "true" *)reg signed [31:0]  accum_dbg = 32'd0;
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
(* dont_touch = "true" *)wire [31:0] VIO_PS_STEP_SIZE;
(* dont_touch = "true" *)wire [31:0] SAMPLE_PERIOD;
reg unsigned [31:0] i0_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] i1_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] i2_PS_COUNT_VAL = 32'd0;
reg unsigned [31:0] ps_counter = 32'd0;
reg ps_pulse = 1'b0;
(* dont_touch = "true" *)reg PS_SEL = 1'b0;
(* dont_touch = "true" *)reg [1:0] ila_input_C_DBG = 4'd0;

reg sample_pulse = 1'b0;
reg i_sample_pulse = 1'b0;
reg i0_sample_pulse = 1'b0;
reg i1_sample_pulse = 1'b0;
reg i2_sample_pulse = 1'b0;
reg i3_sample_pulse = 1'b0;

(*dont_touch = "true" *)reg DBG_MMCM_psincdec;

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
            ila_input_C_DBG <= i1_VOLTAGE[15:12];
            PS_SEL <= accum_dbg[31];
        end

 end

filter #(.WIDTH(32), .SIZE(8)) U_filter (
    .reset_in(ACCUM_reset),
    .clk(clk_156_25_PS),
    .data_in(accum),
    .data_out(accum_filter_out)

);

// always @ (posedge clk_156_25_PS) begin
//     if (ACCUM_reset) begin
//         step_count <= 32'd512;
//         DBG_step_count <= 32'd512;
//     end else if (sample_pulse) begin
//         step_count <= (step_count + accum_filter_out);
//     end
//     if (step_count > $signed(32'd1024))
//         DBG_step_count <=  $signed(32'd1024);
//     else if (step_count < $signed(32'd1))
//         DBG_step_count <=  $signed(32'd0);
//     else
//         DBG_step_count <=  step_count;
// end
always @ (posedge clk_156_25_PS) begin
    if (ACCUM_reset) begin 
        DBG_step_count <= 32'd1024;
        DBG_MMCM_psincdec <= 1'b0; 
    end else begin
        if ($signed(accum_filter_out) >  $signed(32'd1024)) begin
            DBG_step_count <= 32'd1024;
        end else if ($signed(accum_filter_out) < $signed(32'd0)) begin
            DBG_step_count <= $signed(32'd0);
        end else begin 
            DBG_step_count <=  32'd1024 + accum_filter_out;
        end
        DBG_MMCM_psincdec <= ~DBG_step_count[31]; 
    end
end



assign ila_input_C = {ila_input_C_DBG, DBG_MMCM_psincdec, master_mmcm_locked, PLL_locked, PS_SEL, MMCM_locked, dbg_PS}; 

MMCM_status_ILA U_MMCM_status_ILA (
    .clk(clk_156_25_PS),
    .probe0(sync_independent_count_Y),
    .probe1(sync_slave_count_Y),
    .probe2(ila_input_C),
    .probe3(accum_dbg),
    .probe4(DBG_step_count),
    .probe5(accum_filter_out)
    .probe6(i1_VOLTAGE)
    .probe7(PS_DELTA)
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

always@(posedge clk_156_25_PS)
begin
   if (ACCUM_reset) begin
        picxo_rst[7:0]     <= 8'b11111111;
   end
   else begin
        picxo_rst[7:0]     <=  {picxo_rst[6:0],ACCUM_reset};
   end
end 

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

