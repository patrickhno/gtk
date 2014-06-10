module Gtk
  module Lib
    attach_method :gtk_tree_selection_set_mode, [:pointer, SelectionMode], :void
  end

  class TreeSelection < GObject
    def initialize(pointer)
      @native = pointer
    end
  end
end

