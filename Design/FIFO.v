`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 05:20:24 PM
// Design Name: 
// Module Name: FIFO
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


module FIFO #(parameter dbits = 8)(
input clk,reset_n,wr_en,rd_en,
input [dbits-1:0] buf_in,
output reg [dbits-1:0] buf_out,
output empty,full,
output reg [4:0] fifo_counter 
    );
    reg [3:0] wr_ptr ; //head
    reg [3:0] rd_ptr ; //read
    reg [dbits-1:0] fifo_memory [15:0] ; // 16 Elements
    
    assign empty = (fifo_counter ==0) ;
    assign full = (fifo_counter ==16) ;
    
    always @(posedge clk or negedge reset_n)
    begin
    if(!reset_n) //active low reset
    begin
    fifo_counter <=0;
    end
    else if ((!full && wr_en) && (!empty && rd_en))
    fifo_counter <= fifo_counter;
    else if (!full && wr_en)
    fifo_counter <=fifo_counter + 1;
    else if (!empty && rd_en)
    fifo_counter <= fifo_counter -1;
    else
    fifo_counter <= fifo_counter;
    end
    
    always @(posedge clk or negedge reset_n)
    begin
    if (!reset_n)
    begin
    buf_out <=0;
    end
    else if (!empty && rd_en)
    buf_out <= fifo_memory[rd_ptr];
    else
    buf_out <= buf_out;
    end
    
    always @(posedge clk )
    begin
    if (!full && wr_en)
    begin 
    fifo_memory [wr_ptr] <= buf_in;
    end
    else
    fifo_memory[wr_ptr] <= fifo_memory[wr_ptr] ;
    end
    
    always @(posedge clk or negedge reset_n)
    begin
    if (!reset_n)
    begin
    wr_ptr <=0;
    rd_ptr <=0;
    end
    else
    begin
    if (wr_en && !full)
    wr_ptr <= wr_ptr+1;
    else
    wr_ptr <= wr_ptr;
    
    if (rd_en && !empty)
    rd_ptr <= rd_ptr +1;
    else 
    rd_ptr <= rd_ptr;
    end
    end
    
endmodule
