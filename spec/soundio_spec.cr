require "spec"
require "./spec_helper.cr"

describe "LibSoundIo" do

  #### versin ####

  it "version_{string|major|minor}" do
    String.new(LibSoundIo.version_string()).should eq "#{LibSoundIo.version_major()}.#{LibSoundIo.version_minor()}.#{LibSoundIo.version_patch()}"
  end

  it "create/destroy" do
    io = LibSoundIo.create
    String.new(io.value.app_name).should eq "SoundIo"
    LibSoundIo.destroy(io)
  end

  #### connectoin ####

  it "connect" do
    io = Helper.get_soundio()
    LibSoundIo.connect(io).should eq LibSoundIo::Error::None.to_i
  end

  it "connect_backend" do
    io = Helper.get_soundio()
    LibSoundIo.connect_backend(io, LibSoundIo::Backend::Dummy).should eq LibSoundIo::Error::None.to_i
  end

  it "disconnect" do
    io = Helper.get_soundio()
    LibSoundIo.disconnect(io)
    io.value.current_backend.should eq LibSoundIo::Backend::None
  end

  #### backend ####

  it "backend_name" do
    String.new(LibSoundIo.backend_name(LibSoundIo::Backend::Dummy)).should eq "Dummy"
  end

  it "backend_count" do
    io = Helper.get_soundio()
    LibSoundIo.backend_count(io).should be >= 1 # inluce Dummy
  end

  it "get_backend" do
    io = Helper.get_soundio()
    # WARN: depends an environment
    LibSoundIo.get_backend(io, 0).should be_a LibSoundIo::Backend
  end

  it "have_backend" do
    LibSoundIo.have_backend(LibSoundIo::Backend::Dummy).should be_true
  end

  #### event ####

  # TODO: better test
  it "event" do
    io = Helper.get_soundio()
    LibSoundIo.connect(io)
    LibSoundIo.flush_events(io)
    # LibSoundIo.wait_events(io) ==> stuck
    LibSoundIo.wakeup(io)
    LibSoundIo.force_device_scan(io)
  end

  #### channel layout ####

  it "channel_layout_equal" do
    # TODO: better test
  end

  it "get_channel_name" do
    String.new(LibSoundIo.get_channel_name(LibSoundIo::ChannelId::FrontLeft)).should eq "Front Left"
  end

  it "parse_channel_id" do
    LibSoundIo.parse_channel_id("front-left", 10).should eq LibSoundIo::ChannelId::FrontLeft
  end

  #### format ####
  it "get_bytes_per_sample" do
    LibSoundIo.get_bytes_per_sample(LibSoundIo::Format::Float32LE).should eq 4
  end

  it "format_string" do
    String.new(LibSoundIo.format_string(LibSoundIo::Format::Float32LE)).should eq "float 32-bit LE"
  end

  #### device ####
  it "input_device_count" do
    io = Helper.get_soundio()
    LibSoundIo.connect(io)
    LibSoundIo.flush_events(io)
    LibSoundIo.input_device_count(io).should be >= 0
  end

  it "output_device_count" do
    io = Helper.get_soundio()
    LibSoundIo.connect(io)
    LibSoundIo.flush_events(io)
    LibSoundIo.input_device_count(io).should be >= 0
  end

  #### ring buffer ####
  it "ring_buffer_{create|destroy}" do
    io = Helper.get_soundio()
    rb = LibSoundIo.ring_buffer_create(io, 32).should_not eq Pointer(UInt8).null
    LibSoundIo.ring_buffer_destroy(rb)
  end

  it "ring_buffer_capacity" do
    io = Helper.get_soundio()
    rb = LibSoundIo.ring_buffer_create(io, 32)
    LibSoundIo.ring_buffer_capacity(rb).should be > 32
  end

  it "ring_buffer_write_ptr" do
    io = Helper.get_soundio()
    rb = LibSoundIo.ring_buffer_create(io, 32)
    LibSoundIo.ring_buffer_write_ptr(rb).should_not eq Pointer(UInt8).null
    LibSoundIo.ring_buffer_destroy(rb)
  end

  it "ring_buffer_advance_write_ptr" do
    io = Helper.get_soundio()
    rb = LibSoundIo.ring_buffer_create(io, 32)
    LibSoundIo.ring_buffer_advance_write_ptr(rb, 4)
    LibSoundIo.ring_buffer_destroy(rb)
  end

  it "ring_buffer_read_ptr" do
    io = Helper.get_soundio()
    rb = LibSoundIo.ring_buffer_create(io, 32)
    LibSoundIo.ring_buffer_read_ptr(rb).should_not eq Pointer(UInt8).null
    LibSoundIo.ring_buffer_destroy(rb)
  end

  it "ring_buffer_advance_read_ptr" do
    io = Helper.get_soundio()
    rb = LibSoundIo.ring_buffer_create(io, 32)
    LibSoundIo.ring_buffer_advance_read_ptr(rb, 4)
    LibSoundIo.ring_buffer_destroy(rb)
  end

  it "ring buffer read/write" do
    io = Helper.get_soundio()
    rb = LibSoundIo.ring_buffer_create(io, 32)

    (0..64).each do |i|
      ptr = LibSoundIo.ring_buffer_write_ptr(rb)
      ptr[0] = i.to_u8
      LibSoundIo.ring_buffer_advance_write_ptr(rb, 1)

      ptr = LibSoundIo.ring_buffer_read_ptr(rb)
      ptr.value.should eq i
      LibSoundIo.ring_buffer_advance_read_ptr(rb, 1)
    end

    LibSoundIo.ring_buffer_destroy(rb)
  end
end
