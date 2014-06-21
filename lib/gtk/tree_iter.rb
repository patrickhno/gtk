module Gtk
  class TreeIter < FFI::Struct
    attr_accessor :owner

    layout  :stamp, :long,
            :user_data, :pointer,
            :user_data2, :pointer,
            :user_data3, :pointer

    def [] i      
      owner.get(self,i)
    end

    def []= i,value      
      owner.set(self,i,value)
    end

    def instance
      ObjectSpace._id2ref(owner.get(self,0))
    end
  end
end

