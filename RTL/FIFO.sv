////////////////////////////////////////////////////////////////////////////////
// File Name    : FIFO.sv
// Author       : Abdelrahman Essam Fahmy
// Date         : 10/10/2024
// Version      : 1.0
// Description  : Synchronous FIFO (First-In-First-Out) memory buffer
//                - Configurable width and depth via parameters
//                - Standard FIFO signals: full, empty, almost full, almost empty
//                - Error flags: overflow, underflow
//                - Write acknowledge signal
//                - Assertion-based verification (when SIM defined)
// 
// Interface    : FIFO_interface (modport DUT used)
// Parameters   : Defined in Shared_Pkg:
//                - FIFO_WIDTH: Data width in bits
//                - FIFO_DEPTH: Number of entries in FIFO
//                - max_fifo_addr: ceil(log2(FIFO_DEPTH))
//
// Notes        : - Reset is active low
//                - Read and write operations are synchronous to rising clock edge
//                - Simultaneous read/write supported when not full/empty
////////////////////////////////////////////////////////////////////////////////

`define mk_assert(content) assert property (@(posedge FIFO_IF.clk) disable iff(!FIFO_IF.rst_n) (content));
`define mk_cover(content) cover property (@(posedge FIFO_IF.clk) disable iff(!FIFO_IF.rst_n) (content));
`define mk_rst_assert(content) assert final (content);
`define mk_rst_cover(content) cover final (content);

module FIFO(fifo_if.DUT FIFO_IF);
import Shared_Pkg::*;


// FIFO memory array
reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

// FIFO control pointers and counters
reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;  // Pointers for write and read locations
reg [max_fifo_addr:0] count;             // Tracks number of occupied entries

//=============================================================================
// Write Pointer and Overflow Control Logic
//=============================================================================
always @(posedge FIFO_IF.clk or negedge FIFO_IF.rst_n) begin
    if (!FIFO_IF.rst_n) begin
        // Reset conditions
        wr_ptr           <= 0;
        FIFO_IF.overflow <= 0;
        FIFO_IF.wr_ack   <= 0;
    end
    else if (FIFO_IF.wr_en && count < FIFO_DEPTH) begin
        // Normal write operation when FIFO not full
        mem[wr_ptr]     <= FIFO_IF.data_in;
        FIFO_IF.wr_ack   <= 1;
        wr_ptr          <= wr_ptr + 1;
        FIFO_IF.overflow <= 0;
    end
    else begin
        // Handle write attempts when FIFO is full
        FIFO_IF.wr_ack <= 0;
        if (FIFO_IF.full && FIFO_IF.wr_en)
            FIFO_IF.overflow <= 1;
        else
            FIFO_IF.overflow <= 0;
    end
end

//=============================================================================
// Read Pointer and Underflow Control Logic
//=============================================================================
always @(posedge FIFO_IF.clk or negedge FIFO_IF.rst_n) begin
    if (!FIFO_IF.rst_n) begin
        // Reset conditions
        rd_ptr            <= 0;
        FIFO_IF.underflow <= 0;
        FIFO_IF.data_out  <= 0;
    end
    else if (FIFO_IF.rd_en && !FIFO_IF.empty) begin
        // Normal read operation when FIFO not empty
        FIFO_IF.data_out <= mem[rd_ptr];
        rd_ptr          <= rd_ptr + 1;
        FIFO_IF.underflow <= 0;
    end
    else begin
        // Handle read attempts when FIFO is empty
        if (FIFO_IF.empty && FIFO_IF.rd_en)
            FIFO_IF.underflow <= 1;
        else
            FIFO_IF.underflow <= 0;
    end
end

//=============================================================================
// FIFO Occupancy Counter Logic
//=============================================================================
always @(posedge FIFO_IF.clk or negedge FIFO_IF.rst_n) begin
    if (!FIFO_IF.rst_n) begin
        count <= 0;
    end
    else begin
        case ({FIFO_IF.wr_en, FIFO_IF.rd_en})
            2'b10: if (!FIFO_IF.full)  count <= count + 1;  // Write only
            2'b01: if (!FIFO_IF.empty) count <= count - 1;  // Read only
            2'b11: begin                                   // Simultaneous read/write
                if (FIFO_IF.empty)     count <= count + 1;
                else if (FIFO_IF.full)  count <= count - 1;
            end
            default: ; // No operation
        endcase
    end
end

//=============================================================================
// FIFO Status Flags
//=============================================================================
assign FIFO_IF.full        = (count == FIFO_DEPTH) ? 1 : 0; 
assign FIFO_IF.empty       = (count == 0) ? 1 : 0;
assign FIFO_IF.almostfull  = (count == FIFO_DEPTH-1) ? 1 : 0;
assign FIFO_IF.almostempty = (count == 1) ? 1 : 0;

//=============================================================================
// Assertion-Based Verification (Active when SIM is defined)
//=============================================================================
`ifdef SIM
//-------------------------------------------------------------------------
// Write Operation Sequences
//-------------------------------------------------------------------------
sequence wr_full_seq1;      // overflow on && wr_ack off
    (FIFO_IF.wr_en && FIFO_IF.full);
endsequence

sequence wr_full_seq0;      // overflow off && wr_ack on
    (FIFO_IF.wr_en && !FIFO_IF.full);
endsequence

sequence wr_empty_seq1;     // almostempty on
    (FIFO_IF.wr_en && FIFO_IF.empty && !FIFO_IF.rd_en);
endsequence

sequence wr_empty_seq0;     // almostempty off
    (FIFO_IF.wr_en && FIFO_IF.almostempty && !FIFO_IF.rd_en);
endsequence

sequence wr_almostfull_seq1; // full on
    (FIFO_IF.wr_en && FIFO_IF.almostfull && !FIFO_IF.rd_en);
endsequence

sequence wr_almostfull_seq0; // full off
    (FIFO_IF.wr_en && !FIFO_IF.almostfull && !FIFO_IF.full);
endsequence

//-------------------------------------------------------------------------
// Read Operation Sequences
//-------------------------------------------------------------------------
sequence rd_full_seq1;      // almostfull on
    (FIFO_IF.rd_en && FIFO_IF.full && !FIFO_IF.wr_en);
endsequence

sequence rd_full_seq0;      // almostfull off
    (FIFO_IF.rd_en && FIFO_IF.almostfull && !FIFO_IF.wr_en);
endsequence

sequence rd_empty_seq1;     // underflow on
    (FIFO_IF.rd_en && FIFO_IF.empty);
endsequence

sequence rd_empty_seq0;     // underflow off
    (FIFO_IF.rd_en && !FIFO_IF.empty);
endsequence

sequence rd_almostempty_seq1; // empty on
    (FIFO_IF.rd_en && FIFO_IF.almostempty && !FIFO_IF.wr_en);
endsequence

sequence rd_almostempty_seq0; // empty off
    (FIFO_IF.rd_en && !FIFO_IF.almostempty && !FIFO_IF.empty && !FIFO_IF.wr_en);
endsequence

//-------------------------------------------------------------------------
// Combined Read/Write Sequences
//-------------------------------------------------------------------------
sequence wr_rd_seq;         // Normal simultaneous read/write
    (FIFO_IF.wr_en && FIFO_IF.rd_en && !FIFO_IF.full && !FIFO_IF.empty);
endsequence

sequence not_wr_rd_seq;     // Read from full FIFO
    (FIFO_IF.wr_en && FIFO_IF.rd_en && FIFO_IF.full && !FIFO_IF.empty);
endsequence

sequence wr_not_rd_seq;     // Write to empty FIFO
    (FIFO_IF.wr_en && FIFO_IF.rd_en && !FIFO_IF.full && FIFO_IF.empty);
endsequence

//-------------------------------------------------------------------------
// Internal Signals Sequences
//-------------------------------------------------------------------------
sequence inc_count;         // Counter increment
    (FIFO_IF.wr_en && !FIFO_IF.rd_en && count!=FIFO_DEPTH);
endsequence

sequence dec_count;         // Counter decrement
    (FIFO_IF.rd_en && !FIFO_IF.wr_en && count!=0);
endsequence

sequence stable_count;      // Counter stable (simultaneous R/W)
    (FIFO_IF.wr_en && FIFO_IF.rd_en && count!=FIFO_DEPTH && count!=0);
endsequence

sequence max_count;         // Counter at maximum
    (FIFO_IF.wr_en && !FIFO_IF.rd_en && count==FIFO_DEPTH);
endsequence

sequence zero_count;        // Counter at zero
    (!FIFO_IF.wr_en && FIFO_IF.rd_en && count==0);
endsequence

sequence inc_wr_ptr;        // Write pointer increment
    (FIFO_IF.wr_en && !FIFO_IF.full && !FIFO_IF.rd_en);
endsequence

sequence inc_rd_ptr;        // Read pointer increment
    (FIFO_IF.rd_en && !FIFO_IF.empty && !FIFO_IF.wr_en);
endsequence

//-------------------------------------------------------------------------
// Reset Assertions
//-------------------------------------------------------------------------
always_comb begin
    if(!FIFO_IF.rst_n)begin
        wr_ack_rst_asrt       : `mk_rst_assert(FIFO_IF.wr_ack==0)
        overflow_rst_asrt     : `mk_rst_assert(FIFO_IF.overflow==0)
        underflow_rst_asrt    : `mk_rst_assert(FIFO_IF.underflow==0)
        full_rst_asrt         : `mk_rst_assert(FIFO_IF.full==0)
        almostfull_rst_asrt   : `mk_rst_assert(FIFO_IF.almostfull==0)
        empty_rst_asrt        : `mk_rst_assert(FIFO_IF.empty==1)
        almostempty_rst_asrt  : `mk_rst_assert(FIFO_IF.almostempty==0)
        count_rst_asrt       : `mk_rst_assert(count==0)
        wr_ptr_rst_asrt      : `mk_rst_assert(wr_ptr==0)
        rd_ptr_rst_asrt      : `mk_rst_assert(rd_ptr==0)
    end
end

//-------------------------------------------------------------------------
// Operational Assertions
//-------------------------------------------------------------------------
overflow_on_asrt       : `mk_assert(wr_full_seq1  |=> FIFO_IF.overflow==1 && FIFO_IF.wr_ack==0)
overflow_off_asrt      : `mk_assert(wr_full_seq0 |=> FIFO_IF.overflow==0 && FIFO_IF.wr_ack==1)
almostempty_on_asrt    : `mk_assert(wr_empty_seq1 |=> FIFO_IF.almostempty)
almostempty_off_asrt   : `mk_assert(wr_empty_seq0 |=> !FIFO_IF.almostempty)
underflow_on_asrt      : `mk_assert(rd_empty_seq1 |=> FIFO_IF.underflow==1)
underflow_off_asrt     : `mk_assert(rd_empty_seq0 |=> FIFO_IF.underflow==0)
full_on_asrt           : `mk_assert(wr_almostfull_seq1 |=> FIFO_IF.full)
full_off_asrt          : `mk_assert(wr_almostfull_seq0 |=> !FIFO_IF.full)
almostfull_on_asrt     : `mk_assert(rd_full_seq1 |=> FIFO_IF.almostfull)
almostfull_off_asrt    : `mk_assert(rd_full_seq0 |=> !FIFO_IF.almostfull)
empty_on_asrt          : `mk_assert(rd_almostempty_seq1 |=> FIFO_IF.empty)
empty_off_asrt         : `mk_assert(rd_almostempty_seq0 |=> !FIFO_IF.empty)

// Internal signals assertions
inc_count_asrt         : `mk_assert(inc_count |=> count==$past(count)+1)
dec_count_asrt         : `mk_assert(dec_count |=> count==$past(count)-1)
stable_count_asrt      : `mk_assert(stable_count |=> count==$past(count))
zero_count_asrt        : `mk_assert(zero_count |=> count==0)
max_count_count_asrt   : `mk_assert(max_count |=> count==FIFO_DEPTH)
inc_wr_ptr_asrt        : `mk_assert(inc_wr_ptr |=> wr_ptr==$past(wr_ptr)+1)
inc_rd_ptr_asrt        : `mk_assert(inc_rd_ptr |=> rd_ptr==$past(rd_ptr)+1)

//-------------------------------------------------------------------------
// Coverage Points
//-------------------------------------------------------------------------
always_comb begin
    if(!FIFO_IF.rst_n)begin
        wr_ack_rst_cvr       : `mk_rst_cover(FIFO_IF.wr_ack==0)
        overflow_rst_cvr     : `mk_rst_cover(FIFO_IF.overflow==0)
        underflow_rst_cvr    : `mk_rst_cover(FIFO_IF.underflow==0)
        full_rst_cvr         : `mk_rst_cover(FIFO_IF.full==0)
        almostfull_rst_cvr   : `mk_rst_cover(FIFO_IF.almostfull==0)
        empty_rst_cvr        : `mk_rst_cover(FIFO_IF.empty==1)
        almostempty_rst_cvr  : `mk_rst_cover(FIFO_IF.almostempty==0)
        count_rst_cvr        : `mk_rst_cover(count==0)
        wr_ptr_rst_cvr       : `mk_rst_cover(wr_ptr==0)
        rd_ptr_rst_cvr       : `mk_rst_cover(rd_ptr==0)
    end
end

overflow_on_cvr       : `mk_cover(wr_full_seq1  |=> FIFO_IF.overflow==1 && FIFO_IF.wr_ack==0)
overflow_off_cvr      : `mk_cover(wr_full_seq0 |=> FIFO_IF.overflow==0 && FIFO_IF.wr_ack==1)
almostempty_on_cvr    : `mk_cover(wr_empty_seq1 |=> FIFO_IF.almostempty)
almostempty_off_cvr   : `mk_cover(wr_empty_seq0 |=> !FIFO_IF.almostempty)
underflow_on_cvr      : `mk_cover(rd_empty_seq1 |=> FIFO_IF.underflow==1)
underflow_off_cvr     : `mk_cover(rd_empty_seq0 |=> FIFO_IF.underflow==0)
full_on_cvr           : `mk_cover(wr_almostfull_seq1 |=> FIFO_IF.full)
full_off_cvr          : `mk_cover(wr_almostfull_seq0 |=> !FIFO_IF.full)
almostfull_on_cvr     : `mk_cover(rd_full_seq1 |=> FIFO_IF.almostfull)
almostfull_off_cvr    : `mk_cover(rd_full_seq0 |=> !FIFO_IF.almostfull)
empty_on_cvr          : `mk_cover(rd_almostempty_seq1 |=> FIFO_IF.empty)
empty_off_cvr         : `mk_cover(rd_almostempty_seq0 |=> !FIFO_IF.empty)

// Internal signals coverage
inc_count_cvr         : `mk_cover(inc_count |=> count==$past(count)+1)
dec_count_cvr         : `mk_cover(dec_count |=> count==$past(count)-1)
stable_count_cvr      : `mk_cover(stable_count |=> count==$past(count))
zero_count_cvr        : `mk_cover(zero_count |=> count==0)
max_count_count_cvr   : `mk_cover(max_count |=> count==FIFO_DEPTH)
inc_wr_ptr_cvr        : `mk_cover(inc_wr_ptr |=> wr_ptr==$past(wr_ptr)+1)
inc_rd_ptr_cvr        : `mk_cover(inc_rd_ptr |=> rd_ptr==$past(rd_ptr)+1)

`endif // SIM
endmodule