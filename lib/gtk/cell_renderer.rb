module Gtk
  module Lib
#    attach_function :gtk_cell_renderer_new, [], :pointer
    attach_method :gtk_cell_renderer_get_state, [:pointer, :pointer, :int], :int
    attach_method :gtk_cell_renderer_get_padding, [:pointer, :pointer, :pointer], :void
    attach_method :gtk_cell_renderer_set_padding, [:pointer, :int, :int], :void
    attach_method :gtk_cell_renderer_get_alignment, [:pointer, :pointer, :pointer], :void
    attach_function :gtk_cell_renderer_get_type, [], :ulong
  end

  class CellRenderer < Widget
    class GObjectClass < FFI::Struct
      layout  :g_type_class, :long,
              :construct_properties, :pointer,
              :constructor, :pointer,
              :set_property, :pointer,
              :get_property, :pointer
    end

    class GtkCellRendererClass < FFI::Struct

      # layout  :get_request_mode, :get_request_mode_function,
      #         :get_preferred_width, :get_preferred_width_function,
      #         :get_preferred_height_for_width, :get_preferred_height_for_width_function,
      #         :get_preferred_height, :get_preferred_height_function,
      #         :get_preferred_width_for_height, :get_preferred_width_for_height_function,
      #         :get_aligned_area, :get_aligned_area_function,
      #         :get_size, :get_size_function,
      #         :render, :render_function

      SIZE_OF_GInitiallyUnownedClass = 136

      layout  :parent_class, [:uint8, SIZE_OF_GInitiallyUnownedClass],
              :get_request_mode, :pointer,
              :get_preferred_width, :pointer,
              :get_preferred_height_for_width, :pointer,
              :get_preferred_height, :pointer,
              :get_preferred_width_for_height, :pointer,
              :get_aligned_area, :pointer,
              :get_size, :pointer,
              :render, :pointer

    # gboolean           (* activate)                        (GtkCellRenderer      *cell,
    #                                                         GdkEvent             *event,
    #                                                         GtkWidget            *widget,
    #                                                         const gchar          *path,
    #                                                         const GdkRectangle   *background_area,
    #                                                         const GdkRectangle   *cell_area,
    #                                                         GtkCellRendererState  flags);
    # GtkCellEditable *  (* start_editing)                   (GtkCellRenderer      *cell,
    #                                                         GdkEvent             *event,
    #                                                         GtkWidget            *widget,
    #                                                         const gchar          *path,
    #                                                         const GdkRectangle   *background_area,
    #                                                         const GdkRectangle   *cell_area,
    #                                                         GtkCellRendererState  flags);

    # /* Signals */
    # void (* editing_canceled) (GtkCellRenderer *cell);
    # void (* editing_started)  (GtkCellRenderer *cell,
    #          GtkCellEditable *editable,
    #          const gchar     *path);
    end

    GetProperty = FFI::Function.new(:void,[:pointer, :uint, :pointer, :pointer]) do |_object,property_id,_value,_pspec|
      raise "get_property"
    end
    SetProperty = FFI::Function.new(:void,[:pointer, :uint, :pointer, :pointer]) do |_object,property_id,_value,_pspec|
      raise "set_property"
    end

    def self.inherited sub
      sub.const_set(:ClassInit,FFI::Function.new(:void,[:pointer]) do |_klass|
        cell_class = GtkCellRendererClass.new(_klass)
        object_class = GObjectClass.new(_klass)
        cell_class[:render] = Render
        cell_class[:get_size] = GetSize
        object_class[:set_property] = SetProperty
        object_class[:get_property] = GetProperty
        sub.init(cell_class,object_class)
      end)
    end

    InstanceInit = FFI::Function.new(:void,[:pointer]) do |_klass|
      Gtk::CellRenderer.new(FFI::Pointer.new(_klass)).set_padding 2,2
    end

    def self.type_info
      @type_info ||= begin
        type_info = Gtk::Lib::GTypeInfo.new
        type_info[:class_size] = 264
        type_info[:class_init] = self.const_get(:ClassInit)
        type_info[:instance_init] = InstanceInit
        type_info[:instance_size] = 40
        type_info
      end
    end

    class CairoRectangleInt < FFI::Struct
      layout :x, :int, :y, :int, :width, :int, :height, :int;
    end

    Render = FFI::Function.new(:void,[:pointer, :pointer, :pointer, :pointer, :pointer, :int]) do |_cell,_cr,_widget,_background_area,_cell_area,flags|
      Cairo::Context.new(FFI::Pointer.new(_cr)) do |cr|
        instances[_cell.address].render(
          cr,
          Gtk::Widget.new(FFI::Pointer.new(_widget)),
          CairoRectangleInt.new(FFI::Pointer.new(_background_area)),
          CairoRectangleInt.new(FFI::Pointer.new(_cell_area)),
          flags
        )
      end
    end

    GetSize = FFI::Function.new(:void,[:pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer]) do |_cell,_widget,_cell_area,_x_offset,_y_offset,_width,_height|
      x_offset,y_offset,width,height = instances[_cell.address].get_size(
        Gtk::Widget.new(FFI::Pointer.new(_widget)),
        _cell_area.null? ? nil : CairoRectangleInt.new(FFI::Pointer.new(_cell_area))
      )
      _x_offset.write_int(x_offset) if x_offset
      _y_offset.write_int(x_offset) if y_offset
      _width.write_int(width) unless _width.null?
      _height.write_int(height) unless _height.null?
    end

    def self.instances
      @@instances ||= {}
    end
    def instances
      self.class.instances
    end

    def initialize pointer
      raise "hell" unless pointer.is_a?(FFI::Pointer)
      @native = pointer
      instances[native.address] = self
    end
    def self.type
      @type ||= Lib.gtk_cell_renderer_text_get_type()
    end
    def get_padding
      xpad = FFI::MemoryPointer.new(:int,1)
      ypad = FFI::MemoryPointer.new(:int,1)
      Lib.gtk_cell_renderer_get_padding(native,xpad,ypad)
      [xpad.read_int,ypad.read_int]
    end
    def set_padding xpad,ypad
      Lib.gtk_cell_renderer_set_padding(native,xpad,ypad)
    end
    def get_alignment
      xpad = FFI::MemoryPointer.new(:int,1)
      ypad = FFI::MemoryPointer.new(:int,1)
      Lib.gtk_cell_renderer_get_alignment(native,xpad,ypad)
      [xpad.read_int,ypad.read_int]
    end
    # def initialize
    #   @native = Lib.gtk_cell_renderer_new()
    # end
    def self.type
      Lib.gtk_cell_renderer_get_type()
    end
  end
end

