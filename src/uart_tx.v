// UART передавач 8N1
module uart_tx #(parameter CLKS_PER_BIT = 434)(
    input            clk,       // тактовий сигнал
    input            rst,       // синхронне скидання
    input            tx_start,  // імпульс початку передачі
    input      [7:0] tx_data,   // байт для передачі
    output reg       tx,        // лінія TxD
    output reg       tx_busy    // 1 під час передачі
);
    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;
    reg [1:0]  state;     // стан FSM
    reg [15:0] clk_cnt;   // лічильник тактів у біті
    reg [2:0]  bit_idx;   // номер біта даних
    reg [7:0]  data_reg;  // зафіксований байт

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE; tx <= 1'b1; tx_busy <= 1'b0;
            clk_cnt <= 0; bit_idx <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1; tx_busy <= 1'b0; clk_cnt <= 0; bit_idx <= 0;
                    if (tx_start) begin
                        data_reg <= tx_data; tx_busy <= 1'b1; state <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;                       // стартовий біт
                    if (clk_cnt == CLKS_PER_BIT-1) begin
                        clk_cnt <= 0; state <= DATA;
                    end else clk_cnt <= clk_cnt + 1;
                end
                DATA: begin
                    tx <= data_reg[bit_idx];          // LSB першим
                    if (clk_cnt == CLKS_PER_BIT-1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1;
                    end else clk_cnt <= clk_cnt + 1;
                end
                STOP: begin
                    tx <= 1'b1;                       // стоповий біт
                    if (clk_cnt == CLKS_PER_BIT-1) begin
                        clk_cnt <= 0; state <= IDLE; tx_busy <= 1'b0;
                    end else clk_cnt <= clk_cnt + 1;
                end
            endcase
        end
    end
endmodule