`timescale 1ns/100ps

module line_mux #(
    parameter NUM_INPUTS  = 'd10,
    parameter NUM_OUTPUTS = 'd10,
    parameter ID = 'd0)
(
    input clk,
    input rstn,

    input  [NUM_INPUTS-1:0]  input_lines,

    input  [$clog2(NUM_INPUTS+2)-1:0]  input_select,
    input  [$clog2(NUM_OUTPUTS)-1:0]   output_select,

    output o
);

reg [$clog2(NUM_INPUTS+2)-1:0] current_id;

wire [NUM_INPUTS+1:0] input_lines_extra;

assign input_lines_extra = {input_lines, 'b1, 'b0};
assign o = input_lines_extra[current_id];

always @(clk, rstn)
begin
    if (rstn == 'b0)
    begin
        current_id = 'd0;
    end else if(clk == 'b1)
    begin
        if(output_select == ID)
        begin
            current_id = input_select;
        end
    end
end

endmodule
