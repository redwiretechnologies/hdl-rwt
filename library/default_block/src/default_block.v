
`timescale 1ns/100ps

module default_block #(
  parameter CLK_FREQ = 100000000,
  parameter ENABLE_DUAL_CIC = 0
)(
  input         user_clk,
  input         user_resetn,

  // axi interface
  input         s_axi_aclk,
  input         s_axi_aresetn,
  input         s_axi_awvalid,
  input [15:0]  s_axi_awaddr,
  input [ 2:0]  s_axi_awprot,
  output        s_axi_awready,
  input         s_axi_wvalid,
  input [31:0]  s_axi_wdata,
  input [ 3:0]  s_axi_wstrb,
  output        s_axi_wready,
  output        s_axi_bvalid,
  output [ 1:0] s_axi_bresp,
  input         s_axi_bready,
  input         s_axi_arvalid,
  input [15:0]  s_axi_araddr,
  input [ 2:0]  s_axi_arprot,
  output        s_axi_arready,
  output        s_axi_rvalid,
  output [31:0] s_axi_rdata,
  output [ 1:0] s_axi_rresp,
  input         s_axi_rready,

  // Misc Signals
  input         pps,

  // 9361 interface
  input         adc_rstn,
  input         adc_clk,
  input [63:0]  adc_data,
  input [3:0]   adc_enable,
  input [3:0]   adc_valid,
  output        adc_overflow,

  // ADC DMA interface
  input         m_adc_dma_aclk,
  input         m_adc_dma_aresetn,
  input         m_adc_dma_ready,
  output        m_adc_dma_valid,
  output [63:0] m_adc_dma_data,
  output [0:0]  m_adc_dma_user,
  output        m_adc_dma_last,

  // DAC DMA interface
  input         s_dac_dma_aclk,
  input         s_dac_dma_aresetn,
  output        s_dac_dma_ready,
  input         s_dac_dma_valid,
  input [63:0]  s_dac_dma_data,
  input         s_dac_dma_last,

  // 9361 interface
  input         dac_rstn,
  input         dac_clk,
  output [63:0] dac_data,
  input [3:0]   dac_enable,
  input [3:0]   dac_valid,
  output        dac_underflow);

  /****************************************************************************
   * Registers
   ***************************************************************************/
  localparam    NUM_REG_BLOCKS = 3;
  localparam    REG_BLK = 0;
  localparam    REG_ADC = 1;
  localparam    REG_DAC = 2;

  wire          up_clk;
  wire          up_rstn;
  wire [8:0]    up_waddr;
  wire [8:0]    up_raddr;
  wire [31:0]   up_wdata;
  wire [31:0]   up_rdata[0:NUM_REG_BLOCKS-1];
  reg [(32*NUM_REG_BLOCKS)-1:0]  up_rdata_flatten;
  wire [NUM_REG_BLOCKS-1:0]      up_wreq;
  wire [NUM_REG_BLOCKS-1:0]      up_wack;
  wire [NUM_REG_BLOCKS-1:0]      up_rreq;
  wire [NUM_REG_BLOCKS-1:0]      up_rack;
  wire [31:0]   up_rdata_dummy;
  wire          up_rack_dummy;
  wire          up_wack_dummy;

  /**** AXI --> UP ****/
  rwt_common_regs #(
    .NUM_BLOCKS(NUM_REG_BLOCKS))
  i_rwt_common_regs (
    .s_axi_aclk(s_axi_aclk),
    .s_axi_aresetn(s_axi_aresetn),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awready(s_axi_awready),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wstrb(s_axi_wstrb),
    .s_axi_wready(s_axi_wready),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bready(s_axi_bready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arready(s_axi_arready),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rready(s_axi_rready),

    .up_clk(up_clk),
    .up_rstn(up_rstn),
    .up_wreq(up_wreq),
    .up_waddr(up_waddr),
    .up_wdata(up_wdata),
    .up_wack(up_wack),
    .up_rreq(up_rreq),
    .up_raddr(up_raddr),
    .up_rdata(up_rdata_flatten),
    .up_rack(up_rack));

  always @* begin: flatten_proc
    integer i;
    for (i = 0; i < NUM_REG_BLOCKS; i = i + 1) begin
	  up_rdata_flatten[32*i +: 32] <= up_rdata[i];
    end
  end

  /****************************************************************************
   * ADC
   ***************************************************************************/
  wire            m_adc_user_aclk;
  wire            m_adc_user_aresetn;
  wire            m_adc_user_ready;
  wire            m_adc_user_valid;
  wire [63:0]     m_adc_user_data;
  wire [3:0]      m_adc_user_enables;
  wire [9:0]      m_adc_user_level;

  wire            s_adc_user_aclk;
  wire            s_adc_user_aresetn;
  wire            s_adc_user_ready;
  wire            s_adc_user_valid;
  wire [63:0]     s_adc_user_data;
  wire            s_adc_user_tag_valid;
  wire [6:0]      s_adc_user_tag_type;
  wire            s_adc_user_last;

  rwt_common_adc_if i_adc(
    .up_clk(up_clk),
    .up_rstn(up_rstn),
    .up_wreq(up_wreq[REG_ADC]),
    .up_waddr(up_waddr),
    .up_wdata(up_wdata),
    .up_wack(up_wack[REG_ADC]),
    .up_rreq(up_rreq[REG_ADC]),
    .up_raddr(up_raddr),
    .up_rdata(up_rdata[REG_ADC]),
    .up_rack(up_rack[REG_ADC]),

    .adc_rst(~adc_rstn),
    .adc_clk(adc_clk),
    .adc_data(adc_data),
    .adc_enable(adc_enable),
    .adc_valid(adc_valid),
    .adc_overflow(),

    .m_user_aclk(m_adc_user_aclk),
    .m_user_aresetn(m_adc_user_aresetn),
    .m_user_ready(m_adc_user_ready),
    .m_user_valid(m_adc_user_valid),
    .m_user_data(m_adc_user_data),
    .m_user_enables(m_adc_user_enables),
    .m_user_level(m_adc_user_level),

    .s_user_aclk(s_adc_user_aclk),
    .s_user_aresetn(s_adc_user_aresetn),
    .s_user_ready(s_adc_user_ready),
    .s_user_valid(s_adc_user_valid),
    .s_user_data(s_adc_user_data),
    .s_user_tag_valid(s_adc_user_tag_valid),
    .s_user_tag_type(s_adc_user_tag_type),
    .s_user_last(s_adc_user_last),

    .m_dma_aclk(m_adc_dma_aclk),
    .m_dma_aresetn(m_adc_dma_aresetn),
    .m_dma_ready(m_adc_dma_ready),
    .m_dma_valid(m_adc_dma_valid),
    .m_dma_data(m_adc_dma_data),
    .m_dma_user(m_adc_dma_user),
    .m_dma_last(m_adc_dma_last));


  /****************************************************************************
   * DAC
   ***************************************************************************/
  wire            m_dac_user_aclk;
  wire            m_dac_user_aresetn;
  wire            m_dac_user_ready;
  wire            m_dac_user_valid;
  wire [63:0]     m_dac_user_data;
  wire            m_dac_user_tag_valid;
  wire [6:0]      m_dac_user_tag_type;
  wire            m_dac_user_last;

  wire            s_dac_user_aclk;
  wire            s_dac_user_aresetn;
  wire            s_dac_user_ready;
  wire            s_dac_user_valid;
  wire [63:0]     s_dac_user_data;
  wire            s_dac_user_empty;
  wire [9:0]      s_dac_user_room;
  wire [3:0]      s_dac_user_enables;

  rwt_common_dac_if i_dac(
    .up_clk(up_clk),
    .up_rstn(up_rstn),
    .up_wreq(up_wreq[REG_DAC]),
    .up_waddr(up_waddr),
    .up_wdata(up_wdata),
    .up_wack(up_wack[REG_DAC]),
    .up_rreq(up_rreq[REG_DAC]),
    .up_raddr(up_raddr),
    .up_rdata(up_rdata[REG_DAC]),
    .up_rack(up_rack[REG_DAC]),

    .s_dma_aclk(s_dac_dma_aclk),
    .s_dma_aresetn(s_dac_dma_aresetn),
    .s_dma_ready(s_dac_dma_ready),
    .s_dma_valid(s_dac_dma_valid),
    .s_dma_data(s_dac_dma_data),
    .s_dma_last(s_dac_dma_last),

    .m_user_aclk(m_dac_user_aclk),
    .m_user_aresetn(m_dac_user_aresetn),
    .m_user_ready(m_dac_user_ready),
    .m_user_valid(m_dac_user_valid),
    .m_user_data(m_dac_user_data),
    .m_user_tag_valid(m_dac_user_tag_valid),
    .m_user_tag_type(m_dac_user_tag_type),
    .m_user_last(m_dac_user_last),

    .s_user_aclk(s_dac_user_aclk),
    .s_user_aresetn(s_dac_user_aresetn),
    .s_user_ready(s_dac_user_ready),
    .s_user_valid(s_dac_user_valid),
    .s_user_data(s_dac_user_data),
    .s_user_enables(s_dac_user_enables),
    .s_user_empty(s_dac_user_empty),
    .s_user_room(s_dac_user_room),

    .dac_rst(~dac_rstn),
    .dac_clk(dac_clk),
    .dac_data(dac_data),
    .dac_enable(dac_enable),
    .dac_valid(dac_valid),
    .dac_underflow());


  /****************************************************************************
   * User Code
   ***************************************************************************/

  default_block_user #(
    .CLK_FREQ(CLK_FREQ),
    .ENABLE_DUAL_CIC(ENABLE_DUAL_CIC)
  )
  i_user(
    .user_clk(user_clk),
    .user_resetn(user_resetn),
    .dac_clk(dac_clk),
    .dac_rstn(dac_rstn),
    .adc_clk(adc_clk),
    .adc_rstn(adc_rstn),

    .pps_ext(pps),
    .adc_overflow(adc_overflow),
    .dac_underflow(dac_underflow),

    .up_clk(up_clk),
    .up_rstn(up_rstn),
    .up_wreq(up_wreq[REG_BLK]),
    .up_waddr(up_waddr),
    .up_wdata(up_wdata),
    .up_wack(up_wack[REG_BLK]),
    .up_rreq(up_rreq[REG_BLK]),
    .up_raddr(up_raddr),
    .up_rdata(up_rdata[REG_BLK]),
    .up_rack(up_rack[REG_BLK]),

    .s_adc_aclk(m_adc_user_aclk),
    .s_adc_aresetn(m_adc_user_aresetn),
    .s_adc_ready(m_adc_user_ready),
    .s_adc_valid(m_adc_user_valid),
    .s_adc_data(m_adc_user_data),
    .s_adc_enables(m_adc_user_enables),
    .s_adc_level(m_adc_user_level),

    .m_adc_aclk(s_adc_user_aclk),
    .m_adc_aresetn(s_adc_user_aresetn),
    .m_adc_ready(s_adc_user_ready),
    .m_adc_valid(s_adc_user_valid),
    .m_adc_data(s_adc_user_data),
    .m_adc_tag_valid(s_adc_user_tag_valid),
    .m_adc_tag_type(s_adc_user_tag_type),
    .m_adc_last(s_adc_user_last),

    .s_dac_aclk(m_dac_user_aclk),
    .s_dac_aresetn(m_dac_user_aresetn),
    .s_dac_ready(m_dac_user_ready),
    .s_dac_valid(m_dac_user_valid),
    .s_dac_data(m_dac_user_data),
    .s_dac_tag_valid(m_dac_user_tag_valid),
    .s_dac_tag_type(m_dac_user_tag_type),
    .s_dac_last(m_dac_user_last),

    .m_dac_aclk(s_dac_user_aclk),
    .m_dac_aresetn(s_dac_user_aresetn),
    .m_dac_ready(s_dac_user_ready),
    .m_dac_valid(s_dac_user_valid),
    .m_dac_enables(s_dac_user_enables),
    .m_dac_empty(s_dac_user_empty),
    .m_dac_room(s_dac_user_room),
    .m_dac_data(s_dac_user_data));
endmodule
