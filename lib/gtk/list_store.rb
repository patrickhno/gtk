module Gtk
  module Lib
    attach_function :gtk_list_store_new, [:int, :varargs], :pointer
    attach_method :gtk_list_store_append, [:pointer, :pointer], :void
    attach_method :gtk_list_store_set, [:pointer, :pointer, :varargs], :void
  end

  class ListStore < GObject
    def initialize(*types)
      if types.first.is_a?(FFI::Pointer)
        @native = types[0]
        @types = types[1]
      else
        @types = types
        @native = Lib.gtk_list_store_new(types.size,
          *(types.map{ |type| [:int,GType[type]] }.flatten)
        )
      end
    end
    def append iter
      iter.owner = self
      Lib.gtk_list_store_append(native,iter.to_ptr)
    end
    def to_tree_model
      Gtk::TreeModel.new(native,@types)
    end
    def set iter,i,value
      if value.is_a?(OpenStruct) && @types[i] == :ulong
        # TODO: Find a proper way to store these
        @instances ||= []
        @instances << value
        value = value.object_id
      end
      Lib.gtk_list_store_set(native,iter,:int,i,@types[i],value,:int,-1)
    end
  end
end

