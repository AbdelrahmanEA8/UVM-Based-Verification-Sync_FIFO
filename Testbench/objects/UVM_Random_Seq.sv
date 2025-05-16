//=========================================================================
// File       : randomized_sequence.sv
// Description: UVM sequence generating fully randomized transactions
//              - No constraints are explicitly modified here
//              - Runs 10,000 randomized items
//=========================================================================

package randomized_sequence;

  import uvm_pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class randomized_seq extends uvm_sequence#(my_seq_item);
    `uvm_object_utils(randomized_seq)

    my_seq_item randomized_item;

    function new(string name = "randomized_seq");
      super.new(name);
    endfunction

    virtual task body();
      repeat (10_000) begin
        randomized_item = my_seq_item::type_id::create("randomized_item");

        start_item(randomized_item);
        assert(randomized_item.randomize());
        finish_item(randomized_item);
      end
    endtask

  endclass

endpackage
