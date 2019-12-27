require "../src/soundio.cr"

write_callback = ->(outstream : Pointer(LibSoundIo::OutStream), frame_count_min : Int32, frame_count_max : Int32) {
  layout = outstream.value.layout
  float_sample_rate = outstream.value.sample_rate
  seconds_per_frame = 1.0 / float_sample_rate
  areas = Pointer(LibSoundIo::ChannelArea).null
  frame_left = frame_count_max

  seconds_offset = outstream.value.userdata.as(Pointer(Float64))

  while frame_left > 0
    frame_count = frame_left

    if (err = LibSoundIo.outstream_begin_write(outstream, pointerof(areas), pointerof(frame_count))) != 0
      STDERR.puts LibSoundIo.strerror err
      raise "cannt begin write"
    end

    if frame_count == 0
      break
    end

    pitch = 440.0
    radias_per_second = pitch * 2.0 * Math::PI

    (0...frame_count).each do |frame|
      sample = Math.sin((seconds_offset.value + frame * seconds_per_frame) * radias_per_second)
      (0...layout.channel_count).each do |channel|
        ptr = (areas[channel].ptr + areas[channel].step * frame).as(Pointer(Float32))
        ptr.value = sample.to_f32
      end
    end

    seconds_offset.value = (seconds_offset.value + seconds_per_frame * frame_count).modulo(1.0)

    if (err = LibSoundIo.outstream_end_write(outstream)) != 0
      STDERR.puts LibSoundIo.strerror err
      raise "cannt end write"
    end

    frame_left -= frame_count
  end
}

soundio = LibSoundIo.create

if soundio == Pointer(LibSoundIo::SoundIo).null
  STDERR.puts "out of memory"
  exit 1
end

if (err = LibSoundIo.connect(soundio)) < 0
  STDERR.puts "error connecting: " + String.new(LibSoundIo.strerror(err))
  exit 1
end

LibSoundIo.flush_events(soundio)

default_out_device_index = LibSoundIo.default_output_device_index(soundio)

if default_out_device_index < 0
  STDERR.puts "no output device found"
  exit 1
end

device = LibSoundIo.get_output_device(soundio, default_out_device_index)

if device == Pointer(LibSoundIo::Device).null
  STDERR.puts "out of memory"
  exit 1
end

STDERR.puts "Output device: " + String.new(device.value.name)

outstream = LibSoundIo.outstream_create(device)

if outstream == Pointer(LibSoundIo::OutStream).null
  STDERR.puts "out of memory"
  exit 1
end

seconds_offset = Pointer(Float64).malloc

outstream.value.format = LibSoundIo::Format::Float32NE
outstream.value.write_callback = write_callback
outstream.value.userdata = seconds_offset.as(Pointer(Void))

if (err = LibSoundIo.outstream_open(outstream)) != 0
  STDERR.puts "unable to open device: " + String.new(LibSoundIo.strerror(err))
  exit 1
end

if outstream.value.layout_error != 0
  STDERR.puts "unable to set channel layout: " + String.new(LibSoundIo.strerror(outstream.value.layout_error))
end

if (err = LibSoundIo.outstream_start(outstream)) != 0
  STDERR.puts "unable to start device: " + String.new(LibSoundIo.strerror(err))
  exit 1
end

loop do
  LibSoundIo.wait_events(soundio)
end

LibSoundIo.outstream_destroy(outstream)
LibSoundIo.device_unref(device)
LibSoundIo.destroy(soundio)

exit 0
