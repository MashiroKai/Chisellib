module ft232hq_send(
	input				clock,
	input				rst_n,
    input        [16:0]rdusedw,
	
	//ft接口
	input  wire			rd_n,
	input  wire			txe_n,
	
	output wire			wr_n,
	output wire [7:0]	data_send,
	
	//读fifo接口
	input  wire	[7:0]	fifo_data_out,
	input  wire			fifo_empty_n,
	output wire			fifo_rd_en
	
    );
	
reg txe_n_d0;	
reg fifo_rd_en_d0;
reg fifo_empty_n_d0;
	
//*****************************************************
//**                    main code
//*****************************************************
 //在FT232H写状态，且usb_txe_n为低，且FPGA FIFO 不空时，使能FT232H FIFO写
 assign wr_n = ((txe_n_d0 == 0) && (txe_n == 0 )&& (fifo_empty_n_d0 == 0)&& rd_n&&(rdusedw>=17'd66048) && (fifo_rd_en_d0 == 1))?1'b0 : 1'b1;
 //在FT232H写状态，将FIFO的数据输出赋值给将USB数据总线，其他时候为高阻态
 assign data_send = ((txe_n_d0 == 0) &&(txe_n == 0) && (fifo_empty_n_d0 == 0) && rd_n &&(rdusedw>=17'd66048)&& (fifo_rd_en_d0 == 1))? fifo_data_out: 8'hzz;
 //在FT232H写状态，且usb_txe_n也为低时，且FPGA FIFO 不空时，使能FIFO读
 assign fifo_rd_en =((txe_n_d0 == 0) && (txe_n == 0 )&& (fifo_empty_n == 0)&& rd_n&&(rdusedw>=17'd66048))?1'b1 : 1'b0;
 //FT232H数据接收txe_n打一拍
 always@(posedge clock or negedge rst_n)begin
     if(!rst_n)
         txe_n_d0 <= 1'b1;
     else 
         txe_n_d0 <= txe_n;
 end
 
always@(posedge clock or negedge rst_n)begin
    if(!rst_n) begin
        fifo_rd_en_d0 <= 1'b1;
		fifo_empty_n_d0 <= 1;
	end
     else begin
        fifo_rd_en_d0 <= fifo_rd_en;
		fifo_empty_n_d0 <= fifo_empty_n;
	end
 end
		
endmodule