`timescale 1ns / 1ps

module fft_top #(
    parameter D = 16,
    parameter Q = 15
)(
    input wire clk,
    input wire rst,
    
    // Cổng nạp dữ liệu song song (2 mẫu/clock)
    input wire signed [D-1:0] data_in_a_re, data_in_a_im,
    input wire signed [D-1:0] data_in_b_re, data_in_b_im,
    
    output wire done
);

    // --- 1. KHAI BÁO CÁC ĐƯỜNG DÂY LIÊN KẾT (INTERNAL WIRES) ---
    
    // Tín hiệu từ AGU
    wire [4:0] addr_a_rd, addr_b_rd;
    wire [3:0] addr_w;
    wire valid_agu, done_agu;
    wire ena_agu;

    // Tín hiệu từ Control Unit
    wire sel, we;
    wire [4:0] addr_a_w, addr_b_w;

    // Tín hiệu từ DPRAM (Dữ liệu đọc ra)
    wire signed [D-1:0] dout_a_re, dout_a_im;
    wire signed [D-1:0] dout_b_re, dout_b_im;

    // Tín hiệu từ Twiddle ROM
    wire signed [D-1:0] w_re, w_im;

    // Tín hiệu từ Butterfly (Kết quả tính toán)
    wire signed [D-1:0] x_re, x_im, y_re, y_im;

    // --- 2. LOGIC MUX CHỌN DỮ LIỆU GHI VÀO RAM ---
    // Nếu sel = 0: Nạp từ Input ngoài. Nếu sel = 1: Ghi kết quả từ Butterfly
    wire signed [D-1:0] ram_din_a_re = (sel == 1'b0) ? data_in_a_re : x_re;
    wire signed [D-1:0] ram_din_a_im = (sel == 1'b0) ? data_in_a_im : x_im;
    wire signed [D-1:0] ram_din_b_re = (sel == 1'b0) ? data_in_b_re : y_re;
    wire signed [D-1:0] ram_din_b_im = (sel == 1'b0) ? data_in_b_im : y_im;

    // --- 3. INSTANTIATION: GỌI CÁC MODULE CON ---

    // Khối bộ não sinh địa chỉ
    AGU u_agu (
        .clk(clk), .rst(rst), .enable(ena_agu),
        .addr_a(addr_a_rd), .addr_b(addr_b_rd), .addr_w(addr_w),
        .valid(valid_agu), .done(done_agu)
    );

    // Khối nhạc trưởng điều phối Pipeline
    Control_Unit u_cu (
        .clk(clk), .rst(rst),
        .valid_in(valid_agu), .done_in(done_agu),
        .addr_a_agu(addr_a_rd), .addr_b_agu(addr_b_rd),
        .ena_agu(ena_agu), .sel(sel), .we(we),
        .addr_a_w(addr_a_w), .addr_b_w(addr_b_w)
    );

    // Khối bộ nhớ 4 cổng (Distributed RAM)
    // Giả định bạn dùng 1 block RAM 4 cổng như đã chốt
    // Khối tính toán Butterfly
// Khối bộ nhớ 4 cổng (Distributed RAM)
    dpram_fft32 u_ram (
        .clk(clk),
        
        // Cổng Đọc
        .addr_a_rd(addr_a_rd), 
        .dout_a_re(dout_a_re), 
        .dout_a_im(dout_a_im),
        
        .addr_b_rd(addr_b_rd),
        .dout_b_re(dout_b_re), 
        .dout_b_im(dout_b_im),
        
        // Cổng Ghi
        // Nối tín hiệu 'we' duy nhất từ Control Unit vào cả 2 cổng Ghi của RAM
        .we_a(we),             
        .addr_a_wr(addr_a_w),  // Lưu ý: Trong top gọi là addr_a_w, trong RAM là addr_a_wr
        .din_a_re(ram_din_a_re), 
        .din_a_im(ram_din_a_im),
        
        .we_b(we),             
        .addr_b_wr(addr_b_w), 
        .din_b_re(ram_din_b_re), 
        .din_b_im(ram_din_b_im)
    );
    Butterfly #( .D(D), .Q(Q) ) u_bf (
        .clk(clk), .rst(rst),
        .A_re(dout_a_re), .A_im(dout_a_im),
        .B_re(dout_b_re), .B_im(dout_b_im),
        .W_re(w_re), .W_im(w_im),
        .X_re(x_re), .X_im(x_im),
        .Y_re(y_re), .Y_im(y_im)
    );

    // Khối ROM hệ số góc (Placeholder - bạn cần nạp file .coe hoặc dùng case)
    twiddle_rom_32 u_rom (
        .clk(clk), .addr(addr_w),
        .tw_real(w_re), .tw_imag(w_im)
    );

    assign done = (u_cu.state == 2'd2); // S_DONE

endmodule
