`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2025 01:36:54 PM
// Design Name: 
// Module Name: receiver
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


module receiver #(parameter sb_tick =16 , dbits =8 ) (
input clk, reset_n,
input rx,s_tick,
output [dbits-1:0] rx_dout,
output reg rx_done_tick
    );
    localparam idle =0 , start =1, data =2, stop =3;
    reg [1:0] state,next_state;
    reg [3:0] s_reg,s_next;
    reg [$clog2(dbits)-1:0] n_reg,n_next;
    reg [dbits-1:0] b_reg,b_next;
    //next state 
    always @(*)
    begin
    // Default values
    next_state = state;
    s_next = s_reg;
    b_next = b_reg;
    n_next = n_reg;    
    case (state)
        idle:
        begin
                rx_done_tick=0;
                if (rx)
                begin
                        next_state=idle;
                end
                else
                begin
                        s_next=0;
                        next_state=start;
                end
        end
        start:
                if (~s_tick)
                begin
                        next_state=start;
                end
                else
                begin
                        if (s_reg==7)
                        begin
                                s_next=0;
                                n_next=0;
                                next_state=data;
                        end
                        else
                        begin
                                s_next=s_reg+1;
                                next_state=start;
                        end
                end
        data:
                if (~s_tick)
                begin
                        next_state=data;
                end        
                else
                begin
                        if (s_reg==15)
                        begin
                                s_next=0;
                                b_next={rx, b_reg[dbits-1:1]};
                                if (n_reg==dbits-1)
                                begin
                                        next_state=stop;
                                end
                                else
                                begin
                                        n_next=n_reg+1;
                                        next_state=data;
                                end
                        end
                        else
                        begin
                                s_next=s_reg+1;
                                next_state=data;
                        end
                end
        stop:
                        if (~s_tick)
                        begin
                                next_state=stop;
                        end
                        else
                        begin
                                if(s_reg==sb_tick-1)
                                begin
                                        rx_done_tick=1;
                                        next_state=idle;
                                end
                                else
                                begin
                                        s_next=s_reg+1;
                                        next_state=stop;
                                end
                        end
    endcase
    end
    //state registere
    always @(posedge clk or negedge reset_n)
    begin
    if (!reset_n)
    begin
    state = idle;
    n_reg =0;
    s_reg=0;
    b_reg=0;
    end
    else
    begin
    state <= next_state;
    n_reg <=n_next;
    s_reg <=s_next;
    b_reg <=b_next;   
    end
    end
    //output logic 
    assign rx_dout = b_reg ;
endmodule
