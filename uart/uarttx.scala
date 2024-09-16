package lib.uart
import chisel3._
import chisel3.util._

class UartTxIo extends Bundle {
    val valid = Input(Bool())
    val tx_data = Input(UInt(8.W))
    val ready = Output(Bool())
    val rs422_tx = Output(Bool())
}

class BaudTxIo extends Bundle{
    val clk = Input(Bool())
    val rst_n = Input(Bool())
    val bps_en = Input(Bool())
    val bps_clk = Output(Bool())
}

class TxIo extends Bundle{
    val clk = Input(Bool())
    val rst_n = Input(Bool())
    val valid = Input(Bool())
    val tx_data = Input(UInt(8.W))
    val ready = Output(Bool())
    val rs422_tx = Output(Bool())
    val bps_en = Output(Bool())
    val bps_clk = Input(Bool())
}

class BaudTx extends HasBlackBoxPath {
    val io = IO(new BaudTxIo)
    addPath("./src/main/scala/lib/verilog/uart/baud_tx.v")
}

class Tx extends HasBlackBoxPath {
    val io = IO(new TxIo)
    addPath("./src/main/scala/lib/verilog/uart/uart_tx.v")
}

class UartTx extends  Module {
    val io = IO(new UartTxIo)
    val baudInstance = Module(new BaudTx)
    val txInstance = Module(new Tx)

    txInstance.io.clk := clock.asBool()
    txInstance.io.rst_n := !reset.asAsyncReset().asBool()
    txInstance.io.valid := io.valid
    txInstance.io.tx_data := io.tx_data
    txInstance.io.ready <> io.ready
    txInstance.io.rs422_tx <> io.rs422_tx
    txInstance.io.bps_clk<> baudInstance.io.bps_clk
    txInstance.io.bps_en<> baudInstance.io.bps_en

    baudInstance.io.clk := clock.asBool()
    baudInstance.io.rst_n := !reset.asAsyncReset().asBool()



}

object UartTx extends App {
  (new chisel3.stage.ChiselStage).emitVerilog(new UartTx(), Array("--target-dir","generated"))
}