
`timescale 1ns/100ps

module rwt_common_regs #(
  parameter NUM_BLOCKS = 1
) (
  // axi interface
  input                       s_axi_aclk,
  input                       s_axi_aresetn,
  input                       s_axi_awvalid,
  input [15:0]                s_axi_awaddr,
  output                      s_axi_awready,
  input                       s_axi_wvalid,
  input [31:0]                s_axi_wdata,
  input [ 3:0]                s_axi_wstrb,
  output                      s_axi_wready,
  output                      s_axi_bvalid,
  output [ 1:0]               s_axi_bresp,
  input                       s_axi_bready,
  input                       s_axi_arvalid,
  input [15:0]                s_axi_araddr,
  output                      s_axi_arready,
  output                      s_axi_rvalid,
  output [31:0]               s_axi_rdata,
  output [ 1:0]               s_axi_rresp,
  input                       s_axi_rready,

  // Register Interface
  output                      up_clk,
  output                      up_rstn,
  output reg [NUM_BLOCKS-1:0] up_wreq,
  output [8:0]                up_waddr,
  output [31:0]               up_wdata,
  input [NUM_BLOCKS-1:0]      up_wack,
  output reg [NUM_BLOCKS-1:0] up_rreq,
  output [8:0]                up_raddr,
  input [(NUM_BLOCKS*32)-1:0] up_rdata,
  input [NUM_BLOCKS-1:0]      up_rack);

  wire                        up_wreq_s;
  wire [13:0]                 up_waddr_s;
  reg                         up_wack_s;
  wire                        up_rreq_s;
  wire [13:0]                 up_raddr_s;
  reg                         up_rack_s;
  reg [31:0]                  up_rdata_s;

  /**** axi -> up ****/
  up_axi i_up_axi (
    .up_clk(s_axi_aclk),
    .up_rstn(s_axi_aresetn),
    .up_axi_awvalid(s_axi_awvalid),
    .up_axi_awaddr(s_axi_awaddr),
    .up_axi_awready(s_axi_awready),
    .up_axi_wvalid(s_axi_wvalid),
    .up_axi_wdata(s_axi_wdata),
    .up_axi_wstrb(s_axi_wstrb),
    .up_axi_wready(s_axi_wready),
    .up_axi_bvalid(s_axi_bvalid),
    .up_axi_bresp(s_axi_bresp),
    .up_axi_bready(s_axi_bready),
    .up_axi_arvalid(s_axi_arvalid),
    .up_axi_araddr(s_axi_araddr),
    .up_axi_arready(s_axi_arready),
    .up_axi_rvalid(s_axi_rvalid),
    .up_axi_rresp(s_axi_rresp),
    .up_axi_rdata(s_axi_rdata),
    .up_axi_rready(s_axi_rready),
    .up_wreq(up_wreq_s),
    .up_waddr(up_waddr_s),
    .up_wdata(up_wdata),
    .up_wack(up_wack_s),
    .up_rreq(up_rreq_s),
    .up_raddr(up_raddr_s),
    .up_rdata(up_rdata_s),
    .up_rack(up_rack_s));

  assign up_clk = s_axi_aclk;
  assign up_rstn = s_axi_aresetn;
  assign up_raddr = up_raddr_s[8:0];
  assign up_waddr = up_waddr_s[8:0];

  /**** wreq mux ****/
  always @* begin: wreq_mux
    integer i;

    for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
      if (up_waddr_s[13:9] == i) begin
        up_wreq[i] <= up_wreq_s;
      end else begin
        up_wreq[i] <= 1'b0;
      end
    end
  end

  /**** rreq mux ****/
  always @* begin: rreq_mux
    integer i;

    for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
      if (up_raddr_s[13:9] == i) begin
        up_rreq[i] <= up_rreq_s;
      end else begin
        up_rreq[i] <= 1'b0;
      end
    end
  end

  /**** wack mux ****/
  always @* begin: wack_mux
    integer i;

    up_wack_s <= 1'b0;

    for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
      if (up_waddr_s[13:9] == i) begin
        up_wack_s <= up_wack[i];
      end
    end

    if (up_waddr_s[13:9] >= NUM_BLOCKS) begin
      up_wack_s <= up_wreq_s;
    end
  end

  /**** rack mux ****/
  always @* begin: rack_mux
    integer i;

    up_rack_s <= 1'b0;

    for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
      if (up_raddr_s[13:9] == i) begin
        up_rack_s  <= up_rack[i];
      end
    end

    if (up_raddr_s[13:9] >= NUM_BLOCKS) begin
      up_rack_s <= up_rreq_s;
    end
  end

  /**** rdata mux ****/
  always @* begin: rdata_mux
    integer i;

    up_rdata_s <= 'd0;

    for (i = 0; i < NUM_BLOCKS; i = i + 1) begin
      if (up_raddr_s[13:9] == i) begin
        up_rdata_s <= up_rdata[32*i +: 32];
      end
    end
  end

endmodule
