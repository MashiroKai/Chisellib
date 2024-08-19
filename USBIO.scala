import chisel3._
import chisel3.util._
class USBIO_RD extends Bundle {
val RXF_N   = Input(Bool())
val RD_N    = Output(Bool())
val OE_N    = Output(Bool())
val Data    = Input(UInt(8.W))
}
class USBIO_WR extends Bundle{
val TXE_N   = Input(Bool())
val WR_N    = Output(Bool())
val Data    = Output(UInt(8.W))
}