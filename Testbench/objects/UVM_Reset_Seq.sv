//=========================================================================
// File       : rst_seq_pkg.sv
// Description: Reset sequence driving reset transaction with no activity.
//=========================================================================

package rst_seq_Pkg;
  import uvm_pkg::*;
  import Shared_Pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class rst_seq extends uvm_sequence #(my_seq_item);
    `uvm_object_utils(rst_seq)

    my_seq_item rst_item;

    function new(string name = "rst_seq");
      super.new(name);
    endfunction

    virtual task body();
      rst_item = my_seq_item::type_id::create("rst_item");
      rst_item.constraint_mode(0);  // Disable constraints for reset transaction

      repeat(5) begin
        start_item(rst_item);
        rst_item.rst_n   = 0;
        rst_item.data_in = 0;
        rst_item.rd_en   = 0;
        rst_item.wr_en   = 0;
        finish_item(rst_item);
      end
    endtask
  endclass

endpackage
