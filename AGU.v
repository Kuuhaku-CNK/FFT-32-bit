module AGU (
    input wire clk, 
    input wire rst, 
    input wire enable, 
    output wire [4:0] addr_a,  
    output wire [4:0] addr_b,  
    output wire [3:0] addr_w,  
    output wire valid,       // Đã thêm tín hiệu valid
    output reg done      
);
  reg [2:0] stage;  
  reg [5:0] i, j;
  wire [5:0] len;
  
  assign len = 6'b000001 << stage;
  assign addr_a = i + j;
  assign addr_b = i + j + len;
  
  // ĐÃ SỬA LỖI OVERFLOW Ở ĐÂY
  assign addr_w = j << (3'd4 - stage); 
  
  // Tín hiệu valid cho Shift Register
  assign valid = enable && ~done;

  always @(posedge clk) begin
    if (rst) begin
      stage <= 0;
      i <= 0;
      j <= 0;
      done <= 0;
    end
    else if (enable && ~done) begin
      if (j == len - 1) begin
        j <= 0;
        if (i >= 32 - (len << 1)) begin   
          i <= 0;
          if (stage == 3'b100)
             done <= 1;
          else 
             stage <= stage + 1;
        end      
        else begin
          i <= i + (len << 1);
        end
      end
      else begin
        j <= j + 1;
      end
    end
  end
endmodule
