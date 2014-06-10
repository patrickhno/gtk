module Gtk
  module Lib
    attach_function :gtk_message_dialog_new, [:pointer, :long, :long, :long, :string, :varargs], :pointer
    attach_method :gtk_dialog_run, [:pointer], :long
  end

  class MessageDialog < Widget
    def initialize(options)
      @native = Lib.gtk_message_dialog_new(
        options[:parent],
        DialogFlags[options[:flags]],
        MessageType[options[:type]],
        ButtonsType[options[:buttons_type]],
        "%s",
        :string,
        options[:message]
      )
    end

    def run
      Lib.gtk_dialog_run(native)
    end
  end
end

