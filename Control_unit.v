module Control_unit (
    input clk, rst, valid_in, 
    input [4:0] addr_a_in,addr_b_in,  
    
    output reg [4:0] addr_a_out, addr_b_out
);
    reg [4:0] a0,a1,b0,b1;
    always @(posedge clk)
    begin
        if (rst) 
        begin
            a0 <= 5'd0;
            b0 <= 5'd0;
            addr_a_out <= 5'd0;
            addr_b_out <= 5'd0;
        end
        else 
        begin
          a0 <= addr_a_in;
          b0 <= addr_b_in;
        
          addr_a_out <= a1;
          addr_b_out <= a1;
        end
    end
endmodule