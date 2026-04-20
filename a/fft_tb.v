`timescale 1ns / 1ps

module fft_tb;

    // --- 1. KHAI BÁO THAM SỐ VÀ TÍN HIỆU ---
    parameter D = 16;
    parameter Q = 15;

    reg clk;
    reg rst;
    
    // Khai báo ngõ vào dữ liệu
    reg signed [D-1:0] in_a_re, in_a_im;
    reg signed [D-1:0] in_b_re, in_b_im;
    
    // Khai báo ngõ ra
    wire done;

    // KHAI BÁO CÁC BIẾN VÒNG LẶP VÀ XỬ LÝ FILE Ở ĐÂY (TRƯỚC INITIAL)
    integer i, k;
    integer file_id; 

    // --- 2. GỌI MODULE TOP ---
    fft_top #(
        .D(D), 
        .Q(Q)
    ) uut (
        .clk(clk),
        .rst(rst),
        .data_in_a_re(in_a_re), .data_in_a_im(in_a_im),
        .data_in_b_re(in_b_re), .data_in_b_im(in_b_im),
        .done(done)
    );

    // --- 3. BỘ TẠO XUNG CLOCK (100 MHz) ---
    always #5 clk = ~clk; // Chu kỳ 10ns

    // --- 4. KỊCH BẢN TEST (STIMULUS) ---
    initial begin
        // Khởi tạo ban đầu
        clk = 0;
        rst = 1;
        in_a_re = 0; in_a_im = 0;
        in_b_re = 0; in_b_im = 0;

        // Giữ Reset trong 105ns 
        #105; 
        rst = 0;
        
        $display("[%0t] --- BAT DAU NAP DU LIEU (TEST NYQUIST) ---", $time);
        
        for (i = 0; i < 16; i = i + 1) begin
            // Mẫu chẵn (0, 2, 4...) nạp vào Port A
            in_a_re =  16'sd15000;  
            in_a_im = -16'sd8000;   // Phần ảo là số âm
            
            // Mẫu lẻ (1, 3, 5...) nạp vào Port B (Lật dấu ngược lại)
            in_b_re = -16'sd15000;  
            in_b_im =  16'sd8000;   
            
            #10; 
        end 
        
        // Nạp xong 16 nhịp, dọn dẹp cổng nạp
        in_a_re = 0; in_b_re = 0; 
        
        $display("[%0t] --- DANG TINH TOAN FFT (CALC PHASE) ---", $time);

        // Chờ đợi tín hiệu done từ hệ thống bật lên 1
        wait (done == 1'b1);
        $display("[%0t] --- FFT HOAN THANH! ---", $time);
        
        // ========================================================
        // ĐOẠN CODE XUẤT DỮ LIỆU RA FILE TXT
        // ========================================================
        $display("[%0t] --- DANG XUAT DU LIEU RA FILE txt ---", $time);
        
        // Mở file theo đường dẫn tuyệt đối sang ổ C của Windows
        file_id = $fopen("C:/Users/Khang/Downloads/FFT-32-bit-main/fft_output.txt", "w");
        
        if (file_id) begin
            // Vòng lặp chọc thẳng vào RAM để lấy 32 giá trị ra
            for (k = 0; k < 32; k = k + 1) begin
                // Ghi theo format: [Phần_Thực] [Dấu_cách] [Phần_Ảo]
                $fwrite(file_id, "%d %d\n", uut.u_ram.mem_re[k], uut.u_ram.mem_im[k]);
            end
            
            $fclose(file_id); // Đóng file lại để lưu
            $display("[%0t] --- GHI FILE THANH CONG! ---", $time);
        end else begin
            $display("LOI: Khong the tao file fft_output.txt. Hay kiem tra lai duong dan!");
        end
        // ========================================================

        // Chờ thêm một chút để quan sát dạng sóng rồi dừng mô phỏng
        #50; 
        $stop;
    end

endmodule