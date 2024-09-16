package lib.module.usb.async

import  chisel3._

import  chisel3.util._
import  chisel3.experimental.ChiselEnum
import  lib.io.UsbIoAsyncRd
// ! clock should be set at 30Mhz, 33.3Mhz at most 
object Read extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new Read(), Array("--target-dir","generated"))
}
class Read extends Module{
    val io = IO(new Bundle {
        //user interface
        val user =   new DecoupledIO(UInt(8.W))
        //usb write interface
        val usb  =   new UsbIoAsyncRd
    })

    val rxfnReg = RegNext(io.usb.rxfn)
    val dataReg = RegNext(io.usb.data)

    io.usb.rdn  := Mux(!rxfnReg&&io.user.ready,false.B,true.B)
    io.user.bits  := dataReg
    io.user.valid := !io.usb.rdn
}
