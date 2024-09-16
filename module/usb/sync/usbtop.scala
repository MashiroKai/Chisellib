package lib.module.usb.sync.usbtop

import chisel3._

import chisel3.util._
import lib.io.UsbIoSyncWr
import lib.io.UsbIoSyncRd

import lib.module.usb.sync._

object UsbTop extends App{
 (new chisel3.stage.ChiselStage).emitVerilog(new UsbTop(), Array("--target-dir","generated"))
}

class UsbTop extends Module{
val io = IO(new Bundle{
val ctrl   = Input(Bool())  //High Write Low Read    
val readHs = new DecoupledIO(UInt(8.W)) 
val readIo = new UsbIoSyncRd
val writeHs =Flipped(new DecoupledIO(UInt(8.W))) 
val writeIo =new UsbIoSyncWr
})
val readInstance = Module(new Read())
val writeInstance = Module(new Write())
io.ctrl<>readInstance.io.ctrl
io.readHs<>readInstance.io.readHs
io.readIo<>readInstance.io.readIo
io.writeHs<>writeInstance.io.writeHs
io.writeIo<>writeInstance.io.writeIo
}