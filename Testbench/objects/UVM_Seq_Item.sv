//=========================================================================
// File       : seq_item_Pkg.sv
// Description: UVM sequence item defining FIFO stimulus and reference signals
//              with configurable constraint probabilities.
//=========================================================================

package seq_item_Pkg;

  import uvm_pkg::*;
  import Shared_Pkg::*;
  `include "uvm_macros.svh"

  class my_seq_item extends uvm_sequence_item;
    `uvm_object_utils(my_seq_item)

    // Stimulus signals
    rand logic [FIFO_WIDTH-1:0] data_in;
    rand logic rst_n;
    rand logic wr_en;
    rand logic rd_en;

    // DUT response signals
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack;
    logic overflow, underflow;
    logic full, empty;
    logic almostfull, almostempty;

    // Reference model signals
    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

    // Constraints on signal probabilities
    constraint rst_constraints {
      rst_n dist {1'b0 := rst_on, 1'b1 := rst_off};
    }
    constraint wr_constraints {
      wr_en dist {1'b1 := WR_EN_ON_DIST, 1'b0 := (100 - WR_EN_ON_DIST)};
    }
    constraint rd_constraints {
      rd_en dist {1'b1 := RD_EN_ON_DIST, 1'b0 := (100 - RD_EN_ON_DIST)};
    }

    // Constructor: sets enable probabilities for read and write signals
    function new(integer RD_EN_ON_DIST_1 = 30, WR_EN_ON_DIST_1 = 70);
      RD_EN_ON_DIST = RD_EN_ON_DIST_1;
      WR_EN_ON_DIST = WR_EN_ON_DIST_1;
    endfunction

    // String representation including all signals
    function string convert2string();
      return $sformatf("%s rst_n=%0b, data_in=%0b, wr_en=%0b, rd_en=%0b, data_out=%0b, wr_ack=%0b, overflow=%0b, underflow=%0b, empty=%0b, almostempty=%0b, full=%0b, almostfull=%0b",
                      super.convert2string(), rst_n, data_in, wr_en, rd_en, data_out, wr_ack, overflow, underflow, empty, almostempty, full, almostfull);
    endfunction

    // String representation for stimulus signals only
    function string convert2string_stimulus();
      return $sformatf("rst_n=%0b, data_in=%0b, wr_en=%0b, rd_en=%0b",
                      rst_n, data_in, wr_en, rd_en);
    endfunction

  endclass

endpackage
