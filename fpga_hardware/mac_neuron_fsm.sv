module mac_neuron_fsm #(
    parameter NUM_INPUTS = 2 // Set to 2 for hidden layer, 8 for output layer
)(
    input logic clk,
    input logic start,
    input logic signed [7:0] x,
    input logic [4:0] weight_idx, // 5-bit index to select from the 24 weights
    input logic rst,
    output logic signed [15:0] acc,
    output logic signed [15:0] relu_out,
    output logic done_out
);

    logic signed [7:0] weight_val;

    // Combinational ROM implementation using a case statement
    // This avoids array initialization errors in Icarus Verilog
    always_comb begin
        case (weight_idx)
            5'd0:  weight_val =  8'sd0;
            5'd1:  weight_val = -8'sd20;
            5'd2:  weight_val = -8'sd3;
            5'd3:  weight_val =  8'sd46;
            5'd4:  weight_val =  8'sd0;
            5'd5:  weight_val = -8'sd1;
            5'd6:  weight_val =  8'sd5;
            5'd7:  weight_val =  8'sd31;
            5'd8:  weight_val =  8'sd0;
            5'd9:  weight_val =  8'sd25;
            5'd10: weight_val = -8'sd2;
            5'd11: weight_val = -8'sd40;
            5'd12: weight_val =  8'sd0;
            5'd13: weight_val =  8'sd127;
            5'd14: weight_val =  8'sd59;
            5'd15: weight_val =  8'sd90;
            5'd16: weight_val =  8'sd0;
            5'd17: weight_val =  8'sd25;
            5'd18: weight_val = -8'sd2;
            5'd19: weight_val = -8'sd39;
            5'd20: weight_val =  8'sd0;
            5'd21: weight_val =  8'sd127;
            5'd22: weight_val =  8'sd58;
            5'd23: weight_val =  8'sd89;
            default: weight_val = 8'sd0; // Fallback
        endcase
    end

    logic signed [15:0] mult;
    logic [3:0] count; 
    logic clear;
    logic en;
    logic done;

    // Multiply input x by the weight fetched from the ROM
    assign mult = x * weight_val;
    
    // FSM done condition
    assign done = (count == (NUM_INPUTS - 1));
    assign done_out = (state == DONE);
    
    // ReLU Activation: clamp negative values to 0
    assign relu_out = (acc[15] == 1'b1) ? 16'sd0 : acc;

    typedef enum logic[1:0]{ 
        IDLE, CLEAR, MAC, DONE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk ) begin
        if(rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case(state)
            IDLE: if(start) next_state = CLEAR;
            CLEAR: next_state = MAC;
            MAC : if(done) next_state = DONE;
            DONE : next_state = IDLE;
        endcase
    end

    always_comb begin
        clear = 0;
        en = 0;
        case(state)
            CLEAR: clear = 1;
            MAC: en = 1;
        endcase
    end

    always_ff @(posedge clk) begin
        if(clear || rst) begin
            acc <= 0;
            count <= 0;
        end
        else if(en) begin
            acc <= acc + mult;
            count <= count + 1;
        end
    end

endmodule