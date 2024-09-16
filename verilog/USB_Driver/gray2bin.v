/*
gray2bin #(
    .N()
)
g2b(
    .gray()
    ,.bin()
);
*/

module gray2bin #(
    parameter N = 4
)(
    input [N-1:0] gray,
    output [N-1:0] bin
    );
    assign bin[N-1] = gray[N-1];
    genvar i;
    generate
    for(i = N-2; i >= 0; i = i - 1) begin: gray_2_bin
        assign bin[i] = bin[i + 1] ^ gray[i];
    end
    endgenerate
endmodule