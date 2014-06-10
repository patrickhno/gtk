module Gtk
  module Lib
    attach_method :gtk_tree_model_get_iter_first, [:pointer, :pointer], :bool
    attach_method :gtk_tree_model_get, [:pointer, :pointer, :varargs], :void
  end

  class TreeModel < GObject # GInterface really
    def initialize(pointer)
      raise "hell" unless pointer.is_a?(FFI::Pointer)
      @native = pointer
    end
    def iter_first
      iter = TreeIter.new
      iter.owner = self
      Lib.gtk_tree_model_get_iter_first(native,iter.to_ptr)
      iter
    end
  end
end

