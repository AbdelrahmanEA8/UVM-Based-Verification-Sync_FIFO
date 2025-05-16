//=========================================================================
// File       : driver_pkg.sv
// Description: UVM driver driving FIFO stimulus from sequence items.
//=========================================================================

package driver_Pkg;
  import uvm_pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class fifo_driver extends uvm_driver #(my_seq_item);
    `uvm_component_utils(fifo_driver)

    virtual fifo_if fifo_vif;       // Virtual interface handle
    my_seq_item stim_seq_item;      // Current transaction

    function new(string name = "fifo_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        stim_seq_item = my_seq_item::type_id::create("stim_seq_item");
        seq_item_port.get_next_item(stim_seq_item);

        fifo_vif.rst_n  = stim_seq_item.rst_n;
        fifo_vif.data_in = stim_seq_item.data_in;
        fifo_vif.wr_en  = stim_seq_item.wr_en;
        fifo_vif.rd_en  = stim_seq_item.rd_en;

        @(negedge fifo_vif.clk);
        seq_item_port.item_done();

        `uvm_info("run_phase", stim_seq_item.convert2string_stimulus(), UVM_HIGH)
      end
    endtask
  endclass

endpackage
