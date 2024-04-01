`timescale 1ns/1ps

module LVDSIPCoreInit_tb;

    logic clk;
    logic rst;
    logic user_mode;
    logic rx_locked;
    logic rx_dpa_locked;
    logic pll_areset;
    logic rx_reset;
    logic rx_fifo_reset;
    logic rx_cda_reset;
    logic monitor;

    LVDSIPCoreInit uut (
        .clk(clk),
        .rst(rst),
        .user_mode(user_mode),
        .rx_locked(rx_locked),
        .rx_dpa_locked(rx_dpa_locked),
        .pll_areset(pll_areset),
        .rx_reset(rx_reset),
        .rx_fifo_reset(rx_fifo_reset),
        .rx_cda_reset(rx_cda_reset),
        .monitor(monitor)
    );

    always #5 clk = ~clk; 

    initial begin
        clk = 0;
        rst = 1;
        user_mode = 0;
        rx_locked = 0;
        rx_dpa_locked = 0;
        
        #10 rst = 1; 
        #10 rst = 0;
        #30; 


        user_mode = 1; 
        #30;

        rx_locked = 1; 
        #30;

        rx_dpa_locked = 1;

        #300;

    end
endmodule
