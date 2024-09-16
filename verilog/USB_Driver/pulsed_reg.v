/*
pulsed_reg #(
    .WIDTH(5)
)
p1(
    .clk(clk)
    ,.rst_n(rst_n)
    ,.signal(signal)
    ,.pos(pos)
    ,.neg(neg)
);

*/
module pulsed_reg #(
    parameter WIDTH = 5
)
(
        input      clk
        ,input     rst_n
        ,input      [WIDTH-1:0]signal
        ,output     [WIDTH-1:0]pos
        ,output     [WIDTH-1:0]neg
);
reg [2*WIDTH-1:0]temp;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        temp <= 0;
    end
    else begin
        temp <= {temp[WIDTH-1:0],signal};
    end
end
assign pos= (~temp[2*WIDTH-1:WIDTH])&temp[WIDTH-1:0];
assign neg= temp[2*WIDTH-1:WIDTH]&(~temp[WIDTH-1:0]);
endmodule