`timescale 1ns/1ps

module tb_mac_neuron_fsm;

reg clk;
reg rst;
reg start;
reg signed [7:0] x;
reg signed [7:0] w;

wire signed [15:0] acc;
wire signed [15:0] relu_out;
wire done_out;

// DUT
mac_neuron_fsm dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .x(x),
    .w(w),
    .acc(acc),
    .relu_out(relu_out),
    .done_out(done_out)
);

// Clock 10ns
always #5 clk = ~clk;

initial begin
    $dumpfile("fsm_wave.vcd");
    $dumpvars(0, tb_mac_neuron_fsm);

    clk = 0;
    rst = 1;
    start = 0;
    x = 0;
    w = 0;

    // Reset
    #20 rst = 0;

    // ---------- POSITIVE TEST ----------
    #10 start = 1;
    #10 start = 0;

    #10 x = 2; w = 5;   // 10
    #10 x = 3; w = 6;   // +18
    #10 x = 4; w = 7;   // +28

    wait(done_out == 1);

    #10;
    $display("POSITIVE TEST:");
    $display("acc = %d", acc);
    $display("relu_out = %d", relu_out);

    // ---------- NEGATIVE TEST ----------
    #20 rst = 1;
    #20 rst = 0;

    #10 start = 1;
    #10 start = 0;

    #10 x = -2; w = 5;   // -10
    #10 x = -3; w = 6;   // -18
    #10 x = -4; w = 7;   // -28

    wait(done_out == 1);

    #10;
    $display("NEGATIVE TEST:");
    $display("acc = %d", acc);
    $display("relu_out = %d", relu_out);

    #30;
    $finish;
end

endmodule