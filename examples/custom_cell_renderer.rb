require 'ffi'
require 'cairo'
require 'gtk'

Gtk.init

window = Gtk::Window.new(:toplevel)
window.set_default_size(150, 200)

window.signal_connect("delete_event") do
  Gtk.main_quit
end

liststore = Gtk::ListStore.new(:ulong, :string)
iter = Gtk::TreeIter.new
liststore.append(iter)
iter[0] = Gtk::CellInstance.new(:percentage => 0.5, :increasing => true)
liststore.append(iter)
iter[0] = Gtk::CellInstance.new(:percentage => 0.4, :increasing => false, :height => 40)
liststore.append(iter)
iter[0] = Gtk::CellInstance.new(:percentage => 0.3, :increasing => true)

view = Gtk::TreeView.new(liststore)
liststore.unref

renderer = Gtk::CellRendererText.new
col = Gtk::TreeViewColumn.new
col.pack_start(renderer, true)
col.add_attribute(renderer, "text", 1)
col.set_title "Progress"
view.append_column(col)

class MyCustomCell < Gtk::CellRenderer

  def get_size cell, widget, cell_area
    _xpad = FFI::MemoryPointer.new(:int,1)
    _ypad = FFI::MemoryPointer.new(:int,1)
    _xalign = FFI::MemoryPointer.new(:int,1)
    _yalign = FFI::MemoryPointer.new(:int,1)
    Gtk::Lib.gtk_cell_renderer_get_padding(cell.native,_xpad,_ypad)
    Gtk::Lib.gtk_cell_renderer_get_alignment(cell.native,_xalign,_yalign)
    xpad = _xpad.read_int
    ypad = _ypad.read_int
    xalign = _xpad.read_int
    yalign = _ypad.read_int

    calc_width  = xpad * 2 + FIXED_WIDTH
    calc_height = ypad * 2 + FIXED_HEIGHT

    if cell.height && cell.height > 0
      calc_height = cell.height
    end

    # if cell_area
    #   if x_offset
    #     _x_offset = xalign * (cell_area[:width] - calc_width)
    #     x_offset.write [_x_offset, 0].max
    #   end

    #   if y_offset
    #     _y_offset = yalign * (cell_area[:height] - calc_height)
    #     y_offset.write_int [y_offset, 0].max
    #   end
    # end

    [nil,nil,calc_width,calc_height]
  end

  def render cell, cr, widget, background_area, cell_area, expose_area, flags
    cr.save
    cr.rectangle(background_area[:x],background_area[:y],background_area[:width] * cell.percentage,background_area[:height])
    cr.set_source_rgba(1.0, 0.0, 0.0, 0.80)
    cr.fill
    cr.restore
  end
end

renderer = MyCustomCell.new

col = Gtk::TreeViewColumn.new
col.pack_start(renderer, true)
col.add_attribute(renderer, "instance", 0)
col.set_title "Progress bar"
view.append_column(col)

window.add(view)

Gtk.widget_show_all(window)

STEP = 0.001
@foo = ""
Glib.timeout_add(5) do
  model = liststore.to_tree_model
  iter = model.iter_first
  while iter
    cell = iter.instance
    perc = cell.percentage

    if perc > (1.0-STEP)  ||  (perc < STEP && perc > 0.0)
      cell.increasing = !cell.increasing
    end

    if cell.increasing
      perc = perc + STEP
    else
      perc = perc - STEP
    end
    cell.percentage = perc

    iter[1] = @foo = "#{(perc*100).floor} %"

    iter = model.iter_next
  end

  true
end

Gtk.main
