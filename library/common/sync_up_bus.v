
`timescale 1ns/100ps

module sync_up_bus #(
  parameter ASYNC_CLK=1
)(

  // Up-side Interface
  input             up_clk,
  input             up_rstn,
  input             up_wreq,
  input [8:0]       up_waddr,
  input [31:0]      up_wdata,
  output reg        up_wack,
  input             up_rreq,
  input [8:0]       up_raddr,
  output reg [31:0] up_rdata,
  output reg        up_rack,

  // User-side Interface
  input             user_clk,
  input             user_rstn,
  output reg        user_wreq,
  output reg [8:0]  user_waddr,
  output reg [31:0] user_wdata,
  input             user_wack,
  output reg        user_rreq,
  output reg [8:0]  user_raddr,
  input [31:0]      user_rdata,
  input             user_rack);

  reg [40:0]    up_wr_hold;
  reg [8:0]     up_rd_hold;
  reg           up_wreq_hold;
  reg           up_rreq_hold;

  reg           wreq_edge;
  reg           rreq_edge;
  reg [3:0]     user_wreq_hold;
  reg [3:0]     user_rreq_hold;

  reg [31:0]    user_rdata_hold;
  reg [3:0]     user_wack_extend;
  reg [3:0]     user_rack_extend;
  reg [2:0]     up_wack_s;
  reg [3:0]     up_rack_s;
  reg           wack_edge;
  reg           rack_edge;


  always @(posedge up_clk) begin
    if (up_rstn == 0) begin
      up_wr_hold <= 'd0;
      up_rd_hold <= 'd0;
      up_wreq_hold <= 1'b0;
      up_rreq_hold <= 1'b0;
    end else begin
      if (up_wreq_hold) begin
        if (up_wack) begin
          up_wreq_hold <= 1'b0;
        end
      end else if (up_wreq) begin
        up_wr_hold <= {up_wdata, up_waddr};
        up_wreq_hold <= 1'b1;
      end

      if (up_rreq_hold) begin
        if (up_rack) begin
          up_rreq_hold <= 1'b0;
        end
      end else if (up_rreq) begin
        up_rd_hold <= up_raddr;
        up_rreq_hold <= 1'b1;
      end
    end
  end

  always @(posedge user_clk) begin
    if (user_rstn == 0) begin
      user_wreq_hold <= 'd0;
      user_rreq_hold <= 'd0;
      user_wreq <= 1'b0;
      user_wdata <= 'd0;
      user_waddr <= 'd0;
      user_rreq <= 1'b0;
      user_raddr <= 'd0;
    end else begin
      user_wreq_hold <= {user_wreq_hold[2:0], up_wreq_hold};
      user_rreq_hold <= {user_rreq_hold[2:0], up_rreq_hold};

      wreq_edge = (~user_wreq_hold[3]) & user_wreq_hold[2];
      rreq_edge = (~user_rreq_hold[3]) & user_rreq_hold[2];

      user_wreq <= wreq_edge;
      user_rreq <= rreq_edge;

      if (wreq_edge) begin
        user_wdata <= up_wr_hold[40:9];
        user_waddr <= up_wr_hold[8:0];
      end

      if (rreq_edge) begin
        user_raddr <= up_rd_hold;
      end
    end
  end

  always @(posedge user_clk) begin
    user_wack_extend <= {user_wack_extend[2:0], user_wack};
    user_rack_extend <= {user_rack_extend[2:0], user_rack};
  end

  always @(posedge up_clk) begin
    if (up_rstn == 0) begin
      up_wack_s <= 'd0;
      up_rack_s <= 'd0;
      up_rdata <= 'd0;
      up_wack <= 1'b0;
      up_rack <= 1'b0;
    end else begin
      up_wack_s <= {up_wack_s[1:0], |user_wack_extend};
      up_rack_s <= {up_rack_s[2:0], |user_rack_extend};

      rack_edge = (~up_rack_s[3]) & up_rack_s[2];
      wack_edge = (~up_wack_s[2]) & up_wack_s[1];

      if (rack_edge)
        up_rdata <= user_rdata_hold;

      up_wack <= wack_edge;
      up_rack <= rack_edge;
    end
  end

  always @(posedge user_clk) begin
    if (user_rstn == 0) begin
      user_rdata_hold <= 'd0;
    end else begin
      if (user_rack)
        user_rdata_hold <= user_rdata;
    end
  end

endmodule
