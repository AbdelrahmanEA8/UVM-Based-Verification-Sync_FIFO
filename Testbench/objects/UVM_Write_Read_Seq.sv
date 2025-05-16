//=========================================================================
// File       : write_read_sequence.sv
// Description: UVM sequence that drives simultaneous write and read
//              - Disables all constraints
//              - Enables reset-specific constraints
//              - Asserts both wr_en and rd_en signals
//=========================================================================

package write_read_sequence;

  import uvm_pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class write_read_seq extends uvm_sequence#(my_seq_item);
    `uvm_object_utils(write_read_seq)

    my_seq_item write_read_item;

    function new(string name = "write_read_seq");
      super.new(name);
    endfunction

    virtual task body();
      repeat (5000) begin
        write_read_item = my_seq_item::type_id::create("write_read_item");

        // Disable all constraints, then enable reset-only constraints
        write_read_item.constraint_mode(0);
        write_read_item.rst_constraints.constraint_mode(1);

        start_item(write_read_item);
        assert(write_read_item.randomize());

        // Enable both read and write
        write_read_item.wr_en = 1;
        write_read_item.rd_en = 1;

        finish_item(write_read_item);
      end
    endtask

  endclass

endpackage
