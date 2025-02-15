/* verilator lint_off TIMESCALEMOD */
module axis_uart_top #(
    parameter CLK_FREQ   = 27_000_000,
    parameter BAUD_RATE  = 115_200,
    parameter DATA_WIDTH = 8
)(
    input  logic clk_i,
    input  logic arstn_i,
    input  logic rx_i,
    output logic tx_o
);

axis_if axis();

axis_uart_tx #(
    .CLK_FREQ   (CLK_FREQ  ),
    .BAUD_RATE  (BAUD_RATE ),
    .DATA_WIDTH (DATA_WIDTH)
) i_axis_uart_tx (
    .clk_i   (clk_i  ),
    .arstn_i (arstn_i),
    .tx_o    (tx_o   ),
    .s_axis  (axis   )
);

axis_uart_rx #(
    .CLK_FREQ   (CLK_FREQ  ),
    .BAUD_RATE  (BAUD_RATE ),
    .DATA_WIDTH (DATA_WIDTH)
) i_axis_uart_rx (
    .clk_i   (clk_i  ),
    .arstn_i (arstn_i),
    .rx_i    (rx_i   ),
    .m_axis  (axis   )
);

`ifdef COCOTB_SIM
    initial begin
        $dumpfile ("axis_uart_top.vcd");
        $dumpvars (0, axis_uart_top);
        #1;
    end
`endif

endmodule
