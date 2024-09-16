/*
fifo #(
    .WIDTH(),
    .PTRWIDTH()
)
f1(
    .clk(clk)
    ,.rst_n(rst_n)
    ,.valid()
    ,.din()
    ,.load()
    ,.dout()
    ,.fifo_valid()
    ,.full()
    ,.empty()
    ,.usedw()
);
*/
module fifo(
    input            clk
    ,input           rst_n
    ,input              valid
    ,input            [WIDTH-1:0]din
    ,input              load
    ,output     reg   [WIDTH-1:0]dout
    ,output     reg     fifo_valid       
    ,output             full
    ,output             empty
    ,output           [PTRWIDTH:0]usedw
);

parameter   WIDTH = 4'd8;
localparam   DEPTH = exp2(PTRWIDTH);
parameter   PTRWIDTH = 9;

reg     [WIDTH-1:0] buffer [DEPTH-1:0];
reg     [PTRWIDTH:0]  wr_ptr;
reg     [PTRWIDTH:0]  rd_ptr;

wire    [PTRWIDTH-1:0]  wr_ptr_ture;
wire    [PTRWIDTH-1:0]  rd_ptr_ture;

assign wr_ptr_ture = wr_ptr[PTRWIDTH-1:0];
assign rd_ptr_ture = rd_ptr[PTRWIDTH-1:0];
assign usedw = (wr_ptr[PTRWIDTH] >= rd_ptr[PTRWIDTH])?(wr_ptr - rd_ptr):({~wr_ptr[PTRWIDTH],wr_ptr[PTRWIDTH-1:0]} - {~(rd_ptr[PTRWIDTH]),rd_ptr[PTRWIDTH-1:0]});
assign full = (wr_ptr == {~(rd_ptr[PTRWIDTH]),rd_ptr[PTRWIDTH-1:0]})?1'b1:1'b0;
assign empty = (wr_ptr == rd_ptr)?1'b1:1'b0;

//fifo write opperation
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= 'd0;
    end
    else if(!full&&valid) begin
        buffer[wr_ptr_ture] <= din ;
        wr_ptr <= wr_ptr + 1'b1;
    end
end

//fifo read opperation
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rd_ptr <= 'd0;
        dout <= 'd0;
        fifo_valid <= 1'b0;
    end
    else if(!empty&&load) begin
        dout <= buffer[rd_ptr_ture];
        rd_ptr <= rd_ptr + 1'b1;
        fifo_valid <= 1'b1;
    end else begin
        fifo_valid <= 1'b0;
    end
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
endmodule

