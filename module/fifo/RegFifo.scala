package lib.fifo

import chisel3._
import chisel3.util._

/**
  * FIFO with read and write pointer using dedicated registers as memory.
  */
object RegFifo extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new RegFifo(UInt(8.W),12), Array("--target-dir","generated"))
}

class RegFifo[T <: Data](gen: T, depth: Int) extends Fifo(gen: T, depth: Int) {

  def counter(depth: Int, incr: Bool): (UInt, UInt) = {
    val cntReg = RegInit(0.U(log2Ceil(depth).W))
    val nextVal = Mux(cntReg === (depth-1).U, 0.U, cntReg + 1.U)
    when (incr) {
      cntReg := nextVal
    }
    (cntReg, nextVal)
  }

  // the register based memory
  val memReg = Reg(Vec(depth, gen))

  val incrRead = WireInit(false.B)
  val incrWrite = WireInit(false.B)
  val (readPtr, nextRead) = counter(depth, incrRead)
  val (writePtr, nextWrite) = counter(depth, incrWrite)

  val emptyReg = RegInit(true.B)
  val fullReg = RegInit(false.B)

  when (io.wr.valid && !fullReg) {
    memReg(writePtr) := io.wr.bits
    emptyReg := false.B
    fullReg := nextWrite === readPtr
    incrWrite := true.B
  }

  when (io.rd.ready && !emptyReg) {
    fullReg := false.B
    emptyReg := nextRead === writePtr
    incrRead := true.B
  }

  io.rd.bits := memReg(readPtr)
  io.wr.ready := !fullReg
  io.rd.valid := !emptyReg
}
