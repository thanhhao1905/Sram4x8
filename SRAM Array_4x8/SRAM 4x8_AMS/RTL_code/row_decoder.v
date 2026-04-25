module row_decoder_2to4_syn (
    input  wire [1:0] addr,
    input  wire       en,
    output wire [3:0] wl
);
    
    // Decoded outputs
    wire [3:0] decoded;
    
    assign decoded[0] = (addr == 2'b00);
    assign decoded[1] = (addr == 2'b01);
    assign decoded[2] = (addr == 2'b10);
    assign decoded[3] = (addr == 2'b11);
    
    // Enable gate
    assign wl = en ? decoded : 4'b0000;
    
endmodule
