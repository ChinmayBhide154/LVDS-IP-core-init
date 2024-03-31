module LVDSIPCoreInit #(
    parameter integer STABLE_COUNT = 10  // Number of clock cycles for stability
) (
    input logic clk,
    input logic rst,
    input logic user_mode,          // Input signal indicating user mode
    input logic rx_locked,          // PLL lock indicator
    input logic rx_dpa_locked,      // Additional lock indicator
    output logic pll_areset,        // PLL asynchronous reset
    output logic rx_reset,          // RX reset
    output logic rx_fifo_reset,     // RX FIFO reset
    output logic rx_cda_reset       // RX CDA reset
);
	// States
	parameter IDLE = 4'b0000;
	parameter USERMODE = 4'b0001;
	parameter MONITOR = 4'b0010;
	parameter D_RX_RST = 4'b0011;
	parameter WAIT_RX_DPA_LOCK = 4'b0100;
	parameter ASSERT_RX_FIFO_RESET = 4'b0101;
	parameter DEASSERT_RX_FIFO_RESET = 4'b0110;
	parameter ASSERT_RX_CDA_RESET = 4'b0111;
	parameter DEASSERT_RX_CDA_RESET = 4'b1000;
	
	logic [3:0] state, next;
	
	always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next;
        end
    end
	 
	 always_comb begin
        case (state)
            IDLE: begin
                if (user_mode) next = USERMODE;
				else next = IDLE;
            end
				
            USERMODE: next = MONITOR;
            
            MONITOR: begin
                //if (rx_locked) next = D_RX_RST;
				//else next = MONITOR;
				next = D_RX_RST;
            end
            D_RX_RST: begin
                //if (stable_count == STABLE_COUNT) next = WAIT_RX_DPA_LOCK;
				//else next = D_RX_RST;
				if (rx_locked) next = WAIT_RX_DPA_LOCK;
				else next = D_RX_RST;
            end
            WAIT_RX_DPA_LOCK: begin
                if (rx_dpa_locked) next = ASSERT_RX_FIFO_RESET;
				else next = WAIT_RX_DPA_LOCK;
            end
            ASSERT_RX_FIFO_RESET: begin
                next = DEASSERT_RX_FIFO_RESET;
            end
			DEASSERT_RX_FIFO_RESET: begin
				next = ASSERT_RX_CDA_RESET;
			end
            ASSERT_RX_CDA_RESET: begin
                next = IDLE; 
            end

			DEASSERT_RX_CDA_RESET: begin
				next = IDLE;
			end
			default: next = IDLE;
        endcase
    end
	 
	 always_ff @(posedge clk) begin
		case (next)
			IDLE: begin
				// Reset all outputs
				pll_areset <= 0;
				rx_reset <= 0;
				rx_fifo_reset <= 0;
				rx_cda_reset <= 0;
				//stable_count <= 0;
			end
			USERMODE: begin
				pll_areset <= 1;
				rx_reset <= 1;
			end
			MONITOR: begin
				//pll_areset <= 0;
			end
			D_RX_RST: begin
				pll_areset <= 0;
				//if (rx_locked)
					//stable_count <= stable_count + 1;
				//else
				//	stable_count <= 0;
				//if (stable_count < STABLE_COUNT)
				//	rx_reset <= 1;
			end
			ASSERT_RX_FIFO_RESET: begin
				rx_fifo_reset <= 1'b1;
			end
			DEASSERT_RX_FIFO_RESET: begin
				rx_fifo_reset <= 1'b0;
			end
			ASSERT_RX_CDA_RESET: begin
				rx_cda_reset <= 1'b1;
			end

			DEASSERT_RX_CDA_RESET: begin
				rx_cda_reset <= 1'b0;
			end
		endcase
     end
endmodule
