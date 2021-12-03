//untested

module axi_pipeline_add #(
  parameter DWIDTH = 64,
  parameter UWIDTH = 1,
  parameter CHUNK_SZ = 16
)(
  input               clk,
  input               aresetn,

  input [DWIDTH-1:0]  cmp,

  output              s_axi_ready,
  input               s_axi_valid,
  input [DWIDTH-1:0]  s_axi_data_a,
  input [DWIDTH-1:0]  s_axi_data_b,
  input [UWIDTH-1:0]  s_axi_user,

  input               m_axi_ready,
  output              m_axi_valid,
  output [DWIDTH-1:0] m_axi_data_a,
  output [DWIDTH-1:0] m_axi_data_b,
  output [DWIDTH-1:0] m_axi_data_result,
  output              m_axi_data_carry,
  output [UWIDTH-1:0] m_axi_user);

  localparam NUM_CHUNKS = DWIDTH/CHUNK_SZ;

  // @todo: add assert DWIDTH must be a multiple of CHUNK_SZ

  wire             advance;
  reg              valid [0:NUM_CHUNKS-1];
  reg [UWIDTH-1:0] user [0:NUM_CHUNKS-1];
  reg [DWIDTH-1:0] a [0:NUM_CHUNKS-1];
  reg [DWIDTH-1:0] b [0:NUM_CHUNKS-1];
  reg [DWIDTH-1:0] result [0:NUM_CHUNKS-1];
  reg              carry [0:NUM_CHUNKS-1];

  reg              c;
  reg [CHUNK_SZ-1:0] value;

  assign advance = m_axi_ready | ~valid[NUM_CHUNKS-1];
  assign s_axi_ready = advance;

  assign m_axi_valid = valid[NUM_CHUNKS-1];
  assign m_axi_data_a = a[NUM_CHUNKS-1];
  assign m_axi_data_b = b[NUM_CHUNKS-1];
  assign m_axi_data_result = result[NUM_CHUNKS-1];
  assign m_axi_data_carry = carry[NUM_CHUNKS-1];
  assign m_axi_user = user[NUM_CHUNKS-1];

  always @(posedge clk) begin: sync_proc
    integer i;

    if (aresetn == 1'b0) begin
      for (i=0; i < NUM_CHUNKS; i = i + 1) begin
        valid[i] <= 1'b0;
        user[i] <= 'd0;
        a[i] <= 'd0;
        b[i] <= 'd0;
        result[i] <= 'd0;
        carry[i] <= 'd0;
      end
    end else begin
      if (advance) begin
        valid[0] <= s_axi_valid;
        user[0] <= s_axi_user;
        a[0] <= s_axi_data_a;
        b[0] <= s_axi_data_b;

        {c, value} = s_axi_data_a[0 +: CHUNK_SZ] + s_axi_data_b[0 +: CHUNK_SZ];
        carry[0] <= c;
        result[0] <= 'd0;
        result[0][0 +: CHUNK_SZ] <= value;

        for (i=1; i < NUM_CHUNKS; i = i + 1) begin
          valid[i] <= valid[i - 1];
          user[i] <= user[i - 1];
          a[i] <= a[i - 1];
          b[i] <= b[i - 1];

          {c, value} = {{CHUNK_SZ-1{1'b0}}, carry[i-1]} +
                       a[i-1][i*CHUNK_SZ +: CHUNK_SZ] +
                       b[i-1][i*CHUNK_SZ +: CHUNK_SZ];
          carry[i] <= c;

          result[i] <= result[i-1];
          result[i][i*CHUNK_SZ +: CHUNK_SZ] <= value;
        end
      end
    end
  end

endmodule
