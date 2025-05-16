//=========================================================================
// File       : monitor_pkg.sv
// Description: UVM monitor capturing FIFO interface signals and
//              forwarding transactions via analysis port.
//=========================================================================

package monitor_Pkg;
  import uvm_pkg::*;
  import Shared_Pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    virtual fifo_if fifo_vif;                    // Virtual interface handle
    my_seq_item rsp_my_seq_item;                  // Transaction object
    uvm_analysis_port #(my_seq_item) mon_ap;      // Analysis port

    function new(string name = "fifo_monitor", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon_ap = new("mon_ap", this);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        rsp_my_seq_item = my_seq_item::type_id::create("rsp_my_seq_item");
        // Sample on negative clock edge for stable signals
        @(posedge fifo_vif.clk);
            
          // Capture all DUT signals
          rsp_my_seq_item.rst_n       = fifo_vif.rst_n;
          rsp_my_seq_item.wr_en       = fifo_vif.wr_en;
          rsp_my_seq_item.rd_en       = fifo_vif.rd_en;
          rsp_my_seq_item.data_in     = fifo_vif.data_in;
            
        @(negedge fifo_vif.clk);
         
         rsp_my_seq_item.data_out      = fifo_vif.data_out;
         rsp_my_seq_item.wr_ack        = fifo_vif.wr_ack;
         rsp_my_seq_item.overflow      = fifo_vif.overflow;
         rsp_my_seq_item.underflow     = fifo_vif.underflow;
         rsp_my_seq_item.empty         = fifo_vif.empty;
         rsp_my_seq_item.almostempty   = fifo_vif.almostempty;
         rsp_my_seq_item.full          = fifo_vif.full;
         rsp_my_seq_item.almostfull    = fifo_vif.almostfull;

        mon_ap.write(rsp_my_seq_item);
        `uvm_info("run_phase", rsp_my_seq_item.convert2string(), UVM_HIGH)
      end
    endtask

  endclass
endpackage
