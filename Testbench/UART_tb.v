`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 06:33:07 PM
// Design Name: 
// Module Name: UART_tb
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


module UART_tb;
    reg clk ,reset_n;
    reg [10:0]  Final_Value;
    reg rx;
    reg rd_uart;
    reg wr_uart;
    reg [7:0] w_data;
    
    wire tx;
    wire rx_empty,tx_full;
    wire [7:0]   r_data;
    
    // Clock Generation: 50MHz
    always #5 clk = ~clk;

    // Instantiate the DUT
    UART_Top #( .max_bits(11), .dbits(8) ) DUT (
        .clk(clk),
        .reset_n(reset_n),
        .Final_Value(Final_Value),
        .rx(rx),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .w_data(w_data),
        .tx(tx),
        .rx_empty(rx_empty),
        .tx_full(tx_full),
        .r_data(r_data)
    );

`define BIT_TIME_NS 104166   

task uart_rx_byte;
    input [7:0] data;
    integer i;
    begin
        rx = 0; // Start bit
        #(`BIT_TIME_NS);
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #(`BIT_TIME_NS);
        end
        rx = 1; // Stop bit
        #(`BIT_TIME_NS);
    end
endtask

initial begin
        // Initialize inputs
        clk = 0;
        reset_n = 0;
        Final_Value = 11'd649; // For 9600 baud if clk = 100 MHz
        rx = 1; // Idle line is high
        rd_uart = 0;
        wr_uart = 0;
        w_data = 8'h00;

        // Reset pulse
        #25;
        reset_n = 1;

        // Wait a bit
        #50;

        // Simulate writing a byte to UART
        
        w_data = 8'hA5;
        wr_uart = 1;
        #10;
        w_data = 8'h0f;  
        #10 
        w_data = 8'h78;  
        #10
        wr_uart = 0;  
        #10            
                         
        // Simulate read request after some time
        #4000000;  // Let transmitter finish
        rd_uart = 1;
        #10;
        rd_uart = 0;
        
        // Finish simulation
        #100;
        $stop;
    end
    
initial begin
        #1000; // let system stabilize
        uart_rx_byte(8'hA5); // Send A5 over rx
        #200000; 
        rd_uart=1;
        #10;
        rd_uart=0;
        uart_rx_byte(8'h3C); // send another byte
        #200000; 
        rd_uart=1;
        #10;
        rd_uart=0;
        uart_rx_byte(8'h32); // send another byte
        #200000; 
        rd_uart=1;
        #10;        
        rd_uart=0;

    end

endmodule
