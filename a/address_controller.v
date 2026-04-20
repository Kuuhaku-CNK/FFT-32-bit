module address_controller (
    input clk,       
    input rst_n,
    input btn_pulse, 
    input ctrl,      
    output reg [4:0] addr
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            addr <= 5'd0;
        else if (btn_pulse) begin 
            if (ctrl)
                addr <= addr + 5'd1;
            else
                addr <= addr - 5'd1;
        end
    end
endmodule