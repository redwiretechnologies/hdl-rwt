class vivado_rpt_parser():
    def __init__(self, fn):
        self.read_lines(fn)
        self.split_lines()
        self.clean_up_splits()

    def read_lines(self, fn):
        self.lines = []
        with open(fn) as f:
            count = 0
            for line in f:
                if line[0] == '+':
                    count = count + 1
                if count > 0:
                    if line[0] == '|':
                        self.lines.append(line)

    def split_lines(self):
        self.s_lines = []
        for line in self.lines:
            a = line.split('|')
            del a[0]
            del a[-1]
            self.s_lines.append(a)

    def clean_up_splits(self):
        new_lines = []
        for line_num, line in enumerate(self.s_lines):
            new_line = []
            for string_index, string in enumerate(line):
                if line_num != 0:
                    if string_index==0:
                        string = string.rstrip()
                        temp = string.lstrip()
                        line.append(int((len(string)-len(temp)-1)/2))
                        string = temp
                    elif string_index==1:
                        string = string.strip()
                    else:
                        string = int(string)
                else:
                    try:
                        string = string.strip()
                    except:
                        pass
                    if string_index==0:
                        line.append(0)
                new_line.append(string)
            new_lines.append(new_line)
        self.s_lines = new_lines


    def print_lines(self):
        for line in self.lines:
            print(line)

    def print_s_lines(self):
        for line in self.s_lines:
            print(line)

if __name__=="__main__":
    v = vivado_rpt_parser("util.rpt")
    v.print_s_lines()
