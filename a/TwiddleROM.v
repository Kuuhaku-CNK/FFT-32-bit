`timescale 1ns / 1ps

module twiddle_rom_32 (
    input wire clk,
    input wire [3:0] addr,              
    output reg signed [15:0] tw_real,   
    output reg signed [15:0] tw_imag    
);

    always @(posedge clk) begin
        case (addr)
            4'd0:  begin tw_real <=  16'sd32767; tw_imag <=  16'sd0;      end
            4'd1:  begin tw_real <=  16'sd32137; tw_imag <= -16'sd6393;   end
            4'd2:  begin tw_real <=  16'sd30273; tw_imag <= -16'sd12539;  end
            4'd3:  begin tw_real <=  16'sd27245; tw_imag <= -16'sd18204;  end
            4'd4:  begin tw_real <=  16'sd23170; tw_imag <= -16'sd23170;  end
            4'd5:  begin tw_real <=  16'sd18204; tw_imag <= -16'sd27245;  end
            4'd6:  begin tw_real <=  16'sd12539; tw_imag <= -16'sd30273;  end
            4'd7:  begin tw_real <=  16'sd6393;  tw_imag <= -16'sd32137;  end
            4'd8:  begin tw_real <=  16'sd0;     tw_imag <= -16'sd32767;  end
            4'd9:  begin tw_real <= -16'sd6393;  tw_imag <= -16'sd32137;  end
            4'd10: begin tw_real <= -16'sd12539; tw_imag <= -16'sd30273;  end
            4'd11: begin tw_real <= -16'sd18204; tw_imag <= -16'sd27245;  end
            4'd12: begin tw_real <= -16'sd23170; tw_imag <= -16'sd23170;  end
            4'd13: begin tw_real <= -16'sd27245; tw_imag <= -16'sd18204;  end
            4'd14: begin tw_real <= -16'sd30273; tw_imag <= -16'sd12539;  end
            4'd15: begin tw_real <= -16'sd32137; tw_imag <= -16'sd6393;   end
            default: begin tw_real <= 16'sd0;    tw_imag <= 16'sd0;       end
        endcase
    end

endmodule
