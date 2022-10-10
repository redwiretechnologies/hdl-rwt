import sys
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from gi.repository import Pango
from vivado_rpt_parser import vivado_rpt_parser

class MyWindow(Gtk.ApplicationWindow):

    def __init__(self, app, parser):
        Gtk.Window.__init__(self, title="Utilization Full", application=app)
        self.set_default_size(500, 500)
        self.set_border_width(10)

        self.scrolled_window = Gtk.ScrolledWindow()
        self.scrolled_window.set_policy(Gtk.PolicyType.ALWAYS, Gtk.PolicyType.ALWAYS)

        # the data are stored in the model
        # create a treestore with two columns
        self.store = Gtk.TreeStore(str, str, int, int, int, int, int, int, int, int, int)
        # fill in the model
        piter = [None] * 40
        for i in range(1, len(parser.s_lines)):
            # the iter piter is returned when appending the author in the first column
            # and False in the second
            piter[parser.s_lines[i][-1]] = self.store.append(piter[parser.s_lines[i][-1]-1], parser.s_lines[i][0:-1])

        # the treeview shows the model
        # create a treeview on the model self.store
        view = Gtk.TreeView()
        view.set_model(self.store)

        # the cellrenderer for the first column - text
        for i in range(len(parser.s_lines[0])-1):
            renderer = Gtk.CellRendererText()
            # the first column is created
            column = Gtk.TreeViewColumn(parser.s_lines[0][i], renderer, text=i)
            column.set_sort_column_id(i)
            # and it is appended to the treeview
            view.append_column(column)

        # add the treeview to the window
        self.scrolled_window.add(view)
        self.add(self.scrolled_window)

class MyApplication(Gtk.Application):

    def __init__(self, parser):
        Gtk.Application.__init__(self)
        self.parser = parser

    def do_activate(self):
        win = MyWindow(self, self.parser)
        win.show_all()

    def do_startup(self):
        Gtk.Application.do_startup(self)

if __name__=="__main__":
    parser = vivado_rpt_parser(sys.argv[1])
    app = MyApplication(parser)
    temp = sys.argv
    del temp[1]
    exit_status = app.run(temp)
    sys.exit(exit_status)
