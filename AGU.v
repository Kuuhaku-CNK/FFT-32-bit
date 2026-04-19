module AGU (
    input clk, rst, enable, 
    output [4:0] addr_a, addr_b,  
    output [3:0] addr_w,  
    output valid,      
    output reg done      
);
  reg [2:0] stage;  
  reg [4:0] i, j;
  wire [5:0] len;
  wire [4:0] ipj;
  assign len = 6'b1 << stage;
  assign ipj = i + j;
  assign addr_a = ipj;
  assign addr_b = ipj + len;
  assign addr_w = j << (5'd4 - stage); 
  assign valid = enable && ~done;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      stage <= 0;
      i <= 0;
      j <= 0;
      done <= 0;
    end
    else if (enable && ~done) begin
      if (j == len - 1'b1) begin
        j <= 0;
        if (i >= 6'd32 - (len << 1)) begin   
          i <= 0;
          if (stage == 3'b100)
             done <= 1;
          else 
             stage <= stage + 1'b1;
        end      
        else begin
          i <= i + (len << 1);
        end
      end
      else begin
        j <= j + 1'b1;
      end
    end
  end
endmodule