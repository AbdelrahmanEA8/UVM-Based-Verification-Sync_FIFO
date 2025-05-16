//=========================================================================
// File       : fifo_scoreboard.sv
// Description: UVM scoreboard for FIFO output verification.
//              Compares DUT outputs against reference model outputs.
//=========================================================================

package scoreboard_Pkg;
  import uvm_pkg::*;
  import Shared_Pkg::*;
  import seq_item_Pkg::*;
  `include "uvm_macros.svh"

  class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_export #(my_seq_item) sb_export;
    uvm_tlm_analysis_fifo   #(my_seq_item) sb_fifo;
    my_seq_item seq_item_sb;

    // Reference outputs for comparison
    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

    // FIFO memory (Stack)
    logic [FIFO_WIDTH-1:0] MyFifo [$];

    // int correct_count = 0;
    // int error_count = 0;

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_export = new("sb_export", this);
      sb_fifo   = new("sb_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        sb_fifo.get(seq_item_sb);
        reference_model(seq_item_sb);

        if (seq_item_sb.data_out    == data_out_ref &&
            seq_item_sb.wr_ack      == wr_ack_ref &&
            seq_item_sb.overflow    == overflow_ref &&
            seq_item_sb.underflow   == underflow_ref &&
            seq_item_sb.empty       == empty_ref &&
            seq_item_sb.almostempty == almostempty_ref &&
            seq_item_sb.full        == full_ref &&
            seq_item_sb.almostfull  == almostfull_ref) 
        begin
          `uvm_info("run_phase", $sformatf("Correct output: %s", seq_item_sb.convert2string()), UVM_HIGH)
          correct_count++;
        end else begin
          `uvm_info("run_phase", $sformatf("Mismatch detected. Received: %s, Reference: %b", seq_item_sb.convert2string(), data_out_ref), UVM_MEDIUM)
          error_count++;
        end
      end
    endtask

    // golden model reference values
    task reference_model(my_seq_item seq_item_sb);
        if (!seq_item_sb.rst_n) begin
            MyFifo.delete();
            data_out_ref = 0;
            overflow_ref = 0; wr_ack_ref = 0;
            full_ref = 0; empty_ref = 1;
            almostfull_ref = 0; almostempty_ref = 0;
            underflow_ref = 0;
        end
        else begin
        // Write operation
            if (seq_item_sb.wr_en && !full_ref) begin
                MyFifo.push_back(seq_item_sb.data_in);
                wr_ack_ref = 1;
                overflow_ref = 0;
            end
            else begin
                wr_ack_ref = 0;
                if(full_ref && seq_item_sb.wr_en)
                    overflow_ref = 1;
                else
                    overflow_ref = 0;
            end
        // Read operation
            if (seq_item_sb.rd_en && !empty_ref) begin
                data_out_ref = MyFifo.pop_front();
                underflow_ref = 0;
            end
            else begin
                if(empty_ref && seq_item_sb.rd_en)
                    underflow_ref = 1;
                else
                    underflow_ref = 0;
            end
        end 
    
        full_ref = (MyFifo.size() == FIFO_DEPTH)? 1 : 0;  
        empty_ref = (MyFifo.size() == 0)? 1 : 0; 
        almostfull_ref = (MyFifo.size() == FIFO_DEPTH-1)? 1 : 0;
        almostempty_ref = (MyFifo.size() == 1)? 1 : 0; 

    endtask

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("report_phase", $sformatf("Total correct transactions: %0d", correct_count), UVM_MEDIUM)
      `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM)
    endfunction

  endclass
endpackage
