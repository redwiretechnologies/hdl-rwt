// SPDX-License-Identifier: Apache-2.0

`ifndef RWT_AXI4LITE_LIB_SV
`define RWT_AXI4LITE_LIB_SV

`define RWT_AXIS4LITE_CONNECT(prefix, axis) \
  .``prefix``awvalid(axis.awvalid),      \
  .``prefix``awaddr(axis.awaddr),        \
  .``prefix``awready(axis.awready),      \
  .``prefix``wvalid(axis.wvalid),        \
  .``prefix``wdata(axis.wdata),          \
  .``prefix``wstrb(axis.wstrb),          \
  .``prefix``wready(axis.wready),        \
  .``prefix``bvalid(axis.bvalid),        \
  .``prefix``bresp(axis.bresp),          \
  .``prefix``bready(axis.bready),        \
  .``prefix``arvalid(axis.arvalid),      \
  .``prefix``araddr(axis.araddr),        \
  .``prefix``arready(axis.arready),      \
  .``prefix``rvalid(axis.rvalid),        \
  .``prefix``rresp(axis.rresp),          \
  .``prefix``rdata(axis.rdata),          \
  .``prefix``rready(axis.rready)


interface rwt_axi4lite_lib #(
  parameter   ADDRESS_WIDTH = 16
)(
  input logic clk,
  input logic rstn);

  logic                       awvalid = 0;
  logic [(ADDRESS_WIDTH-1):0] awaddr = 0;
  logic                       awready = 0;
  logic                       wvalid = 0;
  logic [31:0]                wdata = 0;
  logic [ 3:0]                wstrb = 0;
  logic                       wready = 0;
  logic                       bvalid = 0;
  logic [ 1:0]                bresp = 0;
  logic                       bready = 0;
  logic                       arvalid = 0;
  logic [(ADDRESS_WIDTH-1):0] araddr = 0;
  logic                       arready = 0;
  logic                       rvalid = 0;
  logic [ 1:0]                rresp = 0;
  logic [31:0]                rdata = 0;
  logic                       rready = 0;

  task automatic master_reset();
    begin
      awvalid <= 0;
      awaddr <= 0;
      wvalid <= 0;
      wdata <= 0;
      wstrb <= 0;
      bready <= 0;

      arvalid <= 0;
      araddr <= 0;
      rready <= 0;
    end
  endtask

  task automatic slave_reset();
    begin
      awready <= 0;
      wready <= 0;
      bvalid <= 0;
      bresp <= 0;

      arready <= 0;
      rvalid <= 0;
      rresp <= 0;
      rdata <= 0;
    end
  endtask

  task automatic write(
    input logic [(ADDRESS_WIDTH-1):0] addr,
    input logic [31:0]                data,
    output logic [1:0]                resp);
    begin
      logic set_awready = 1'b0;
      logic set_wready = 1'b0;
      logic set_bvalid = 1'b0;

      @(posedge clk);
      awvalid <= 1'b1;
      wvalid <= 1'b1;
      awaddr <= addr;
      wdata <= data;
      wstrb <= '1;
      bready <= 1'b1;

      forever begin
        @(posedge clk);

        if (awready == 1'b1) begin
          set_awready = 1'b1;
          awvalid <= 1'b0;
        end

        if (wready == 1'b1) begin
          set_wready = 1'b1;
          wvalid <= 1'b0;
        end

        if (bvalid == 1'b1) begin
          set_bvalid = 1'b1;
          bready <= 1'b0;
          resp = bresp;
        end

        if (set_awready && set_wready && set_bvalid) begin
          break;
        end
      end;
    end
  endtask

  task automatic read(
    input logic [(ADDRESS_WIDTH-1):0] addr,
    output logic [31:0]               data,
    output logic [1:0]                resp);

    begin
      logic set_arready = 1'b0;
      logic set_rvalid = 1'b0;

      @(posedge clk);
      arvalid <= 1'b1;
      araddr <= addr;
      rready <= 1'b1;

      forever begin
        @(posedge clk);

        if (arready == 1'b1) begin
          set_arready = 1'b1;
          arvalid <= 1'b0;
        end

        if (rvalid == 1'b1) begin
          set_rvalid = 1'b1;
          rready <= 1'b0;
          resp = rresp;
          data = rdata;
        end

        if (set_arready && set_rvalid) begin
          break;
        end
      end;
    end
  endtask

  task automatic write_fifo(
    input logic [13:0] addr,
    input logic [31:0] data[$],
    input int          incr_addr = 0,
    input int          throttle = 0);
    begin
      logic [13:0] curr_addr = addr;
      logic [1:0]  resp;

      if (data.size() == 0)
        return;

      for (int i = 0; i < data.size(); i++) begin
        for (int j = 0; j < throttle; j++) begin
          @(posedge clk);
        end

        write(curr_addr, data[i], resp);
        if (incr_addr)
          curr_addr++;
      end
    end
  endtask

  task automatic read_fifo(
    input logic [13:0]  addr,
    output logic [31:0] data[$],
    input int           num_samples,
    input int           incr_addr = 0,
    input int           throttle = 0);
    begin
      logic [13:0] curr_addr = addr;
      logic [31:0] curr_data;
      logic [1:0]  resp;

      if (num_samples == 0)
        return;

      for (int i = 0; i < num_samples; i++) begin
        for (int j = 0; j < throttle; j++) begin
          @(posedge clk);
        end

        read(curr_addr, curr_data, resp);
        data.push_back(curr_data);

        if (incr_addr)
          curr_addr++;
      end
    end
  endtask
endinterface


`endif
