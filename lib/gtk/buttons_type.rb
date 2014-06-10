module Gtk
  module ButtonsType
    NONE      = 0
    OK        = 1
    CLOSE     = 2
    CANCEL    = 3
    YES_NO    = 4
    OK_CANCEL = 5

    def self.[] symbol
      const_get(symbol.to_s.upcase.to_sym)
    end
  end
end
