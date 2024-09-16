package lib.module.usb.async


import  chisel3._

import  chisel3.util._
import  chisel3.experimental.ChiselEnum
import  lib.io.UsbIoAsyncWr

object Write extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new Write(), Array("--target-dir","generated"))
}

class Write extends Module{
    val io = IO(new Bundle {
        //user userterface
        val user  =   Flipped(new DecoupledIO(UInt(8.W)))
        //usb write userterface
        val usb =   new UsbIoAsyncWr
    })

    val txenReg = RegNext(io.usb.txen)
    io.usb.wrn := Mux(!txenReg&&io.user.valid,false.B,true.B)
    io.usb.data  := RegNext(io.user.bits)
    io.user.ready := !txenReg
}
