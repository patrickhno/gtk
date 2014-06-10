module Gtk
  module Lib
    attach_method :gtk_tree_view_new_with_model, [:pointer], :pointer
    attach_method :gtk_tree_view_get_selection, [:pointer], :pointer
    attach_method :gtk_tree_view_append_column, [:pointer, :pointer], :long
    attach_method :gtk_tree_view_get_cursor, [:pointer, :pointer, :pointer], :void
  end

  class TreeView < Widget
    def initialize(model=nil)
      @native = if model
        if model.is_a?(FFI::Pointer)
          model
        else
          Lib.gtk_tree_view_new_with_model(model.native)
        end
      else
        Lib.gtk_tree_view_new()
      end
    end
    def get_selection
      TreeSelection.new(Lib.gtk_tree_view_get_selection(native))
    end
    def get_cursor
      path = FFI::MemoryPointer.new :pointer
      column = FFI::MemoryPointer.new :pointer
      Lib.gtk_tree_view_get_cursor(native,path,column)
      path = path.get_pointer(0)
      column = column.get_pointer(0)
      [TreePath.new(path),TreeViewColumn.new(column)]
    end
  end
end

