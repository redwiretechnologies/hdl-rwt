// SPDX-License-Identifier: Apache-2.0

`timescale 1 ns/10 ps

module line_matrix_tb;

localparam period=100;

localparam NUM_INPUTS=8;
localparam NUM_OUTPUTS=10;

reg clk;
reg rstn;

wire [NUM_INPUTS-1:0]  input_lines;
wire [NUM_OUTPUTS-1:0] output_lines;

reg [$clog2(NUM_INPUTS+2)-1:0] input_select;
reg [$clog2(NUM_OUTPUTS)-1:0]  output_select;

integer i=0;
integer j=0;

assign input_lines = 'b10011001;

line_matrix #( .NUM_INPUTS(NUM_INPUTS), .NUM_OUTPUTS(NUM_OUTPUTS) )
    uut ( .clk(clk),
          .rstn(rstn),
          .input_lines(input_lines),
          .output_lines(output_lines),
          .input_select(input_select),
          .output_select(output_select));

initial
begin
    rstn = 'b1;
    #(period);
    rstn = 'b0;
    #(period);
    rstn = 'b1;
    #(period);

    for(i=0;i<NUM_OUTPUTS; i++)
    begin
        output_select = i;
        for(j=0; j<NUM_INPUTS+2; j++)
        begin
            input_select=j;
            clk = 'b1;
            #(period);
            clk = 'b0;
            #(period*2);
        end
    end
    rstn = 'b0;
end

endmodule

