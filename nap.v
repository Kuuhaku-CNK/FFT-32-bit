`timescale 1ns / 1ps

module nap (
    input CLOCK_50,
    input [3:0] KEY,        // KEY[0] làm Reset, KEY[1] làm nút nh?n chuy?n ??a ch?
    input [17:0] SW,        // SW[0] ch?n chi?u t?ng/gi?m

    // Các chân giao ti?p màn hình LCD trên DE2
    output [7:0] LCD_DATA,
    output LCD_RW, LCD_EN, LCD_RS, LCD_ON, LCD_BLON,
    
    // LED hi?n th? tr?ng thái
    output [8:0] LEDG       // LEDG[0] sáng khi FFT tính xong
);

    // =========================================================================
    // 1. KHAI BÁO DÂY N?I GI?A HAI KH?I (INTERNAL WIRES)
    // =========================================================================
    wire [4:0]  read_addr_wire;      // Dây truy?n ??a ch? t? LCD sang FFT
    wire signed [15:0] fft_out_re_wire; // Dây truy?n data ph?n th?c t? FFT sang LCD
    wire signed [15:0] fft_out_im_wire; // Dây truy?n data ph?n ?o t? FFT sang LCD
    wire        fft_done_wire;       // Dây báo tr?ng thái hoàn thành

    // X? lý tín hi?u Reset (Nút nh?n trên DE2 là tích c?c m?c th?p - Active Low)
    wire rst_active_high = ~KEY[0];  // Module FFT dùng rst tích c?c m?c cao
    wire rst_active_low  = KEY[0];   // Module LCD dùng rst tích c?c m?c th?p

    // =========================================================================
    // 2. KH?I T?O KH?I FFT_TOP
    // =========================================================================
    fft_top #(
        .D(16),
        .Q(15)
    ) u_fft (
        .clk(CLOCK_50),
        .rst(rst_active_high),
        
        // C?NG N?P D? LI?U: 
        // (T?m th?i gán 0. Trong th?c t? b?n c?n n?i các chân này v?i kh?i n?p d? li?u t? ADC ho?c ROM test case)
        .data_in_a_re(16'd0), .data_in_a_im(16'd0),
        .data_in_b_re(16'd0), .data_in_b_im(16'd0),
        
        .done(fft_done_wire),
        
        // NH?N ??A CH? T? LCD: N?i dây t? kh?i LCD vào chân ext_read_addr
        .ext_read_addr(read_addr_wire), 
        
        // XU?T D? LI?U RA LCD
        .data_out_re(fft_out_re_wire),
        .data_out_im(fft_out_im_wire)
    );

    de2_ram_lcd u_lcd (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),             
        .SW_CTRL(SW[0]),       
        .ram_data({fft_out_re_wire, fft_out_im_wire}), 
        
        // N?I DÂY VÀO ?ÂY: Truy?n tr?ng thái hoàn thành t? FFT sang LCD
        .fft_done(fft_done_wire), 
        
        .ram_addr(read_addr_wire), 
        .LCD_DATA(LCD_DATA),
        .LCD_RW(LCD_RW), .LCD_EN(LCD_EN), .LCD_RS(LCD_RS), 
        .LCD_ON(LCD_ON), .LCD_BLON(LCD_BLON)
    );

    assign LEDG[0] = fft_done_wire; // Khi FFT tính xong, ?èn LED xanh s? sáng

endmodule
