`timescale 1ns/1ps

module LVDSIPCoreInit_tb;

    // Testbench Signals
    logic clk;
    logic rst;
    logic user_mode;
    logic rx_locked;
    logic rx_dpa_locked;
    logic pll_areset;
    logic rx_reset;
    logic rx_fifo_reset;
    logic rx_cda_reset;

    // Instantiate the Unit Under Test (UUT)
    LVDSIPCoreInit uut (
        .clk(clk),
        .rst(rst),
        .user_mode(user_mode),
        .rx_locked(rx_locked),
        .rx_dpa_locked(rx_dpa_locked),
        .pll_areset(pll_areset),
        .rx_reset(rx_reset),
        .rx_fifo_reset(rx_fifo_reset),
        .rx_cda_reset(rx_cda_reset)
    );

    // Clock Generation
    always #5 clk = ~clk; // Generate a clock with a 10ns period (100MHz)

    // Test Sequence
    initial begin
        // Initialize Signals
        clk = 0;
        rst = 1;
        user_mode = 0;
        rx_locked = 0;
        rx_dpa_locked = 0;
        
        // Reset the design
        #10 rst = 1; // De-assert reset
        #10 rst = 0;
        #20; // Wait for a few clock cycles

        // Drive the state machine through its states
        // To USERMODE
        user_mode = 1; 
        #20; // Wait for state transition
        
        // To MONITOR
        #10; // Just need to wait, no inputs required

        // To D_RX_RST (Depends on rx_locked)
        rx_locked = 1; 
        #20; // Wait for state transition

        // To WAIT_RX_DPA_LOCK
        #10; // Just need to wait, no inputs required

        // To ASSERT_RX_FIFO_RESET (Depends on rx_dpa_locked)
        rx_dpa_locked = 1;
        #20; // Wait for state transition

        // To ASSERT_RX_CDA_RESET
        #10; // Just need to wait, no inputs required

        // Back to IDLE
        #10; // Complete the cycle

        #300;

        //$finish; // End the simulation
    end
endmodule
