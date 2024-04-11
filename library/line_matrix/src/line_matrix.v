`timescale 1ns/100ps

module line_matrix #(
    parameter NUM_INPUTS  = 10,
    parameter NUM_OUTPUTS = 10)
(
    input clk,
    input rstn,

    input  [NUM_INPUTS-1:0]  input_lines,
    output [NUM_OUTPUTS-1:0] output_lines,

    input  [$clog2(NUM_INPUTS+2)-1:0]  input_select,
    input  [$clog2(NUM_OUTPUTS)-1:0]   output_select
);

    genvar i;

    //Make each module
    generate
        for (i=0; i<NUM_OUTPUTS; i=i+1) begin : initialize_modules
            line_mux   #( .NUM_INPUTS(NUM_INPUTS),
                          .NUM_OUTPUTS(NUM_OUTPUTS),
                          .ID(i))
                    lm0 ( .clk(clk),
                          .rstn(rstn),
                          .input_select(input_select),
                          .output_select(output_select),
                          .input_lines(input_lines),
                          .o(output_lines[i])
                        );
        end
    endgenerate
endmodule
