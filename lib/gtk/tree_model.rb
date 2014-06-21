module Gtk
  module Lib
    attach_method :gtk_tree_model_get_iter_first, [:pointer, :pointer], :bool
    attach_method :gtk_tree_model_iter_next, [:pointer, :pointer], :bool
    attach_method :gtk_tree_model_get, [:pointer, :pointer, :varargs], :void
  end

  class TreeModel < GObject # GInterface really
    def initialize(pointer,types)
      raise "hell" unless pointer.is_a?(FFI::Pointer)
      @native = pointer
      @types = types
    end
    def iter_first
      @iter = TreeIter.new
      @iter.owner = self
      Lib.gtk_tree_model_get_iter_first(native,@iter.to_ptr)
      @iter
    end
    def iter_next
      Lib.gtk_tree_model_iter_next(native,@iter.to_ptr) ? @iter : nil
    end
    def get iter,i
      type = @types[i]
      type = :int if type == :bool
      val = FFI::MemoryPointer.new(type,1)
      Lib.gtk_tree_model_get(native,iter,:int,i,:pointer,val,:int,-1)
      val = val.send("read_#{type}")
      @types[i] == :bool ? val!=0 : val
    end
    def to_list_store
      Gtk::ListStore.new(native,@types)
    end
    def set iter,i,value
      to_list_store.set(iter,i,value)
    end
  end
end

