`timescale 1ns / 1ps
module dpram_fft32 (
    input  wire        clk,

    input  wire [4:0] addr_a_rd,
    output reg  signed [15:0] dout_a_re,
    output reg  signed [15:0] dout_a_im,

    input  wire [4:0] addr_b_rd,
    output reg  signed [15:0] dout_b_re,
    output reg  signed [15:0] dout_b_im,

    input  wire we_a,
    input  wire [4:0] addr_a_wr,
    input  wire signed [15:0] din_a_re,
    input  wire signed [15:0] din_a_im,

    input  wire we_b,
    input  wire [4:0] addr_b_wr,
    input  wire signed [15:0] din_b_re,
    input  wire signed [15:0] din_b_im
);

    reg signed [15:0] mem_re [0:31];
    reg signed [15:0] mem_im [0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            mem_re[i] = 16'sd0;
            mem_im[i] = 16'sd0;
        end
    end

    always @(posedge clk) begin
        if (we_a) begin
            mem_re[addr_a_wr] <= din_a_re;
            mem_im[addr_a_wr] <= din_a_im;
        end
        dout_a_re <= mem_re[addr_a_rd];
        dout_a_im <= mem_im[addr_a_rd];
    end

    always @(posedge clk) begin
        if (we_b) begin
            mem_re[addr_b_wr] <= din_b_re;
            mem_im[addr_b_wr] <= din_b_im;
        end
        dout_b_re <= mem_re[addr_b_rd];
        dout_b_im <= mem_im[addr_b_rd];
    end
endmodule
