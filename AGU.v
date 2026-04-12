`timescale 1ns / 1ps
module fft_agu_32 (
    input clk, rst, enable, 
    output [4:0] addr_a,addr_b,  
    output [3:0] addr_w,   
    output reg done     
);
  reg [2:0] stage;  
  reg [5:0] i,j;
  wire [5:0] len;
  
  assign len = 6'b000001 << stage;
  assign addr_a = i + j;
  assign addr_b = i + j + len;
  assign addr_w = (j << 4) >> stage;
  always @(posedge clk)
  begin
    if (rst) 
    begin
      stage <= 0;
      i <= 0;
      j <= 0;
      done <= 0;
    end
    else if (enable && ~done)
    begin
      if (j == len - 1) 
      begin
        j <= 0;
        if (i >= 32 - (len << 1)) 
	      begin	
	        i <= 0;
	        if (stage == 3'b100)
	           done <= 1;
          else stage <= stage + 1;
        end      
        else
          i <= i + (len << 1);
      end
      else 
	      j <= j + 1;
    end
  end
endmodule