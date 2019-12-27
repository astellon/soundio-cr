@[Link("soundio")]
lib LibSoundIo
  enum Error
    None
    NoMem
    InitAudioBackend
    SystemResources
    OpeningDevice
    NoSuchDevice
    Invalid
    BackendUnavailable
    Streaming
    IncompatibleDevice
    NoSuchClient
    IncompatibleBackend
    BackendDisconnected
    Interrupted
    Underflow
    EncodingString
  end

  enum ChannelId
    Invalid
    FrontLeft
    FrontRight
    FrontCenter
    Lfe
    BackLeft
    BackRight
    FrontLeftCenter
    FrontRightCenter
    BackCenter
    SideLeft
    SideRight
    TopCenter
    TopFrontLeft
    TopFrontCenter
    TopFrontRight
    TopBackLeft
    TopBackCenter
    TopBackRight
    BackLeftCenter
    BackRightCenter
    FrontLeftWide
    FrontRightWide
    FrontLeftHigh
    FrontCenterHigh
    FrontRightHigh
    TopFrontLeftCenter
    TopFrontRightCenter
    TopSideLeft
    TopSideRight
    LeftLfe
    RightLfe
    Lfe2
    BottomCenter
    BottomLeftCenter
    BottomRightCenter
    MsMid
    MsSide
    AmbisonicW
    AmbisonicX
    AmbisonicY
    AmbisonicZ
    XyX
    XyY
    HeadphonesLeft
    HeadphonesRight
    ClickTrack
    ForeignLanguage
    HearingImpaired
    Narration
    Haptic
    DialogCentricMix
    Aux
    Aux0
    Aux1
    Aux2
    Aux3
    Aux4
    Aux5
    Aux6
    Aux7
    Aux8
    Aux9
    Aux10
    Aux11
    Aux12
    Aux13
    Aux14
    Aux15
  end

  enum ChannelLayoutId
    Mono
    Stereo
    C2Point1
    C3Point0
    C3Point0Back
    C3Point1
    C4Point0
    Quad
    QuadSide
    C4Point1
    C5Point0Back
    C5Point0Side
    C5Point1
    C5Point1Back
    C6Point0Side
    C6Point0Front
    Hexagonal
    C6Point1
    C6Point1Back
    C6Point1Front
    C7Point0
    C7Point0Front
    C7Point1
    C7Point1Wide
    C7Point1WideBack
    Octagonal
  end

  enum Backend
    None
    Jack
    PulseAudio
    Alsa
    CoreAudio
    Wasapi
    Dummy
  end

  enum DeviceAim
    Input
    Output
  end

  enum Format
    Invalid
    S8
    U8
    S16LE
    S16BE
    U16LE
    U16BE
    S24LE
    S24BE
    U24LE
    U24BE
    S32LE
    S32BE
    U32LE
    U32BE
    Float32LE
    Float32BE
    Float64LE
    Float64BE
    {% if IO::ByteFormat::SystemEndian == IO::ByteFormat::LittleEndian %}
      S16NE     = S16LE
      U16NE     = U16LE
      S24NE     = S24LE
      U24NE     = U24LE
      S32NE     = S32LE
      U32NE     = U32LE
      Float32NE = Float32LE
      Float64NE = Float64LE
    {% else %}
      S16NE     = S16BE
      U16NE     = U16BE
      S24NE     = S24BE
      U24NE     = U24BE
      S32NE     = S32BE
      U32NE     = U32BE
      Float32NE = Float32BE
      Float64NE = Float64BE
    {% end %}
  end

  SOUNDIO_MAX_CHANNELS = 24

  struct ChannelLayout
    name : UInt8*
    channel_count : Int32
    channels : StaticArray(ChannelId, SOUNDIO_MAX_CHANNELS)
  end

  struct SampleRateRange
    min : Int32
    max : Int32
  end

  struct ChannelArea
    ptr : UInt8*
    step : Int32
  end

  struct SoundIo
    userdata : Void*
    on_device_change : SoundIo* -> Void
    on_backend_disconnect : SoundIo*, Int32 -> Void
    on_events_signal : SoundIo* -> Void
    current_backend : LibSoundIo::Backend
    app_name : UInt8*
    emit_rtprio_warning : Void -> Void
    jack_info_callback : UInt8* -> Void
    jack_error_callback : UInt8* -> Void
  end

  struct Device
    soundio : SoundIo*
    id : UInt8*
    name : UInt8*
    aim : DeviceAim
    layouts : ChannelLayout*
    layout_count : Int32
    current_layout : ChannelLayout
    formats : Format*
    format_count : Int32
    current_format : Format
    sample_rates : SampleRateRange*
    sample_rate_count : Int32
    sample_rate_current : Int32
    software_latency_min : Float64
    software_latency_max : Float64
    software_latency_current : Float64
    is_raw : Bool
    ref_count : Int32
    probe_error : Int32
  end

  struct OutStream
    device : Device*
    format : Format
    sample_rate : Int32
    layout : ChannelLayout
    software_latency : Float64
    volume : Float32
    userdata : Void*
    write_callback : OutStream*, Int32, Int32 -> Void
    underflow_callback : OutStream* -> Void
    error_callback : OutStream*, Int32 -> Void
    name : UInt8*
    non_terminal_hint : Bool
    bytes_per_frame : Int32
    bytes_per_sample　 : Int32
    layout_error : Int32
  end

  struct InStream
    device : Device*
    format : Format
    sample_rate : Int32
    layout : ChannelLayout
    software_latency : Float64
    userdata : Void*
    read_callback : OutStream*, Int32, Int32 -> Void
    overflow_callback : OutStream* -> Void
    error_callback : OutStream*, Int32 -> Void
    name : UInt8*
    non_terminal_hint : Bool
    bytes_per_frame : Int32
    bytes_per_sample　 : Int32
    layout_error : Int32
  end

  alias RingBuffer = Void*

  fun version_string = soundio_version_string : UInt8*
  fun version_major = soundio_version_major : Int32
  fun version_minor = soundio_version_minor : Int32
  fun version_patch = soundio_version_patch : Int32

  fun create = soundio_create : SoundIo*
  fun destroy = soundio_destroy(SoundIo*) : Void

  fun connect = soundio_connect(SoundIo*) : Int32
  fun connect_backend = soundio_connect_backend(SoundIo*, Backend) : Int32
  fun disconnect = soundio_disconnect(SoundIo*)

  fun strerror = soundio_strerror(Int32) : UInt8*

  fun backend_name = soundio_backend_name(Backend) : UInt8*
  fun backend_count = soundio_backend_count(SoundIo*) : Int32
  fun get_backend = soundio_get_backend(SoundIo*, Int32) : Backend
  fun have_backend = soundio_have_backend(Backend) : Bool

  fun flush_events = soundio_flush_events(SoundIo*) : Void
  fun wait_events = soundio_wait_events(SoundIo*) : Void
  fun wakeup = soundio_wakeup(SoundIo*) : Void
  fun force_device_scan = soundio_force_device_scan(SoundIo*) : Void

  fun channel_layout_equal = soundio_channel_layout_equal(ChannelLayout*, ChannelLayout*) : Bool
  fun get_channel_name = soundio_get_channel_name(ChannelId) : UInt8*
  fun parse_channel_id = soundio_parse_channel_id(UInt8*, Int32) : ChannelId
  fun channel_layout_builtin_count = soundio_channel_layout_builtin_count : Int32
  fun channel_layout_get_builtin = soundio_channel_layout_get_builtin(Int32) : ChannelLayout*
  fun channel_layout_get_default = soundio_channel_layout_get_default(Int32) : ChannelLayout*
  fun channel_layout_find_channel = soundio_channel_layout_find_channel(ChannelLayout*, ChannelId) : Int32
  fun channel_layout_detect_builtin = soundio_channel_layout_detect_builtin(ChannelLayout*) : Bool
  fun best_matching_channel_layout = soundio_best_matching_channel_layout(ChannelLayout*, Int32, ChannelLayout*, Int32) : ChannelLayout*
  fun sort_channel_layouts = soundio_sort_channel_layouts(ChannelLayout*, Int32) : Void

  fun get_bytes_per_sample = soundio_get_bytes_per_sample(Format) : Int32
  fun format_string = soundio_format_string(Format) : UInt8*

  fun input_device_count = soundio_input_device_count(SoundIo*) : Int32
  fun output_device_count = soundio_output_device_count(SoundIo*) : Int32
  fun get_input_device = soundio_get_input_device(SoundIo*, Int32) : Device*
  fun get_output_device = soundio_get_output_device(SoundIo*, Int32) : Device*
  fun default_input_device_index = soundio_default_input_device_index(SoundIo*) : Int32
  fun default_output_device_index = soundio_default_output_device_index(SoundIo*) : Int32
  fun device_ref = soundio_device_ref(Device*) : Void
  fun device_unref = soundio_device_unref(Device*) : Void
  fun device_equal = soundio_device_equal(Device*, Device*) : Bool
  fun device_sort_channel_layouts = soundio_device_sort_channel_layouts(Device*) : Void
  fun device_supports_format = soundio_device_supports_format(Device*, Format) : Bool
  fun device_supports_layout = soundio_device_supports_layout(Device*, ChannelLayout*) : Bool
  fun device_supports_sample_rate = soundio_device_supports_sample_rate(Device*, Int32) : Bool
  fun device_nearest_sample_rate = soundio_device_nearest_sample_rate(Device*, Int32) : Int32

  # ### stream ####
  fun outstream_create = soundio_outstream_create(Device*) : OutStream*
  fun outstream_destroy = soundio_outstream_destroy(OutStream*) : Void
  fun outstream_open = soundio_outstream_open(OutStream*) : Int32
  @[Raises]
  fun outstream_start = soundio_outstream_start(OutStream*) : Int32
  fun outstream_begin_write = soundio_outstream_begin_write(OutStream*, ChannelArea**, Int32*) : Int32
  fun outstream_end_write = soundio_outstream_end_write(OutStream*) : Int32
  fun outstream_clear_buffer = soundio_outstream_clear_buffer(OutStream*) : Int32
  fun outstream_pause = soundio_outstream_pause(OutStream*, Bool) : Int32
  fun outstream_get_latency = soundio_outstream_get_latency(OutStream*, Float64*) : Int32

  fun instream_create = soundio_instream_create(Device*) : InStream*
  fun instream_destroy = soundio_instream_destroy(InStream*) : Void
  fun instream_open = soundio_instream_open(InStream*) : Int32
  fun instream_start = soundio_instream_start(InStream*) : Int32
  fun instream_begin_read = soundio_instream_begin_write(InStream*, ChannelArea**, Int32*) : Int32
  fun instream_end_read = soundio_instream_end_write(InStream*) : Int32
  fun instream_clear_buffer = soundio_instream_clear_buffer(InStream*) : Int32
  fun instream_pause = soundio_instream_pause(InStream*, Bool) : Int32
  fun instream_get_latency = soundio_instream_get_latency(InStream*, Float64*) : Int32

  # ### ring buffer ####
  fun ring_buffer_create = soundio_ring_buffer_create(SoundIo*, Int32) : RingBuffer*
  fun ring_buffer_destroy = soundio_ring_buffer_destroy(RingBuffer*) : Void
  fun ring_buffer_capacity = soundio_ring_buffer_capacity(RingBuffer*) : Int32
  fun ring_buffer_write_ptr = soundio_ring_buffer_write_ptr(RingBuffer*) : UInt8*
  fun ring_buffer_advance_write_ptr = soundio_ring_buffer_advance_write_ptr(RingBuffer*, Int32) : Void
  fun ring_buffer_read_ptr = soundio_ring_buffer_read_ptr(RingBuffer*) : UInt8*
  fun ring_buffer_advance_read_ptr = soundio_ring_buffer_advance_read_ptr(RingBuffer*, Int32) : Void
  fun ring_buffer_fill_count = soundio_ring_buffer_fill_count(RingBuffer*) : Int32
  fun ring_buffer_free_count = soundio_ring_buffer_free_count(RingBuffer*) : Int32
  fun ring_buffer_clear = soundio_ring_buffer_clear(RingBuffer*) : Void
end
