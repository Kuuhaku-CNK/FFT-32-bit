module Control_unit (
    input clk, rst,valid, 
    input [4:0] addr_a_in,addr_b_in,  
    
    output reg [4:0] addr_a_out, addr_b_out,
    output reg we
);
    reg [4:0] a0,b0;
    reg we0;
    always @(posedge clk)
    begin
        if (rst) 
        begin
            a0 <= 0;
            b0 <= 0;
            addr_a_out <= 0;
            addr_b_out <= 0;
	    we0 <= 0;
	    we <= 0;
        end
        else 
        begin
          a0 <= addr_a_in;
          b0 <= addr_b_in;
          we0 <= valid;
          
          addr_a_out <= a0;
          addr_b_out <= b0;
          we <= we0;
        end
    end
endmodule
