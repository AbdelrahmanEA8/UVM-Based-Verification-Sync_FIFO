//=========================================================================
// File       : write_only_sequence.sv
// Description: UVM sequence that drives write-only transactions to FIFO
//              - Disables default constraints
//              - Enables reset-specific constraints
//              - Forces write enable, disables read
//=========================================================================

package write_only_sequence;

  import uvm_pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class write_only_seq extends uvm_sequence#(my_seq_item);
    `uvm_object_utils(write_only_seq)

    my_seq_item write_only_item;

    function new(string name = "write_only_seq");
      super.new(name);
    endfunction

    virtual task body();
      repeat (16) begin
        write_only_item = my_seq_item::type_id::create("write_only_item");

        // Disable all constraints, then enable reset-only constraints
        write_only_item.constraint_mode(0);
        write_only_item.rst_constraints.constraint_mode(1);

        start_item(write_only_item);
        assert(write_only_item.randomize());
        
        // Force write-only behavior
        write_only_item.wr_en = 1;
        write_only_item.rd_en = 0;
        
        finish_item(write_only_item);
      end
    endtask

  endclass

endpackage

