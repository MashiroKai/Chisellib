module parallel_to_serial
(
  input clk,      // 时钟信号
  input rst,      // 复位信号
  input load,     // 同步数据加载信号
  input [DATA_WIDTH-1:0] din,   // 并行输入数据端口
  output reg dout,    // 串行输出数据端口
  output reg valid,   // 输出数据有效标志
  output reg load_en  // 同步数据加载使能
);

  parameter DATA_WIDTH = 8;         //用于自定义参数
  reg [DATA_WIDTH-1:0] shift_reg;  // 移位寄存器，用于存储并行输入数据
  reg [DATA_WIDTH-1:0]  counter;    // 计数器，用于计算移位寄存器中的数据位数,verilog无取对数函数这里counter寄存器存在冗余


  always @ (posedge clk or posedge rst)
  begin
    if (rst)  // 复位信号置高时清零移位寄存器和计数器
    begin
      shift_reg <= 0;
      counter <= 0;
      dout <= 0;
      valid <= 0;
      load_en <= 1;
    end
    else   // 复位信号置低时进行移位操作
    begin
      if (load&load_en)  // 需要加载数据且数据发送完毕时允许加载新数据
      begin
        shift_reg <= din;
        counter <= DATA_WIDTH;
        valid <= 0;
        load_en <= 0;
      end
      else if (counter > 0)  // 如果计数器大于0，表示移位寄存器中还有数据需要输出
      begin
        //shift_reg <= {shift_reg[DATA_WIDTH-2:0], shift_reg[DATA_WIDTH-1]};  // 移位寄存器左移一位
        shift_reg<={shift_reg[0],shift_reg[DATA_WIDTH-1:1]};//移位寄存器右移一位
        counter <= counter - 1;  // 计数器减1
        valid <= 1;  // 标记输出数据为有效数据
        load_en <= 0;  // 不允许加载新的数据
      end
      else
      begin
        valid <= 0;//输出结束，拉低有效
        load_en <= 1;//输出结束，允许加载
      end
    end
    //dout <= shift_reg[DATA_WIDTH-1];  // 输出串行输出数据的最高位
      dout <= shift_reg[0];  // 输出串行输出数据的最低位
  end
endmodule
