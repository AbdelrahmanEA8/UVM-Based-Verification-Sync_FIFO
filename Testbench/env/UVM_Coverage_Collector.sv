//=========================================================================
// File       : fifo_coverage.sv
// Description: UVM coverage component for FIFO control signal transactions.
//              Collects functional coverage from fifo transactions via analysis export.
//=========================================================================

package coverage;
  import uvm_pkg::*;
  import Shared_Pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class fifo_coverage extends uvm_component;
    `uvm_component_utils(fifo_coverage)

    uvm_analysis_export #(my_seq_item) co_export;
    uvm_tlm_analysis_fifo #(my_seq_item) co_fifo;
    my_seq_item seq_item_co;

    covergroup cvr_grp;
        //////////////////////////// Control Signals ///////////////////////////
        rst_n_cp: coverpoint seq_item_co.rst_n {
            bins inactive = {1}; 
            bins active   = {0};
            bins inactive_active_trans = (1 => 0);
            bins active_inactive_trans = (0 => 1);
        }
        
        wr_en_cp: coverpoint seq_item_co.wr_en { bins high = {1}; bins low = {0}; }
        rd_en_cp: coverpoint seq_item_co.rd_en { bins high = {1}; bins low = {0}; }

        ////////////////////////// Status Indicators ///////////////////////////
        wr_ack_cp: coverpoint seq_item_co.wr_ack {
            bins high = {1}; bins low = {0};
            bins high_low_trans = (1 => 0);
            bins low_high_trans = (0 => 1);
        }

        full_cp:  coverpoint seq_item_co.full {
            bins high = {1}; bins low = {0};
            bins high_low_trans = (1 => 0);
            bins low_high_trans = (0 => 1);
        }

        empty_cp: coverpoint seq_item_co.empty {
            bins high = {1}; bins low = {0};
            bins high_low_trans = (1 => 0);
            bins low_high_trans = (0 => 1);
        }

        almostfull_cp:  coverpoint seq_item_co.almostfull {
            bins high = {1}; bins low = {0};
            bins high_low_trans = (1 => 0);
            bins low_high_trans = (0 => 1);
        }

        almostempty_cp: coverpoint seq_item_co.almostempty {
            bins high = {1}; bins low = {0};
            bins high_low_trans = (1 => 0);
            bins low_high_trans = (0 => 1);
        }

        ///////////////////////// Error Conditions ////////////////////////////
        overflow_cp: coverpoint seq_item_co.overflow {
            bins high = {1}; bins low = {0};
            bins high_low_trans = (1 => 0);
            bins low_high_trans = (0 => 1);
        }

        underflow_cp: coverpoint seq_item_co.underflow {
            bins high = {1}; bins low = {0};
            bins high_low_trans = (1 => 0);
            bins low_high_trans = (0 => 1);
        }

        ////////////////////////// Cross Coverage //////////////////////////////
        // Reset behavior verification
        rst_n_full:        cross rst_n_cp, full_cp {
            bins rst_n_full = binsof(rst_n_cp.active) && binsof(full_cp.low);
            option.cross_auto_bin_max = 0;
        }
        
        rst_n_empty:       cross rst_n_cp, empty_cp {
            bins rst_n_empty = binsof(rst_n_cp.active) && binsof(empty_cp.high);
            option.cross_auto_bin_max = 0;
        }

        // Write operation coverage
        wr_en_wr_ack_cross: cross wr_en_cp, wr_ack_cp {
            bins wr_en_wr_ack = binsof(wr_ack_cp.high) && binsof(wr_en_cp.high);
            option.cross_auto_bin_max = 0;
        }

        // Read operation coverage
        rd_en_empty_cross: cross rd_en_cp, empty_cp {
            bins empty_rd_en = binsof(empty_cp.high) && binsof(rd_en_cp.high);
            option.cross_auto_bin_max = 0;
        }

        // 3-way crosses with invalid combination filtering
        wr_rd_ack_cross: cross wr_en_cp, rd_en_cp, wr_ack_cp {
            ignore_bins wr_low_ack_high1 = binsof(wr_ack_cp.high) && binsof(wr_en_cp.low);
            ignore_bins wr_low_ack_high2 = binsof(wr_ack_cp.low_high_trans) && binsof(wr_en_cp.low);
        }

        wr_rd_overflow_cross: cross wr_en_cp, rd_en_cp, overflow_cp {
            ignore_bins wr_low_overflow_high1 = binsof(overflow_cp.high) && binsof(wr_en_cp.low);
            ignore_bins wr_low_overflow_high2 = binsof(overflow_cp.low_high_trans) && binsof(wr_en_cp.low);
        }
    endgroup

    function new(string name = "fifo_coverage", uvm_component parent = null);
      super.new(name, parent);
      cvr_grp = new();
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      co_export = new("co_export", this);
      co_fifo   = new("co_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      co_export.connect(co_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        co_fifo.get(seq_item_co);
        cvr_grp.sample();
      end
    endtask

  endclass
endpackage
