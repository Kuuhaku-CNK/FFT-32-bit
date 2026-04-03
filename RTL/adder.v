module adder #
(
    parameter N = 16
)
(
    input wire signed [N-1:0] A,
    input wire signed [N-1:0] B,
    input wire signed [N:0] C
)
    assign C = A + B;
endmodule
