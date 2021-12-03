module sample_clk #(
  parameter CLK_FREQ = 100000000,
  parameter SAMPLE_CLK_WIDTH = 64,
  parameter NUM_SAMPLE_CLKS = 1
)(
  input                                         clk,
  input                                         aresetn,
  input                                         which_pps,
  input                                         pps_ext,
  input                                         sample_idx_set_mode,
  input [SAMPLE_CLK_WIDTH-1:0]                  sample_idx_reg,
  input                                         sample_idx_reg_valid,
  input [NUM_SAMPLE_CLKS-1:0]                   sample_idx_incr,
  output [NUM_SAMPLE_CLKS*SAMPLE_CLK_WIDTH-1:0] sample_idx,
  output                                        pps,
  output                                        pps_edge
);

  localparam MODE_IMMEDIATE = 0;
  localparam MODE_PPS = 1;

  genvar i;

  reg [31:0] pps_count;
  reg        pps_int;
  reg        pps_d1;
  reg        pps_ext_d1;
  reg        pps_ext_d2;

  assign pps = which_pps ? pps_ext_d2 : pps_int;
  assign pps_edge = pps & !pps_d1;

  // Synchronize external pps
  always @(posedge clk) begin
    if (aresetn == 1'b0) begin
      pps_ext_d1 <= 1'b0;
      pps_ext_d2 <= 1'b0;
    end else begin
      pps_ext_d1 <= pps_ext;
      pps_ext_d2 <= pps_ext_d1;
    end
  end

  // Delay for pps edge detection.
  always @(posedge clk) begin
    if (aresetn == 1'b0) begin
      pps_d1 <= 1'b0;
    end else begin
      pps_d1 <= pps;
    end
  end

  // Internal PPS signal.
  always @(posedge clk) begin
    if (aresetn == 1'b0) begin
      pps_int <= 1'b0;
    end else begin
      if (pps_count == (CLK_FREQ/2)) begin
        pps_int <= 1'b0;
      end else if (pps_count == (CLK_FREQ-1)) begin
        pps_int <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if (aresetn == 1'b0) begin
      pps_count <= 'd0;
    end else begin
      if (pps_count == (CLK_FREQ-1))
        pps_count <= 'd0;
      else
        pps_count <= pps_count + 'd1;
    end
  end

  for (i = 0; i < NUM_SAMPLE_CLKS; i = i + 1) begin: sample_idx_loop
    reg [SAMPLE_CLK_WIDTH-1:0] sample_reg;
    reg sample_idx_hold_valid;
    reg sample_idx_hold_valid_pps;
    reg sample_idx_hold_valid_immediate;

    assign sample_idx[(i+1)*SAMPLE_CLK_WIDTH-1:i*SAMPLE_CLK_WIDTH] = sample_reg;

    // Sample Register.
    //   Increments by 1 unless the user sets a value for the next pps.
    always @(posedge clk) begin
      if (aresetn == 1'b0) begin
        sample_reg <= 'd0;
      end else begin
        if (sample_idx_incr[i]) begin
          if (sample_idx_hold_valid_pps) begin
            sample_reg <= sample_idx_reg;
          end else if (sample_idx_hold_valid_immediate) begin
            sample_reg <= sample_idx_reg;
          end else begin
            sample_reg <= sample_reg + 1;
          end
        end
      end
    end

    // Hold for changing the sample register until a PPS occurs.
    always @(posedge clk) begin
      if (aresetn == 1'b0) begin
        sample_idx_hold_valid_immediate <= 1'b0;
        sample_idx_hold_valid_pps <= 1'b0;
        sample_idx_hold_valid <= 1'b0;
      end else begin
        if (sample_idx_incr[i]) begin
          sample_idx_hold_valid_pps <= 1'b0;
          sample_idx_hold_valid_immediate <= 1'b0;
        end
        if (pps_edge) begin
          sample_idx_hold_valid <= 1'b0;
          sample_idx_hold_valid_pps <=
              (sample_idx_set_mode == MODE_PPS) && sample_idx_hold_valid;
        end
        if (sample_idx_reg_valid) begin
          sample_idx_hold_valid <= 1'b1;
          sample_idx_hold_valid_immediate <=
              (sample_idx_set_mode == MODE_IMMEDIATE);
        end
      end
    end
  end
endmodule
