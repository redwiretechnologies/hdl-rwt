`ifndef RWT_AXIS_SV
`define RWT_AXIS_SV

`include "rwt_parse_utils.sv"


`define RWT_AXIS_CONNECT_NOUSER(prefix, axis_if) \
  .``prefix``ready(axis_if.m_ready),            \
  .``prefix``valid(axis_if.m_valid),            \
  .``prefix``data(axis_if.m_data),              \
  .``prefix``last(axis_if.m_last)

`define RWT_AXIS_CONNECT(prefix, axis_if)   \
  `RWT_AXIS_CONNECT_NOUSER(prefix,axis_if), \
  .``prefix``user(axis_if.m_user)

interface rwt_axis #(
  parameter DWIDTH = 32,
  parameter UWIDTH = 1
 ) (
  input logic m_clk,
  input logic m_resetn
);
  logic m_ready = 0;
  logic m_valid = 0;
  logic [DWIDTH-1:0] m_data = 0;
  logic [UWIDTH-1:0] m_user = 0;
  logic              m_last = 0;
  logic              stop = 0;

  modport master (
    output m_data,
    output m_valid,
    output m_user,
    output m_last,
    input  m_ready);

  modport slave (
    input  m_data,
    input  m_valid,
    input  m_user,
    input  m_last,
    output m_ready);

  task automatic master_reset;
    begin
      m_valid = 0;
      m_data = 0;
      m_user = 0;
      m_last = 0;
    end
  endtask

  task automatic slave_reset;
    begin
      m_ready = 0;
    end
  endtask

  task automatic write(
    input logic [DWIDTH-1:0] data,
    input logic [UWIDTH-1:0] user = 'd0,
    input logic              last = 1'b0,
    input int                throttle = 0);
    begin
      for (int i = 0; i < throttle; i++) begin
        @(posedge m_clk);
      end

      m_valid <= 1'b1;
      m_data <= data;
      m_user <= user;
      m_last <= last;

      do begin
        @(posedge m_clk);
      end while (m_ready == 0);

      m_valid <= 1'b0;
      m_data <= 'd0;
      m_user <= 'd0;
      m_last <= 1'b0;
    end
  endtask

  task automatic read_tags (
    output logic [DWIDTH-1:0] data,
    output logic [UWIDTH-1:0] user,
    output logic              last,
    input int                 throttle = 0,
    input int                 monitor = 0);
    begin
      if (monitor) begin
        // Monitor doesn't drive m_ready. It just monitors the channel.
        // In monitor mode, throttle is ignored.
        do begin
          @(posedge m_clk);
        end while (~(m_valid & m_ready));
      end else begin

        for (int i = 0; i < throttle; i++) begin
          @(posedge m_clk);
        end

        m_ready <= 1'b1;

        do begin
          @(posedge m_clk);
        end while (m_valid == 0);

        m_ready <= 1'b0;
      end

      data = m_data;
      user = m_user;
      last = m_last;
    end
  endtask

  task automatic read (
    output logic [DWIDTH-1:0] data,
    input int                 throttle = 0,
    input int                 monitor = 0);
    begin
      logic last = 1'b0;
      logic [UWIDTH-1:0] user = 'd0;
      read_tags(data, user, last, throttle, monitor);
    end
  endtask

  task automatic read_until_stop(
    input int throttle = 0);
    begin
      logic [DWIDTH-1:0] value;
      while (~stop) begin
        read(value, throttle);
      end
    end
  endtask

  task automatic read_pkt(
    output logic [DWIDTH-1:0] pkt[$],
    input int                 max_samples = 0,
    input int                 throttle = 0,
    input int                 ignore_last = 0,
    input int                 monitor = 0);
    begin
      logic [DWIDTH-1:0] value;
      logic              last = 1'b0;
      logic              user;
      int                idx = 0;

      while (~last) begin
        if ((max_samples != 0) && (idx >= max_samples)) begin
          break;
        end

        read_tags(value, user, last, throttle, monitor);
        last = ignore_last ? 1'b0 : last;

        pkt.push_back(value);
        idx = idx + 1;

      end
    end
  endtask

  task automatic write_pkt(
    input logic [DWIDTH-1:0] pkt[$],
    input logic              send_last = 1'b1,
    input int                throttle = 0);
    begin
      if (pkt.size() == 0) begin
        return;
      end

      for (int i = 0; i < pkt.size()-1; i = i+1) begin
        write(pkt[i], 0, 1'b0, throttle);
      end
      write(pkt[pkt.size()-1], 0, send_last, throttle);
    end
  endtask

  task automatic file_source(
    input string filename,
    input int    throttle = 0);
    begin
      int fd;
      int ret;
      int idx = 0;
      string line;
      logic [DWIDTH-1:0] data;
      logic [UWIDTH-1:0] user;
      logic [6:0]        tag_type;
      logic              last;
      parse_line_type_t  line_type;

      fd = $fopen(filename, "r");
      if (!fd) begin
        $display("Could not open %s", filename);
        return;
      end

      @(posedge m_clk);

      while (!$feof(fd)) begin
        ret = $fgets(line, fd);
        idx++;

        parse_axis #(DWIDTH,UWIDTH)::parse(
          line, line_type, data, user, tag_type, last);

        if (line_type == BLANK) begin
          //$display("Line %4d: Blank", idx);
          continue;
        end else if (line_type != DATA) begin
          $display("Invalid Line %4d in %s", idx, filename);
          continue;
        end

        //$display("Line %4d: %x %x %x", idx, data, user, last);

        write(data, user, last, throttle);
      end
      $fclose(fd);
    end
  endtask

  task automatic file_sink(
    input string filename,
    input int    append = 0,
    input int    only_nonzero_user = 1,
    input int    throttle = 0,
    input int    max_samples = 0,
    input int    max_pkts = 0,
    input int    monitor = 0);

    begin
      int fd;
      int ret;
      int num_samples = 0;
      int num_pkts = 0;
      logic [DWIDTH-1:0] data;
      logic [UWIDTH-1:0] user;
      logic              last;

      if (append)
        fd = $fopen(filename, "a");
      else
        fd = $fopen(filename, "w");

      if (!fd) begin
        $display("Could not open %s", filename);
        return;
      end

      while (1) begin
        read_tags(data, user, last, throttle, monitor);

        if (last)
          $fwrite(fd, "* ");
        else
          $fwrite(fd, "  ");

        $fwrite(fd, "%x", data);
        if (!only_nonzero_user || (user != 0))
          $fwrite(fd, " %x", user);
        $fwrite(fd, "\n");

        if (last)
          $fflush(fd);
        else if ((num_samples % 100) == 99)
          $fflush(fd);

        num_samples++;
        if (last)
          num_pkts++;

        if (max_samples && (num_samples >= max_samples))
          break;
        else if (max_pkts && (num_pkts >= max_pkts))
          break;
      end

      $fclose(fd);
    end
  endtask
endinterface

`endif
