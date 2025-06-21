`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 05:55:29 PM
// Design Name: 
// Module Name: UART_Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_Top #(parameter max_bits =11,dbits =8)(clk,reset_n,Final_Value,rx,rd_uart,wr_uart,w_data,tx,rx_empty,tx_full,r_data);
input               clk,reset_n;
input [max_bits-1:0]  Final_Value;
input               rx;
input               rd_uart;
input               wr_uart;
input [dbits-1:0]   w_data;

output              tx;
output              rx_empty,tx_full;
output[dbits-1:0]   r_data;

wire                done_stick;
wire [dbits-1:0]    rxdout_din;
wire                rxdone_wren;
wire [dbits-1:0]    dout_txdin;
wire                txdone_rden;
wire                empty_not_start;

Baud_Rate_generator BRG (
.clk(clk),
.reset_n(reset_n),
.Final_Value(Final_Value),
.enable(1),
.done(done_stick)
);

receiver RX (
.clk(clk),
.reset_n(reset_n),
.rx(rx),
.s_tick(done_stick),
.rx_dout(rxdout_din),
.rx_done_tick(rxdone_wren)    
);

FIFO RX_FIFO (
.clk(clk),
.reset_n(reset_n),
.wr_en(rxdone_wren),
.rd_en(rd_uart),
.buf_in(rxdout_din),
.buf_out(r_data),
.empty(rx_empty)
);

transmitter TX (
.clk(clk),
.reset_n(reset_n),
.s_tick(done_stick),
.tx_din(dout_txdin),
.tx_start(!empty_not_start),
.tx_done_tick(txdone_rden),
.tx(tx)
);

FIFO TX_FIFO (
.clk(clk),
.reset_n(reset_n),
.wr_en(wr_uart),
.rd_en(txdone_rden),
.buf_in(w_data),
.buf_out(dout_txdin),
.empty(empty_not_start),
.full(tx_full)
);

endmodule
