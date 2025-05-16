//=========================================================================
// File       : read_only_sequence.sv
// Description: UVM sequence driving read-only transactions to FIFO
//              - Disables all constraints initially
//              - Enables reset-specific constraints
//              - Forces read enable, disables write enable
//=========================================================================

package read_only_sequence;

  import uvm_pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class read_only_seq extends uvm_sequence#(my_seq_item);
    `uvm_object_utils(read_only_seq)

    my_seq_item read_only_item;

    function new(string name = "read_only_seq");
      super.new(name);
    endfunction

    virtual task body();
      repeat (16) begin
        read_only_item = my_seq_item::type_id::create("read_only_item");

        // Disable all constraints, then enable reset-only constraints
        read_only_item.constraint_mode(0);
        read_only_item.rst_constraints.constraint_mode(1);

        start_item(read_only_item);
        assert(read_only_item.randomize());

        // Enable read only, disable write
        read_only_item.wr_en = 0;
        read_only_item.rd_en = 1;

        finish_item(read_only_item);
      end
    endtask

  endclass

endpackage
