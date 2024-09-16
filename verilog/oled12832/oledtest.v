`timescale 100ns / 1ns
module oled_tb;

reg clk;
reg rst_n;
reg [3:0]sw;
wire oled_csn;
wire oled_rst;
wire oled_dcn;
wire oled_clk;
wire oled_dat;

OLED12832 oled(clk,rst_n,sw,oled_csn,oled_rst,oled_dcn,oled_clk,oled_dat);

/*iverilog */
initial
begin            
    $dumpfile("oled.vcd");        //生成的vcd文件名称
    $dumpvars(0, oled_tb);     //tb模块名称
end
/*iverilog */

initial
begin
  clk=0;
  rst_n=1;
  sw=4'b0000;
  clk=1;
  #20
  sw=4'b0001;
  #30
  rst_n=1;
end
always
#1 clk=~clk;

initial
  #2000 $finish;

endmodule