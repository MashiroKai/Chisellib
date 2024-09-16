///////////////////////////////////////////////////////////////////////////////
// Project:  Aurora 64B/66B
// Company:  Xilinx  
//
//
// (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
////////////////////////////////////////////////////////////////////////////////

// CRC32 generator (adopted form Xilinx Aurora Core)
// 2015 Dirk Hutter
//
// compatible with boost crc_32_type
// polynom:           0x04C11DB7
// initial remainder: 0xFFFFFFFF
// final xor:         0xFFFFFFFF
// reflect input:     true
// reflect output:    true
//
// generated with Vivado 2015.1 / Auroro 64/66 v10.0 
// changed output byte order

`define DLY #1

//***********************************Entity Declaration*******************************
`timescale  1 ns / 10 ps

// CRC32 polynom
//`define POLYNOMIAL 32'h04C11DB7	// 00000100 11000001 00011101 10110111
// CRC32C
`define POLYNOMIAL 32'h1EDC6F41
module crc_32 #
  (
   // Initial value
   parameter CRC_INIT = 32'hFFFFFFFF
   )
   (
    CRCOUT,
    CRCCLK,
    CRCDATAVALID,
    CRCDATAWIDTH,
    CRCIN,
    CRCRESET
    );
   
   output [31:0] CRCOUT;
   
   input         CRCCLK;
   input         CRCDATAVALID;
   input [2:0]   CRCDATAWIDTH;
   input [63:0]  CRCIN;
   input         CRCRESET;
   
   reg [2:0]     data_width;
   reg           data_valid;
   
   reg [31:0]    crcreg;
   reg [64:0]    msg_4byte;
   (* keep = "TRUE" *) reg [32:0] 	 msg;
   reg [32:0]    i,j;
   reg [63:0]    crc_data_i;
   wire          crcreset_int;

   wire [31:0]   crcout_ref;
   wire [31:0]   crcout_ref_xor;
   

   assign 	 crcreset_int = CRCRESET;

   // reflect input - reverse bit order in data bytes
   always @ (posedge CRCCLK)
     begin
	crc_data_i[63:56] <= `DLY {CRCIN[56],CRCIN[57],CRCIN[58],CRCIN[59],CRCIN[60],CRCIN[61],CRCIN[62],CRCIN[63]};  
	crc_data_i[55:48] <= `DLY {CRCIN[48],CRCIN[49],CRCIN[50],CRCIN[51],CRCIN[52],CRCIN[53],CRCIN[54],CRCIN[55]};
	crc_data_i[47:40] <= `DLY {CRCIN[40],CRCIN[41],CRCIN[42],CRCIN[43],CRCIN[44],CRCIN[45],CRCIN[46],CRCIN[47]};
	crc_data_i[39:32] <= `DLY {CRCIN[32],CRCIN[33],CRCIN[34],CRCIN[35],CRCIN[36],CRCIN[37],CRCIN[38],CRCIN[39]};
	crc_data_i[31:24] <= `DLY {CRCIN[24],CRCIN[25],CRCIN[26],CRCIN[27],CRCIN[28],CRCIN[29],CRCIN[30],CRCIN[31]};
	crc_data_i[23:16] <= `DLY {CRCIN[16],CRCIN[17],CRCIN[18],CRCIN[19],CRCIN[20],CRCIN[21],CRCIN[22],CRCIN[23]};
	crc_data_i[15:8]  <= `DLY {CRCIN[8],CRCIN[9],CRCIN[10],CRCIN[11],CRCIN[12],CRCIN[13],CRCIN[14],CRCIN[15]};
	crc_data_i[7:0]	  <= `DLY {CRCIN[0],CRCIN[1],CRCIN[2],CRCIN[3],CRCIN[4],CRCIN[5],CRCIN[6],CRCIN[7]};
     end
   
   // non reflected input
   //   always @ (posedge CRCCLK)
   //   begin
   //        crc_data_i[63:0] <= `DLY CRCIN;  
   //   end
   
   always @ (posedge CRCCLK)
     begin
 	data_valid <= `DLY CRCDATAVALID;
        data_width <= `DLY CRCDATAWIDTH;
     end


   always @ (msg_4byte or crcreg or crc_data_i or data_width)
     begin
        case(data_width)
          3'b100 : msg_4byte = {crcreg,32'h0} ^ {crc_data_i[63:24],24'h0};
          3'b101 : msg_4byte = {crcreg,32'h0} ^ {crc_data_i[63:16],16'h0};
          3'b110 : msg_4byte = {crcreg,32'h0} ^ {crc_data_i[63:8] ,8'h0 };
          3'b111 : msg_4byte = {crcreg,32'h0} ^ crc_data_i;
	  default: msg_4byte = 32'h0 ^ CRC_INIT;
        endcase 

	for (j = 0; j < 32; j = j + 1) begin
	   msg_4byte = msg_4byte << 1;
	   if (msg_4byte[64] == 1'b1) begin
 	      msg_4byte[63:32] = msg_4byte[63:32] ^ `POLYNOMIAL;
	   end
	end
     end

   //CRC Generator Logic
   always @(crcreg or data_width or crc_data_i or msg or msg_4byte)
     begin
        
        case (data_width[1:0])
          2'b00: begin //CRC-8
             if (data_width[2] == 1'b0) begin 
	        msg = crcreg ^ {crc_data_i[63:56],24'h0};
             end
             else begin
                msg = msg_4byte[64:32];
             end      
             for (i = 0; i < 8; i = i + 1) begin
	        msg = msg << 1;
	        if (msg[32] == 1'b1) begin
 	  	   msg[31:0] = msg[31:0] ^ `POLYNOMIAL;
	        end
	     end
	  end 
	  
          2'b01: begin //CRC-16
             if (data_width[2] == 1'b0) begin 
	        msg = crcreg ^ {crc_data_i[63:48],16'h0};
             end
             else begin
                msg = msg_4byte[64:32];
             end       
	     for (i = 0; i < 16; i = i + 1) begin
	        msg = msg << 1;
	        if (msg[32] == 1'b1) begin
 	  	   msg[31:0] = msg[31:0] ^ `POLYNOMIAL;
	        end
	     end
	  end
	  
          2'b10: begin //CRC-24]
             if (data_width[2] == 1'b0) begin 
	        msg = crcreg ^ {crc_data_i[63:40],8'h0};
             end
             else begin
                msg = msg_4byte[64:32];
             end    
	     for (i = 0; i < 24; i = i + 1) begin
	        msg = msg << 1;
	        if (msg[32] == 1'b1) begin
 	  	   msg[31:0] = msg[31:0] ^ `POLYNOMIAL;
	        end
	     end
          end 
	  
          default : begin  //CRC-32
             if (data_width[2] == 1'b0) begin 
	        msg = crcreg ^ crc_data_i[63:32];
             end
             else begin
                msg = msg_4byte[64:32];
             end       
	     for (i = 0; i < 32; i = i + 1) begin
	        msg = msg << 1;
	        if (msg[32] == 1'b1) begin
 	  	   msg[31:0] = msg[31:0] ^ `POLYNOMIAL;
	        end
	     end
	  end
        endcase
     end


   // 32-bit CRC internal register
   always @ (posedge CRCCLK)
     begin
	if (crcreset_int)
	  crcreg <= `DLY CRC_INIT;
        else if (data_valid) begin
	   crcreg <= `DLY msg[31:0];
        end
     end


   // // refelect output xor with 0x00000000 - reverse bit order in full crc
   // assign crcout_ref = {crcreg[0],crcreg[1],crcreg[2],crcreg[3],
   //      		crcreg[4],crcreg[5],crcreg[6],crcreg[7],
   //      		crcreg[8],crcreg[9],crcreg[10],crcreg[11],
   //      		crcreg[12],crcreg[13],crcreg[14],crcreg[15],
   //      		crcreg[16],crcreg[17],crcreg[18],crcreg[19],
   //      		crcreg[20],crcreg[21],crcreg[22],crcreg[23],
   //      		crcreg[24],crcreg[25],crcreg[26],crcreg[27],
   //      		crcreg[28],crcreg[29],crcreg[30],crcreg[31]};

   // refelect output and xor 0xFFFFFFFF
   assign crcout_ref_xor = {!crcreg[0],!crcreg[1],!crcreg[2],!crcreg[3],
			    !crcreg[4],!crcreg[5],!crcreg[6],!crcreg[7],
			    !crcreg[8],!crcreg[9],!crcreg[10],!crcreg[11],
			    !crcreg[12],!crcreg[13],!crcreg[14],!crcreg[15],
		            !crcreg[16],!crcreg[17],!crcreg[18],!crcreg[19],
		            !crcreg[20],!crcreg[21],!crcreg[22],!crcreg[23],
		            !crcreg[24],!crcreg[25],!crcreg[26],!crcreg[27],
		            !crcreg[28],!crcreg[29],!crcreg[30],!crcreg[31]};
   
   assign CRCOUT = crcout_ref_xor; 
   
endmodule   
