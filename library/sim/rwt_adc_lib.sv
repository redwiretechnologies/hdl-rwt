// SPDX-License-Identifier: Apache-2.0

`ifndef RWT_ADC_LIB_SV
`define RWT_ADC_LIB_SV

`include "rwt_parse_utils.sv"

`define RWT_ADC_CONNECT(prefix, adc_if)   \
  .``prefix``clk(adc_if.clk),            \
  .``prefix``data(adc_if.data),          \
  .``prefix``enable(adc_if.enable),      \
  .``prefix``valid(adc_if.valid)


interface rwt_adc_lib #(
    parameter MAX_CHANNELS=4)
    ();

  logic                       clk = 'd0;
  logic [MAX_CHANNELS*16-1:0] data = 'd0;
  logic [MAX_CHANNELS-1:0]    enable = 'd0;
  logic [MAX_CHANNELS-1:0]    valid = 'd0;
  logic                       stop = 1'b0;

  task automatic reset();
    begin
      clk <= 0;
      data <= 0;
      enable <= 0;
      valid <= 0;
      stop <= 0;
    end
  endtask

  task automatic quit();
    begin
      stop = 1;
    end
  endtask;

  task automatic file_source(
    input string                   filename,
    input int                      samp_rate,
    input int                      file_num_channels = MAX_CHANNELS,
    input logic                    binary = 1,
    input logic [MAX_CHANNELS-1:0] enable_mask = ~0,
    input logic                    cyclic = 0);
    begin

      logic done = 0;
      int   fd;

      stop = 0;

      assert((file_num_channels >= 1) && (file_num_channels <= MAX_CHANNELS));

      fork
        begin
          clk = 0;
          forever begin
            if ((stop == 1) || (done == 1))
              break;
            #(samp_rate/2);
            clk = 1;
            #(samp_rate/2);
            clk = 0;
          end
        end

        begin

          if (binary)
            fd = $fopen(filename, "rb");
          else
            fd = $fopen(filename, "r");

          if (fd == 0)
            $display("Could not open %s", filename);

          do begin
            int   idx = 0;
            int   ret;
            logic [15:0] samples[0:MAX_CHANNELS-1];
            parse_line_type_t line_type;

            if (fd == 0)
              break;

            while ((!stop) && (fd != 0) && !$feof(fd)) begin
              idx++;

              parse_adc #(MAX_CHANNELS)::parse(
                fd, 0, binary, line_type, file_num_channels, samples);

              if (line_type == BLANK) begin
                continue;
              end else if (line_type != DATA) begin
                if (binary) begin
                  break;
                end else begin
                  $display("Invalid Line %4d in %s", idx, filename);
                  continue;
                end
              end

              @(posedge clk);
              data <= 0;
              enable <= enable_mask;
              valid <= '1;

              for (int i = 0; i < file_num_channels; i++) begin
                data[16*i +: 16] <= samples[i];
              end
            end

            ret = $rewind(fd);

          end while((!stop) && (fd != 0) && cyclic);

          done = 1;
          #(samp_rate);
          data <= 0;
          enable <= 0;
          valid <= 0;

          if (fd != 0)
            $fclose(fd);
        end
      join

    end
  endtask

endinterface

`endif
