`timescale 1ns/100ps
module async_fifo_tb;
    reg wr_clk = 0,rd_clk = 0;
    always #10 wr_clk = ~ wr_clk;//50mhz clock
    always #15 rd_clk = ~ rd_clk;//33.33mhz clock
    reg wr_rst_n = 0,rd_rst_n=0;
    reg wr_en = 0,rd_en = 0;
    reg [WIDTH-1:0]data_in = 'd0;
    //write data into fifo
    initial begin
    wr_clk = 0;
    wr_rst_n = 0;
    #10 
    wr_clk = 1;
    wr_rst_n = 1;
        // Write data into FIFO
        #20 wr_en = 1; data_in = 8'hAA;
        #20 wr_en = 0;
        #20 wr_en = 1; data_in = 8'h11;
        #20 wr_en = 0;
        #20 wr_en = 1; data_in = 8'h22;
        #20 wr_en = 0;
        #20 wr_en = 1; data_in = 8'h33;
        #20 wr_en = 0;


    end

    //read data from fifo
    initial begin
        rd_clk = 0;
        rd_rst_n = 0;
        #15 
        rd_clk = 1;
        rd_rst_n = 1;
        // Read data from FIFO
        #300 rd_en = 1;
        #30 rd_en = 0;
        #30 rd_en = 1;
        #30 rd_en = 0;
        #30 rd_en = 1;
        #30 rd_en = 0;
        #30 rd_en = 1;
        #30 rd_en = 0;
        $finish();
    end
localparam WIDTH = 8;
localparam PTRWIDTH = 2;
wire [PTRWIDTH:0]wr_usedw,rd_usedw;
wire [WIDTH-1:0]data_out;
wire empty,full,valid;

async_fifo#(
    .WIDTH(WIDTH),        // 设置数据位宽为8位
    .PTRWIDTH(PTRWIDTH)      // 设置深度为4
) my_fifo (
    // 写入数据接口
    .wr_clk(wr_clk),   // 连接写时钟
    .wr_rst_n(wr_rst_n), // 连接写复位信号
    .wr_en(wr_en),     // 连接写使能信号
    .data_in(data_in), // 连接写入的数据
    .wr_usedw(wr_usedw), // 连接写指针的位宽

    // 读取数据接口
    .rd_clk(rd_clk),   // 连接读时钟
    .rd_rst_n(rd_rst_n), // 连接读复位信号
    .rd_en(rd_en),     // 连接读使能信号
    .data_out(data_out), // 连接输出的数据
    .rd_usedw(rd_usedw), // 连接读指针的位宽

    // 状态标志输出
    .empty(empty),     // 连接空标志
    .full(full),       // 连接满标志
    .valid(valid)      // 连接valid标志
);

initial begin
  $dumpfile("async_fifo_tb.vcd");
  $dumpvars(0,async_fifo_tb);
end

endmodule