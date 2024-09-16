package lib.module.usb.sync

import chisel3._
import chisel3.util._
import lib.io.UsbIoSyncRd


class Read extends Module { 
val io = IO(new Bundle {
val ctrl   = Input(Bool())  //High Write Low Read
val readHs = new DecoupledIO(UInt(8.W)) 
val readIo = new UsbIoSyncRd
})

val rd  =   WireDefault(false.B)
io.readIo.oen := io.ctrl
io.readIo.rdn := RegNext(!rd)
io.readHs.valid := RegNext(rd)
io.readHs.bits := RegNext(io.readIo.data)
when(io.ctrl === false.B  &&  io.readIo.rxfn === false.B && io.readHs.ready === true.B){
    rd  := true.B
}.otherwise{
    rd  := false.B
}
}
/*
object Read extends App{
 (new chisel3.stage.ChiselStage).emitVerilog(new Read(), Array("--target-dir","generated"))
}
*/