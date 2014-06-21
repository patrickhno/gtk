require 'ffi'
require 'cairo'
require 'active_support/inflector'

module Gtk
  class Enums
    def self.[] symbol
      const_get(symbol.to_s.upcase.to_sym)
    end
  end
end

module Gtk
  G_PARAM_READABLE = 1
  G_PARAM_WRITABLE = 2
  G_PARAM_READWRITE = G_PARAM_READABLE | G_PARAM_WRITABLE
  module Lib
    extend FFI::Library
    ffi_lib 'gtk-3'

    def self.attached_methods
      @attached_methods ||= {}
    end

    def self.attach_method method, args, ret
      attached_methods[method] = { :name => method, :args => args, :ret => ret }
      attach_function method,args.map{ |arg| arg.respond_to?(:superclass) && arg.superclass == Enums ? :long : arg },ret
    end

    attach_method :gtk_init, [:pointer, :pointer], :void
    attach_method :gtk_main, [], :void
    attach_method :gtk_main_quit, [], :void
    attach_method :gtk_events_pending, [], :bool
    attach_method :gtk_main_iteration, [], :bool
    attach_method :gtk_render_focus, [:pointer, :pointer, :double, :double, :double, :double], :void
  end

  def self.init
    Lib.gtk_init(nil,nil)
  end

  def self.method_missing method,*args
    name = "gtk_#{method}".to_sym
    m = Lib.attached_methods[name]
    raise ArgumentError.new unless m[:args].size == args.size

    args = args.map do |v|
      case v
      when GObject
        v.native
      when Cairo::Context
        v.to_ptr
      when Fixnum, Float
        v
      else
        raise v.inspect
      end
    end

    Lib.send(name,*args)
  end
end

module Glib

  module Lib
    extend FFI::Library
    ffi_lib 'glib-2.0'

    attach_function :g_timeout_add, [:ulong, :pointer, :pointer], :ulong

    class GObject < FFI::Struct
      layout  :g_type_instance, :pointer, #Gtk::Lib::GTypeInstance,
              :ref_count, :ulong,
              :qdata, :pointer
    end
  end

  def self.timeout_add(interval,&block)
    @callback ||= FFI::Function.new(:bool, [:pointer]) do |data|
      block.call
    end
    Lib.g_timeout_add(interval,@callback,nil)
  end
end

module GObject
  extend FFI::Library
  ffi_lib 'gobject-2.0'
end

module Gtk
  module Lib
    class GTypeInstance < FFI::Struct
    end

    attach_function :g_signal_connect_data, [:pointer, :string, :pointer, :pointer, :pointer, :long], :ulong
    attach_function :g_param_spec_string, [:string, :string, :string, :string, :int], :pointer
    attach_function :g_param_spec_double, [:string, :string, :string, :double, :double, :double, :int], :pointer
    attach_function :g_param_spec_int, [:string, :string, :string, :int, :int, :int, :int], :pointer
    attach_function :g_param_spec_ulong, [:string, :string, :string, :ulong, :ulong, :ulong, :ulong], :pointer
    attach_function :g_type_register_static, [:ulong, :string, :pointer, :int], :ulong
    attach_function :g_type_add_instance_private, [:ulong, :ulong], :int
    attach_function :g_intern_static_string, [:string], :string
    attach_function :g_type_register_static_simple, [:ulong, :string, :ulong, :pointer, :ulong, :pointer, :ulong], :long
    attach_function :g_type_name, [:ulong], :string
    attach_function :g_type_class_peek_parent, [:pointer], :pointer
    attach_function :g_value_get_double, [:pointer], :double
    attach_function :g_value_get_int, [:pointer], :int
    attach_function :g_value_get_ulong, [:pointer], :ulong

    attach_function :g_object_class_install_property, [:pointer, :uint, :pointer], :void
    attach_function :g_object_new, [:ulong, :string, :varargs], :pointer
    attach_function :g_object_unref, [:pointer], :void

    class GTypeInfo < FFI::Struct
      layout  :class_size, :uint,
              :base_init, :pointer,
              :base_finalize, :pointer,
              :class_init, :pointer,
              :class_finalize, :pointer,
              :class_data, :pointer,
              :instance_size, :uint,
              :n_preallocs, :uint,
              :instance_init, :pointer
    end
  end

  class GObject
    attr_accessor :native,:type

    def initialize *args
      raise "hell" unless args.size == 1 && args.first.is_a?(FFI::Pointer)
      @native = args.first
    end

    def self.type_register
      type_name = name.gsub(/::/,'__')
      cell_progress_info = Lib::GTypeInfo.new
      @type = Lib.g_type_register_static(
        superclass.type,
        type_name,
        cell_progress_info.to_ptr,
        0
      )
    end

    def signal_connect(name,&block)
      @callback ||= FFI::Function.new(:void, [:pointer]) do |data|
        block.call
      end
      Lib.g_signal_connect_data(native,name,@callback,nil,nil,0)
    end

    def unref
      Lib.g_object_unref(native)
    end

    def method_missing method,*args
      method = "set_#{method.to_s[0..-2]}".to_sym if method.to_s[-1] == '='

      getter = "get_#{method}".to_sym
      klass = self.class
      while klass
        raise "hell #{method} #{self.inspect}" if klass == Object
        return send(getter,*args) if respond_to?(getter)

        name = "gtk_#{klass.name.split('::').last.underscore}_#{method}".to_sym
        getter_name = "gtk_#{klass.name.split('::').last.underscore}_#{getter}".to_sym
        if m = (Lib.attached_methods[name] || Lib.attached_methods[getter_name])
          raise "#{self.class.name}: #{method}" unless m
          if m[:args].last == :varargs
            raise ArgumentError.new unless m[:args].size <= (args.size+1)
          else
            raise ArgumentError.new unless m[:args].size == (args.size+1)
          end

          types = m[:args][1..-1]
          args = args.map do |arg|
            type = types.shift
            if arg.is_a?(GObject)
              arg.native
            elsif arg.is_a?(Symbol) && type.respond_to?(:superclass) && type.superclass == Enums
              type[arg]
            else
              arg
            end
          end

          return Lib.send(m[:name],@native,*args)
        end
        klass = klass.superclass
      end
    end
  end
end

module Gtk
  module Lib
    attach_method :gtk_widget_show_all, [:pointer], :void
    attach_method :gtk_widget_destroy, [:pointer], :void
    attach_method :gtk_widget_get_style_context, [:pointer], :pointer
  end

  class Widget < GObject
    def get_style_context
      Gtk::StyleContext.new(Lib.gtk_widget_get_style_context(native))
    end
  end
end

require 'gtk/dialog_flags'
require 'gtk/message_type'
require 'gtk/buttons_type'
require 'gtk/g_type'
require 'gtk/window_type'
require 'gtk/window_position'
require 'gtk/tree_iter'
require 'gtk/selection_mode'

require 'gtk/container'
require 'gtk/bin'
require 'gtk/cell_renderer'
require 'gtk/cell_renderer_text'
require 'gtk/list_store'
require 'gtk/message_dialog'
require 'gtk/style_context'
require 'gtk/tree_model'
require 'gtk/tree_path'
require 'gtk/tree_selection'
require 'gtk/tree_store'
require 'gtk/tree_view'
require 'gtk/tree_view_column'
require 'gtk/window'
