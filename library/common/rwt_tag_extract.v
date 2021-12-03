// Tagged type format:
//   For the defaults (DWIDTH=64, TYPE_WIDTH=7), the format is:
//
//     Bit Index   | 63   |  62-56   | 55-0
//     ============+======+==========+===============
//     Description | More | Tag Type | Tag Value


`timescale 1ns/100ps

module rwt_tag_extract #(
  parameter DWIDTH = 64,
  parameter TYPE_WIDTH = 7
)(
  input                       clk,
  input                       aresetn,

  input                       use_tags,
  input [DWIDTH-1:0]          tag_escape,

  output                      s_axi_ready,
  input                       s_axi_valid,
  input [DWIDTH-1:0]          s_axi_data,
  input                       s_axi_last,

  input                       m_axi_ready,
  output                      m_axi_valid,
  output reg [DWIDTH-1:0]     m_axi_data,
  output reg                  m_axi_tag_valid,
  output reg [TYPE_WIDTH-1:0] m_axi_tag_type,
  output reg                  m_axi_last);

  localparam MORE_FLAG = DWIDTH - 1;
  localparam TAG_WIDTH = DWIDTH - 1 - TYPE_WIDTH;

  wire ready;
  reg  valid;
  reg  reg_magic;
  reg  reg_tlast;

  assign s_axi_ready = ready;
  assign m_axi_valid = valid;

  assign ready = (~valid) || (valid && m_axi_ready);

  always @(posedge clk)
  begin
    if (aresetn == 1'b0) begin
      valid <= 1'b0;
      reg_magic <= 1'b0;
      reg_tlast <= 1'b0;
      m_axi_data <= 'd0;
      m_axi_tag_valid <= 1'b0;
      m_axi_tag_type <= 'd0;
      m_axi_last <= 1'b0;
    end else begin
      if (m_axi_ready) begin
        valid <= 1'b0;
      end

      if (ready && s_axi_valid) begin
        // Default: Pass data through
        valid <= 1'b1;
        reg_magic <= 1'b0;
        reg_tlast <= 1'b0;
        m_axi_data <= s_axi_data;
        m_axi_last <= s_axi_last;
        m_axi_tag_valid <= 1'b0;
        m_axi_tag_type <= 'd0;

        if (use_tags) begin
          if (reg_magic) begin
            if (s_axi_data == 'd0) begin
              // The magic keyword was escaped.
              // magic followed by 0 ==> magic
              m_axi_data <= tag_escape;
              m_axi_last <= reg_tlast | s_axi_last;

            end else begin
              // Else this is a tagged element.

              if (s_axi_data[MORE_FLAG]) begin
                // More tags follow, so continue to process them.
                reg_magic <= 1'b1;
                reg_tlast <= reg_tlast | s_axi_last;
              end

              // Set the tag data.
              m_axi_data <= 'd0;
              m_axi_data[0 +: TAG_WIDTH] <= s_axi_data[0 +: TAG_WIDTH];
              m_axi_tag_type <= s_axi_data[TAG_WIDTH +: TYPE_WIDTH];
              m_axi_last <= 1'b0;
              m_axi_tag_valid <= 1'b1;
            end
          end else begin
            // Note: The !escape is handled by defaults. It passes the
            // data through.
            if (s_axi_data == tag_escape) begin
              valid <= 1'b0;
              reg_magic <= 1'b1;
              reg_tlast <= s_axi_last;
            end

          end
        end
      end
    end
  end
endmodule
