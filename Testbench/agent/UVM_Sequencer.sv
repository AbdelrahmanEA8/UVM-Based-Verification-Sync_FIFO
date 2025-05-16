//=========================================================================
// File       : sqr_pkg.sv
// Description: UVM sequencer class for my_seq_item transactions.
//=========================================================================

package sqr_Pkg;
  import uvm_pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class my_sequencer extends uvm_sequencer#(my_seq_item);
    `uvm_component_utils(my_sequencer)

    function new(string name = "my_sequencer", uvm_component parent = null);
      super.new(name, parent);
    endfunction
  endclass  

endpackage
