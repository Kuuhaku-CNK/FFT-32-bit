`timescale 1ns / 1ps

module nap (
    input CLOCK_50,
    input [1:0] KEY,        // KEY[0] l�m Reset, KEY[1] l�m n�t nh?n chuy?n ??a ch?
    input [0:0] SW,        // SW[0] ch?n chi?u t?ng/gi?m

    // C�c ch�n giao ti?p m�n h�nh LCD tr�n DE2
    output [7:0] LCD_DATA,
    output LCD_RW, LCD_EN, LCD_RS, LCD_ON, LCD_BLON,
    
    // LED hi?n th? tr?ng th�i
    output [0:0] LEDG       // LEDG[0] s�ng khi FFT t�nh xong
);

    // =========================================================================
    // 1. KHAI B�O D�Y N?I GI?A HAI KH?I (INTERNAL WIRES)
    // =========================================================================
    wire [4:0] load_addr_a_wire, load_addr_b_wire; // ??a ch? t? FFT sang ROM
    wire [15:0] rom_data_a_re, rom_data_a_im;      // D? li?u t? ROM v? FFT
    wire [15:0] rom_data_b_re, rom_data_b_im;
    wire [4:0]  read_addr_wire;      // D�y truy?n ??a ch? t? LCD sang FFT
    wire signed [15:0] fft_out_re_wire; // D�y truy?n data ph?n th?c t? FFT sang LCD
    wire signed [15:0] fft_out_im_wire; // D�y truy?n data ph?n ?o t? FFT sang LCD
    wire        fft_done_wire;       // D�y b�o tr?ng th�i ho�n th�nh

    // X? l� t�n hi?u Reset (N�t nh?n tr�n DE2 l� t�ch c?c m?c th?p - Active Low)
    wire rst_active_high = ~KEY[0];  // Module FFT d�ng rst t�ch c?c m?c cao
    wire rst_active_low  = KEY[0];   // Module LCD d�ng rst t�ch c?c m?c th?p

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
        // (T?m th?i g�n 0. Trong th?c t? b?n c?n n?i c�c ch�n n�y v?i kh?i n?p d? li?u t? ADC ho?c ROM test case)
        .data_in_a_re(rom_data_a_re), .data_in_a_im(rom_data_a_im),
        .data_in_b_re(rom_data_b_re), .data_in_b_im(rom_data_b_im),
        .load_addr_a(load_addr_a_wire),
        .load_addr_b(load_addr_b_wire),
        .done(fft_done_wire),
        
        // NH?N ??A CH? T? LCD: N?i d�y t? kh?i LCD v�o ch�n ext_read_addr
        .ext_read_addr(read_addr_wire), 
        
        // XU?T D? LI?U RA LCD
        .data_out_re(fft_out_re_wire),
        .data_out_im(fft_out_im_wire)
    );
    input_rom_32 u_input_rom (
        .addr_a(load_addr_a_wire), 
        .addr_b(load_addr_b_wire),
        .data_a_re(rom_data_a_re), .data_a_im(rom_data_a_im),
        .data_b_re(rom_data_b_re), .data_b_im(rom_data_b_im)
    );
    de2_ram_lcd u_lcd (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),             
        .SW_CTRL(SW[0]),       
        .ram_data({fft_out_re_wire, fft_out_im_wire}), 
        
        // N?I D�Y V�O ?�Y: Truy?n tr?ng th�i ho�n th�nh t? FFT sang LCD
        .fft_done(fft_done_wire), 
        
        .ram_addr(read_addr_wire), 
        .LCD_DATA(LCD_DATA),
        .LCD_RW(LCD_RW), .LCD_EN(LCD_EN), .LCD_RS(LCD_RS), 
        .LCD_ON(LCD_ON), .LCD_BLON(LCD_BLON)
    );

    assign LEDG[0] = fft_done_wire; // Khi FFT t�nh xong, ?�n LED xanh s? s�ng

endmodule
