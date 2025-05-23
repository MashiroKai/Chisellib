package lib.func

import chisel3._

import chisel3.util._
import chisel3.experimental.ChiselEnum

object Edge{
    def rising(signal : Bool) = signal & ! RegNext(signal)
    def falling(signal : Bool) = !signal & RegNext(signal) 
    
}
object Async{
    def sync[T <:Data](signal: T) = RegNext(RegNext(signal))

    def filter(signal: Bool, sampe: Bool) = {
    val reg = RegInit(0.U(3.W))
    when (sampe) {
      reg := Cat(reg(1, 0), signal)//shift reg
    }
    (reg(2) & reg(1)) | (reg(2) & reg(0)) | (reg(1) & reg(0))
  }
}
object Cnt{
    def validTickGen(max: Int,valid : Bool) = {
        val reg = RegInit(0.U(log2Up(max).W))
        val tick = reg === (max-1).U
        reg := Mux(tick, 0.U, Mux(valid,reg + 1.U,reg))
        tick
  }
        def tickGen(max: Int) = {
        val reg = RegInit(0.U(log2Up(max).W))
        val tick = reg === (max-1).U
        reg := Mux(tick, 0.U, reg + 1.U)
        tick
  }
      def validTickGenCnt(max: Int,valid : Bool) = {
        val reg = RegInit(0.U(log2Up(max).W))
        val tick = reg === (max-1).U
        reg := Mux(tick, 0.U,  Mux(valid,  reg + 1.U  ,  reg))
        (tick,reg)
  }
      def reverseValidTickGenCnt(max: Int,valid : Bool) = {
        val reg = RegInit((max-1).U(log2Up(max).W))
        val tick = reg === 0.U
        reg := Mux(tick, (max-1).U,  Mux(valid,  reg - 1.U  ,  reg))
        (tick,reg)
  }
    def counter(max: Int) = {
    val x = RegInit(0.U(log2Up(max).W))
    x := Mux(x === (max - 1).U, 0.U, x + 1.U)
    x
  }
    def validCnt(max :Int ,valid :Bool) = {
    val cnt = RegInit(0.U(log2Up(max).W))
    cnt := Mux(cnt === (max-1).U,  0.U  ,  Mux(valid,  cnt + 1.U  ,  cnt))
    cnt
    }
    def fifoCnt(depth: Int, incr: Bool , multi : Int) : (UInt, UInt) = {
    val cntReg = RegInit(0.U(log2Ceil(depth).W))
    val nextVal = Mux(cntReg === (depth-multi).U, 0.U, cntReg + multi.U)
    when (incr) {
      cntReg := nextVal
    }
    (cntReg, nextVal)
  }
      def validCntClearTick(max :UInt ,valid :Bool,clear :Bool) = {
    val width = max.getWidth
    val cnt = RegInit(0.U(width.W))
    val tick = cnt === max-1.U
    cnt := Mux(clear||cnt === max-1.U,  0.U  ,  Mux(valid,  cnt + 1.U  ,  cnt))
    (tick , cnt)
    }
      def validCntClear(max :UInt ,valid :Bool,clear :Bool) = {
    val width = max.getWidth
    val cnt = RegInit(0.U(width.W))
    cnt := Mux(clear||cnt === max-1.U,  0.U  ,  Mux(valid,  cnt + 1.U  ,  cnt))
    cnt
    }
      def clearTick(max :UInt,clear :Bool) = {
    val width = max.getWidth
    val cnt = RegInit(0.U(width.W))
    val tick = cnt === max-1.U
    cnt := Mux(clear||(cnt === max-1.U),  0.U  , cnt + 1.U )
    tick
    }
}
object Main{
    // Flip internal state when input true.
    def toggle(p: Bool) = {
    val x = RegInit(false.B)
    x := Mux(p, !x, x)
    x
    }
    def max[T <: UInt](gen: Seq[T]): T ={
      gen.reduce((a,b) => Mux(a>b,a,b))
    }
    def min[T <: UInt](gen: Seq[T]): T = {
      gen.reduce((a,b) => Mux(a<b,a,b))
    }
    // Produce pulse every n cycles.
   // def pulse(n: UInt) = counter(n - 1.U) === 0.U
}
object Shift{
  def shift[T <:Data](gen: T , depth : Int ,valid : Bool) = {
  val reg = RegInit(VecInit(Seq.fill(depth)(gen)))
    reg(0) := Mux(valid,gen,reg(0))
  for(i <- 1 until depth){
    reg(i) := Mux(valid,reg(i-1),reg(i))
  }
    reg(depth-1)
  }
  def shiftOut[T <:Data](gen: T , depth : Int ,valid : Bool ,position : UInt) = {
  val reg = RegInit(VecInit(Seq.fill(depth)(gen)))
    reg(0) := Mux(valid,gen,reg(0))
  for(i <- 1 until depth){
    reg(i) := Mux(valid,reg(i-1),reg(i))
  }
    reg(position)
  }
def shiftSum[T <: Data](gen: T, depth: Int, valid: Bool, position: UInt): UInt = {
  assert(position < depth.U, "Out of range")

  // 创建一个类型为 gen 的 Vec，并初始化为全零
  val width = gen.getWidth + log2Up(depth)
  val reg = RegInit(VecInit(Seq.fill(depth)(0.U(width.W))))

  // 累加和的初始化
  val sum = WireDefault(0.U(width.W))

  // 写入第一个值
  reg(0) := Mux(valid, gen, reg(0))

  // 级联移位寄存器
  for (i <- 1 until depth) {
    reg(i) := Mux(valid, reg(i - 1), reg(i))
  }

  // 根据位置计算累加和
  sum := (0 until depth).map(i => Mux(i.U < position, reg(i).asUInt, 0.U)).reduce((a,b) =>a+b)

  sum
  }
  def shiftCmp[T <: Data](gen: T, valid: Bool, data: UInt): Bool = {
  
  val width = gen.getWidth
  val depth = (data.getWidth)/(gen.getWidth)
  val reg = RegInit(VecInit(Seq.fill(depth)(0.U(width.W))))

  // 写入第一个值
  reg(0) := Mux(valid, gen, reg(0))
  // 级联移位寄存器
  for (i <- 1 until depth) {
    reg(i) := Mux(valid, reg(i - 1), reg(i))
  }
  val signal = Edge.rising(Mux(reg.asUInt === data , true.B , false.B))
  signal
  }
def shiftAverage[T <: Data](gen: T, valid: Bool, depth: Int): UInt = {
  val width = gen.getWidth
  val reg = RegInit(VecInit(Seq.fill(depth)(0.U(width.W)))) // 滑动窗口存储最近 depth 个值

  // 移位更新逻辑
  when(valid) {
    for (i <- depth - 1 to 1 by -1) {
      reg(i) := reg(i - 1) // 右移
    }
    reg(0) := gen // 最新数据进入
  }

  // 计算平均值 (扩展位宽防止溢出)
  val sum = reg.reduce(_ +& _) // 使用 +& 避免溢出
  val average = sum / depth.U
  average
}
def shiftAverageValue[T <: Data](gen: T, valid: Bool, depth: Int): (UInt, UInt) = {
  val width = gen.getWidth
  val reg = RegInit(VecInit(Seq.fill(depth)(0.U(width.W)))) // 滑动窗口存储最近 depth 个值

  // 移位更新逻辑
  when(valid) {
    for (i <- depth - 1 to 1 by -1) {
      reg(i) := reg(i - 1) // 右移
    }
    reg(0) := gen // 最新数据进入
  }

  // 计算平均值 (扩展位宽防止溢出)
  val sum = reg.reduce(_ +& _) // 使用 +& 避免溢出
  val average = sum / depth.U
  (average,reg(depth-1))
}
}

