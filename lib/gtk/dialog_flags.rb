module Gtk
  module DialogFlags
    MODAL               = 1 << 0
    DESTROY_WITH_PARENT = 1 << 1
    NO_SEPARATOR        = 1 << 2

    def self.[] symbol
      const_get(symbol.to_s.upcase.to_sym)
    end
  end
end
