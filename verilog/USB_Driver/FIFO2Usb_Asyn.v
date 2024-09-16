/*
// 例化 FIFO2Usb_Asyn 模块
FIFO2Usb_Asyn #(
    .WIDTH(8),                // 设置数据位宽
    .SENDTHRESHOUD(66048),    // 设置发送阈值
    .WUSEDW(17),              // 设置写使用位宽
    .RUSEDW(9)                // 设置读使用位宽
) my_fifo_usb_asyn (
    // 模块接口
    .clk(clk),
    .rst_n(rst_n),
    // FIFO接口
    .VALID(valid_signal),
    .FIFO_DIN(data_in_signal),
    .WR_USEDW(write_used_width_signal),
    .FULL(full_signal),
    .LOAD(load_signal),
    .FIFO_VALID(fifo_valid_signal),
    .FIFO_DOUT(data_out_signal),
    .RD_USEDW(read_used_width_signal),
    .EMPTY(empty_signal),
    // USB模块接口
    .D(data_bus),
    .RXF_N(rxf_n_signal),
    .TXE_N(txe_n_signal),
    .RD_N(rd_n_signal),
    .WR_N(wr_n_signal),
    .SIWU_N(siwu_n_signal)
);

*/

module FIFO2Usb_Asyn#(
    // DATA WIDTH AND FIFO DEPTH
    parameter   WIDTH = 8,
    parameter   SENDTHRESHOUD = 2064,
    parameter   WUSEDW = 17,
    parameter   RUSEDW = 9
)
(
     input      clk   //maxium 33.333mhz,typical 30mhz
    ,input      rst_n
    //FIFO INTERFACE
    ,input      VALID
    ,input      [WIDTH-1:0]FIFO_DIN
    ,output     [WUSEDW:0]WR_USEDW
    ,output     FULL
    ,input      LOAD
    ,output     FIFO_VALID
    ,output     [WIDTH-1:0]FIFO_DOUT
    ,output     [RUSEDW:0]RD_USEDW
    ,output     EMPTY
    //USB MODULE INTERFACE
    ,inout      [WIDTH-1:0]D
    ,input      RXF_N //indicate if the data is avaliable to read from usb fifo
    ,input      TXE_N //indicate if the data can be wirtten to usb fifo 
    ,output     reg RD_N  //usb fifo rd control 
    ,output     reg WR_N  //usb fifo wr control
    ,output     SIWU_N  //tie to high
    // wr/rd one data at a time
);
wire [WIDTH-1:0]DOUT;
assign D= FLAG?DOUT:8'bzzzzzzzz;
assign SIWU_N = 1'b1;
reg TXE_N_r,RXF_N_r;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        TXE_N_r <= 1'b1;
        RXF_N_r <= 1'b1;
    end
    else begin
        TXE_N_r <= TXE_N;
        RXF_N_r <= RXF_N;
    end
end
fifo #(
    .WIDTH(WIDTH),
    .PTRWIDTH(WUSEDW)
)
wr(
    .clk(clk)
    ,.rst_n(rst_n)
    ,.valid(VALID)
    ,.din(FIFO_DIN)
    ,.load(WR_LOAD)
    ,.dout(DOUT)
    ,.fifo_valid(WR_FIFO_VALID)
    ,.full(FULL)
    ,.empty(WR_EMPTY)
    ,.usedw(WR_USEDW)
);
reg WR_LOAD;
wire WR_EMPTY;
wire WR_FIFO_DOUT;
wire WR_FIFO_VALID;
fifo #(
    .WIDTH(WIDTH),
    .PTRWIDTH(RUSEDW)
)
rd(
    .clk(clk)
    ,.rst_n(rst_n)
    ,.valid(RD_FIFO_VALID)
    ,.din(RD_FIFO_DIN)
    ,.load(LOAD)
    ,.dout(FIFO_DOUT)
    ,.fifo_valid(FIFO_VALID)
    ,.full(RD_FULL)
    ,.empty(EMPTY)
    ,.usedw(RD_USEDW)
);
counter #(
    .RST(SENDTHRESHOUD),
    .START(0)
)
sendcnt(
    .clk(clk)
    ,.rst_n(rst_n)
    ,.asyn(1'b0)
    ,.en(~WR_N)
    ,.pulse(SEND_CMPLE)
);
wire SEND_CMPLE;
wire RD_FULL;
reg RD_FIFO_VALID;
reg RD_FIFO_DIN;
reg [2:0]STATE;
localparam   IDLE = 3'b000;
localparam   RD_STATE = 3'b001;
localparam   WR_STATE = 3'b010;
localparam   RD_FROM_WR_FIFO = 3'b011;
localparam   WR_TO_RD_FIFO = 3'b100;
localparam   RD_WAIT = 3'b101;
localparam   WR_WAIT = 3'b110;
reg FLAG;
reg SEND_ENABLE;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        SEND_ENABLE <= 1'b0;
    end
    else begin
        if (SEND_CMPLE) begin
            SEND_ENABLE <= 1'b0;
        end
        else begin
            if (WR_USEDW >=SENDTHRESHOUD||(OVERTIME&&WR_USEDW>0)) begin
                SEND_ENABLE <= 1'b1;
            end
            else begin
                SEND_ENABLE <= SEND_ENABLE;
            end
        end
    end
end
counter #(
    .RST(12000),//1ms
    .START(0)
)
c1(
    .clk(clk)
    ,.rst_n(rst_n)
    ,.asyn(VALID)
    ,.en(1'b1)
    ,.pulse(OVERTIME)
);
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        STATE <= IDLE;
        FLAG <= 1'b0;
        WR_LOAD <= 1'b0;
        RD_N <= 1'b1;
        WR_N <= 1'b1;
        RD_FIFO_VALID <= 1'b0;
        RD_FIFO_DIN <= 8'd0;
    end
    else begin
        case (STATE)
        IDLE    :begin
                FLAG <= 1'b0;
            if (!RD_FULL&&!RXF_N&&!RXF_N_r) begin // RD_FIFO isn't FULL, and there are data avaliable , then read data from FT232
                STATE <= RD_STATE;
            end
            else begin
            if (!WR_EMPTY&&!TXE_N&&!TXE_N_r&&SEND_ENABLE) begin //WR_FIFO isn't EMPTY,and FT232 is ready to receive data , then write data to FT232
                STATE <= RD_FROM_WR_FIFO;
                WR_LOAD <= 1'b1;
                FLAG <= 1'b1;
            end
            end
        end 
        RD_STATE  :begin
            RD_N <= 1'b0;
            STATE <= WR_TO_RD_FIFO;
        end
        WR_STATE  :begin
            WR_N    <= 1'b0;  
            STATE   <= WR_WAIT;
        end
        RD_FROM_WR_FIFO :begin
            WR_LOAD <= 1'b0;
            if (WR_FIFO_VALID) begin
                STATE  <= WR_STATE;
            end
        end
        WR_TO_RD_FIFO :begin
            RD_N <= 1'b1;
            RD_FIFO_VALID <= 1'b1;
            RD_FIFO_DIN <= D;
            STATE <= RD_WAIT;
        end
        RD_WAIT :begin//wait for RXF_N changing into HIGH
            RD_FIFO_VALID <= 1'b0;
            STATE <= IDLE;
        end
        WR_WAIT :begin
            WR_N <= 1'b1;
            STATE <= IDLE;
        end
        endcase
    end
end
endmodule