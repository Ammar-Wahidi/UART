`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Ammar Ahmed Wahidi
// 
// Create Date: 06/19/2025 01:21:03 PM
// Design Name: 
// Module Name: Baud_Rate_generator
// Project Name: UART
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


module Baud_Rate_generator #(parameter max_bits =11) (
input clk,reset_n,enable,
input [max_bits-1:0] Final_Value,
output done
    );
    
    //Final Value = (f/(16*BR))-1
    
    reg [max_bits-1:0] Q_reg ,Q_next;
    
    //next state
    always @(*)
    begin
    Q_next = (done)? 0 : Q_reg +1;
    end
    //State Register
    always @(posedge clk or negedge reset_n)
    begin
    if (!reset_n)
    Q_reg <= 0;
    else if(enable)
    Q_reg <= Q_next;
    else
    Q_reg <= Q_reg;
    end
    //Output Logic
    assign done = (Q_reg == Final_Value);
endmodule
