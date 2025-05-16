//=========================================================================
// File       : fifo_test_pkg.sv
// Description: UVM test package for FIFO verification
//              - Contains main test class (fifo_test)
//              - Sequences are constructed and run in order
//              - Provides test config and drives reset/data sequences
//=========================================================================

package fifo_test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import config_obj::*;
  import fifo_env_pkg::*;
  import rst_seq_Pkg::*;
  import write_only_sequence::*;
  import read_only_sequence::*;
  import write_read_sequence::*;
  import rondomized_sequence::*;
  import no_constraints_sequence::*;

  class fifo_test extends uvm_test;
    `uvm_component_utils(fifo_test)

    fifo_env             env;
    virtual fifo_if      fifo_vif;
    fifo_config          fifo_cfg;

    rst_seq              rst_seq_test;
    write_only_seq       write_only_seq_test;
    read_only_seq        read_only_seq_test;
    write_read_seq       write_read_seq_test;
    randomized_seq       randomized_seq_test;
    no_constraints_seq   no_constraints_seq_test;

    function new(string name = "fifo_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      env                   = fifo_env::type_id::create("env", this);
      fifo_cfg              = fifo_config::type_id::create("fifo_cfg");
      rst_seq_test          = rst_seq::type_id::create("rst_seq_test");
      write_only_seq_test   = write_only_seq::type_id::create("write_only_seq_test");
      read_only_seq_test    = read_only_seq::type_id::create("read_only_seq_test");
      write_read_seq_test   = write_read_seq::type_id::create("write_read_seq_test");
      randomized_seq_test   = randomized_seq::type_id::create("randomized_seq_test");
      no_constraints_seq_test = no_constraints_seq::type_id::create("no_constraints_seq_test");

      if (!uvm_config_db#(virtual fifo_if)::get(this, "", "fifo_if", fifo_cfg.fifo_vif))
        `uvm_fatal("build_phase", "Test - Unable to get the virtual interface from uvm_config_db")

      uvm_config_db#(fifo_config)::set(this, "*", "CFG", fifo_cfg);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);

      `uvm_info("run_phase", "Reset sequence", UVM_LOW)
      rst_seq_test.start(env.agt.sqr);

      `uvm_info("run_phase", "Write-only sequence", UVM_LOW)
      write_only_seq_test.start(env.agt.sqr);

      `uvm_info("run_phase", "Read-only sequence", UVM_LOW)
      read_only_seq_test.start(env.agt.sqr);

      `uvm_info("run_phase", "Reset sequence again", UVM_LOW)
      rst_seq_test.start(env.agt.sqr);

      `uvm_info("run_phase", "Write-Read sequence", UVM_LOW)
      write_read_seq_test.start(env.agt.sqr);

      `uvm_info("run_phase", "Randomized sequence", UVM_LOW)
      randomized_seq_test.start(env.agt.sqr);

      `uvm_info("run_phase", "No-constraints sequence", UVM_LOW)
      no_constraints_seq_test.start(env.agt.sqr);

      phase.drop_objection(this);
    endtask : run_phase

  endclass

endpackage
