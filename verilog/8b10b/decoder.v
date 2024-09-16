// Copyright 2007 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

// baeckler - 04-10-2006
// an 8b10b decoder, based on files from Martin R and IBM paper
/*
decoder_8b10b d1(
    .clk(clk)
    ,.rst(~rst_n)
    ,.din_ena()
    ,.din_dat()
    ,.dout_val()
    ,.dout_dat()
    ,.dout_k()
);
*/
module decoder_8b10b (
    clk,
    rst_n,			
    din_ena,			// 10b data ready
    din_dat,			// 10b data input
    dout_val,			// data out valid		
    dout_dat,			// data out
    dout_k				// special code
);



input       clk;
input       rst_n;
input       din_ena;
input [9:0] din_dat;

output      dout_val;
output[7:0] dout_dat;
output      dout_k;

//reg [9:0] din_dat;

reg         dout_val;
reg   [7:0] dout_dat;
reg         dout_k;


wire a = din_dat[0];
wire b = din_dat[1];
wire c = din_dat[2];
wire d = din_dat[3];
wire e = din_dat[4];
wire i = din_dat[5];
wire f = din_dat[6];
wire g = din_dat[7];
wire h = din_dat[8];
wire j = din_dat[9];


//classification
wire P04 = (!a & !b & !c & !d);
wire P13 = (!a & !b & !c & d) | (!a & !b & c & !d) | (!a & b & !c & !d) | (a & !b & !c & !d);
wire P22 = (!a & !b & c & d) | (!a & b & c & !d) | (a & b & !c & !d) | (a & !b & c & !d) | (a & !b & !c & d)  | (!a & b & !c & d);
wire P31 = (a & b & c & !d) | (a & b & !c & d) | (a & !b & c & d) | (!a & b & c & d);
wire P40 = (a & b & c & d);


////////////////////////////////////////////////
// data outputs
////////////////////////////////////////////////

wire A = (P22 & !b & !c & !(e^i)) ? !a :
         (P31 & i) ? !a :
         (P13 & d & e & i) ? !a :
         (P22 & !a & !c & !(e^i)) ? !a :
         (P13 & !e) ? !a :
         (a & b & e & i) ? !a :
         (!c & !d & !e & !i) ? !a :
         a;
wire B = (P22 & b & c & !(e^i)) ? !b :
         (P31 & i) ? !b :
         (P13 & d & e & i) ? !b :
         (P22 & a & c & !(e^i)) ? !b :
         (P13 & !e) ? !b :
         (a & b & e & i) ? !b :
         (!c & !d & !e & !i) ? !b :
         b;
wire C = (P22 & b & c & !(e^i)) ? !c :
         (P31 & i) ? !c :
         (P13 & d & e & i) ? !c :
         (P22 & !a & !c & !(e^i)) ? !c :
         (P13 & !e) ? !c :
         (!a & !b & !e & !i) ? !c :
         (!c & !d & !e & !i) ? !c :
         c;
wire D = (P22 & !b & !c & !(e^i)) ? !d :
         (P31 & i) ? !d :
         (P13 & d & e & i) ? !d :
         (P22 & a & c & !(e^i)) ? !d :
         (P13 & !e) ? !d :
         (a & b & e & i) ? !d :
         (!c & !d & !e & !i) ? !d :
         d;
wire E = (P22 & !b & !c & !(e^i)) ? !e :
         (P13 & !i) ? !e :
         (P13 & d & e & i) ? !e :
         (P22 & !a & !c & !(e^i)) ? !e :
         (P13 & !e) ? !e :
         (!a & !b & !e & !i) ? !e :
         (!c & !d & !e & !i) ? !e :
         e;


wire F = (f & h & j) ? !f :
         (!c & !d & !e & !i & (h^j)) ? !f :
         (!f & !g & h & j) ? !f :
         (f & g & j) ? !f :
         (!f & !g & !h) ? !f :
         (g & h & j) ? !f :
         f;
wire G = (!f & !h & !j) ? !g :
         (!c & !d & !e & !i & (h^j)) ? !g :
         (!f & !g & h & j) ? !g :
         (f & g & j) ? !g :
         (!f & !g & !h) ? !g :
         (!g & !h & !j) ? !g :
         g;
wire H = (f & h & j) ? !h :
         (!c & !d & !e & !i & (h^j)) ? !h :
         (!f & !g & h & j) ? !h :
         (f & g & j) ? !h :
         (!f & !g & !h) ? !h :
         (!g & !h & !j) ? !h :
         h;


wire K = (c & d & e & i) |
         (!c & !d & !e & !i) |
         (P13 & !e & i & g & h & j) |
         (P31 & e & !i & !g & !h & !j);




////////////////////////////////////////////////
// output registers
////////////////////////////////////////////////
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        dout_k <= 0;
        dout_val <= 0;
        dout_dat <= 0;

    end
    else
    begin
        dout_val <= 0;
        if (din_ena)
        begin
            dout_k <= K;
            dout_val <= din_ena;
            dout_dat <= {H,G,F,E,D,C,B,A};
        end
    end
end


endmodule
