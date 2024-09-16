package lib.fifo

import chisel3._

/**
  * A simple bubble FIFO.
  * Maximum throughput is one word every two clock cycles.
  */
class BubbleFifo[T <: Data](gen: T, depth: Int) extends Fifo(gen: T, depth: Int) {

  private class Buffer() extends Module {
    val io = IO(new FifoIO(gen))

    val fullReg = RegInit(false.B)
    val dataReg = Reg(gen)

    when (fullReg) {
      when (io.rd.ready) {
        fullReg := false.B
      }
    } .otherwise {
      when (io.wr.valid) {
        fullReg := true.B
        dataReg := io.wr.bits
      }
    }

    io.wr.ready := !fullReg
    io.rd.valid := fullReg
    io.rd.bits := dataReg
  }

  private val buffers = Array.fill(depth) { Module(new Buffer()) }
  for (i <- 0 until depth - 1) {
    buffers(i + 1).io.wr <> buffers(i).io.rd
  }

  io.wr <> buffers(0).io.wr
  io.rd <> buffers(depth - 1).io.rd
}