//=========================================================================
// File       : Shared_Pkg.sv
// Description: Global parameters and controls shared across FIFO testbench
//=========================================================================

package Shared_Pkg;

  parameter FIFO_WIDTH  = 16;
  parameter FIFO_DEPTH  = 8;
  localparam max_fifo_addr = $clog2(FIFO_DEPTH);

  bit test_finished = 0;

  int error_count = 0;
  int correct_count = 0;

  int RD_EN_ON_DIST = 30;
  int WR_EN_ON_DIST = 70;
  int rst_on        = 2;
  int rst_off       = 98;

endpackage
