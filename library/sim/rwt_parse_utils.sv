// SPDX-License-Identifier: Apache-2.0

`ifndef RWT_PARSE_UTILS_SV
`define RWT_PARSE_UTILS_SV

typedef enum int {
  BLANK=0,
  INVALID=1,
  DATA=2,
  TAGGED=3
} parse_line_type_t;

function string str_strip(input string line);
  automatic string stripped;
  automatic int    str_start = line.len()-1;
  automatic int    str_end = line.len();

  if (line.len() == 0)
    return "";

  for (int i = 0; i < line.len(); i++) begin
    if (line[i] == "#") begin
      str_end = i;
      break;
    end
  end

  if (str_end == 0) begin
    return "";
  end

  for (int i = 0; i < str_end; i++) begin
    if (!((line[i] == "\t") || (line[i] == "#") ||
          (line[i] == " ") || (line[i] == "\n")))
    begin
      str_start = i;
      break;
    end
  end

  for (int i = str_end - 1; i >= 0; i--) begin
    if ((line[i] == "\t") || (line[i] == " ") || (line[i] == "\n"))
      str_end = i;
    else
      break;
  end

  if (str_start >= str_end)
    return "";

  return line.substr(str_start, str_end-1);

endfunction

function string str_replace(
  input string line,
  input string replace_chars,
  input string new_chr);
  begin
    for (int i = 0; i < line.len(); i++) begin
      for (int j = 0; j < replace_chars.len(); j++) begin
        if (line[i] == replace_chars[j])
          line[i] = " ";
      end
    end
    return line;
  end
endfunction

typedef string token_queue[$];

function token_queue str_tokenize(
  input string line,
  input string delims);
  begin
    automatic int last_idx = 0;
    automatic token_queue tokens;

    for (int i = 0; i < line.len(); i++) begin
      for (int j = 0; j < delims.len(); j++) begin
        if (line[i] == delims[j]) begin
          if (last_idx != i)
            tokens.push_back(line.substr(last_idx, i-1));

          last_idx = i + 1;
          break;
        end
      end
    end

    if (last_idx != line.len()) begin
      tokens.push_back(line.substr(last_idx, line.len()-1));
    end

    return tokens;
  end
endfunction


class parse_axis #(
  parameter DWIDTH = 32,
  parameter UWIDTH = 1);

  static task parse (
    input string              line,
    output parse_line_type_t  line_type,
    output logic [DWIDTH-1:0] data,
    output logic [UWIDTH-1:0] user,
    output logic [6:0]        tag_type,
    output logic              last);
    begin
      string replace_chars = "*,+";
      int    ret;

      line_type = BLANK;
      data = 0;
      user = 0;
      last = 0;
      tag_type = 0;

      line = str_strip(line);

      if (line.len() < 1)
        return;

      for (int i = 0; i < line.len(); i++) begin
        if (line[i] == "*")
          last = 1'b1;
        else if (line[i] == "+")
          line_type = TAGGED;
      end

      line = str_replace(line, replace_chars, " ");

      if (line_type == BLANK)
        line_type = DATA;

      if (line_type == DATA)
        ret = $sscanf(line, "%x %x", data, user);
      else
        ret = $sscanf(line, "%x %x", data, tag_type);


      if (ret == 0) begin
        line_type = INVALID;
      end else if (ret == 1) begin
        /* Potential bug in Vivado simulator. It will fill in user or tag_type
           event if ret == 1.*/
        user = 0;
        tag_type = 0;
      end
    end
  endtask
endclass

class parse_adc #(
  parameter MAX_SAMPLES = 4);

  static task parse (
    input int                fd,
    input int                fmt_hex,
    input logic              binary,
    output parse_line_type_t line_type,
    input int                num_channels,
    output logic [15:0]      data[0:MAX_SAMPLES-1]);
    begin
      string replace_chars = ",";
      string line;
      int    ret;
      int    value;
      logic [15:0] value_logic;

      token_queue tokens;

      line_type = BLANK;

      if (binary == 0) begin
        ret = $fgets(line, fd);

        line = str_strip(line);
        if (line.len() < 1)
          return;

        tokens = str_tokenize(line, " ,");

        if (tokens.size() < num_channels) begin
          line_type = INVALID;
          return;
        end

        for (int i = 0; i < num_channels; i++)
        begin
          if (fmt_hex)
            ret = $sscanf(tokens[i], "%x", value);
          else
            ret = $sscanf(tokens[i], "%d", value);

          if (ret != 1) begin
            line_type = INVALID;
            return;
          end
          data[i] = value;
          line = line.substr(ret, line.len()-1);
        end

      end else begin

        for (int i = 0; i < num_channels; i++) begin
          ret = $fgetc(fd);
          if (ret < 0) begin
            line_type = INVALID;
            return;
          end
          value_logic[15:8] = ret & 16'hff;

          ret = $fgetc(fd);
          if (ret < 0) begin
            line_type = INVALID;
            return;
          end
          value_logic[7:0] = ret & 16'hff;

          data[i] = value_logic;
        end

      end

      line_type = DATA;
    end
  endtask
endclass

`endif
