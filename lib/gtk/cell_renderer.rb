
require 'ostruct'

module Gtk
  module Lib
    attach_method :gtk_cell_renderer_get_state, [:pointer, :pointer, :int], :int
    attach_method :gtk_cell_renderer_get_padding, [:pointer, :pointer, :pointer], :void
    attach_method :gtk_cell_renderer_set_padding, [:pointer, :int, :int], :void
    attach_method :gtk_cell_renderer_get_alignment, [:pointer, :pointer, :pointer], :void
    attach_function :gtk_cell_renderer_get_type, [], :ulong
    callback :finalize, [:pointer], :void

    class GObjectClass < FFI::Struct

      layout  :g_type_class, :long,
              :construct_properties, :pointer,
              :constructor, :pointer,
              :set_property, :pointer,
              :get_property, :pointer,
              :dispose, :pointer,
              :finalize, :finalize
    end

    class CellRenderer < FFI::Struct
      layout  :parent_instance, Glib::Lib::GObject,
              :priv, :pointer
    end

    class CellRendererClass < FFI::Struct
      SIZE_OF_GInitiallyUnownedClass = 136

      layout  :parent_class, [:uint8, SIZE_OF_GInitiallyUnownedClass],
              :get_request_mode, :pointer,
              :get_preferred_width, :pointer,
              :get_preferred_height_for_width, :pointer,
              :get_preferred_height, :pointer,
              :get_preferred_width_for_height, :pointer,
              :get_aligned_area, :pointer,
              :get_size, :pointer,
              :render, :pointer,
              :activate, :pointer,
              :start_editing, :pointer,
              :editing_canceled, :pointer,
              :editing_started, :pointer,
              :priv, :pointer,
              :reserved2, :pointer,
              :reserved3, :pointer,
              :reserved4, :pointer
    end

    class CairoRectangleInt < FFI::Struct
      layout :x, :int, :y, :int, :width, :int, :height, :int;
    end

    class CustomCellRendererInstance < FFI::Struct
      layout  :parent, Gtk::Lib::CellRenderer,
              :instance, :ulong
    end
  end

  class CellInstance < OpenStruct
  end

  class CellRenderer < Widget

    def render cell, cr, widget, background_area, cell_area, expose_area, flags
    end
    def get_size cell, widget, cell_area
    end

    def self.inherited sub
      @type_info = Gtk::Lib::GTypeInfo.new

      @type_info[:class_size] = @class_size = Gtk::Lib::CellRendererClass.size

      @type_info[:class_init] = @class_init = FFI::Function.new(:void,[:pointer]) do |klass|
        @parent_class = Gtk::Lib::GObjectClass.new(Gtk::Lib.g_type_class_peek_parent(klass))
        @cell_class = Gtk::Lib::CellRendererClass.new(klass)
        @object_class = Gtk::Lib::GObjectClass.new(klass)
        @cell_class[:render] = FFI::Function.new(:void,[:pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :int]) do |cell,_cr,_widget,_background_area,_cell_area,_expose_area,flags|
          native = Gtk::Lib::CustomCellRendererInstance.new(cell)
          widget = Gtk::Widget.new(FFI::Pointer.new(_widget))
          background_area = Gtk::Lib::CairoRectangleInt.new(_background_area)
          cell_area = Gtk::Lib::CairoRectangleInt.new(FFI::Pointer.new(_cell_area))
          expose_area = Gtk::Lib::CairoRectangleInt.new(FFI::Pointer.new(_expose_area))

          cell_instance = ObjectSpace._id2ref(native[:instance])
          cell_instance.native = native

          Cairo::Context.wrap(_cr) do |cr|
            instances[cell.address].render cell_instance,cr,widget,background_area,cell_area,expose_area,flags
          end
        end

        @cell_class[:get_size] = @get_size = FFI::Function.new(:void,[:pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer]) do |cell,_widget,_cell_area,x_offset,y_offset,width,height|
          native = Gtk::Lib::CustomCellRendererInstance.new(cell)
          widget = Gtk::Widget.new(FFI::Pointer.new(_widget))
          cell_area = Gtk::Lib::CairoRectangleInt.new(FFI::Pointer.new(_cell_area))

          cell_instance = ObjectSpace._id2ref(native[:instance])
          cell_instance.native = native

          _x_offset, _y_offset, _width, _height = instances[cell.address].get_size(cell_instance, widget, cell_area)

          x_offset.write_int _x_offset if _x_offset
          y_offset.write_int _y_offset if _y_offset
          width.write_int _width       if _width
          height.write_int _height     if _height
        end

        @object_class[:finalize] = @finalize = FFI::Function.new(:void,[:pointer]) do |object|
          @parent_class[:finalize].call(object)
        end

        @object_class[:set_property] = FFI::Function.new(:void,[:pointer, :ulong, :pointer, :pointer]) do |cell,param_id,value,psec|
          native = Gtk::Lib::CustomCellRendererInstance.new(cell)
          case param_id
          when 1
            native[:instance] = Gtk::Lib.g_value_get_ulong(value)
          else
            raise "hell"
          end
        end

        @object_class[:get_property] = @get_property = FFI::Function.new(:void,[:pointer, :ulong, :pointer, :pointer]) do |cell,param_id,value,psec|
          native = Gtk::Lib::CustomCellRendererInstance.new(cell)
          case param_id
          when 1
            Gtk::Lib.g_value_set_ulong(value,native[:instance])
          else
            raise "hell"
          end
        end

        Gtk::Lib.g_object_class_install_property(@object_class,
                                         1,
                                         Gtk::Lib.g_param_spec_ulong("instance",
                                                              "Instance",
                                                               "Ruby object instance",
                                                               0, 0xffffffffffffffff, 1,
                                                               Gtk::G_PARAM_READWRITE))

      end
      @type_info[:instance_size] = @instance_size = Gtk::Lib::CustomCellRendererInstance.size
      @type_info[:instance_init] = @instance_init = FFI::Function.new(:void,[:pointer]) do |cell|
        native = Gtk::Lib::CustomCellRendererInstance.new(cell)
        Gtk::Lib.gtk_cell_renderer_set_padding(native,2,2)
      end

      cell_type = Gtk::Lib.gtk_cell_renderer_get_type()
      sub.type = Gtk::Lib.g_type_register_static(cell_type,
        sub.name,
        @type_info.to_ptr,
        0
      )
    end

    def initialize
      super Gtk::Lib.g_object_new(self.class.type,nil)
      instances[native.address] = self
    end

    def self.instances
      @@instances ||= {}
    end
    def instances
      self.class.instances
    end

    def self.type= type
      @type=type
    end
    def self.type
      @type
    end

    def padding
      xpad = FFI::MemoryPointer.new(:int,1)
      ypad = FFI::MemoryPointer.new(:int,1)
      Gtk::Lib.gtk_cell_renderer_get_padding(native, xpad, ypad)
      [xpad.read_int, ypad.read_int]
    end

    def alignment
      xalign = FFI::MemoryPointer.new(:int,1)
      yalign = FFI::MemoryPointer.new(:int,1)
      Gtk::Lib.gtk_cell_renderer_get_alignment(native,xalign,yalign)
      [xalign.read_int, yalign.read_int]
    end

  end
end

