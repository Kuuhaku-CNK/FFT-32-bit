`timescale 1ns / 1ps

module input_rom_32 #(
    parameter D = 16
)(
    input  wire [4:0] addr_a,
    input  wire [4:0] addr_b,
    output wire signed [D-1:0] data_a_re,
    output wire signed [D-1:0] data_a_im,
    output wire signed [D-1:0] data_b_re,
    output wire signed [D-1:0] data_b_im
);

    // M?ng b? nh?: 32 ô, m?i ô 32-bit (Ph?n th?c 16-bit + Ph?n ?o 16-bit)
    reg [31:0] rom_data [0:31];

    // N?p d? li?u t? file bên ngoài
    initial begin
        // ??m b?o file "input_data.txt" n?m cùng th? m?c v?i file .v ho?c project Quartus
        $readmemh("input_data.txt", rom_data);
    end

    // ??c t? h?p (nh? d? li?u ngay khi có ??a ch?)
    // C?u trúc file: [31:16] là Real, [15:0] là Imag
    assign data_a_re = rom_data[addr_a][31:16];
    assign data_a_im = rom_data[addr_a][15:0];
    
    assign data_b_re = rom_data[addr_b][31:16];
    assign data_b_im = rom_data[addr_b][15:0];

endmodule
