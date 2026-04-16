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

    // --- 2. GỌI MODULE TOP ---
    // LƯU Ý: Chắc chắn rằng file fft_top.v của bạn cũng đã xóa input 'start'
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
    integer i;
    
    initial begin
        // Khởi tạo ban đầu
        clk = 0;
        rst = 1;
        in_a_re = 0; in_a_im = 0;
        in_b_re = 0; in_b_im = 0;

        // Giữ Reset trong 105ns (Thả reset ở sườn âm để an toàn cho setup-time)
        #105; 
        rst = 0;
        
        $display("[%0t] --- BAT DAU NAP DU LIEU (LOAD PHASE) ---", $time);
        
        // Ngay khi rst = 0, Control_Unit của bạn sẽ ở S_IDLE_LOAD và we = 1
        // Ta có chính xác 16 chu kỳ clock để bơm 32 mẫu vào RAM
                
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
        
        // Nạp xong 16 nhịp, Control_Unit của bạn tự động chuyển sang S_CALC
        // Ta dọn dẹp cổng nạp để không ảnh hưởng
        in_a_re = 0; in_b_re = 0; 
        
        $display("[%0t] --- DANG TINH TOAN FFT (CALC PHASE) ---", $time);

        // Chờ đợi tín hiệu done từ hệ thống
        wait (done == 1'b1);
        integer k, i;
    integer file_id; // Thêm biến này để xử lý file
    
    initial begin
        // ... (Phần nạp tín hiệu Testcase và chạy chờ giống hệt trước đây) ...
        
        $display("[%0t] --- DANG TINH TOAN FFT ---", $time);

        // Chờ đến khi cờ done bật lên 1
        wait (done == 1'b1);
        $display("[%0t] --- FFT HOAN THANH! ---", $time);
        
        // ========================================================
        // ĐOẠN CODE MỚI: XUẤT DỮ LIỆU RA FILE TXT
        // ========================================================
        $display("[%0t] --- DANG XUAT DU LIEU RA FILE txt ---", $time);
        
        // Mở file (nếu chưa có tự tạo, 'w' là chế độ ghi đè)
        file_id = $fopen("fft_output.txt", "w"); 
        
        if (file_id) begin
            // Vòng lặp chọc thẳng vào RAM để lấy 32 giá trị ra
            for (k = 0; k < 32; k = k + 1) begin
                // Ghi theo format: [Phần_Thực] [Dấu_cách] [Phần_Ảo]
                $fwrite(file_id, "%d %d\n", uut.u_ram.mem_re[k], uut.u_ram.mem_im[k]);
            end
            
            $fclose(file_id); // Đóng file lại để lưu
            $display("[%0t] --- GHI FILE THANH CONG! ---", $time);
        end else begin
            $display("LOI: Khong the tao file fft_output.txt");
        end
        // ========================================================

        #50; 
        $finish;
    end        
        $display("[%0t] --- FFT HOAN THANH! ---", $time);
        
        // Chờ thêm một chút để quan sát dạng sóng rồi kết thúc
        #50; 
        $stop;
    end

endmodule
