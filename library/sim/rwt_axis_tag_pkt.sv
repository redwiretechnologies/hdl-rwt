// SPDX-License-Identifier: Apache-2.0

`ifndef RWT_AXIS_TAG_PKT_SV
`define RWT_AXIS_TAG_PKT_SV

`include "rwt_parse_utils.sv"
`include "rwt_axis.sv"

`define RWT_AXIS_TAG_CONNECT_NOUSER(prefix, axis_if) \
  `RWT_AXIS_CONNECT_NOUSER(prefix, axis_if.streamer)

`define RWT_AXIS_TAG_CONNECT(prefix, axis_if) \
  `RWT_AXIS_CONNECT(prefix, axis_if.streamer)

typedef struct {
  logic [6:0]  tag_type;
  logic [63:0] value;
  int          pos;
} rwt_tag_t;


interface rwt_axis_tag_pkt
#(
  parameter DWIDTH = 32,
  parameter UWIDTH = 1
) (
  input logic m_clk,
  input logic m_resetn
);

  rwt_axis #(DWIDTH, UWIDTH) streamer(m_clk, m_resetn);

  task automatic master_reset;
    begin
      streamer.master_reset();
    end
  endtask;

  task automatic slave_reset;
    begin
      streamer.slave_reset();
    end
  endtask;

  task automatic _read_escaped_or_tag_pkt (
    output logic [DWIDTH-1:0] pkt[$],
    output logic [UWIDTH-1:0] user_q[$],
    output rwt_tag_t           tags[$],
    input int                 use_tag_bit,
    input int                 use_escape,
    input int                 tag_bit,
    input logic [DWIDTH-1:0]  magic_word,
    input int                 max_samples = 0,
    input int                 throttle = 0,
    input int                 ignore_last = 0,
    input int                 monitor = 0);
    begin
      logic [DWIDTH-1:0] value;
      logic [UWIDTH-1:0] user;
      logic              last = 1'b0;
      logic              is_magic = 1'b0;
      rwt_tag_t           tag;
      int                idx = 0;

      assert(DWIDTH > 8);
      assert((ignore_last == 0) || (max_samples != 0));
      assert((!use_tag_bit) || (tag_bit < UWIDTH));


      while (~last) begin
        if ((max_samples != 0) && (idx >= max_samples)) begin
          break;
        end

        streamer.read_tags(value, user, last, throttle, monitor);
        last = ignore_last ? 1'b0 : last;

        if (is_magic) begin
          if (value == 'd0) begin
            pkt.push_back(magic_word);
            user_q.push_back(user);
            idx = idx + 1;
            is_magic = 1'b0;
          end else begin
            if (~value[DWIDTH-1]) begin
              // More is '0', so no more tags.
              is_magic = 1'b0;
            end

            tag.pos = idx;
            tag.tag_type = value[DWIDTH-2:DWIDTH-8];
            tag.value[DWIDTH-9:0] = value[DWIDTH-9:0];
            tag.value[63:DWIDTH-8] = 'd0;
            tags.push_back(tag);
          end
        end else if (use_escape && (value == magic_word)) begin
          is_magic = 1'b1;
        end else if (use_tag_bit && user[use_tag_bit]) begin
          tag.pos = idx;
          tag.tag_type = value[DWIDTH-2:DWIDTH-8];
          tag.value[DWIDTH-9:0] = value[DWIDTH-9:0];
          tag.value[63:DWIDTH-8] = 'd0;
          tags.push_back(tag);
        end else begin
          pkt.push_back(value);
          user_q.push_back(user);
          idx = idx + 1;
        end
      end
    end
  endtask

  task automatic _write_escaped_or_tag_pkt (
    input logic [DWIDTH-1:0] pkt[$],
    input logic [UWIDTH-1:0] user[$],
    input rwt_tag_t           tags[$],
    input int                use_tag_bit,
    input int                use_escape,
    input int                tag_bit,
    input [DWIDTH-1:0]       magic_word,
    input logic              send_last,
    input int                throttle);

    begin
      logic [DWIDTH-1:0] value;
      logic              more;
      logic              last;
      int                tag_idx = 0;
      logic [UWIDTH-1:0] tag_user = 'd0;
      logic [UWIDTH-1:0] user_value;

      assert(DWIDTH > 8);
      assert((!use_tag_bit) || (tag_bit < UWIDTH));

      if (use_tag_bit) begin
        tag_user[tag_bit] = 1'b1;
      end

      for (int idx = 0; idx < pkt.size(); idx++) begin
        if (tag_idx < tags.size()) begin
          while (tags[tag_idx].pos < idx) begin
            tag_idx = tag_idx + 1;
          end

          if (tags[tag_idx].pos == idx) begin
            if (use_escape) begin
              streamer.write(magic_word, 0, 1'b0, throttle);
            end

            while ((tag_idx < tags.size()) && (tags[tag_idx].pos == idx)) begin
              if (((tag_idx+1 < tags.size()) && (tags[tag_idx+1].pos == idx))) begin
                more = 1'b1;
              end else begin
                more = 1'b0;
              end

              value = {
                more,
                tags[tag_idx].tag_type,
                tags[tag_idx].value[DWIDTH-9:0]};

              streamer.write(value, tag_user, 1'b0, throttle);
              tag_idx = tag_idx + 1;
            end
          end
        end

        last = (idx == (pkt.size() - 1)) ? send_last : 1'b0;

        if (user.size() > idx)
          user_value = user[idx];
        else
          user_value = 0;

        if ((use_escape != 0) && (pkt[idx] == magic_word)) begin
          streamer.write(magic_word, 0, 1'b0, throttle);
          streamer.write(0, user_value, last, throttle);
        end else begin
          streamer.write(pkt[idx], user_value, last, throttle);
        end
      end
    end
  endtask

  task automatic _file_sink_escaped_or_tag(
    input string             filename,
    input int                use_tag_bit,
    input int                use_escape,
    input int                tag_bit,
    input logic [DWIDTH-1:0] magic_word,
    input int                append = 0,
    input int                only_nonzero_user = 1,
    input int                throttle = 0,
    input int                max_pkts = 0,
    input int                monitor = 0);

    begin
      int fd;
      int ret;
      int num_pkts = 0;
      int tag_idx = 0;
      logic [DWIDTH-1:0] pkt[$];
      logic [UWIDTH-1:0] user[$];
      rwt_tag_t tags[$];

      if (append)
        fd = $fopen(filename, "a");
      else
        fd = $fopen(filename, "w");

      if (!fd) begin
        $display("Could not open %s", filename);
        return;
      end

      while (1) begin
        _read_escaped_or_tag_pkt(
          pkt, user, tags,
          use_tag_bit, use_escape, tag_bit, magic_word,
          0, throttle, 0, monitor);

        tag_idx = 0;

        for (int i=0; i < pkt.size(); i++) begin
          if (tag_idx < tags.size()) begin
            while (tags[tag_idx].pos < i) begin
              tag_idx = tag_idx + 1;
            end

            while ((tag_idx < tags.size()) && (tags[tag_idx].pos == i)) begin
              $fwrite(fd, "+ %x %x\n", tags[tag_idx].value[DWIDTH-9:0], tags[tag_idx].tag_type);
              tag_idx = tag_idx + 1;
            end
          end

          if (i == pkt.size()-1)
            $fwrite(fd, "* ");
          else
            $fwrite(fd, "  ");

          $fwrite(fd, "%x", pkt[i]);
          if ((only_nonzero_user == 0) || (user[i] != 0))
            $fwrite(fd, " %x", user[i]);
          $fwrite(fd, "\n");
        end

        $fflush(fd);
        num_pkts++;

        if (max_pkts && (num_pkts >= max_pkts))
          break;
      end

      $fclose(fd);
    end
  endtask

  task automatic _file_source_escaped_or_tag(
    input string             filename,
    input int                use_tag_bit,
    input int                use_escape,
    input int                tag_bit,
    input logic [DWIDTH-1:0] magic_word,
    input logic              send_last = 1'b1,
    input int                throttle = 0);
    begin
      logic [DWIDTH-1:0] pkt[$];
      logic [UWIDTH-1:0] user_q[$];
      rwt_tag_t tags[$];
      int fd;
      int ret;
      int idx = 0;
      string line;

      logic [DWIDTH-1:0] data;
      logic [UWIDTH-1:0] user;
      logic [6:0]        tag_type;
      logic              last;
      parse_line_type_t  line_type;
      rwt_tag_t tag;

      fd = $fopen(filename, "r");
      if (!fd) begin
        $display("Could not open %s", filename);
        return;
      end

      while (!$feof(fd)) begin
        ret = $fgets(line, fd);
        idx++;

        parse_axis #(DWIDTH,UWIDTH)::parse(
          line, line_type, data, user, tag_type, last);

        if (line_type == BLANK) begin
          continue;
        end else if (line_type == DATA) begin
          pkt.push_back(data);
          user_q.push_back(user);

          if (last) begin
            _write_escaped_or_tag_pkt(
              pkt, user_q, tags, use_tag_bit, use_escape, tag_bit,
              magic_word, send_last, throttle);

            pkt = {};
            user_q = {};
            tags = {};
          end

        end else if (line_type == TAGGED) begin
          tag.pos = pkt.size();
          tag.tag_type = tag_type;
          tag.value[DWIDTH-9:0] = data[DWIDTH-9:0];
          tag.value[63:DWIDTH-8] = 'd0;
          tags.push_back(tag);

        end else begin
          $display("Invalid Line %4d in %s", idx, filename);
          continue;
        end
      end

      if (pkt.size() != 0) begin
        $display("Extra data begin dropped in filename %s", filename);
      end

      $fclose(fd);
    end
  endtask

  task automatic read_escaped_pkt (
    output logic [DWIDTH-1:0] pkt[$],
    output logic [UWIDTH-1:0] user[$],
    output rwt_tag_t           tags[$],
    input logic [DWIDTH-1:0]  magic_word,
    input int                 max_samples = 0,
    input int                 throttle = 0,
    input int                 ignore_last = 0,
    input int                 monitor = 0);
    begin
      _read_escaped_or_tag_pkt(
        pkt, user, tags, 0, 1, 0, magic_word,
        max_samples, throttle, ignore_last, monitor);
    end
  endtask

  task automatic read_tagged_pkt (
    output logic [DWIDTH-1:0] pkt[$],
    output logic [UWIDTH-1:0] user[$],
    output rwt_tag_t           tags[$],
    input int                 tag_bit,
    input int                 max_samples = 0,
    input int                 throttle = 0,
    input int                 ignore_last = 0,
    input int                 monitor = 0);
    begin
      _read_escaped_or_tag_pkt(
        pkt, user, tags, 1, 0, tag_bit, 0,
        max_samples, throttle, ignore_last, monitor);
    end
  endtask

  task automatic write_escaped_pkt (
    input logic [DWIDTH-1:0] pkt[$],
    input logic [UWIDTH-1:0] user[$],
    input rwt_tag_t           tags[$],
    input [DWIDTH-1:0]       magic_word,
    input logic              send_last = 1'b1,
    input int                throttle = 0);
    begin
      _write_escaped_or_tag_pkt(
        pkt, user, tags, 0, 1, 0, magic_word, send_last, throttle);
    end
  endtask

  task automatic write_tagged_pkt (
    input logic [DWIDTH-1:0] pkt[$],
    input logic [UWIDTH-1:0] user[$],
    input rwt_tag_t           tags[$],
    input int                tag_bit,
    input logic              send_last = 1'b1,
    input int                throttle = 0);
    begin
      _write_escaped_or_tag_pkt(
        pkt, user, tags, 1, 0, tag_bit, 'd0, send_last, throttle);
    end
  endtask

  task automatic file_source_escaped(
    input string             filename,
    input logic [DWIDTH-1:0] magic_word,
    input logic              send_last = 1'b1,
    input int                throttle = 0);
    begin
      _file_source_escaped_or_tag(
        filename, 0, 1, 0, magic_word, send_last, throttle);
    end
  endtask;

  task automatic file_source_tagged(
    input string             filename,
    input int                tag_bit,
    input logic              send_last = 1'b1,
    input int                throttle = 0);
    begin
      _file_source_escaped_or_tag(
        filename, 1, 0, tag_bit, 0, send_last, throttle);
    end
  endtask;

  task automatic file_sink_escaped(
    input string             filename,
    input logic [DWIDTH-1:0] magic_word,
    input int                append = 0,
    input int                only_nonzero_user = 1,
    input int                throttle = 0,
    input int                max_pkts = 0,
    input int                monitor = 0);

    begin
      _file_sink_escaped_or_tag(
        filename, 0, 1, 0, magic_word, append,
        only_nonzero_user, throttle, max_pkts, monitor);
    end
  endtask;

  task automatic file_sink_tagged(
    input string             filename,
    input int                tag_bit,
    input int                append = 0,
    input int                only_nonzero_user = 1,
    input int                throttle = 0,
    input int                max_pkts = 0,
    input int                monitor = 0);

    begin
      _file_sink_escaped_or_tag(
        filename, 1, 0, tag_bit, 0, append,
        only_nonzero_user, throttle, max_pkts, monitor);
    end
  endtask;

endinterface

`endif
