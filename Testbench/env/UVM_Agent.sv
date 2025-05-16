//=========================================================================
// File       : fifo_agent.sv
// Description: UVM agent integrating driver, sequencer, and monitor for FIFO.
//=========================================================================

package agent_Pkg;
  import uvm_pkg::*;
  import seq_item_Pkg::*;
  import sqr_Pkg::*;
  import driver_Pkg::*;
  import monitor_Pkg::*;
  import config_obj::*;
  `include "uvm_macros.svh"

  class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)

    fifo_driver      driver;
    my_sequencer     sqr;
    fifo_config      CFG;
    fifo_monitor     monitor;

    uvm_analysis_port #(my_seq_item) agt_ap;

    function new(string name = "fifo_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db #(fifo_config)::get(this, "", "CFG", CFG)) begin
        `uvm_fatal("build_phase", "Unable to get FIFO config from uvm_config_db")
      end
      sqr     = my_sequencer::type_id::create("sqr", this);
      driver  = fifo_driver::type_id::create("driver", this);
      monitor = fifo_monitor::type_id::create("monitor", this);
      agt_ap  = new("agt_ap", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      driver.fifo_vif  = CFG.fifo_vif;
      monitor.fifo_vif = CFG.fifo_vif;
      driver.seq_item_port.connect(sqr.seq_item_export);
      monitor.mon_ap.connect(agt_ap);
    endfunction

  endclass

endpackage
