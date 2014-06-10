module Gtk
  module Lib
    attach_function :gtk_tree_store_new, [:long, :varargs], :pointer
    attach_method :gtk_tree_store_append, [:pointer, Gtk::TreeIter.by_ref, Gtk::TreeIter.by_ref], :void
    attach_method :gtk_tree_store_set_column_types, [:pointer, :long, :pointer], :void
    attach_method :gtk_tree_store_set, [:pointer, Gtk::TreeIter.by_ref, :varargs], :void
  end

  class TreeStore < GObject

    TYPE_MAP = {
      Integer => 24, # GObject::TYPE_INT,
      String  => 64  # GObject::TYPE_STRING
    }

    def self.type_mapped_types(*types)
      types = types.first if types.size == 1 && types.first.is_a?(Array)
      types.map{ |type| TYPE_MAP[type] }
    end

    def initialize(*types)
      @native = Gtk::Lib.gtk_tree_store_new(
        types.size,
        *self.class.type_mapped_types(*types).map{ |type|
          [:int,type]
        }.flatten
      )
    end

    def set_column_types *types
      types = self.class.type_mapped_types(*types)
      array = FFI::MemoryPointer.new(:long,types.size)
      array.write_array_of_long(types)
      Lib.gtk_tree_store_set_column_types(@native,types.size,array)
    end

    def append parent=nil
      iter = Gtk::TreeIter.new
      Gtk::Lib.gtk_tree_store_append(native,iter,parent)
      iter.owner = self
      iter
    end
  end
end

