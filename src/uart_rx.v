// UART приймач 8N1, семплування в середині біта
module uart_rx #(parameter CLKS_PER_BIT = 434)(
    input            clk,
    input            rst,
    input            rx,        // лінія RxD
    output reg [7:0] rx_data,   // прийнятий байт
    output reg       rx_valid   // імпульс 1 такт: байт готовий
);
    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    reg [1:0]  state;
    reg [15:0] clk_cnt;
    reg [2:0]  bit_idx;
    reg rx_s1, rx_s2;           // синхронізатор вхідного сигналу

    always @(posedge clk) begin rx_s1 <= rx; rx_s2 <= rx_s1; end

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE; clk_cnt <= 0; bit_idx <= 0;
            rx_valid <= 1'b0; rx_data <= 8'h00;
        end else begin
            rx_valid <= 1'b0;
            case (state)
                IDLE: begin
                    clk_cnt <= 0; bit_idx <= 0;
                    if (rx_s2 == 1'b0) state <= START;   // фронт старт-біта
                end
                START: begin
                    if (clk_cnt == (CLKS_PER_BIT-1)/2) begin // середина біта
                        clk_cnt <= 0;
                        if (rx_s2 == 1'b0) state <= DATA;
                        else state <= IDLE;                  // хибний старт
                    end else clk_cnt <= clk_cnt + 1;
                end
                DATA: begin
                    if (clk_cnt == CLKS_PER_BIT-1) begin
                        clk_cnt <= 0;
                        rx_data[bit_idx] <= rx_s2;           // семпл у середині біта
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1;
                    end else clk_cnt <= clk_cnt + 1;
                end
                STOP: begin
                    if (clk_cnt == CLKS_PER_BIT-1) begin
                        rx_valid <= 1'b1; state <= IDLE; clk_cnt <= 0;
                    end else clk_cnt <= clk_cnt + 1;
                end
            endcase
        end
    end
endmodule