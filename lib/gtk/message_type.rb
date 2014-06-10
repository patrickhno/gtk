module Gtk
  module MessageType
    INFO     = 0
    WARNING  = 1
    QUESTION = 2
    ERROR    = 3
    OTHER    = 4

    def self.[] symbol
      const_get(symbol.to_s.upcase.to_sym)
    end
  end
end
