//package edge
import chisel3._
import chisel3.util._
import chisel3.experimental.ChiselEnum

object edge{
    def Rising(Signal : Bool) = Signal & ! RegNext(Signal)
    def Falling(Signal : Bool) = !Signal & RegNext(Signal) 
}

