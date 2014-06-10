module Gtk
  module Lib
    attach_function :gtk_list_store_new, [:int, :varargs], :pointer
    attach_method :gtk_list_store_append, [:pointer, :pointer], :void
    attach_method :gtk_list_store_set, [:pointer, :pointer, :varargs], :void
  end

  class ListStore < GObject
    def initialize(n_columns, *types)
      @native = Lib.gtk_list_store_new(n_columns,
        *(types.map{ |type| [:int,GType[type]] }.flatten)
      )
    end
    def append iter
      iter.owner = self
      Lib.gtk_list_store_append(native,iter.to_ptr)
    end
    # def set *args
    #   puts "SET #{args.inspect}"
    # end
    def to_tree_model
      Gtk::TreeModel.new(native)
    end
  end
end

