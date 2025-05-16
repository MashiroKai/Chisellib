package lib.module.usb.async


import  chisel3._

import  chisel3.util._
import  chisel3.experimental.ChiselEnum
import  lib.io.UsbIoAsyncWr
import  lib.func.Cnt

object Write extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new Write(125000000,1000), Array("--target-dir","generated"))
}

class Write(ClockFeq : Int, maxContinuousWrites: Int ) extends Module{
    val io = IO(new Bundle {
        //user userterface
        val user  =   Flipped(new DecoupledIO(UInt(8.W)))
        //usb write userterface
        val usb =   new UsbIoAsyncWr
    })
    val dividedNum : Int = ClockFeq/30000000
    val tick = Cnt.tickGen(dividedNum)
    val txenReg = RegNext(RegNext(io.usb.txen))
    val readyToGo = io.user.valid & !txenReg
    val idle :: write :: waiting :: ready :: pause :: Nil = Enum(5)
    val stateReg = RegInit(idle)
    val dataReg = RegNext(RegNext(io.user.bits))
    
    // 添加计数器来跟踪连续写入的数量
    val writeCounter = RegInit(0.U(log2Ceil(maxContinuousWrites + 1).W))
    val pauseCounter = RegInit(0.U(log2Ceil(1001).W))

    switch(stateReg){
      is(idle){
        when(readyToGo & tick){
          stateReg := write
          writeCounter := 0.U
        }
      }
      is(write){
        when(tick){
          writeCounter := writeCounter + 1.U
          when(writeCounter === (maxContinuousWrites - 1).U) {
            stateReg := pause
            pauseCounter := 0.U
          }.otherwise {
            stateReg := waiting
          }
        }
      }  
      is(waiting){
        when(tick){
          stateReg := ready
        }
      }
      is(ready){
        stateReg := idle
      }
      is(pause){
        when(tick){
          pauseCounter := pauseCounter + 1.U
          when(pauseCounter === 1000.U) {
            stateReg := idle
          }
        }
      }
    }
    io.usb.wrn := Mux(stateReg === write, false.B, true.B)
    io.usb.data := dataReg
    io.user.ready := Mux(stateReg === ready, true.B, false.B)
}
