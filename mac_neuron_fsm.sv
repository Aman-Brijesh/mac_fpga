module mac_neuron_fsm(
    input logic clk,
    input logic start,
    input logic [7:0]x,
    input logic [7:0]w,
    input logic rst,
    output logic [15:0]acc,
    output logic done_out
);

    logic signed[15:0] mult;
    logic [2:0] count;
    logic clear;
    logic en;
    logic done;

    assign mult = x*w;
    assign done = (count ==2);
    assign done_out = (state == DONE);

    typedef enum logic[1:0]{ 
        IDLE,CLEAR,MAC,DONE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk ) begin
        if(rst)
            state <=IDLE;
        else
            state <=next_state;
        
    end
    always_comb begin
        next_state = state;
        case(state)
        IDLE: if(start) next_state =CLEAR;
        CLEAR: next_state = MAC;
        MAC : if(done) next_state = DONE;
        DONE : next_state = IDLE;
        endcase

        
    end

    always_comb begin
        clear = 0;
        en = 0;
        case(state)
            CLEAR: clear =1;
            MAC: en =1;
        endcase
    end

    always_ff @(posedge clk) begin
        if(clear) begin
            acc <= 0;
            count <=0;
        end
        else if(en) begin
            acc<= acc+mult;
            count <=count+1;
        end
    
    end
    


endmodule