module LVDSIPCoreInit #(
    parameter integer STABLE_COUNT = 10  // Number of clock cycles for stability
) (
    input logic clk,
    input logic rst_n,
    input logic user_mode,          // Input signal indicating user mode
    input logic rx_locked,          // PLL lock indicator
    input logic rx_dpa_locked,      // Additional lock indicator
    output logic pll_areset,        // PLL asynchronous reset
    output logic rx_reset,          // RX reset
    output logic rx_fifo_reset,     // RX FIFO reset
    output logic rx_cda_reset       // RX CDA reset
);

    // State enumeration
    typedef enum logic [3:0] {
        IDLE,
        ASSERT_RESETS,
        WAIT_PLL_LOCK,
        DEASSERT_RX_RESET,
        WAIT_RX_DPA_LOCK,
        ASSERT_RX_FIFO_RESET,
        ASSERT_RX_CDA_RESET
    } state_t;

    state_t current_state, next_state;
    logic [3:0] stable_count; // Counter for stability checking

    // FSM: State transition logic
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end

    // FSM: Next state logic
    always_comb begin
        //next_state = current_state; // Default to stay in the current state
        case (current_state)
            IDLE: begin
                if (user_mode)
                    next_state = ASSERT_RESETS;
            end
            ASSERT_RESETS: begin
                next_state = WAIT_PLL_LOCK;
            end
            WAIT_PLL_LOCK: begin
                if (rx_locked)
                    next_state = DEASSERT_RX_RESET;
            end
            DEASSERT_RX_RESET: begin
                if (stable_count == STABLE_COUNT)
                    next_state = WAIT_RX_DPA_LOCK;
            end
            WAIT_RX_DPA_LOCK: begin
                if (rx_dpa_locked)
                    next_state = ASSERT_RX_FIFO_RESET;
            end
            ASSERT_RX_FIFO_RESET: begin
                next_state = ASSERT_RX_CDA_RESET; // Move to the next state in the next clock cycle
            end
            ASSERT_RX_CDA_RESET: begin
                next_state = IDLE; // Sequence complete, return to IDLE or wait for the next user mode trigger
            end
        endcase
    end

    // FSM: Output logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all outputs
            pll_areset <= 1;
            rx_reset <= 1;
            rx_fifo_reset <= 0;
            rx_cda_reset <= 0;
            stable_count <= 0;
        end else begin
            // Default outputs to inactive state
            pll_areset <= 0;
            rx_reset <= 0;
            rx_fifo_reset <= 0;
            rx_cda_reset <= 0;

            // State actions
            case (next_state)
                ASSERT_RESETS: begin
                    pll_areset <= 1;
                    rx_reset <= 1;
                end
                WAIT_PLL_LOCK: begin
                    pll_areset <= 0;
                end
                DEASSERT_RX_RESET: begin
                    if (rx_locked)
                        stable_count <= stable_count + 1;
                    else
                        stable_count <= 0;
                    if (stable_count < STABLE_COUNT)
                        rx_reset <= 1;
                end
                ASSERT_RX_FIFO_RESET: begin
                    rx_fifo_reset <= 1;
                end
                ASSERT_RX_CDA_RESET: begin
                    rx_cda_reset <= 1;
                end
            endcase
        end
    end

endmodule