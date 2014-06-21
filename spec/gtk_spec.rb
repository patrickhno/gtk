require 'spec_helper'

describe "gtypes" do
  ClassInitFunc = FFI::Function.new(:void,[:pointer, :pointer]) do |klass,class_data|
    @initialized = true
  end
  InstanceInitFunc = FFI::Function.new(:void,[:pointer, :pointer]) do |instance,klass|
    @instanciated ||= 0
    @instanciated += 1
  end

  G_TYPE_OBJECT = 20 << 2
  before do
    @type ||= Gtk::Lib.g_type_register_static_simple(G_TYPE_OBJECT,
     Gtk::Lib.g_intern_static_string("MyType"),
     144, #sizeof (MamanBarClass),
     ClassInitFunc,
     40, #sizeof (MamanBar),
     InstanceInitFunc,
     0)
  end

  it "should register types" do
    Gtk::Lib.g_type_name(@type).should == "MyType"
  end

  it "should create instances" do
    object = Gtk::Lib.g_object_new(@type,nil)
    object = Gtk::Lib.g_object_new(@type,nil)
    @initialized.should == true
    @instanciated.should == 2
  end
end
