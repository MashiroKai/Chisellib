package lib.param

import chisel3._

case class UartParam(Baud : Int,ClkFeq : Int){
    assert(Baud > 0 && ClkFeq > 0 ,"parameters must be larger than 0")
    assert(ClkFeq > Baud, "ClkFeq must be larger than Baud")
}
case class FifoParam(Depth: Int,Width : Int){
    assert(Depth >0 && Width >0 , "parameters must be larger than 0")
}