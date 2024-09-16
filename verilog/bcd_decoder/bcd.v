module bcd(
    input wire clk,
    input wire reset,
    input wire enable,
    output reg [3:0] bcd0,
    output reg [3:0] bcd1,
    output reg [3:0] bcd2
);

reg [10:0] count;
reg [3:0] ones;
reg [3:0] tens;
reg [3:0] hundreds;

always @(posedge clk or posedge reset) begin
    if (reset)
        count <= 0;
		  else if(count==999)
        count <= 0;	
    else if (enable && (count != 1000))
        count <= count + 1;
end

always @(count) begin
    ones <= count % 10;
    tens <= (count / 10) % 10;
    hundreds <= count / 100;
end

always @(ones, tens, hundreds) begin
    bcd0 <= ones;
    bcd1 <= tens;
    bcd2 <= hundreds;
end

endmodule