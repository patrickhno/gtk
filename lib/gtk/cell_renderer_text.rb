module Gtk
  module Lib
    attach_function :gtk_cell_renderer_text_new, [], :pointer
  end

  class CellRendererText < Widget
    def initialize
      @native = Lib.gtk_cell_renderer_text_new()
    end
  end
end

