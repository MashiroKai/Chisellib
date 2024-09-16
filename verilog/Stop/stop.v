module test(

   input clk,
	input rst_n,
	input din,

	output reg [DATA_WIDTH-1:0] dout1,//左移并行输出
	output reg [DATA_WIDTH-1:0] dout2//右移并行输出
);
	parameter DATA_WIDTH=2048;
   reg din_r;

//输入寄存一拍
    always @(posedge clk or negedge rst_n) 
    	if (!rst_n) 
    		 din_r <= 1'b0;
    	else 
    	    din_r <= din;
    
//左移并行输出
    always @(posedge clk or negedge rst_n) begin
    	if (!rst_n) 
    		dout1 <= 0;
    	else 
    	    dout1 <= {dout1[DATA_WIDTH-2:0],din_r};
    end
//右移并行输出
    always @(posedge clk or negedge rst_n) begin
    	if (!rst_n) 
    		dout2 <= 0;
    	else 
    	    dout2 <= {din_r,dout2[DATA_WIDTH-1:1]};
    end


endmodule

