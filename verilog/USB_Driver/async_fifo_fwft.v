//异步FIFO
/*
// 例化异步FIFO模块
async_fifo #(
    .WIDTH(8),        // 设置数据位宽为8位
    .DEPTH(8192)      // 设置深度为8192
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
*/
module	async_fifo_fwft
#(
	parameter   WIDTH = 'd8  ,								//FIFO位宽
    parameter   DEPTH = 'd8192 								//FIFO深度
)		
(	
//写数据		
	input							wr_clk		,				//写时钟
	input							wr_rst_n	,       		//低电平有效的写复位信号
	input							wr_en		,       		//写使能信号，高电平有效	
	input	[WIDTH-1:0]		data_in		,       		//写入的数据
	output	[logb2(DEPTH) : 0]	wr_usedw	,
//读数据			
	input							rd_clk		,				//读时钟
	input							rd_rst_n	,       		//低电平有效的读复位信号	
	input							rd_en		,               //读使能                      
	output	[WIDTH-1:0]	data_out	,				//输出的数据
	output	[logb2(DEPTH) : 0]	rd_usedw	,
//状态标志					
	output							empty		,				//空标志，高电平表示当前FIFO已被写满
	output							full		, 				//满标志，高电平表示当前FIFO已被读空
	output							valid					
);                                                              
assign data_out = fifo_buffer[rd_ptr_true];
//reg define
//用二维数组实现RAM
reg [WIDTH - 1 : 0]			fifo_buffer[DEPTH - 1 : 0];
	
reg [logb2(DEPTH) : 0]		wr_ptr;						//写地址指针，二进制
reg [logb2(DEPTH) : 0]		rd_ptr;						//读地址指针，二进制
reg	[logb2(DEPTH) : 0]		rd_ptr_g_d1;				//读指针格雷码在写时钟域下同步1拍
reg	[logb2(DEPTH) : 0]		rd_ptr_g_d2;				//读指针格雷码在写时钟域下同步2拍
reg	[logb2(DEPTH) : 0]		wr_ptr_g_d1;				//写指针格雷码在读时钟域下同步1拍
reg	[logb2(DEPTH) : 0]		wr_ptr_g_d2;				//写指针格雷码在读时钟域下同步2拍
reg [logb2(DEPTH) : 0]		wr_ptr_r; 
reg								wr_en_r;
	
//wire define
wire [logb2(DEPTH) : 0]		wr_ptr_g;					//写地址指针，格雷码
wire [logb2(DEPTH) : 0]		rd_ptr_g;					//读地址指针，格雷码
wire [logb2(DEPTH) - 1 : 0]	wr_ptr_true;				//真实写地址指针，作为写ram的地址
wire [logb2(DEPTH) - 1 : 0]	rd_ptr_true;				//真实读地址指针，作为读ram的地址
wire 							neg_wr_en = wr_en_r&(~wr_en);
assign valid = neg_wr_en ;

//地址指针从二进制转换成格雷码
assign 	wr_ptr_g = wr_ptr_r ^ (wr_ptr_r >> 1);					
assign 	rd_ptr_g = rd_ptr ^ (rd_ptr >> 1);
//读写RAM地址赋值
assign	wr_ptr_true = wr_ptr [logb2(DEPTH) - 1 : 0];		//写RAM地址等于写指针的低DEPTH位(去除最高位)
assign	rd_ptr_true = rd_ptr [logb2(DEPTH) - 1 : 0];		//读RAM地址等于读指针的低DEPTH位(去除最高位)
 
 
//写操作,更新写地址
always @ (posedge wr_clk or negedge wr_rst_n) begin
	if (!wr_rst_n)
		wr_ptr <= 0;
	else if (!full && wr_en)begin								//写使能有效且非满
		wr_ptr <= wr_ptr + 1'd1;
		fifo_buffer[wr_ptr_true] <= data_in;
	end	
end

always @ (posedge wr_clk or negedge wr_rst_n) begin
	if (!wr_rst_n)
		wr_en_r <= 0;
	else 
		wr_en_r <= wr_en;
end

always @(posedge wr_clk or negedge wr_rst_n) begin
	if (!wr_rst_n)
		wr_ptr_r <= 0;
	else if (neg_wr_en)begin								//一次传输完毕，寄存一次写指针
		wr_ptr_r <= wr_ptr ;
	end		
end

//将读指针的格雷码同步到写时钟域，来判断是否写满
always @ (posedge wr_clk or negedge wr_rst_n) begin
	if (!wr_rst_n)begin
		rd_ptr_g_d1 <= 0;										//寄存1拍
		rd_ptr_g_d2 <= 0;										//寄存2拍
	end				
	else begin												
		rd_ptr_g_d1 <= rd_ptr_g;								//寄存1拍
		rd_ptr_g_d2 <= rd_ptr_g_d1;								//寄存2拍
	end	
end

//读操作,更新读地址
always @ (posedge rd_clk or negedge rd_rst_n) begin
	if (!rd_rst_n)
		rd_ptr <= 'd0;
	else begin if (rd_en&&!empty)begin								//读使能有效且非空
		rd_ptr <= rd_ptr + 1'd1;
	end
end
end
//将写指针的格雷码同步到读时钟域，来判断是否读空
always @ (posedge rd_clk or negedge rd_rst_n) begin
	if (!rd_rst_n)begin
		wr_ptr_g_d1 <= 0;										//寄存1拍
		wr_ptr_g_d2 <= 0;										//寄存2拍
	end				
	else begin												
		wr_ptr_g_d1 <= wr_ptr_g;								//寄存1拍
		wr_ptr_g_d2 <= wr_ptr_g_d1;								//寄存2拍		
	end	
end
//更新指示信号
//当所有位相等时，读指针追到到了写指针，FIFO被读空
assign	empty = ( wr_ptr_g_d2 == rd_ptr_g ) ? 1'b1 : 1'b0;
//当高位相反且其他位相等时，写指针超过读指针一圈，FIFO被写满
//同步后的读指针格雷码高两位取反，再拼接上余下位
assign	full  = ( wr_ptr_g == { ~(rd_ptr_g_d2[logb2(DEPTH) : logb2(DEPTH) - 1])
				,rd_ptr_g_d2[logb2(DEPTH) - 2 : 0]})? 1'b1 : 1'b0;

wire	[logb2(DEPTH):0] rd_bin_wr_ptr;
wire 	[logb2(DEPTH):0] rd_bin_rd_ptr;
wire	[logb2(DEPTH):0] wr_bin_rd_ptr;
wire 	[logb2(DEPTH):0] wr_bin_wr_ptr;


assign wr_usedw = (wr_bin_wr_ptr[logb2(DEPTH)] >= wr_bin_rd_ptr[logb2(DEPTH)])?(wr_bin_wr_ptr - wr_bin_rd_ptr):({~wr_bin_wr_ptr[logb2(DEPTH)],wr_bin_wr_ptr[logb2(DEPTH)-1:0]} - {~(wr_bin_rd_ptr[logb2(DEPTH)]),wr_bin_rd_ptr[logb2(DEPTH)-1:0]});
assign rd_usedw = (rd_bin_wr_ptr[logb2(DEPTH)] >= rd_bin_rd_ptr[logb2(DEPTH)])?(rd_bin_wr_ptr - rd_bin_rd_ptr):({~rd_bin_wr_ptr[logb2(DEPTH)],rd_bin_wr_ptr[logb2(DEPTH)-1:0]} - {~(rd_bin_rd_ptr[logb2(DEPTH)]),rd_bin_rd_ptr[logb2(DEPTH)-1:0]});
gray2bin #(
    .N(logb2(DEPTH))
)
g2b1(
    .gray(wr_ptr_g_d2)
    ,.bin(rd_bin_wr_ptr)
);
gray2bin #(
    .N(logb2(DEPTH))
)
g2b2(
    .gray(rd_ptr_g)
    ,.bin(rd_bin_rd_ptr)
);
gray2bin #(
    .N(logb2(DEPTH))
)
g2b3(
    .gray(rd_ptr_g_d2)
    ,.bin(wr_bin_rd_ptr)
);
gray2bin #(
    .N(logb2(DEPTH))
)
g2b4(
    .gray(wr_ptr_g)
    ,.bin(wr_bin_wr_ptr)
);

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