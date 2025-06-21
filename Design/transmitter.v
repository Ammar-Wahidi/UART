`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2025 02:08:53 PM
// Design Name: 
// Module Name: transmitter
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


module transmitter  #(parameter sb_tick =16 , dbits =8 ) (
input clk,reset_n,
input s_tick,
input [dbits-1:0] tx_din,
input tx_start,
output reg tx_done_tick,
output reg tx
    );

    localparam idle =0 , start =1, data =2, stop =3; 
    reg [1:0] state,next_state;
    reg [3:0] s_reg,s_next;
    reg [dbits-1:0] b_reg,b_next;
    reg [$clog2(dbits)-1:0] n_reg,n_next;
    //Next State
    always @(*)
    begin
    // Default values
    next_state = state;
    s_next = s_reg;
    b_next = b_reg;
    n_next = n_reg;
    tx_done_tick =0;
        case(state)
        idle: 
        begin
                tx = 1;
                if (~tx_start)
                begin
                    next_state = idle;
                end
                else
                begin
                    s_next = 0;
                    b_next = tx_din;
                    n_next = 0;
                    next_state = start;
                end
        end
        start:
        begin
                tx=0;
                if(~s_tick)
                begin
                    next_state=start;
                end
                else
                begin
                    if (s_reg == 15)
                    begin
                        s_next=0;
                        n_next=0;
                        next_state=data;
                    end
                    else
                    begin
                        s_next=s_reg+1;
                        next_state= start;
                    end
                end
        end
        data:
        begin
                tx=b_reg[0];
                if(~s_tick)
                begin
                    next_state=data;
                end
                else
                begin
                    if (s_reg==15)
                    begin
                        s_next=0;
                        b_next=b_reg>>1;
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
        end
        stop:
        begin
                tx=1;
                if (~s_tick)
                begin
                    next_state=stop;
                end
                else
                begin
                    if (s_reg==sb_tick-1)
                    begin
                        tx_done_tick=1;
                        next_state= idle;
                    end
                    else
                    begin
                        s_next=s_reg+1;
                        next_state=stop;
                    end

                end
        end        
        endcase
    end
    //State Register 
    always @(posedge clk or negedge reset_n)
    begin
        if (~reset_n)
        begin
            state<=idle;
            s_reg<=0;
            n_reg<=0;
            b_reg<=0;
        end
        else
        begin
            state<=next_state;
            s_reg<=s_next;
            n_reg<=n_next;
            b_reg<=b_next;
        end
    end

    
endmodule
