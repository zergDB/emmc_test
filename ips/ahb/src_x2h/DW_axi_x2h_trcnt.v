// ---------------------------------------------------------------------
//
//  ------------------------------------------------------------------------
//
//                    (C) COPYRIGHT 2005 - 2014 SYNOPSYS, INC.
//                            ALL RIGHTS RESERVED
//
//  This software and the associated documentation are confidential and
//  proprietary to Synopsys, Inc.  Your use or disclosure of this
//  software is subject to the terms and conditions of a written
//  license agreement between you, or your company, and Synopsys, Inc.
//
// The entire notice above must be reproduced on all authorized copies.
//
//  ------------------------------------------------------------------------

// 
// Release version :  2.01a
// File Version     :        $Revision: #5 $ 
// Revision: $Id: //dwh/DW_ocb/DW_axi_x2h/amba_dev/src/DW_axi_x2h_trcnt.v#5 $ 
//
// ---------------------------------------------------------------------
//
// AUTHOR:    Jorge Duarte      6/29/2010
//
// VERSION:   DW_axi_x2h_trcnt Verilog Synthesis Model
//
//
// ---------------------------------------------------------------------
// ---------------------------------------------------------------------
//
// ABSTRACT:  Transaction counter
//
// The spec for low power operation calls for the device to remain 
// powered up while there are pending transactions. This block keeps 
// track of pending read and write transactions and informs the low 
// power state machine of whether or not there are any pending 
// transactions.
// Two counters are implemented, one for keeping track of the pending
// write transactions and another for keeping track of the pending read
// transactions.
//
// The beginning of a write transaction is detected by sampling awvalid
// and awready high simultaneoulsy, and the completion of a write 
// transaction is detected by sampling bvalid and bready high 
// simultaneously.
// Whenever a write transaction is initiated the value of the 
// corresponding counter is incremented; conversely, whenever a write 
// transaction is completed the counter is decremented. It is possible
// for a write transaction to be completed at the exact same time a new
// one is initiated; whenever this happens the value of the counter
// remains unchanged.
//
// The beginning of a read transaction is detected by sampling arvalid 
// and arready high simultaneoulsy, and the completion of a read 
// transaction is detected by sampling rvalid, rlast and rready high 
// simultaneously.
// Whenever a read transaction is initiated the value of the 
// corresponding counter is incremented; conversely, whenever a read 
// transaction is completed the counter is decremented. It is possible
// for a read transaction to be completed at the exact same time a new
// one is initiated; whenever this happens the value of the counter
// remains unchanged.
//
// Because it is only necessary to know whether there are any pending
// transactions and no information is required about the status of each
// individual transaction, the active_trans output is generated by 
// evaluating the value of the pending transactions counters; if its 
// value is different from 0, active_trans will be high.
// awvalid and arvalid are also used to generate active_trans; this is
// done in order to support the combinational assertion of cactive by
// these signals (awvalid and arvalid) when in low power mode (clock
// disabled).
//
// Finally, in order to prevent the number of pending transactions to
// exceed the specified limit, the count values are also used to
// generate two 'hold' signals (hold_write_trans and hold_rread_trans)
// intended to be used externally for gating the awready and arready
// signals and for preventing any new command originating from the AXI
// bus to be pushed into the corresponding FIFO
//
// ---------------------------------------------------------------------
`include "DW_axi_x2h_cc_constants.v"
module DW_axi_x2h_trcnt(
  // Outputs
  active_trans,
  hold_write_trans,
  hold_read_trans,
  // Inputs
  aclk, aresetn,
  awvalid, awready, 
  bvalid, bready, 
  arvalid, arready,
  rvalid, rlast, rready 
  );

parameter [`X2H_CNT_PENDTRANS_READ_W-1:0] MAX_PENDTRANS_READ    = 4;
parameter [`X2H_CNT_PENDTRANS_WRITE_W-1:0] MAX_PENDTRANS_WRITE   = 4;
parameter CNT_PENDTRANS_READ_W  = 3;
parameter CNT_PENDTRANS_WRITE_W = 3;

output active_trans;
output hold_write_trans;
output hold_read_trans;
// AXI INTERFACE
// Global
input  aclk;
input  aresetn;
// Write address channel
input  awvalid;
input  awready;
// Write response channel
input  bvalid;
input  bready;
// Read address channel
input  arvalid;
input  arready;
// Read data channel
input  rlast;
input  rvalid;
input  rready;

reg  [CNT_PENDTRANS_READ_W-1:0]  read_pend_trans_cnt;
wire [CNT_PENDTRANS_READ_W-1:0]  read_pend_trans_cnt_c;
reg  [CNT_PENDTRANS_WRITE_W-1:0] write_pend_trans_cnt;
wire [CNT_PENDTRANS_WRITE_W-1:0] write_pend_trans_cnt_c;

wire       init_write_trans;
wire       init_read_trans;
wire       compl_write_trans;
wire       compl_read_trans;

wire       active_trans;
wire       hold_write_trans;
wire       hold_read_trans;


assign init_write_trans  = awvalid && awready; 
assign init_read_trans   = arvalid && arready;
assign compl_write_trans = bvalid && bready;
assign compl_read_trans  = rvalid && rlast && rready;

assign hold_read_trans  = (read_pend_trans_cnt  >= MAX_PENDTRANS_READ);
assign hold_write_trans = (write_pend_trans_cnt >= MAX_PENDTRANS_WRITE);

assign active_trans     = ( read_pend_trans_cnt > 0 ) ||
                          ( write_pend_trans_cnt > 0 ) || 
		          awvalid || arvalid;

  //leda W484 off
  //LMD:Possible loss of carry/borrow in addition/subtraction
  //LJ: Under/Over-flow will never happen functionally. This is taken care by the hold signals.

// leda NTL_CLK05 off
// LMD: All synchronous inputs to a clock system must be clocked twice.
// LJ: NTL_CLK05: Data must be registered by 2 or more flipflops when crossing clock domain
// path from read data fifo to read_pend_trans_cnt, rlast from rdata fifo used
// in path. Data from fifo is only used when fifo is not empty, and empty
// signal is synchronised.
// Counter for pending read transactions
assign read_pend_trans_cnt_c = read_pend_trans_cnt;
always@(posedge aclk or negedge aresetn)
begin:READ_PEND_TRANS_CNT_PROC
  if ( !aresetn )
    read_pend_trans_cnt <= {CNT_PENDTRANS_READ_W{1'b0}};
  else
  begin
    case ( { compl_read_trans, init_read_trans } )
    
      2'b00 : read_pend_trans_cnt <= read_pend_trans_cnt_c;

      2'b01 : if ( ~hold_read_trans )
                read_pend_trans_cnt <= read_pend_trans_cnt_c + 1;
              else
	        read_pend_trans_cnt <= read_pend_trans_cnt_c;

      2'b10 : read_pend_trans_cnt <= read_pend_trans_cnt_c - 1;

      2'b11 : read_pend_trans_cnt <= read_pend_trans_cnt_c;

    endcase
  end
end
// leda NTL_CLK05 on

// Counter for pending write transactions
assign write_pend_trans_cnt_c = write_pend_trans_cnt;
always@(posedge aclk or negedge aresetn)
begin:WRITE_PEND_TRANS_CNT_PROC
  if ( !aresetn )
    write_pend_trans_cnt <= {CNT_PENDTRANS_WRITE_W{1'b0}};
  else
  begin
    case ( { compl_write_trans, init_write_trans } )
    
      2'b00 : write_pend_trans_cnt <= write_pend_trans_cnt_c;

      2'b01 : if ( ~hold_write_trans )
                write_pend_trans_cnt <= write_pend_trans_cnt_c + 1;
              else
	        write_pend_trans_cnt <= write_pend_trans_cnt_c;

      2'b10 : write_pend_trans_cnt <= write_pend_trans_cnt_c - 1;

      2'b11 : write_pend_trans_cnt <= write_pend_trans_cnt_c;

    endcase
  end
end
  //leda W484 on


endmodule