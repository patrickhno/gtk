module Gtk
  module Lib
    attach_function :gtk_tree_view_column_new, [], :pointer
    attach_function :gtk_tree_view_column_new_with_attributes, [:string, :pointer, :varargs], :pointer
    attach_method :gtk_tree_view_column_set_attributes, [:pointer, :pointer, :varargs], :pointer
    attach_method :gtk_tree_view_column_set_title, [:pointer, :string], :void
    attach_method :gtk_tree_view_column_pack_start, [:pointer, :pointer, :bool], :void
    attach_method :gtk_tree_view_column_add_attribute, [:pointer, :pointer, :string, :int], :void
  end

  class TreeViewColumn < Widget
    def initialize(title=nil,renderer=nil,options={})
      if title.is_a?(FFI::Pointer)
        @native = title
      else
        attributes = options.map{ |key,value| [:string,key.to_s,:int,value] }.flatten
        has_title_and_options = title && options.size > 0

        @native = if has_title_and_options
          raise "renderer misses native" unless renderer.native
          Lib.gtk_tree_view_column_new_with_attributes(title,renderer.native,*attributes,:string,nil)
        else
          Lib.gtk_tree_view_column_new()
        end

        unless has_title_and_options
          set_title(title) if title
          if options.size > 0
            Lib.gtk_tree_view_column_set_attributes(native,renderer.native,*attributes,:string,nil)
          end
        end
      end
    end
  end
end

