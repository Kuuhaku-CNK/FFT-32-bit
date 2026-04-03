module multipler #
(
    parameter Q = 8,
    parameter N = 16
)
(
    input clk,
    input rst,
    input wire signed [N-1:0] A,
    input wire signed [N-1:0] B,
    input wire signed [N-1:0] C,
);
    wire signed [2*N-1:0] P;
    assign P = A * B;
    always (negedge clk or posedge rst)
    begin
        if (rst) begin
            C <= 0;
        end else begin
            C <= P[N+Q-1:Q];
        end
    end 
endmodule
