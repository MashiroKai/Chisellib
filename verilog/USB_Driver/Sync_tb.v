`timescale 1ns/100ps
module Sync_tb;
reg sys_clk,ft232_clk,sys_rst_n,ft232_rst_n;
always #20 sys_clk = ~sys_clk;
always #25 ft232_clk = ~ft232_clk;
reg VALID ;
reg [7:0]FIFO_DIN ;
initial begin
    sys_clk = 0 ;
    ft232_clk = 0;
    sys_rst_n = 0;
    ft232_rst_n = 0;
    #200
    sys_rst_n = 1;
    ft232_rst_n = 1;
    VALID = 1'b1;
    FIFO_DIN = 8'hEB;
    #40  
    VALID = 1'b0;
    #40
    VALID = 1'b1;
    FIFO_DIN = 8'hBB;
    #40  
    VALID = 1'b0;
#2000 $finish();
end
FIFO2Usb_Sync #(
    .WIDTH(8),                // 设置数据位宽
    .WRFIFO_DEPTH(131072),    // 设置写FIFO深度
    .RDFIFO_DEPTH(512),       // 设置读FIFO深度
    .SENDTHRESHOUD(1),    // 设置发送阈值
    .WUSEDW(17),              // 设置写使用位宽
    .RUSEDW(9)                // 设置读使用位宽
) my_fifo_usb_sync (
    // 系统接口
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    // FIFO接口
    .VALID(VALID),
    .FIFO_DIN(FIFO_DIN),
    .WR_USEDW(WR_USEDW),
    .FULL(FULL),
    .LOAD(LOAD),
    .FIFO_VALID(FIFO_VALID),
    .FIFO_DOUT(FIFO_DOUT),
    .EMPTY(EMPTY),
    .RD_USEDW(RD_USEDW),
    // USB模块接口
    .ft232_clk(ft232_clk),
    .ft232_rst_n(ft232_rst_n),
    .D(D),
    .RXF_N(1'b1),
    .TXE_N(1'b0),
    .RD_N(RD_N),
    .WR_N(WR_N),
    .SIWU_N(SIWU_N),
    .OE_N(OE_N)
);
//
initial begin
    $dumpfile("Sync_tb.vcd");
    $dumpvars(0,Sync_tb);
end
endmodule