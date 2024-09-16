`timescale 1ns / 1ps
module fifo_tb;
    reg clk;
    reg rst_n;
    reg valid;
    reg [WIDTH-1:0] din;
    reg load;
    wire [WIDTH-1:0] dout;
    wire fifo_valid;
    wire full;
    wire empty;
    wire [PTRWIDTH:0]usedw;

    parameter WIDTH = 4'd8;
    parameter PTRWIDTH = 5'd2;
    fifo #(
        .PTRWIDTH(PTRWIDTH),
        .WIDTH(WIDTH)
    )
    uut (
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .din(din),
        .load(load),
        .dout(dout),
        .fifo_valid(fifo_valid),
        .full(full),
        .empty(empty),
        .usedw(usedw)
    );

    initial begin
        // Initialize inputs
        clk = 0;
        rst_n = 0;
        valid = 0;
        din = 0;
        load = 0;

        // Apply reset and start clock
        #10;
        rst_n = 1;
        clk = 1;
        #10
        // Test scenario
        // Write data into FIFO
        #20 valid = 1; din = 8'hAA;
        #20 valid = 0;
        #20 valid = 1; din = 8'h11;
        #20 valid = 0;
        #20 valid = 1; din = 8'h22;
        #20 valid = 0;
        #20 valid = 1; din = 8'h33;
        #20 valid = 0;
        // Read data from FIFO
        #20 load = 1;
        #20 load = 0;
        #20 load = 1;
        #20 load = 0;
        #20 load = 1;
        #20 load = 0;
        #20 load = 1;
        #20 load = 0;
        // Write data into FIFO
        #20 valid = 1; din = 8'hAA;
        #20 valid = 0;
        #20 valid = 1; din = 8'h11;
        #20 valid = 0;
        #20 valid = 1; din = 8'h22;
        #20 valid = 0;
        // Read data from FIFO
        #20 load = 1;
        #20 load = 0;
        #20 load = 1;
        #20 load = 0;
        #20 load = 1;
        #20 load = 0;
                // Write data into FIFO
        #20 valid = 1; din = 8'hAA;
        #20 valid = 0;
        #20 valid = 1; din = 8'h11;
        #20 valid = 0;
        #20 valid = 1; din = 8'h22;
        #20 valid = 0;
        #20 valid = 1; din = 8'h33;
        #20 valid = 0;
        // Read data from FIFO
        #20 load = 1;
        #20 load = 0;
        #20 load = 1;
        #20 load = 0;
        #20 load = 1;
        #20 load = 0;
        #20 load = 1;
        #20 load = 0;

        // Stop simulation
        #500 $finish;
    end
always  #10 clk = ~clk;

initial
begin            
    $dumpfile("fifo_tb.vcd");        //生成的vcd文件名称
    $dumpvars(0,fifo_tb);     //tb模块名称
end

endmodule
