////////////////////////////////////////////////////////////////////////////////
// Interface   : FIFO_interface
// Description : Main communication bus for FIFO verification
// Features    :
//   - Standard FIFO control signals (full/empty/almost flags)
//   - Golden model reference outputs
//   - Dedicated modports for DUT, TB, and Monitor
// Configuration: Uses FIFO_WIDTH from Shared_Pkg
////////////////////////////////////////////////////////////////////////////////

interface fifo_if(input clk);
import Shared_Pkg::*;

    //------------------------- Design Signals --------------------------------
    logic [FIFO_WIDTH-1:0] data_in;   // Write data port
    logic rst_n;                      // Active-low asynchronous reset
    logic wr_en, rd_en;               // Control signals
    
    logic [FIFO_WIDTH-1:0] data_out;  // Read data port
    logic wr_ack;                     // Write success indicator
    logic overflow, underflow;        // Error conditions
    logic full, empty;                // Capacity status
    logic almostfull, almostempty;    // Early warning indicators

    //------------------------- Golden Model Signals --------------------------
    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref, underflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref;

    //------------------------- Modport Definitions ---------------------------
    modport DUT (
        input  clk, rst_n, wr_en, rd_en, data_in,
        output data_out, wr_ack, overflow, full, empty,
               almostfull, almostempty, underflow
    );

    modport GM (
        input  clk, rst_n, wr_en, rd_en, data_in,
        output data_out_ref, wr_ack_ref, overflow_ref, full_ref, empty_ref,
               almostfull_ref, almostempty_ref, underflow_ref
    );

endinterface