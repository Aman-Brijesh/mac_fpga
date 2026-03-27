`timescale 1ns/1ps

module tb_mac_neuron_fsm;

    reg clk;
    reg rst;
    reg start;
    reg signed [7:0] x;
    reg [4:0] weight_idx;

    wire signed [15:0] acc;
    wire signed [15:0] relu_out;
    wire done_out;

    // Instantiate DUT (Device Under Test)
    // Parameterized for 2 inputs (Layer 1 Neuron)
    mac_neuron_fsm #(
        .NUM_INPUTS(2)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x(x),
        .weight_idx(weight_idx),
        .acc(acc),
        .relu_out(relu_out),
        .done_out(done_out)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fsm_wave.vcd");
        $dumpvars(0, tb_mac_neuron_fsm);

        // Initialize Signals
        clk = 0;
        rst = 1;
        start = 0;
        x = 0;
        weight_idx = 0;

        // Clear Reset
        #20 rst = 0;

        // ==========================================
        // TEST CASE 1: Positive Accumulation
        // ==========================================
        $display("--- Starting Test Case 1 ---");
        #10 start = 1;
        #10 start = 0;

        // Feed Cycle 1: x = 5, weight_idx = 3 
        // ROM value at idx 3 is 46. (5 * 46 = 230)
        #10 x = 5; weight_idx = 3; 
        
        // Feed Cycle 2: x = 2, weight_idx = 7 
        // ROM value at idx 7 is 31. (2 * 31 = 62)
        #10 x = 2; weight_idx = 7;

        // Wait for the FSM to signal completion
        wait(done_out == 1);
        #10;
        
        $display("TEST 1 COMPLETE:");
        $display("Expected acc: 292, Expected relu: 292");
        $display("Actual acc = %d", acc);
        $display("Actual relu_out = %d\n", relu_out);

        // ==========================================
        // TEST CASE 2: Negative Accumulation (ReLU Check)
        // ==========================================
        #20 rst = 1;
        #20 rst = 0;

        $display("--- Starting Test Case 2 ---");
        #10 start = 1;
        #10 start = 0;

        // Feed Cycle 1: x = 10, weight_idx = 1 
        // ROM value at idx 1 is -20. (10 * -20 = -200)
        #10 x = 10; weight_idx = 1; 
        
        // Feed Cycle 2: x = 3, weight_idx = 2 
        // ROM value at idx 2 is -3. (3 * -3 = -9)
        #10 x = 3; weight_idx = 2; 

        // Wait for the FSM to signal completion
        wait(done_out == 1);
        #10;

        $display("TEST 2 COMPLETE:");
        $display("Expected acc: -209, Expected relu: 0 (clamped)");
        $display("Actual acc = %d", acc);
        $display("Actual relu_out = %d\n", relu_out);

        #30;
        $finish;
    end

endmodule