//=========================================================================
// File       : config_obj.sv
// Description: UVM configuration object holding virtual interface handle.
//=========================================================================

package config_obj;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class fifo_config extends uvm_object;
    `uvm_object_utils(fifo_config)

    virtual fifo_if fifo_vif;

    function new(string name = "fifo_config");
      super.new(name);
    endfunction

  endclass

endpackage
