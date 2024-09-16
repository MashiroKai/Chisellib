function integer logb2;
    input [31:0]            value;
    reg   [31:0]            tmp;
begin
    tmp = value - 1;
    for (logb2 = 0; tmp > 0; logb2 = logb2 + 1) 
        tmp = tmp >> 1;
end
endfunction