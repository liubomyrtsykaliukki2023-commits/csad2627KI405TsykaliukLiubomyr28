module uart_top(
    input        clk, rst, tx_start,
    input  [7:0] tx_data,
    output       tx, tx_busy,
    output [7:0] rx_data,
    output       rx_valid
);
    uart_tx u_tx (.clk(clk), .rst(rst), .tx_start(tx_start), .tx_data(tx_data),
                  .tx(tx), .tx_busy(tx_busy));
    uart_rx u_rx (.clk(clk), .rst(rst), .rx(tx), .rx_data(rx_data), .rx_valid(rx_valid));
endmodule