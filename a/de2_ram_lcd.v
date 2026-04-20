module de2_ram_lcd (
    input CLOCK_50,
    input [3:0] KEY,    
    input SW_CTRL,      
    input [31:0] ram_data,
    input fft_done,
    output [4:0] ram_addr,
    output [7:0] LCD_DATA,
    output LCD_RW, LCD_EN, LCD_RS, LCD_ON, LCD_BLON
);
    assign LCD_ON = 1'b1;
    assign LCD_BLON = 1'b1;
    assign LCD_RW = 1'b0; 

    wire [7:0] high_chars [5:0];
    wire [7:0] low_chars [5:0];

    // Tách địa chỉ để hiển thị (00 - 31)
    wire [7:0] addr_tens  = {4'h3, (ram_addr / 10)}; // Hàng chục ASCII
    wire [7:0] addr_units = {4'h3, (ram_addr % 10)}; // Hàng đơn vị ASCII

    // Mạch chống dội phím (Bắt sườn nút nhấn)
    reg key1_d1, key1_d2, key1_d3;
    always @(posedge CLOCK_50 or negedge KEY[0]) begin
        if (!KEY[0]) begin
            key1_d1 <= 1'b1; key1_d2 <= 1'b1; key1_d3 <= 1'b1;
        end else begin
            key1_d1 <= KEY[1]; key1_d2 <= key1_d1; key1_d3 <= key1_d2;
        end
    end
    wire btn_press_pulse = (~key1_d2 & key1_d3); 

    // Khối điều khiển địa chỉ
    address_controller addr_inst (
        .clk(CLOCK_50), .rst_n(KEY[0]),
        .btn_pulse(btn_press_pulse), .ctrl(SW_CTRL),
        .addr(ram_addr)
    );

    // Chuyển đổi 16 bit cao (Phần Thực)
    bin_to_signed_dec high_dec (
        .bin_val(ram_data[31:16]),
        .char5(high_chars[5]), .char4(high_chars[4]), .char3(high_chars[3]),
        .char2(high_chars[2]), .char1(high_chars[1]), .char0(high_chars[0])
    );

    // Chuyển đổi 16 bit thấp (Phần Ảo)
    bin_to_signed_dec low_dec (
        .bin_val(ram_data[15:0]),
        .char5(low_chars[5]), .char4(low_chars[4]), .char3(low_chars[3]),
        .char2(low_chars[2]), .char1(low_chars[1]), .char0(low_chars[0])
    );

    // FSM điều khiển LCD
    reg [5:0] state; 
    reg [7:0] lcd_out;
    reg rs_ctrl, en_ctrl;

    assign LCD_DATA = lcd_out;
    assign LCD_RS = rs_ctrl;
    assign LCD_EN = en_ctrl;

    // Tạo xung clock chậm cho LCD
    reg [17:0] clk_div;
    always @(posedge CLOCK_50) clk_div <= clk_div + 1'b1;
    wire lcd_clk = clk_div[17];

    always @(posedge lcd_clk or negedge KEY[0]) begin
        if (!KEY[0]) begin
            state <= 0; en_ctrl <= 0;
        end else begin
            en_ctrl <= ~en_ctrl; 
            if (en_ctrl) begin
                case (state)
                    // Khởi tạo LCD
                    0: begin rs_ctrl <= 0; lcd_out <= 8'h38; state <= 1; end
                    1: begin rs_ctrl <= 0; lcd_out <= 8'h0C; state <= 2; end
                    2: begin rs_ctrl <= 0; lcd_out <= 8'h01; state <= 3; end 
                    
                    // Trạng thái Chờ: Đợi FFT tính xong mới in
                    3: begin 
                        if (fft_done) begin rs_ctrl <= 0; lcd_out <= 8'h80; state <= 4; end
                        else begin rs_ctrl <= 0; lcd_out <= 8'h80; state <= 3; end
                    end
                    
                    // In tiền tố Địa chỉ "A:xx " (Dòng 1)
                    4: begin rs_ctrl <= 1; lcd_out <= 8'h41; state <= 5; end  // 'A'
                    5: begin rs_ctrl <= 1; lcd_out <= 8'h3A; state <= 6; end  // ':'
                    6: begin rs_ctrl <= 1; lcd_out <= addr_tens; state <= 7; end
                    7: begin rs_ctrl <= 1; lcd_out <= addr_units; state <= 8; end
                    8: begin rs_ctrl <= 1; lcd_out <= 8'h20; state <= 9; end  // Khoảng trắng
                    
                    // In Phần thực "R:+yyyyy"
                    9: begin rs_ctrl <= 1; lcd_out <= 8'h52; state <= 10; end // 'R'
                    10:begin rs_ctrl <= 1; lcd_out <= 8'h3A; state <= 11; end // ':'
                    11:begin rs_ctrl <= 1; lcd_out <= high_chars[5]; state <= 12; end
                    12:begin rs_ctrl <= 1; lcd_out <= high_chars[4]; state <= 13; end
                    13:begin rs_ctrl <= 1; lcd_out <= high_chars[3]; state <= 14; end
                    14:begin rs_ctrl <= 1; lcd_out <= high_chars[2]; state <= 15; end
                    15:begin rs_ctrl <= 1; lcd_out <= high_chars[1]; state <= 16; end
                    16:begin rs_ctrl <= 1; lcd_out <= high_chars[0]; state <= 17; end
                    
                    // Chuyển con trỏ xuống Dòng 2
                    17:begin rs_ctrl <= 0; lcd_out <= 8'hC0; state <= 18; end 
                    
                    // In 5 khoảng trắng để căn lề phần ảo thẳng hàng với phần thực
                    18:begin rs_ctrl <= 1; lcd_out <= 8'h20; state <= 19; end
                    19:begin rs_ctrl <= 1; lcd_out <= 8'h20; state <= 20; end
                    20:begin rs_ctrl <= 1; lcd_out <= 8'h20; state <= 21; end
                    21:begin rs_ctrl <= 1; lcd_out <= 8'h20; state <= 22; end
                    22:begin rs_ctrl <= 1; lcd_out <= 8'h20; state <= 23; end 
                    
                    // In Phần ảo "I:+zzzzzi"
                    23:begin rs_ctrl <= 1; lcd_out <= 8'h49; state <= 24; end // 'I'
                    24:begin rs_ctrl <= 1; lcd_out <= 8'h3A; state <= 25; end // ':'
                    25:begin rs_ctrl <= 1; lcd_out <= low_chars[5]; state <= 26; end
                    26:begin rs_ctrl <= 1; lcd_out <= low_chars[4]; state <= 27; end
                    27:begin rs_ctrl <= 1; lcd_out <= low_chars[3]; state <= 28; end
                    28:begin rs_ctrl <= 1; lcd_out <= low_chars[2]; state <= 29; end
                    29:begin rs_ctrl <= 1; lcd_out <= low_chars[1]; state <= 30; end
                    30:begin rs_ctrl <= 1; lcd_out <= low_chars[0]; state <= 31; end
                    31:begin rs_ctrl <= 1; lcd_out <= 8'h69; // 'i'
                        // Vòng lặp cập nhật liên tục hoặc reset nếu FFT tắt
                        if (!fft_done) state <= 2; else state <= 3; 
                    end
                    
                    default: state <= 0;
                endcase
            end
        end
    end
endmodule