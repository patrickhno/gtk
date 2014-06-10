module Gtk
  module Lib
    attach_method :gtk_tree_path_get_indices, [:pointer], :pointer
    attach_method :gtk_tree_path_get_depth, [:pointer], :long
  end

  class TreePath < GObject
    def initialize(pointer)
      @native = pointer
    end
    def get_indices
      ret = Lib.gtk_tree_path_get_indices(native)
      ret.get_array_of_int(0,depth)
    end
  end
end

