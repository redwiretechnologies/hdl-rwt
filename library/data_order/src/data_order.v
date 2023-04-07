`timescale 1ns/100ps

module data_order #(
    parameter NUM_CHANNELS   = 4,
    parameter CHANNEL_OFFSET = 1024,
    parameter CHANNEL_WIDTH  = 16)
(
    input adc_clk,
    input adc_rstn,

    input send_count,
    input reset_count,

    input [NUM_CHANNELS*CHANNEL_WIDTH-1:0]  adc_data_in,
    input [NUM_CHANNELS-1:0]                adc_enable_in,
    input [NUM_CHANNELS-1:0]                adc_valid_in,

    output [NUM_CHANNELS*CHANNEL_WIDTH-1:0] adc_data_out,
    output [NUM_CHANNELS-1:0]               adc_enable_out,
    output [NUM_CHANNELS-1:0]               adc_valid_out
);

    genvar i;
    integer j;

    wire [NUM_CHANNELS*CHANNEL_WIDTH-1:0] constant_outputs;

    reg [NUM_CHANNELS*CHANNEL_WIDTH-1:0]  count_outputs;

    //Set this to a wire with a channel width to ensure rollover will happen correctly
    wire [CHANNEL_WIDTH-1:0] chan_o;
    assign chan_o = CHANNEL_OFFSET;

    //Set constants
    for (i=0; i<NUM_CHANNELS; i=i+1) begin : set_constants
        assign constant_outputs[CHANNEL_WIDTH*(i+1)-1:CHANNEL_WIDTH*i] =
                chan_o*i;
    end

    //Update counts
    always @(posedge adc_clk)
    begin
        if (!adc_rstn | reset_count)
        begin
            count_outputs = constant_outputs;
        end else
        begin
            for (j=0; j<NUM_CHANNELS; j=j+1) begin : count
                if (adc_enable_in[j] & adc_valid_in[j] & send_count)
                begin
                    count_outputs[CHANNEL_WIDTH*(j+1)-1 -: CHANNEL_WIDTH] =
                        count_outputs[CHANNEL_WIDTH*(j+1)-1 -: CHANNEL_WIDTH]+1;
                end
            end
        end
    end

    assign adc_enable_out = adc_enable_in;
    assign adc_valid_out  = adc_valid_in;
    assign adc_data_out   = (send_count == 1'b1) ? count_outputs : adc_data_in;

endmodule
