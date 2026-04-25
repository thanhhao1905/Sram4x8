module top_sram_tile (
    // Clock and Reset
    input  wire        clk,
    input  wire        rst,
    
    // Control signals
    input  wire        we,      // Write request
    input  wire        re,      // Read request
    input  wire [1:0]  addr,    // Row address (0-3)
    
    // Data interface
    input  wire [7:0]  din,     // Data input
    output wire [7:0]  dout     // Data output
);
    
    // Internal control signals
    wire precharge;
    wire we_pulse, re_pulse, sense_en;
    wire [3:0] wl;
    
    // --------------------------------------------------
    // 1. SRAM Controller
    // --------------------------------------------------
    sram_ctrl_syn u_ctrl (
        .clk        (clk),
        .rst        (rst),
        .we_req     (we),
        .re_req     (re),
        .precharge  (precharge),
        .we_pulse   (we_pulse),
        .re_pulse   (re_pulse),
        .sense_en   (sense_en)
    );
    
    // --------------------------------------------------
    // 2. Row Decoder
    // --------------------------------------------------
    row_decoder_2to4_syn u_dec (
        .addr   (addr),
        .en     (we || re),  // Enable when either read or write
        .wl     (wl)
    );
    
    // --------------------------------------------------
    // 3. Control signal distribution to 8 columns
    // --------------------------------------------------
    wire [7:0] pre = {8{precharge}};
    wire [7:0] sen = {8{sense_en}};
    wire [7:0] wr  = {8{we_pulse}};
    wire [7:0] rd  = {8{re_pulse}};
    
    // --------------------------------------------------
    // 4. SRAM Macro Instantiation
    // --------------------------------------------------
    SRAM_4x8 u_sram (
        // Power
        .VDD       (1'b1),     // Power supply
        .GND       (1'b0),     // Ground
        .VDD2      (1'b1),     // Secondary power
        
        // Wordlines
        .WL1        (wl[0]),
        .WL2        (wl[1]),
        .WL3        (wl[2]),
        .WL4        (wl[3]),
        
        // Precharge (8 columns)
        .Pre_Charge1 (pre[0]),
        .Pre_Charge2 (pre[1]),
        .Pre_Charge3 (pre[2]),
        .Pre_Charge4 (pre[3]),
        .Pre_Charge5 (pre[4]),
        .Pre_Charge6 (pre[5]),
        .Pre_Charge7 (pre[6]),
        .Pre_Charge8 (pre[7]),
        
        // Sense enable (8 columns)
        .Sense1     (sen[0]),
        .Sense2     (sen[1]),
        .Sense3     (sen[2]),
        .Sense4     (sen[3]),
        .Sense5     (sen[4]),
        .Sense6     (sen[5]),
        .Sense7     (sen[6]),
        .Sense8     (sen[7]),
        
        // Write enable (8 columns)
        .Write1     (wr[0]),
        .Write2     (wr[1]),
        .Write3     (wr[2]),
        .Write4     (wr[3]),
        .Write5     (wr[4]),
        .Write6     (wr[5]),
        .Write7     (wr[6]),
        .Write8     (wr[7]),
        
        // Read enable (8 columns)
        .Read1      (rd[0]),
        .Read2      (rd[1]),
        .Read3      (rd[2]),
        .Read4      (rd[3]),
        .Read5      (rd[4]),
        .Read6      (rd[5]),
        .Read7      (rd[6]),
        .Read8      (rd[7]),
        
        // Data input (8 bits)
        .Data_in1   (din[0]),
        .Data_in2   (din[1]),
        .Data_in3   (din[2]),
        .Data_in4   (din[3]),
        .Data_in5   (din[4]),
        .Data_in6   (din[5]),
        .Data_in7   (din[6]),
        .Data_in8   (din[7]),
        
        // Data output (8 bits)
        .Data_out1  (dout[0]),
        .Data_out2  (dout[1]),
        .Data_out3  (dout[2]),
        .Data_out4  (dout[3]),
        .Data_out5  (dout[4]),
        .Data_out6  (dout[5]),
        .Data_out7  (dout[6]),
        .Data_out8  (dout[7])
    );
    
endmodule
