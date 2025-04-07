// SPDX-License-Identifier: Apache-2.0

`ifndef RWT_UP_LIB_SV
`define RWT_UP_LIB_SV

`define RWT_UP_CONNECT(prefix, up_if)  \
    .``prefix``wreq(up_if.up_wreq),   \
    .``prefix``waddr(up_if.up_waddr), \
    .``prefix``wdata(up_if.up_wdata), \
    .``prefix``wack(up_if.up_wack),   \
    .``prefix``rreq(up_if.up_rreq),   \
    .``prefix``raddr(up_if.up_raddr), \
    .``prefix``rdata(up_if.up_rdata), \
    .``prefix``rack(up_if.up_rack)


interface rwt_up_lib #(
  parameter   ADDRESS_WIDTH = 14
)(
  input logic up_clk,
  input logic up_rstn);

  logic                     up_wreq = 0;
  logic [ADDRESS_WIDTH-1:0] up_waddr = 0;
  logic [31:0]              up_wdata = 0;
  logic                     up_wack = 0;
  logic                     up_rreq = 0;
  logic [ADDRESS_WIDTH-1:0] up_raddr = 0;
  logic [31:0]              up_rdata = 0;
  logic                     up_rack = 0;

  task automatic master_reset();
    begin
      up_wreq  = 0;
      up_waddr = 0;
      up_wdata = 0;
      up_rreq  = 0;
      up_raddr = 0;
      up_rdata = 0;
    end
  endtask

  task automatic slave_reset();
    begin
      up_wack  = 0;
      up_rdata = 0;
      up_rack  = 0;
    end
  endtask

  task automatic write(
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [31:0]              data);
    begin
      up_wreq <= 1'b1;
      up_waddr <= addr;
      up_wdata <= data;

      do begin
        @(posedge up_clk);
        up_wreq <= 1'b0;
      end while (up_wack == 0);
    end
  endtask

  task automatic read(
    input logic [ADDRESS_WIDTH-1:0] addr,
    output logic [31:0]             data);
    begin
      up_rreq <= 1'b1;
      up_raddr <= addr;

      do begin
        @(posedge up_clk);
        up_rreq <= 1'b0;
      end while (up_rack == 0);

      data = up_rdata;
    end
  endtask

  task automatic write_fifo(
    input logic [ADDRESS_WIDTH-1:0] addr,
    input logic [31:0]              data[$],
    input int                       incr_addr = 0,
    input int                       throttle = 0);
    begin
      logic [ADDRESS_WIDTH-1:0] curr_addr = addr;

      if (data.size() == 0)
        return;

      for (int i = 0; i < data.size(); i++) begin
        for (int j = 0; j < throttle; j++) begin
          @(posedge up_clk);
        end

        write(curr_addr, data[i]);
        if (incr_addr)
          curr_addr++;
      end
    end
  endtask

  task automatic read_fifo(
    input logic [ADDRESS_WIDTH-1:0] addr,
    output logic [31:0]             data[$],
    input int                       num_samples,
    input int                       incr_addr = 0,
    input int                       throttle = 0);
    begin
      logic [ADDRESS_WIDTH-1:0] curr_addr = addr;
      logic [31:0] curr_data;

      if (num_samples == 0)
        return;

      for (int i = 0; i < num_samples; i++) begin
        for (int j = 0; j < throttle; j++) begin
          @(posedge up_clk);
        end

        read(curr_addr, curr_data);
        data.push_back(curr_data);

        if (incr_addr)
          curr_addr++;
      end
    end
  endtask
endinterface


interface rwt_up_regs #(
  parameter NUM_REGS = 32
)(
  rwt_up_lib up_if
);
  logic [31:0] regs[NUM_REGS] = '{default:0};
  logic        stop = 1'b0;

  task automatic run(
    input int throttle_in = 0,
    input int throttle_out = 0);
    begin
      up_if.slave_reset();
      @(posedge up_if.up_rstn);

      fork
        slave_register_out(throttle_out);
        slave_register_in(throttle_in);
      join
    end
  endtask

  task automatic slave_register_in(
    input int   throttle = 0);
    begin
      forever begin
        if (stop == 1'b1)
          break;

        if (up_if.up_rreq != 1'b1)
          @(posedge up_if.up_rreq or posedge stop);

        @(posedge up_if.up_clk);
        if (up_if.up_rreq == 1'b0)
          continue;

        for (int i = 0; i < throttle; i++)
          @(posedge up_if.up_clk);

        up_if.up_rack <= 1'b1;
        if (up_if.up_raddr < NUM_REGS) begin
          up_if.up_rdata <= regs[up_if.up_raddr];
        end else begin
          up_if.up_rdata <= 'X;
        end

        @(posedge up_if.up_clk);
        up_if.up_rack <= 1'b0;
      end
    end
  endtask

  task automatic slave_register_out(
    input int   throttle = 0);
    begin
      forever begin
        if (stop == 1'b1)
          break;

        if (up_if.up_wreq != 1'b1)
          @(posedge up_if.up_wreq or posedge stop);

        @(posedge up_if.up_clk);
        if (up_if.up_wreq == 1'b0)
          continue;

        for (int i = 0; i < throttle; i++)
          @(posedge up_if.up_clk);

        up_if.up_wack <= 1'b1;
        if (up_if.up_waddr < NUM_REGS) begin
          regs[up_if.up_waddr] <= up_if.up_wdata;
        end

        @(posedge up_if.up_clk);
        up_if.up_wack <= 1'b0;

      end
    end
  endtask
endinterface

`endif
