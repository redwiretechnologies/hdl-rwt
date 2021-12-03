//untested

module axi_pipeline_equal #(
  parameter DWIDTH = 64,
  parameter UWIDTH = 1,
  parameter CHUNK_SZ = 16
)(
  input               clk,
  input               aresetn,

  input [DWIDTH-1:0]  cmp,

  output              s_axi_ready,
  input               s_axi_valid,
  input [DWIDTH-1:0]  s_axi_data,
  input [UWIDTH-1:0]  s_axi_user,

  input               m_axi_ready,
  output              m_axi_valid,
  output [DWIDTH-1:0] m_axi_data,
  output [UWIDTH-1:0] m_axi_user,
  output              m_axi_equal);

  localparam NUM_CHUNKS = DWIDTH/CHUNK_SZ;

  // @todo: add assert DWIDTH must be a multiple of CHUNK_SZ

  wire                advance;
  reg                 valid [0:NUM_CHUNKS-1];
  reg [UWIDTH-1:0]    user [0:NUM_CHUNKS-1];
  reg [DWIDTH-1:0]    data [0:NUM_CHUNKS-1];
  reg                 notequal [0:NUM_CHUNKS-1];

  assign advance = m_axi_ready | ~valid[NUM_CHUNKS-1];
  assign s_axi_ready = advance;

  assign m_axi_valid = valid[NUM_CHUNKS-1];
  assign m_axi_data = data[NUM_CHUNKS-1];
  assign m_axi_user = user[NUM_CHUNKS-1];
  assign m_axi_equal = ~notequal[NUM_CHUNKS-1];

  always @(posedge clk) begin: sync_proc
    integer i;

    if (aresetn == 1'b0) begin
      for (i=0; i < NUM_CHUNKS; i = i + 1) begin
        valid[i] <= 1'b0;
        user[i] <= 'd0;
        data[i] <= 'd0;
        notequal[i] <= 1'b0;
      end
    end else begin
      if (advance) begin
        valid[0] <= s_axi_valid;
        user[0] <= s_axi_user;
        data[0] <= s_axi_data;
        notequal[0] <= s_axi_data[0 +: CHUNK_SZ] != cmp[0 +: CHUNK_SZ];

        for (i=1; i < NUM_CHUNKS; i = i + 1) begin
          valid[i] <= valid[i - 1];
          user[i] <= user[i - 1];
          data[i] <= data[i - 1];
          notequal[i] <= notequal[i - 1] |
                         (data[i-1][i*CHUNK_SZ +: CHUNK_SZ] !=
                           cmp[i*CHUNK_SZ +: CHUNK_SZ]);
        end
      end
    end
  end

endmodule
