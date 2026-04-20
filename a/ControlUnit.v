`timescale 1ns / 1ps
module Control_Unit (
    input clk, rst, valid_in, done_in,        
    input [4:0] addr_a_agu, addr_b_agu,
    output reg ena_agu,        
    output sel, we, done_out,          
    output [4:0] addr_a_w, addr_b_w
);
    localparam S_IDLE_LOAD = 2'd0;
    localparam S_CALC = 2'd1;
    localparam S_DONE = 2'd2;
    reg [1:0] state, next_state;
    reg [5:0] load_counter;    
    reg [4:0] delay_addr_a [0:2], delay_addr_b [0:2];
    reg delay_valid [0:2];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_IDLE_LOAD;
            load_counter <= 5'd0;
        end 
        else begin
            state <= next_state;
            if (state == S_IDLE_LOAD) begin
                load_counter <= load_counter + 2;
            end
        end
    end
    always @(*) begin
        next_state = state;
        ena_agu = 1'b0;
        case (state)
            S_IDLE_LOAD: begin
                if (load_counter >= 6'd30)
                    next_state = S_CALC;  
            end

            S_CALC: begin
                ena_agu = 1'b1;           
                if (done_in)
                    next_state = S_DONE;  
            end
            S_DONE:;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            delay_addr_a[0] <= 5'd0; delay_addr_a[1] <= 5'd0; delay_addr_a[2] <= 5'd0;
            delay_addr_b[0] <= 5'd0; delay_addr_b[1] <= 5'd0; delay_addr_b[2] <= 5'd0;
            delay_valid[0]  <= 1'b0; delay_valid[1]  <= 1'b0; delay_valid[2]  <= 1'b0;
        end 
        else begin
            delay_addr_a[0] <= addr_a_agu;
            delay_addr_b[0] <= addr_b_agu;
            delay_valid[0]  <= valid_in;

            delay_addr_a[1] <= delay_addr_a[0];
            delay_addr_b[1] <= delay_addr_b[0];
            delay_valid[1]  <= delay_valid[0];

            delay_addr_a[2] <= delay_addr_a[1];
            delay_addr_b[2] <= delay_addr_b[1];
            delay_valid[2]  <= delay_valid[1];
        end
    end
    
    assign sel = (state == S_CALC || state == S_DONE) ? 1'b1 : 1'b0;
    assign we = (sel == 1'b0) ? 1'b1 : delay_valid[2];

    wire [4:0] linear_addr_a = load_counter[4:0];
    wire [4:0] linear_addr_b = load_counter[4:0] + 5'd1;
    wire [4:0] bitrev_addr_a = {linear_addr_a[0], linear_addr_a[1], linear_addr_a[2], linear_addr_a[3], linear_addr_a[4]};
    wire [4:0] bitrev_addr_b = {linear_addr_b[0], linear_addr_b[1], linear_addr_b[2], linear_addr_b[3], linear_addr_b[4]};

    assign addr_a_w = (sel == 1'b0) ? bitrev_addr_a : delay_addr_a[2];
    assign addr_b_w = (sel == 1'b0) ? bitrev_addr_b : delay_addr_b[2];
	  assign done_out = (state == S_DONE);
	  
endmodule