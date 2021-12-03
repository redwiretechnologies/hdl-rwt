`ifndef RWT_DAC_LIB_SV
`define RWT_DAC_LIB_SV

`define RWT_DAC_CONNECT(prefix, dac_if)   \
  .``prefix``clk(dac_if.clk),            \
  .``prefix``data(dac_if.data),          \
  .``prefix``enable(dac_if.enable),      \
  .``prefix``valid(dac_if.valid)


interface rwt_dac_lib();

  logic        clk = 'd0;
  logic [63:0] data = 'd0;
  logic [3:0]  enable = 'd0;
  logic [3:0]  valid = 'd0;
  logic        stop = 1'b0;

  task automatic reset();
    begin
      clk <= 0;
      enable <= 0;
      valid <= 0;
      stop <= 0;
    end
  endtask

  task automatic file_sink(
    input string      filename,
    input int         samp_rate,
    input int         file_num_channels = 4,
    input logic       binary = 1,
    input logic [3:0] enable_mask = 4'hf);
    begin

      assert((file_num_channels >= 1) && (file_num_channels <= 4));

      fork
        begin
          clk = 0;
          forever begin
            if (stop == 1)
              break;
            #(samp_rate/2);
            clk = 1;
            #(samp_rate/2);
            clk = 0;
          end
        end

        begin
          int fd;
          int num_samples = 0;

          if (binary)
            fd = $fopen(filename, "wb");
          else
            fd = $fopen(filename, "w");

          if (fd == 0) begin
            $display("Could not open %s", filename);
          end else begin
            enable <= enable_mask;
            valid <= '1;
            @(posedge clk);
          end

          while ((!stop) && (fd != 0)) begin
            //int   ret;
            logic [15:0] sample;

            @(posedge clk or posedge stop);
            if (stop == 1)
              break;

            for (int i = 0; i < file_num_channels; i++) begin
              sample = data[16*i +: 16];
              if (binary) begin
                $fwrite(fd, "%c%c", sample[15:8], sample[7:0]);
              end else begin
                if (i == 0)
                  $fwrite(fd, "%d", sample);
                else
                  $fwrite(fd, ",%d", sample);
              end
            end

            if (!binary) begin
              $fwrite(fd, "\n");
            end

            num_samples++;
            if ((num_samples % 100) == 99)
              $fflush(fd);
          end;

          #(samp_rate);
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
