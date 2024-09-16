package lib.fifo

import chisel3._
import chisel3.util._
import lib.func.Cnt

/**
  * FIFO with read and write pointer using dedicated registers as memory.
  */
object RuyiFifo extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new RuyiFifo(UInt(48.W),UInt(8.W),24), Array("--target-dir","generated"))
}

class RuyiFifo[T <: Data,Y <: Data](in: T , out: Y , depth : Int)  extends Module{
  val io = IO(new Bundle{
    val wr = Flipped(new DecoupledIO(in))
    val rd = new DecoupledIO(out)
  }) 
  val multi = math.max(in.getWidth / out.getWidth , out.getWidth / in.getWidth)
  
  assert((in.getWidth % out.getWidth == 0 )||(out.getWidth % in.getWidth == 0),
  "Input/output data must be a multipe of output/input data")

  assert(depth%multi == 0 ,
  "Depth must be a multipe of multipe between input and output")
  

  // the register based memory
  //val memReg = RegInit(VecInit(Seq.fill(depth*in.getWidth)(0.U(1.W)) ))
  val memReg = SyncReadMem(depth*in.getWidth, UInt(1.W))

  val incrRead = WireInit(false.B)
  val incrWrite = WireInit(false.B)
  
  val (readPtr, nextRead) = Cnt.fifoCnt(depth*in.getWidth, incrRead,out.getWidth)
  val (writePtr, nextWrite) = Cnt.fifoCnt(depth*in.getWidth, incrWrite,in.getWidth)

  val emptyReg = RegInit(true.B)
  val fullReg = RegInit(false.B)

  val wrBitsVec = io.wr.bits.asTypeOf(Vec(in.getWidth, UInt(1.W)))
 // val rdBitsVec = io.rd.bits.asTypeOf(Vec(out.getWidth, UInt(1.W)))
    
  when (io.wr.valid && !fullReg) {
    for(i<-0 until in.getWidth){
    memReg.write((writePtr+i.U) , wrBitsVec(i))
    }
    emptyReg := false.B
    fullReg := ((nextWrite > readPtr)&& (writePtr < readPtr))||(nextWrite === readPtr)
    incrWrite := true.B
  }

  when (io.rd.ready && !emptyReg) {
    fullReg := false.B
    emptyReg := nextRead === writePtr
    incrRead := true.B
  }

  io.rd.bits := VecInit((0 until out.getWidth).map(i => (memReg.read(readPtr + i.U,io.rd.ready )))).asTypeOf(io.rd.bits)
  io.wr.ready := !fullReg
  io.rd.valid := RegNext(!emptyReg&&io.rd.ready)
}