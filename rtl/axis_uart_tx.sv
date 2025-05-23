/* verilator lint_off TIMESCALEMOD */
module axis_uart_tx #(
    parameter CLK_FREQ   = 27_000_000,
    parameter BAUD_RATE  = 115_200,
    parameter DATA_WIDTH = 8
) (
    input  logic clk_i,
    input  logic arstn_i,
    output logic uart_tx_o,

    axis_if      s_axis
);

typedef enum logic [2:0] {
    IDLE  = 3'b000,
    START = 3'b001,
    DATA  = 3'b010,
    STOP  = 3'b011,
    WAIT  = 3'b100
} my_state;

my_state state;

localparam DIVIDER = CLK_FREQ/BAUD_RATE;

logic [$clog2(DATA_WIDTH)-1:0] bit_cnt;
logic [$clog2(DIVIDER)-1:0]    baud_cnt;
logic [DATA_WIDTH-1:0]         tx_data;
logic                          bit_done;
logic                          baud_done;
logic                          s_handshake;

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        uart_tx_o <= 1'b1;
        state     <= IDLE;
    end else begin
        case (state)
            IDLE: begin
                uart_tx_o <= 1'b1;
                if (s_axis.tvalid) begin
                    state <= START;
                end
            end
            START: begin
                uart_tx_o <= 1'b0;
                if (baud_done) begin
                    state <= DATA;
                end
            end
            DATA: begin
                uart_tx_o <= tx_data[bit_cnt];
                if (bit_done) begin
                    state <= STOP;
                end
            end
            STOP: begin
                uart_tx_o <= 1'b1;
                if (baud_done) begin
                    state <= WAIT;
                end
            end
            WAIT: begin
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

always @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        baud_cnt <= '0;
    end else if (baud_done) begin
        baud_cnt <= '0;
    end else if ((state == DATA) || (state == START) || (state == STOP)) begin
        baud_cnt <= baud_cnt + 1'b1;
    end
end

always @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        bit_cnt <= '0;
    end else if (bit_done) begin
        bit_cnt <= '0;
    end else if ((state == DATA) && (baud_done)) begin
        bit_cnt <= bit_cnt + 1'b1;
    end
end

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        tx_data <= '0;
    end else if (s_handshake) begin
        tx_data <= s_axis.tdata;
    end
end

assign s_axis.tready = (state == IDLE) ? 1'b1 : 1'b0;
assign s_handshake   = s_axis.tvalid & s_axis.tready;

/* verilator lint_off WIDTHEXPAND */
assign bit_done  = (bit_cnt == DATA_WIDTH - 1) ? 1'b1 : 1'b0;
assign baud_done = (baud_cnt == DIVIDER - 1) ? 1'b1 : 1'b0;
/* verilator lint_on WIDTHEXPAND */

endmodule
