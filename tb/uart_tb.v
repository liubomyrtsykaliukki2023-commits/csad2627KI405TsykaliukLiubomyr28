`timescale 1ns/1ps
module uart_tb;
    localparam CPB = 434;
    localparam BIT_NS = CPB * 20;        // 20 нс = період 50 МГц

    reg clk = 0, rst = 1, tx_start = 0;
    reg [7:0] tx_data = 0;
    wire tx, tx_busy, rx_valid;
    wire [7:0] rx_data;

    reg rx_manual = 1;                   // ручне джерело для другого Rx
    wire rx2_valid;
    wire [7:0] rx2_data;

    uart_tx #(CPB) u_tx  (.clk(clk), .rst(rst), .tx_start(tx_start),
                          .tx_data(tx_data), .tx(tx), .tx_busy(tx_busy));
    uart_rx #(CPB) u_rx  (.clk(clk), .rst(rst), .rx(tx),
                          .rx_data(rx_data), .rx_valid(rx_valid));
    uart_rx #(CPB) u_rx2 (.clk(clk), .rst(rst), .rx(rx_manual),
                          .rx_data(rx2_data), .rx_valid(rx2_valid));

    always #10 clk = ~clk;

    // Loopback: передати байт і перевірити прийом
    task send_byte(input [7:0] b);
    begin
        @(posedge clk); tx_data <= b; tx_start <= 1;
        @(posedge clk); tx_start <= 0;
        @(posedge rx_valid);
        if (rx_data !== b) $display("FAIL loopback: sent %h got %h", b, rx_data);
        else               $display("PASS loopback: %h", b);
        wait (!tx_busy);
        #(BIT_NS);
    end
    endtask

    // Ручна подача бітів на Rx
    task drive_rx(input [7:0] b);
        integer i;
    begin
        rx_manual = 0; #(BIT_NS);                    // старт
        for (i = 0; i < 8; i = i + 1) begin
            rx_manual = b[i]; #(BIT_NS);
        end
        rx_manual = 1; #(BIT_NS);                    // стоп
        if (rx2_data !== b) $display("FAIL manual rx: %h got %h", b, rx2_data);
        else                $display("PASS manual rx: %h", b);
    end
    endtask

    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);
        #200 rst = 0;
        #(BIT_NS);
        send_byte(8'h55);
        send_byte(8'hA3);
        send_byte(8'hFF);
        drive_rx(8'h3C);
        #(BIT_NS*2);
        $finish;
    end
endmodule