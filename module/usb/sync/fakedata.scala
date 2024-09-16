package lib.module.usb.sync

import chisel3._
import chisel3.util._
//import circt.stage.ChiselStage
import chisel3.experimental.ChiselEnum

object Fakedata extends App{
 (new chisel3.stage.ChiselStage).emitVerilog(new Fakedata(), Array("--target-dir","generated"))
}

class Fakedata extends Module {
val io = IO(new Bundle{
val start = Input(Bool())
val writeHs = new DecoupledIO(UInt(8.W))
})


def cnt (Enable : Bool , Maxium : Int ,Clock: Bool, Clear : Bool) = {
    val counter = RegInit(0.U(unsignedBitLength(Maxium).W))
    counter := Mux(Clear||(counter === Maxium.U),0.U,Mux(Enable&&Clock,counter +1.U,counter))
    counter
}

val idel::send::waitting::Nil = Enum(3)
val bytesNum = 66067 // 66048 bytes
val waitTime = 60000000
val stateReg = RegInit(idel)
val cntValidEnable = Mux(stateReg === send , true.B , false.B)
val cntTimeEnable = Mux(stateReg === waitting , true.B , false.B)
val cntValid = cnt(cntValidEnable,bytesNum,io.writeHs.valid,!cntValidEnable)
val cntTime = cnt(cntTimeEnable,waitTime,true.B,!cntTimeEnable)
io.writeHs.valid := false.B
io.writeHs.bits := cntValid


switch(stateReg){
    is(idel){
        when(io.start){stateReg := send}
    }
    is(send){
        when(io.writeHs.ready) {
            io.writeHs.valid := true.B
            io.writeHs.bits := cntValid
        }.otherwise{
            io.writeHs.valid := false.B
            io.writeHs.bits := cntValid
        }
        when(cntValid === bytesNum.U) {
            stateReg := waitting
        }.elsewhen(!io.start){
            stateReg := idel
        }
    }
    is(waitting){
        when(cntTime === waitTime.U){
            stateReg := send
        }.elsewhen(!io.start){
            stateReg := idel
        }
    }
}
}
