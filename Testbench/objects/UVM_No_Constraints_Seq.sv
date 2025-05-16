//=========================================================================
// File       : no_constraints_sequence.sv
// Description: UVM sequence generating transactions with minimal constraints
//              - Disables all general constraints
//              - Enables reset-specific constraints
//              - Runs 10,000 randomized items
//=========================================================================

package no_constraints_sequence;

  import uvm_pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class no_constraints_seq extends uvm_sequence#(my_seq_item);
    `uvm_object_utils(no_constraints_seq)

    my_seq_item no_constraints_item;

    function new(string name = "no_constraints_seq");
      super.new(name);
    endfunction

    virtual task body();
      repeat (10_000) begin
        no_constraints_item = my_seq_item::type_id::create("no_constraints_item");

        start_item(no_constraints_item);

        // Disable all constraints, enable reset constraints only
        no_constraints_item.constraint_mode(0);
        no_constraints_item.rst_constraints.constraint_mode(1);

        assert(no_constraints_item.randomize());
        finish_item(no_constraints_item);
      end
    endtask

  endclass

endpackage
