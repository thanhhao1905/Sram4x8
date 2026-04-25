module sram_ctrl_syn (
    input  wire clk,
    input  wire rst,
    input  wire we_req,
    input  wire re_req,
    
    output wire precharge,
    output wire we_pulse,
    output wire re_pulse,
    output wire sense_en
);
    
    // State encoding: 00=PRECHARGE, 01=ACTIVE, 10=SENSE
    reg [1:0] state, next_state;
    
    // Sequential state transition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 2'b00;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always @(*) begin
        case (state)
            2'b00: next_state = 2'b01;  // PRECHARGE -> ACTIVE
            2'b01: next_state = 2'b10;  // ACTIVE -> SENSE
            2'b10: next_state = 2'b00;  // SENSE -> PRECHARGE
            default: next_state = 2'b00;
        endcase
    end
    
    // Output logic
    assign precharge = (state == 2'b00);
    assign we_pulse  = (state == 2'b01) && we_req;
    assign re_pulse  = (state == 2'b01) && re_req;
    assign sense_en  = (state == 2'b01) || (state == 2'b10);
    
endmodule
