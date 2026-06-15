// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/100ps

module line_matrix #(
    parameter NUM_INPUTS  = 10,
    parameter NUM_OUTPUTS = 10)
(
    input sys_clk,
    input clk_pin,
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
                    lm0 ( .sys_clk(sys_clk) ,
                          .clk_pin(clk_pin),
                          .rstn(rstn),
                          .input_select(input_select),
                          .output_select(output_select),
                          .input_lines(input_lines),
                          .o(output_lines[i])
                        );
        end
    endgenerate
endmodule
