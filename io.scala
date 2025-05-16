package lib.io

import chisel3._
import chisel3.util._

class UsbIoSyncRd extends Bundle {
val rxfn   = Input(Bool())
val rdn    = Output(Bool())
val oen    = Output(Bool())
val data    = Input(UInt(8.W))
}

class UsbIoSyncWr extends Bundle{
val txen  = Input(Bool())
val wrn   = Output(Bool())
val data  = Output(UInt(8.W))
}

class UsbIoAsyncWr extends Bundle {
val txen  = Input(Bool())
val wrn   = Output(Bool())
val data  = Output(UInt(8.W))
}

class UsbIoAsyncRd extends Bundle {
val rxfn  = Input(Bool())
val rdn   = Output(Bool())
val data  = Input(UInt(8.W))
}

class AdcIo extends Bundle{
val ovr   = Bool()
val data = UInt(14.W)
}

class RamIoWr[T <: Data](Depth : Int ,gen : T) extends Bundle{
val wEn = Input(Bool())
val wAddr = Input(UInt(log2Up(Depth).W))
val wDin = Input(gen)
}

class RamIoRd[T <: Data](Depth : Int ,gen : T)  extends Bundle{
val rAddr = Input(UInt(log2Up(Depth).W))
val rDout = Output(gen)
}

class FifoIoWr[T <: Data](gen : T) extends Bundle{
val wEn = Input(Bool())
val wDin = Input(gen)
val full = Output(Bool())
}

class FifoIoRd[T <: Data](gen : T) extends Bundle{
val rEn = Input(Bool())
val rDout = Output(gen)
val empty = Output(Bool())
}

class FifoIo[T <: Data](gen : T) extends Bundle{
val wEn = Input(Bool())
val wDin = Input(gen)
val full = Output(Bool())
val rEn = Input(Bool())
val rDout = Output(gen)
val empty = Output(Bool())
}

class SampeIo extends Bundle {
val eventValid = Output(Bool())
val underSampe = Output(Bool())
val overSampe = Output(Bool())
}

class ChnCtrl extends Bundle{
  val ready = Input(Bool())
  val hold = Output(Bool())
  val read = Output(Bool())
}

class LedCtrl extends Bundle{
val data = UInt(4.W)
val en   = Bool()
}

class SpiMaster extends Bundle{
//spi setting
val cpol = Output(Bool())
val cpha = Output(Bool())
val clkDivide = Output(Bool())
//spi user interface
val go = Output(Bool())
val data = Output(UInt(16.W))
val busy = Input(Bool())
val done = Input(Bool())
}