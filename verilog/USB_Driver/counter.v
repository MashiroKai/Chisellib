//这是一个异步复位的计数器，aysn必须为脉冲信号，来一次脉冲则清零
//en为使能信号，使能则开始计数，否则暂停。
//RST为复位计数。

/*
counter #(
    .RST(),
    .START()
)
c1(
    .clk(clk)
    ,.rst_n(rst_n)
    ,.asyn(asyn)
    ,.en(en)
    ,.cnt(cnt)
    ,.pulse(pulse)
);
*/
module counter (
    input       clk,
    input       rst_n,
    input       asyn,
    input       en,    
    output   reg   [WIDTH:0] cnt,
    output   reg    pulse    
);
localparam  WIDTH = logb2(RST);
parameter   RST   = 9;
parameter   START = 0;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <=START;
    else if(asyn||cnt ==RST)
        cnt <=START;
    else if(en)
        cnt <= cnt + 1;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        pulse <=1'b0;
    else if(cnt ==RST)
        pulse <=1'b1;
    else
        pulse <=1'b0;    
end
function integer logb2;
    input [31:0]            value;
    reg   [31:0]            tmp;
begin
    tmp = value - 1;
    for (logb2 = 0; tmp > 0; logb2 = logb2 + 1) 
        tmp = tmp >> 1;
end
endfunction
endmodule



