module bin_to_signed_dec (
    input [15:0] bin_val,
    output reg [7:0] char5, char4, char3, char2, char1, char0
);
    reg [15:0] abs_val;
    integer i;
    reg [19:0] bcd; 

    always @(*) begin
        if (bin_val[15]) begin
            char5 = 8'h2D; // Dấu '-'
            abs_val = ~bin_val + 1'b1;
        end else begin
            char5 = 8'h2B; // Dấu '+'
            abs_val = bin_val;
        end

        bcd = 0;
        for (i = 0; i < 16; i = i + 1) begin
            if (bcd[3:0] >= 5) bcd[3:0] = bcd[3:0] + 3;
            if (bcd[7:4] >= 5) bcd[7:4] = bcd[7:4] + 3;
            if (bcd[11:8] >= 5) bcd[11:8] = bcd[11:8] + 3;
            if (bcd[15:12] >= 5) bcd[15:12] = bcd[15:12] + 3;
            if (bcd[19:16] >= 5) bcd[19:16] = bcd[19:16] + 3;
            bcd = {bcd[18:0], abs_val[15-i]};
        end

        char4 = {4'h3, bcd[19:16]};
        char3 = {4'h3, bcd[15:12]};
        char2 = {4'h3, bcd[11:8]};
        char1 = {4'h3, bcd[7:4]};
        char0 = {4'h3, bcd[3:0]};
    end
endmodule