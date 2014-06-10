module Gtk
  module Lib
    attach_method :gtk_style_context_restore, [:pointer], :void
    attach_method :gtk_style_context_set_state, [:pointer, :int], :void
    attach_method :gtk_style_context_add_class, [:pointer, :string], :void
    attach_method :gtk_style_context_save, [:pointer], :void
  end

  class StyleContext < GObject
    def initialize(pointer)
      raise "hell" unless pointer.is_a?(FFI::Pointer)
      @native = pointer
    end
  end
end

