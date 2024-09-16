package lib.module.usb.sync
import chisel3._
import chisel3.util._
import lib.io.UsbIoSyncWr

class Write extends Module{
val io=IO(new Bundle{
val writeHs =Flipped(new DecoupledIO(UInt(8.W))) 
val writeIo =new UsbIoSyncWr
})
io.writeIo.wrn     :=   ~(io.writeHs.valid && ~io.writeIo.txen)
io.writeIo.data     :=   io.writeHs.bits
io.writeHs.ready    := RegNext(~io.writeIo.txen)
}
/*
object Write extends App{
 (new chisel3.stage.ChiselStage).emitVerilog(new Write(), Array("--target-dir","generated"))
}
*/