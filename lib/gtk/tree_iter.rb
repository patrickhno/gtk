module Gtk
  class TreeIter < FFI::Struct
    attr_accessor :owner

    layout  :stamp, :long,
            :user_data, :pointer,
            :user_data2, :pointer,
            :user_data3, :pointer

    def [] i
      val = FFI::MemoryPointer.new(:float,1) # TODO: lookup column type
      owner.get(self,:int,i,:pointer,val,:int,-1)
      val.read_float
    end

    def []= i,value
      owner.set(self,:int,i,
        case value
        when String
          :string
        when Fixnum
          :int
        when Float
          :float
        else
          raise value.class.name
        end,
        value,:int,-1)
    end
  end
end

