//module name:			encode module ver 2008.4.25
//module function:		8B/10B encoder
//module author:		W.D.L.
//module notes:			
//module version history:  
					

//Thanks to Chuck Benz��this module is mostly copied from his original module
`timescale 1ns/100ps

module encode_slave(
	clk,
	rst_n,
	kin,
	datain,
	dataout,
	valid
	);

input clk,rst_n,kin;
input [7:0] datain;
output valid;
output [9:0] dataout;

reg valid;
reg [9:0] dataout;

reg ai,bi,ci,di,ei,fi,gi,hi,ki;
reg fi_reg,gi_reg,hi_reg,kin_reg;


always @ (posedge clk or negedge rst_n)begin
	if (!rst_n) begin
		ai <= 1'b0;
		bi <= 1'b0;
		ci <= 1'b0;
		di <= 1'b0;
		ei <= 1'b0;
		fi <= 1'b0;
		gi <= 1'b0;
		hi <= 1'b0;
		ki <= 1'b1;
	end
	else begin
		ai <= datain[0];
		bi <= datain[1];
		ci <= datain[2];
		di <= datain[3];
		ei <= datain[4];
		fi <= datain[5];
		gi <= datain[6];
		hi <= datain[7];
		ki <= kin;
	end
end
//判断前面四位1和0的数量
wire l22 = (ai & bi & !ci & !di) |
    (ci & di & !ai & !bi) |
    ( (ai^bi) & (ci^di)) ;
wire l40 = ai & bi & ci & di;
wire l04 = !ai & !bi & !ci & !di;
wire l13 = ( (ai^bi) & !ci & !di) |
    ( (ci^di) & !ai & !bi);
wire l31 = ( (ai^bi) & ci & di) |
    ( (ci^di) & ai & bi);

// The 5B/6B encoding
wire ao = ai ;
wire bo = (bi & !l40) | l04 ;
wire co = l04 | ci | (ei & di & !ci & !bi & !ai) ;
wire d_o = di & (!(ai & bi & ci)) ;
//wire eo = (ei | l13) & ! (ei & di & !ci & !bi & !ai) ;
//wire eo = (!(ei & di & !ci & !bi & !ai) & ei) | (l13 & !ei) ;
//(EI and not (L13 and DI and EI))  or (L13 and not EI) ; 
wire eo = (ei & !(l13 & di & ei)) | (l13 & !ei);
//NIO <= (L22 and not EI)
//		or (L04 and EI)
//		or (L13 and not DI and EI)
//		or (L40 and EI) 
//		or (L22 and KI) ;
		

wire io = (l22 & !ei) | (l04 & ei) | (l13 & !di & ei) | (l40 & ei ) | (l22 & ki);
//wire io = (l22 & !ei) |
//   (ei & !di & !ci & !(ai&bi)) |  // D16, D17, D18
//   (ei & l40) |
//   (kin & ei & di & ci & !bi & !ai) | // K.28
//   (ei & !di & ci & !bi & !ai) ;

always @( negedge clk or negedge rst_n)begin
	if(!rst_n) begin
		fi_reg <= 0;
		gi_reg <= 0;
		hi_reg <= 0;
		kin_reg <= 0;
	end
	else begin
		fi_reg <= fi;
		gi_reg <= gi;
		hi_reg <= hi;
	//	kin_reg <= kin;
	//////////////////////////////////////////////////////////////
		kin_reg <= ki;
	end
end

reg LPDL4;
reg LPDL6;
wire COMPLS4 ;
wire COMPLS6 ;

	
wire PD1S6 = (!l22 & !l31 & !ei) | (l13 & di & ei) ;
	
wire ND1S6 = (l31 & !di & !ei) | (ei & !l22 & !l13) | kin_reg ;
	
wire PD0S6 = (!l22 & !l13 & ei) | kin_reg ;
	
wire ND0S6 = (!l22 & !l31 & !ei) | (l13 & di & ei) ;
	
//wire fneg = f^g
wire ND1S4 = (fi_reg & gi_reg);
	
wire ND0S4 = (!fi_reg & !gi_reg);
	
wire PD1S4 = (!fi_reg & !gi_reg) | ((fi_reg^gi_reg) & kin_reg) ;
	
wire PD0S4 = (fi_reg & gi_reg & hi_reg) ;

			
wire PDL6 = (PD0S6 & !COMPLS6) | (COMPLS6 & ND0S6) | (!ND0S6 & !PD0S6 & LPDL4);
			
wire NDL6 = !PDL6 ;
			
wire PDL4 = (LPDL6 & !PD0S4 & !ND0S4) | (ND0S4 & COMPLS4) | (!COMPLS4 & PD0S4) ;

assign COMPLS4 = (PD1S4 & !LPDL6)^(ND1S4 & LPDL6) ;
assign COMPLS6 = (ND1S6 & LPDL4)^(PD1S6 & !LPDL4) ;


reg s;
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		s <= 1'b0;
	end
	else begin
		s <=  (PDL6 & l31 & di & !ei)|(NDL6 & l13 & ei & !di) ;
	end
end


always @ (posedge clk or negedge rst_n)begin
	if( !rst_n) begin
		LPDL6 <= 1'b0;
	end	
	else begin
		LPDL6 <= PDL6 ;
	end
end

always @ (negedge clk or negedge rst_n)begin
	if( !rst_n) begin
		LPDL4 <= 1'b0;
	end	
	else begin
		LPDL4 <= PDL4 ;
	end
end


//wire illegalk = kin & 
//  (ai | bi| !ci | !di| !ei) & // not K28.0->7
//  (!fi| !gi | !hi | !ei | !l31) ; // not K23/27/29/30.7

//wire legaldata = (!kin) | (!(kin & (ai | bi| !ci | !di| !ei) & (!fi| !gi | !hi | !ei | !l31)) );
//wire legaldata = (!kin) | (kin & ( !ai & !bi & ci & di & ei ) | (fi & gi & hi & ei & l31));
wire legaldata = (!ki) | (ki & ( !ai & !bi & ci & di & ei ) | (fi & gi & hi & ei & l31));
	
//wire NAO = ai;
//wire NBO = l04 | (bi & !l40) ;
//wire NCO = ci | l04 | (l13 & di & ei) ;
//wire NDO = (di & !l40) ;
//wire NEO = (ei & !(l13 & di & ei)) | (l13 & !ei) ; 
//wire NIO = (l22 & !ei) | (l04 & ei) | (l13 & !di & ei)
//			| (l40 & ei) | (l22 & kin) ;//������kin_reg

wire SINT = (s & fi_reg & gi_reg & hi_reg) | (kin_reg & fi_reg & gi_reg & hi_reg) ;
wire NFO = (fi_reg & !SINT) ;
wire NGO = gi_reg | (!fi_reg & !gi_reg & !hi_reg) ;
wire NHO = hi_reg ;
wire NJO = SINT | ((fi_reg^gi_reg) & !hi_reg) ;



reg [5:0] dataout_reg;	
always @ (posedge clk or negedge rst_n)begin	
	if(!rst_n)begin		
		dataout_reg  <= 6'b000000;
	end
	else begin
		dataout_reg[0] <= COMPLS6 ^ ao ;
		dataout_reg[1] <= COMPLS6 ^ bo ;
		dataout_reg[2] <= COMPLS6 ^ co ;
		dataout_reg[3] <= COMPLS6 ^ d_o ;
		dataout_reg[4] <= COMPLS6 ^ eo ;
		dataout_reg[5] <= COMPLS6 ^ io ;				
	end	
end


reg legaldata_reg;
always @ (negedge clk or negedge rst_n)begin
	if(!rst_n)begin
		valid <= 1'b0;
		dataout <= 10'b00000000;
		//legaldata_reg <= legaldata;
		legaldata_reg <= 1'b0;
	end
	else begin
		dataout[0] <= dataout_reg[0];
		dataout[1] <= dataout_reg[1];
		dataout[2] <= dataout_reg[2];
		dataout[3] <= dataout_reg[3];
		dataout[4] <= dataout_reg[4];
		dataout[5] <= dataout_reg[5];
			
		dataout[6] <= COMPLS4 ^ NFO ;
		dataout[7] <= COMPLS4 ^ NGO ;
		dataout[8] <= COMPLS4 ^ NHO ;
		dataout[9] <= COMPLS4 ^ NJO ;	
		
		legaldata_reg <= legaldata;
		valid <= legaldata_reg;
		end
end

	
endmodule