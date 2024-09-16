module wr_fifo_test (
        input       clk
        ,input       rst_n
        ,input      full
        ,output      valid
        ,output      [7:0]dout
);
reg [15:0]temp;
assign dout = temp[15:8];
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        temp <= {8'b10101010,8'b01010101};
    end
    else begin
        if (valid) begin
            temp <= {temp[7:0],temp[15:8]};
        end
        else begin
            temp <= temp;
        end
    end
end
assign valid = ~full;

endmodule