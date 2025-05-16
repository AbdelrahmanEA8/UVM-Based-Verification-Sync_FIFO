//====================================================================
// File       : TOP.sv
// Description: UVM testbench top module for FIFO verification
//              Instantiates DUT, reference model, interface, and SVA
//====================================================================

module TOP;

  import uvm_pkg::*;
  import fifo_test_pkg::*;
  import fifo_env_pkg::*;
  `include "uvm_macros.svh"

  bit clk;
  initial forever #1 clk = ~clk;

  fifo_if fifoif(clk);

  FIFO     DUT(fifoif);    // Design Under Test
  FIFO_GM  GM(fifoif);     // Golden Reference Model

  // Bind formal assertions to DUT
//   bind FIFO FIFO_SVA FIFO_SVA_inst (
//     fifoif.clk, fifoif.rst_n, fifoif.data_in, fifoif.wr_en, fifoif.rd_en,
//     fifoif.data_out, fifoif.wr_ack, fifoif.overflow, fifoif.underflow,
//     fifoif.empty, fifoif.almostempty, fifoif.full, fifoif.almostfull
//   );

  initial begin
    // Provide virtual interface to UVM test
    uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top", "fifo_if", fifoif);
    run_test("fifo_test");
  end

endmodule
