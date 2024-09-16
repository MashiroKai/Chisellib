module encoder_8b10b (
    clk,
    rst,
    kin_ena,		// Data in is a special code, not all are legal.	
    ein_ena,		// Data (or code) input enable
    ein_dat,		// 8b data in
    ein_rd,			// running disparity input
    eout_val,		// data out is valid
    eout_dat,		// data out
    eout_rdcomb,	// running disparity output (comb)
    eout_rdreg		// running disparity output (reg)
);

input       clk;
input       rst;
input       kin_ena;
input       ein_ena;
input [7:0] ein_dat;
input       ein_rd;
output      eout_val;
output[9:0] eout_dat;
output      eout_rdcomb;
output      eout_rdreg;

wire        ein_rd;
wire        ein_ena;
wire  [7:0] ein_dat;
reg         eout_val;
reg   [9:0] eout_dat;

wire A = ein_dat[0];
wire B = ein_dat[1];
wire C = ein_dat[2];
wire D = ein_dat[3];
wire E = ein_dat[4];
wire F = ein_dat[5];
wire G = ein_dat[6];
wire H = ein_dat[7];
wire K = kin_ena;

reg  rd1_part /* synthesis keep */;
reg rd1;

reg  eout_rdcomb;
reg  eout_rdreg;
reg SorK;
reg  a,b,c,d,e,f,g,h,i,j;


	//classification
	wire L04 = (!A & !B & !C & !D);
	wire L13 = (!A & !B & !C & D) | (!A & !B & C & !D) | (!A & B & !C & !D) | (A & !B & !C & !D);
	wire L22 = (!A & !B & C & D) | (!A & B & C & !D) | (A & B & !C & !D) | (A & !B & C & !D) | (A & !B & !C & D)  | (!A & B & !C & D);
	wire L31 = (A & B & C & !D) | (A & B & !C & D) | (A & !B & C & D) | (!A & B & C & D);
	wire L40 = (A & B & C & D);

	wire disp0 = (!L22 & !L31 & !E);	
	wire disp1 = (L31 & !D & !E);		
	wire disp2 = (L13 &  D &  E);
	wire disp3 = (!L22 & !L13 &  E);
	wire invert_ai = !(ein_rd ? (disp3 | disp1 | K) : (disp0 | disp2));
	
	always @(*)
	begin
		a = !A ^ invert_ai;
		b = ((L04) ? 0 : (L40) ? 1 :!B) ^ invert_ai;
		c = ((L04) ? 0 : (L13 & D & E) ? 0 : !C)  ^ invert_ai;
		d = ((L40) ? 1 : !D) ^ invert_ai;
		e = ((L13 & !E) ? 0 : (L13 & D & E) ? 1 : !E) ^ invert_ai;
		i = ((L22 & !E) ? 0 : (L04 & E) ? 0 : (L13 & !D & E) ? 0 :
			(L40 & E) ? 0 : (L22 & K) ? 0 : 1) ^ invert_ai;
		
		rd1_part = (disp0 | disp2 | disp3);
		rd1 = (rd1_part | K) ^ ein_rd;
	end

	always @(*)
	begin
		SorK = ( e &  i & !rd1) | (!e & !i & rd1) | K;
	end
		
	wire disp4 = (!F & !G);
	wire disp5 = (F & G);
	wire disp6 = ((F ^ G) & K);
	wire invert_fj = !(rd1 ? disp5 : (disp4 | disp6));

	always @(*)
	begin
		f = ((F & G & H & (SorK)) ? 1 : !F) ^ invert_fj;
		g = ((!F & !G & !H) ? 0 : !G) ^ invert_fj; 
		h = (!H) ^ invert_fj;
		j = (((F ^ G) & !H) ? 0 : (F & G & H & (SorK)) ? 0 : 1) ^ invert_fj;
		eout_rdcomb = (disp4 | (F & G & H)) ^ rd1;
	end

always @(posedge clk or negedge rst)
begin
    if (!rst)
    begin
        eout_rdreg <= 0;
        eout_val <= 0;
        eout_dat <= 0;
    end
    else
    begin
        eout_val <= 0;
       if (ein_ena | kin_ena)
        begin
            eout_rdreg <= eout_rdcomb;
            eout_val <=  ein_ena | kin_ena;
            eout_dat <= {j,h,g,f,i,e,d,c,b,a};
        end
    end
end

endmodule