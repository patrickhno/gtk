module Gtk
  module Lib
    attach_method :gtk_container_add, [:pointer, :pointer], :void
  end

  class Container < Widget
  end
end

