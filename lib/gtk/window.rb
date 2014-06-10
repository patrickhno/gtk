module Gtk
  module Lib
    attach_function :gtk_window_new, [:long], :pointer
    attach_method :gtk_window_set_title, [:pointer,:string], :void
    attach_method :gtk_window_set_default_size, [:pointer,:long,:long], :void
    attach_method :gtk_window_set_position, [:pointer,WindowPosition], :void
  end

  class Window < Bin
    def initialize(type = :toplevel)
      @native = Lib.gtk_window_new(
        WindowType[type]
      )
    end
  end
end

