package lib.fifo

import chisel3._
import chisel3.util._

/**
  * Double buffer FIFO.
  * Maximum throughput is one word per clock cycle.
  * Each stage has a shadow buffer to handle the downstream full.
  */
class DoubleBufferFifo[T <: Data](gen: T, depth: Int) extends Fifo(gen: T, depth: Int) {

  private class DoubleBuffer[T <: Data](gen: T) extends Module {
    val io = IO(new FifoIO(gen))

    val empty :: one :: two :: Nil = Enum(3)
    val stateReg = RegInit(empty)
    val dataReg = Reg(gen)
    val shadowReg = Reg(gen)

    switch(stateReg) {
      is (empty) {
        when (io.wr.valid) {
          stateReg := one
          dataReg := io.wr.bits
        }
      }
      is (one) {
        when (io.rd.ready && !io.wr.valid) {
          stateReg := empty
        }
        when (io.rd.ready && io.wr.valid) {
          stateReg := one
          dataReg := io.wr.bits
        }
        when (!io.rd.ready && io.wr.valid) {
          stateReg := two
          shadowReg := io.wr.bits
        }
      }
      is (two) {
        when (io.rd.ready) {
          dataReg := shadowReg
          stateReg := one
        }

      }
    }

    io.wr.ready := (stateReg === empty || stateReg === one)
    io.rd.valid := (stateReg === one || stateReg === two)
    io.rd.bits := dataReg
  }

  private val buffers = Array.fill((depth+1)/2) { Module(new DoubleBuffer(gen)) }

  for (i <- 0 until (depth+1)/2 - 1) {
    buffers(i + 1).io.wr <> buffers(i).io.rd
  }
  io.wr <> buffers(0).io.wr
  io.rd <> buffers((depth+1)/2 - 1).io.rd
}
