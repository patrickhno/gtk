require 'gtk'
require 'cairo'

require 'active_support/core_ext/module/delegation'
require 'active_support/inflector'

NUM_COLS = 2

Gtk.init

window = Gtk::Window.new(:toplevel)
window.set_default_size(150, 100);

thread = nil
$running = true
window.signal_connect("delete_event") do
  Gtk.main_quit
  $running = false
end

liststore = Gtk::ListStore.new(NUM_COLS, :float, :string)
iter = Gtk::TreeIter.new
liststore.append(iter)
iter[0] = 0.5
#liststore.unref

view = Gtk::TreeView.new(liststore)

renderer = Gtk::CellRendererText.new
col = Gtk::TreeViewColumn.new
col.pack_start(renderer, true)
col.add_attribute(renderer, "text", 1)
col.set_title "Progress"
view.append_column(col)

class CustomCellRendererProgress < Gtk::CellRenderer

  STEP = 0.01

  def initialize *args
    super
    @progress = 0.5
    @increasing = true
  end

  def get_size widget, cell_area
    xpad,ypad = padding
    xalign,yalign = alignment

    width  = xpad * 2 + 100
    height = ypad * 2 + 10

    x_offset = y_offset = nil
    if cell_area
      x_offset = xalign * (cell_area[:width] - width)
      x_offset = [x_offset, 0].max
      y_offset = yalign * (cell_area[:height] - height)
      y_offset = [y_offset, 0].max
    end

    [x_offset,y_offset,width,height]
  end

  def self.init cell_class, object_class
    # spec = Gtk::Lib.g_param_spec_double("percentage",
    #   "Percentage",
    #   "The fractional progress to display",
    #   0, 1, 0,
    #   Gtk::G_PARAM_READWRITE)

    # Gtk::Lib.g_object_class_install_property(object_class,1,spec)
  end

  def self.type
    @type ||= Gtk::Lib.g_type_register_static(superclass.type,
      name,
      type_info.to_ptr,
      0)
  end
  def render cr, widget, background_area, cell_area, flags
    context = widget.style_context

    background_area[:x] -= 5

    cr.save
    cr.rectangle background_area[:x],background_area[:y],background_area[:width],background_area[:height]
    cr.set_source_rgba 1, 0, 0, 0.80
    cr.fill
    cr.reset_clip

    context.save
    context.add_class 'cell'
    Gtk.render_focus(context,cr,background_area[:x],background_area[:y],background_area[:width] * @progress,background_area[:height])

    state = get_state(widget, flags)
    context.state = state

    context.restore
    cr.restore
  end
  def step liststore
    iter = liststore.to_tree_model.iter_first
    perc = iter[0]

    if perc > (1.0-STEP)  ||  (perc < STEP && perc > 0.0)
      @increasing = !@increasing
    end

    if @increasing
      perc = perc + STEP
    else
      perc = perc - STEP
    end

    @progress = perc

    iter.owner = liststore
    iter[0] = perc
    iter[1] = "#{(perc*100).floor} %"
  end
end
renderer = CustomCellRendererProgress.new(Gtk::Lib.g_object_new(CustomCellRendererProgress.type,nil))

col = Gtk::TreeViewColumn.new
col.pack_start(renderer, true)
# col.add_attribute(renderer, "percentage", 0)
col.set_title "Progress bar"
view.append_column(col)

window.add(view)

Gtk.widget_show_all(window)

# Gtk.main
while $running do
  while $running && Gtk.events_pending
    Gtk.main_iteration if $running
  end
  sleep 0.005
  renderer.step(liststore)
end
