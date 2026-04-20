`timescale 1ns/1ps
module Butterfly #(
    parameter D = 16,
    parameter Q = 15
)(
    input clk,
    input rst,

    input wire signed [D-1:0] A_re,
    input wire signed [D-1:0] A_im,
    input wire signed [D-1:0] B_re,
    input wire signed [D-1:0] B_im,
    input wire signed [D-1:0] W_re,
    input wire signed [D-1:0] W_im,
    
    output reg signed [D-1:0] X_re,
    output reg signed [D-1:0] X_im,
    output reg signed [D-1:0] Y_re,
    output reg signed [D-1:0] Y_im

);
    localparam const = 1 << (Q - 1);    
    reg signed [D-1:0] A_re_delay; 
    reg signed [D-1:0] A_im_delay;
    
    reg signed [2*D-1:0] mul_rr;
    reg signed [2*D-1:0] mul_ii;
    reg signed [2*D-1:0] mul_ri;
    reg signed [2*D-1:0] mul_ir;

    wire signed [D-1:0] BW_re;
    wire signed [D-1:0] BW_im;

    assign BW_re = (mul_rr - mul_ii + const) >>> Q;
    assign BW_im = (mul_ri + mul_ir + const) >>> Q;
    wire signed [D:0] X_re_temp = $signed(A_re_delay) + $signed(BW_re);
    wire signed [D:0] X_im_temp = $signed(A_im_delay) + $signed(BW_im);
    wire signed [D:0] Y_re_temp = $signed(A_re_delay) - $signed(BW_re);
    wire signed [D:0] Y_im_temp = $signed(A_im_delay) - $signed(BW_im);
    always @(posedge clk or posedge rst) begin 
        if (rst) begin 
            A_re_delay <= 0;
            A_im_delay <= 0;
            mul_rr <= 0;
            mul_ii <= 0;
            mul_ri <= 0;
            mul_ir <= 0;
            X_re <= 0;
            X_im <= 0;
            Y_re <= 0;
            Y_im <= 0;
         end else begin 
             mul_rr <= B_re * W_re;
             mul_ii <= B_im * W_im;
             mul_ri <= B_re * W_im;
             mul_ir <= B_im * W_re;

             A_re_delay <= A_re;
             A_im_delay <= A_im;
             
             X_re <= X_re_temp[D:1]; 
             X_im <= X_im_temp[D:1];
             Y_re <= Y_re_temp[D:1];
             Y_im <= Y_im_temp[D:1];
         end
     end
endmodule
