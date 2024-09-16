/*
Uart_Rx R1
(
	.clk(clk),
	.rst_n(rst_n),
	.bps_en(),
	.bps_clk(),
	.rs422_rx(),
	.rx_data(),
	.valid(),
	.check(),
	.stop()
);
*/
module Uart_Rx
(
input					clk,			//系统时钟
input					rst_n,		//系统复位，低有效
 
output	reg				bps_en,			//接收时钟使能
input					bps_clk,		//接收时钟输入
 
input					rs422_rx,		//UART接收输入
output	reg		[7:0]	rx_data,		//接收到的数据

output 	reg				valid,			//data valid pulse
output  reg             check,			//check bit error
output  reg 			stop			//stop bit error
);	
 
reg	rs422_rx0,rs422_rx1,rs422_rx2;	
//多级延时锁存去除亚稳态
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		rs422_rx0 <= 1'b0;
		rs422_rx1 <= 1'b0;
		rs422_rx2 <= 1'b0;
	end else begin
		rs422_rx0 <= rs422_rx;
		rs422_rx1 <= rs422_rx0;
		rs422_rx2 <= rs422_rx1;
	end
end
localparam ST01 = 4'b0001;
localparam ST02 = 4'b0010;
localparam ST03 = 4'b0100;
localparam ST04 = 4'b1000;
//检测UART接收输入信号的下降沿
wire	neg_rs422_rx = rs422_rx2 & rs422_rx1 & (~rs422_rx0) & (~rs422_rx);
reg [11:0] rx_data_r;
reg [3:0]num;
reg [1:0]stc;
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rx_data_r <= 12'b0;
		stc		  <= 2'b11;
		num		  <= 4'd0;
		rx_data   <= 8'd0;
	end
	else begin
		if (num == 4'd12) begin
			rx_data <= rx_data_r[8:1];
			stc		<= rx_data_r[11:10];
			num 	<= 4'd0;
		end
		else begin
			if (bps_clk) begin
				num <= num + 1'b1;
				rx_data_r[num] <= rs422_rx;	
			end
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		check <= 1'b0;
	end
	else begin
		if (num == 4'd12) begin
			check  <= ((~(^rx_data_r[8:1])) == rx_data_r[9])? 1'b0:1'b1;
		end
		else begin
			check  <= 1'b0;
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		bps_en <= 1'b0;
	end
	else begin
		if (neg_rs422_rx && (!bps_en)) begin
			bps_en <= 1'b1;
		end
		else begin
			if (num == 4'd12) begin
				bps_en <= 1'b0;
			end
		end
	end
end
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		valid <= 1'b0;
	end
	else begin
		if (num == 4'd12) begin
			valid	<= 1'b1;
		end
		else begin
			valid	<= 1'b0;
		end	
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		stop  <= 1'b0;
	end
	else begin
		if (num==4'd12&&stc != 2'b11) begin
			stop <= 1'b1;
		end
		else begin
			stop <= 1'b0;
		end
	end
end
endmodule