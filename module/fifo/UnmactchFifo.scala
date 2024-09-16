package lib.fifo

import chisel3._
import chisel3.util._

/**
  * FIFO with read and write pointer using dedicated registers as memory.
  */
class UnmatchFifo (depth : Int)extends Module{
assert(depth%2 == 0 && depth > 0,"depth should be plural and larger than 0")
val io = IO(new Bundle{
  val rd = new DecoupledIO(UInt(8.W))
  val wr = Flipped(new DecoupledIO(UInt(16.W)))
})

  def counter(depth: Int, incr: Bool , multi : Int) : (UInt, UInt) = {
    val cntReg = RegInit(0.U(log2Ceil(depth).W))
    val nextVal = Mux(cntReg === (depth-1).U, 0.U, cntReg + multi.U)
    when (incr) {
      cntReg := nextVal
    }
    (cntReg, nextVal)
  }

  // the register based memory
  val memReg = Reg(Vec(depth, UInt(8.W)))

  val lowerByte = io.wr.bits(7,0)
  val highByte = io.wr.bits(15,8)

  val incrRead = WireInit(false.B)
  val incrWrite = WireInit(false.B)
  val (readPtr, nextRead) = counter(depth, incrRead , 1)
  val (writePtr, nextWrite) = counter(depth, incrWrite , 2)

  val emptyReg = RegInit(true.B)
  val fullReg = RegInit(false.B)

  when (io.wr.valid && !fullReg) {
    memReg(writePtr) := lowerByte
    memReg(writePtr + 1.U) := highByte

    emptyReg := false.B
    fullReg := (nextWrite > readPtr&& writePtr < readPtr)||(nextWrite === readPtr)
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
