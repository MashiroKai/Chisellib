`timescale  1ns/100ps
module exp2_tb;
reg [4:0]a,c;
reg [31:0]b,d;
initial begin
  a = 7 ;
  b = exp2(a);
  #20
  a =8  ;
  b = exp2(a);
  #10
  $finish;
end
initial begin
  d = 511;
  c = logb2(d);
  #20
  d = 513;
  c = logb2(d);
end

function integer exp2 ;
input   [4:0] DEPTHWIDTH  ;
reg [4:0]temp;
begin
    exp2 = 1;
    for (temp = 0;temp <DEPTHWIDTH ;temp = temp + 1 ) begin
            exp2 = 2*exp2;
    end
end
endfunction
function integer logb2;
    input [31:0]            value;
    reg   [31:0]            tmp;
begin
    tmp = value - 1;
    for (logb2 = 0; tmp > 0; logb2 = logb2 + 1) 
        tmp = tmp >> 1;
end
endfunction
initial begin
    $dumpfile ("exp2_tb.vcd");
    $dumpvars (0,exp2_tb);
end
endmodule