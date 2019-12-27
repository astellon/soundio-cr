require "spec"
require "../src/soundio.cr"

module Helper
  extend self

  @@soundio = Pointer(LibSoundIo::SoundIo).null

  at_exit { LibSoundIo.destroy(@@soundio) }

  def get_soundio
    if @@soundio != Pointer(LibSoundIo::SoundIo).null
      LibSoundIo.destroy(@@soundio)
    end

    return @@soundio = LibSoundIo.create
  end
end
