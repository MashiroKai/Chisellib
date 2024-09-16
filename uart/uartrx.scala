package lib.uart
import chisel3._
import chisel3.util._

class UartRxIo extends Bundle {
    val valid = Output(Bool())
    val check = Output(Bool())
    val stop = Output(Bool())
    val rx_data = Output(UInt(8.W))
    val rs422_rx = Input(Bool())
}

class BaudRxIo extends Bundle{
    val clk = Input(Bool())
    val rst_n = Input(Bool())
    val bps_en = Input(Bool())
    val bps_clk = Output(Bool())
}

class RxIo extends Bundle{
    val clk = Input(Bool())
    val rst_n = Input(Bool())
    val valid = Output(Bool())
    val rx_data = Output(UInt(8.W))
    val rs422_rx = Input(Bool())
    val check = Output(Bool())
    val stop = Output(Bool())
    val bps_en = Output(Bool())
    val bps_clk = Input(Bool())
}

class BaudRx extends HasBlackBoxPath {
    val io = IO(new BaudRxIo)
    addPath("./src/main/scala/lib/verilog/uart/baud_rx.v")
}

class Rx extends HasBlackBoxPath {
    val io = IO(new RxIo)
    addPath("./src/main/scala/lib/verilog/uart/uart_rx.v")
}

class UartRx extends  Module {
    val io = IO(new UartRxIo)
    val baudInstance = Module(new BaudRx)
    val rxInstance = Module(new Rx)

    rxInstance.io.clk := clock.asBool()
    rxInstance.io.rst_n := !reset.asAsyncReset().asBool()
    rxInstance.io.valid <> io.valid
    rxInstance.io.rx_data <> io.rx_data
    rxInstance.io.rs422_rx <> io.rs422_rx
    rxInstance.io.bps_clk<> baudInstance.io.bps_clk
    rxInstance.io.bps_en<> baudInstance.io.bps_en
    rxInstance.io.check<> io.check
    rxInstance.io.stop<> io.stop

    baudInstance.io.clk := clock.asBool()
    baudInstance.io.rst_n := !reset.asAsyncReset().asBool()



}

object UartRx extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new UartRx(), Array("--target-dir","generated"))
}