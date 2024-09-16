`timescale 1ns/1ps
module UART_TB;
reg clk;
always #40 clk = ~clk; //12mhz clk;
reg rst_n; 
reg [7:0]tx_data;
reg valid;
//functional example
initial begin
	clk = 1'b0;
	rst_n = 1'b1;
	#10 rst_n = 1'b0;
	#10 rst_n = 1'b1;
	TX(8'hAA);
	#1000000
	TX(8'h55);
	#1000000
	TX(8'hEB);
	#1000000
	#10
	$finish(); 
end
Baud_tx#(
	.BPS_PARA(104)
)
b1(
	.clk_in(clk),
	.rst_n_in(rst_n),
	.bps_en(bps_en_tx),
	.bps_clk(bps_clk_tx)
);
Uart_Tx u1(
	.clk_in(clk),
	.rst_n_in(rst_n),
	.bps_en(bps_en_tx),
	.bps_clk(bps_clk_tx),
	.valid(valid),
	.tx_data(tx_data),
	.rs422_tx(rs422_rx),
	.ready(ready)
);
wire ready,rs422_tx;

Baud_rx#(
	.BPS_PARA(104)
)
b2(
	.clk_in(clk),
	.rst_n_in(rst_n),
	.bps_en(bps_en_rx),
	.bps_clk(bps_clk_rx)
);

Uart_Rx R1
(
	.clk(clk),
	.rst_n(rst_n),
	.bps_en(bps_en_rx),
	.bps_clk(bps_clk_rx),
	.rs422_rx(rs422_rx),
	.rx_data(rx_data),
	.valid(rx_valid),
	.check(check),
	.stop(stop)
);
wire [7:0]rx_data;
wire rx_valid,check,stop;

task TX(
	input [7:0]din
);begin
	@(posedge	clk)begin
		valid <= 1'b1;
		tx_data <= din;
	end
	@(posedge	clk)begin
		valid <= 1'b0;
		tx_data <= din;
	end		
end
endtask

initial begin
	$dumpfile("UART_TB.vcd");
	$dumpvars(0,UART_TB);
end
endmodule
