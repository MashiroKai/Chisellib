// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Module: Debounce
// 
// Author: Step
// 
// Description: Debounce for button with FPGA/CPLD
// 
// Web: www.ecbcamp.com
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Version: |Mod. Date:   |Changes Made:
// V1.0     |2015/11/11   |Initial ver
// --------------------------------------------------------------------
/*
Debounce d1(
        .clk(clk),
        .rst_n(rst_n),
        .key_n(),
        .key_pulse()
);
*/
module Debounce(clk,rst_n,key_n,key_pulse,key_state); 
 
input   		clk;			//system clock
input   		rst_n;			//system reset
input   		key_n;			//button input
output  		key_pulse;		//Debounce pulse output
output	reg		key_state;		//Debounce state output
 
reg  key_rst;   
//Register key_rst, lock key_n to next clk
always @(posedge clk  or  negedge rst_n)
    if (!rst_n) key_rst <= 1'b1;
    else  key_rst <=key_n;
 
//Detect the edge of key_n
wire  key_an = (key_rst==key_n)? 0:1;
 
reg[18:0]  cnt;
//Count the number of clk when a edge of key_n is occured
always @ (posedge clk  or negedge rst_n)
    if (!rst_n) cnt <= 19'd0;
    else if(key_an) cnt <=19'd0;
    else cnt <= cnt + 1'b1;
 
reg  low_sw;
//Lock the status to register low_sw when cnt count to 19'd500000
always @(posedge clk  or  negedge rst_n)
    if (!rst_n)  low_sw <= 1'b1;
	else if (cnt == 19'd500000)
        low_sw <= key_n;
 
reg   low_sw_r;
//Register low_sw_r, lock low_sw to next clk
always @ ( posedge clk  or  negedge rst_n )
    if (!rst_n) low_sw_r <= 1'b1;
    else  low_sw_r <= low_sw;
 
wire  key_pulse;
//Detect the negedge of low_sw, generate pulse
assign key_pulse= low_sw_r & ( ~low_sw);
 
//Detect the negedge of low_sw, generate state
always @(posedge clk or negedge rst_n)
	if (!rst_n) key_state <= 1'b1;
    else if(key_pulse) key_state <= ~key_state;
	else key_state <= key_state;
 
endmodule