`timescale 1ns/1ps


module sample_clk_tb();
  logic clk = 0;
  logic resetn = 0;
  logic which_pps = 0;
  logic pps_ext = 0;
  logic [55:0] sample_idx_reg = 'd0;
  logic        sample_idx_reg_valid = 0;
  logic        sample_idx_incr = 0;
  logic [55:0] sample_idx;
  logic        pps;

  always #5 clk = ~clk;
  initial #1000 resetn = 1;

  // pps_external has 8 ms rate.
  always #4000000 pps_ext <= ~pps_ext;

  // control sample_idx and which_pps.
  initial begin
    #10000;

    @(posedge clk);
    sample_idx_reg <= 56'h000000deadbeaf;
    sample_idx_reg_valid <= 1'b1;
    @(posedge clk);
    sample_idx_reg_valid <= 1'b0;

    #10000000; // 10ms
    @(posedge clk);
    sample_idx_reg <= 56'haaaaaaaaaaaaaa;
    sample_idx_reg_valid <= 1'b1;
    @(posedge clk);
    sample_idx_reg_valid <= 1'b0;

    #25000000; // 25ms
    which_pps <= 1'b1;

    #20000000; // 20ms
    @(posedge clk);
    sample_idx_reg <= 56'h55555555555555;
    sample_idx_reg_valid <= 1'b1;
    @(posedge clk);
    sample_idx_reg_valid <= 1'b0;

  end


  // Assert sample_idx_incr every 100 ticks.
  initial begin
    while (1) begin
      for (int i = 0; i < 100; i++) begin
        @(posedge clk);
      end

      sample_idx_incr <= 1'b1;
      @(posedge clk);
      sample_idx_incr <= 1'b0;
    end
  end


  sample_clk #(
    .CLK_FREQ(1000000), // every 10ms
    .SAMPLE_CLK_WIDTH(56)
  ) u_sample_clk(
    .clk(clk),
    .aresetn(resetn),
    .which_pps(which_pps),
    .pps_ext(pps_ext),
    .sample_idx_reg(sample_idx_reg),
    .sample_idx_reg_valid(sample_idx_reg_valid),
    .sample_idx_incr(sample_idx_incr),
    .sample_idx(sample_idx),
    .pps(pps));

endmodule
