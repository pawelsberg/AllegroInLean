import Allegro.Core.System

/-!
Audio addon bindings for Allegro 5.

Covers the full audio pipeline: sample loading & quick-play, sample
instances with gain/pan/speed control, audio streams for music,
mixer and voice management, device enumeration, and playmode/depth/
channel configuration constants.

## Quick playback (fire-and-forget)
```
let _ ← Allegro.installAudio
let _ ← Allegro.initAcodecAddon
let _ ← Allegro.reserveSamples 4
let spl ← Allegro.loadSample "beep.wav"
let _ ← Allegro.playSample spl 1.0 0.0 1.0 Playmode.once
Allegro.rest 0.5
Allegro.destroySample spl
```

## Sample instance (gain / pan / speed control)
```
let inst ← Allegro.createSampleInstance spl
let mixer ← Allegro.getDefaultMixer
let _ ← Allegro.attachSampleInstanceToMixer inst mixer
let _ ← Allegro.setSampleInstanceGain inst 0.6
let _ ← Allegro.playSampleInstance inst
```

## Audio stream (music)
```
let stream ← Allegro.loadAudioStream "music.ogg" 4 2048
let mixer ← Allegro.getDefaultMixer
let _ ← Allegro.attachAudioStreamToMixer stream mixer
let _ ← Allegro.setAudioStreamPlaymode stream Allegro.Playmode.loop
```
-/
namespace Allegro

/-- Opaque handle to a loaded audio sample. -/
def Sample := UInt64

instance : BEq Sample := inferInstanceAs (BEq UInt64)
instance : Inhabited Sample := inferInstanceAs (Inhabited UInt64)
instance : OfNat Sample 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Sample := ⟨fun (h : UInt64) => s!"Sample#{h}"⟩
instance : Repr Sample := ⟨fun (h : UInt64) _ => .text s!"Sample#{repr h}"⟩

/-- Opaque handle to a sample instance (playback control). -/
def SampleInstance := UInt64

instance : BEq SampleInstance := inferInstanceAs (BEq UInt64)
instance : Inhabited SampleInstance := inferInstanceAs (Inhabited UInt64)
instance : OfNat SampleInstance 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString SampleInstance := ⟨fun (h : UInt64) => s!"SampleInstance#{h}"⟩
instance : Repr SampleInstance := ⟨fun (h : UInt64) _ => .text s!"SampleInstance#{repr h}"⟩

/-- Opaque handle to an audio stream (music, long audio). -/
def AudioStream := UInt64

instance : BEq AudioStream := inferInstanceAs (BEq UInt64)
instance : Inhabited AudioStream := inferInstanceAs (Inhabited UInt64)
instance : OfNat AudioStream 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString AudioStream := ⟨fun (h : UInt64) => s!"AudioStream#{h}"⟩
instance : Repr AudioStream := ⟨fun (h : UInt64) _ => .text s!"AudioStream#{repr h}"⟩

/-- Opaque handle to an audio mixer. -/
def Mixer := UInt64

instance : BEq Mixer := inferInstanceAs (BEq UInt64)
instance : Inhabited Mixer := inferInstanceAs (Inhabited UInt64)
instance : OfNat Mixer 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Mixer := ⟨fun (h : UInt64) => s!"Mixer#{h}"⟩
instance : Repr Mixer := ⟨fun (h : UInt64) _ => .text s!"Mixer#{repr h}"⟩

/-- Opaque handle to an audio voice (output device). -/
def Voice := UInt64

instance : BEq Voice := inferInstanceAs (BEq UInt64)
instance : Inhabited Voice := inferInstanceAs (Inhabited UInt64)
instance : OfNat Voice 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Voice := ⟨fun (h : UInt64) => s!"Voice#{h}"⟩
instance : Repr Voice := ⟨fun (h : UInt64) _ => .text s!"Voice#{repr h}"⟩

/-- Opaque handle to an audio recorder (UNSTABLE). -/
def AudioRecorder := UInt64

instance : BEq AudioRecorder := inferInstanceAs (BEq UInt64)
instance : Inhabited AudioRecorder := inferInstanceAs (Inhabited UInt64)
instance : OfNat AudioRecorder 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString AudioRecorder := ⟨fun (h : UInt64) => s!"AudioRecorder#{h}"⟩
instance : Repr AudioRecorder := ⟨fun (h : UInt64) _ => .text s!"AudioRecorder#{repr h}"⟩

-- ── Installation & codec ──

/-- Install the audio subsystem. Returns non-zero on success. -/
@[extern "allegro_al_install_audio"]
opaque installAudio : IO UInt32

/-- Uninstall the audio subsystem. -/
@[extern "allegro_al_uninstall_audio"]
opaque uninstallAudio : IO Unit

/-- Check if the audio subsystem is installed. Returns 1 if yes. -/
@[extern "allegro_al_is_audio_installed"]
opaque isAudioInstalled : IO UInt32

/-- Initialise the audio codec addon (OGG, FLAC, WAV, etc.). Returns non-zero on success. -/
@[extern "allegro_al_init_acodec_addon"]
opaque initAcodecAddon : IO UInt32

/-- Reserve sample slots for fire-and-forget playback via `playSample`. -/
@[extern "allegro_al_reserve_samples"]
opaque reserveSamples : UInt32 → IO UInt32

-- ── Sample ──

/-- Load an audio sample from a file. Returns null on failure. -/
@[extern "allegro_al_load_sample"]
opaque loadSample : String → IO Sample

/-- Destroy an audio sample and free its memory. -/
@[extern "allegro_al_destroy_sample"]
opaque destroySample : Sample → IO Unit

-- ── Playmode constants ──

/-- Allegro playmode (once, loop, bidirectional, etc.). -/
structure Playmode where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace Playmode
/-- Play the sample/stream once, then stop. -/
def once : Playmode := ⟨256⟩
/-- Loop the sample/stream continuously. -/
def loop : Playmode := ⟨257⟩
/-- Loop the sample/stream in bidirectional (ping-pong) mode. -/
def bidir : Playmode := ⟨258⟩
/-- Play the sample loop section once (loop start → loop end), then stop. -/
def loopOnce : Playmode := ⟨261⟩
end Playmode

-- ── Audio depth constants ──

/-- Allegro audio sample depth (bit-depth and signedness). -/
structure AudioDepth where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace AudioDepth
/-- Signed 8-bit integer audio depth. -/
def int8 : AudioDepth := ⟨0⟩
/-- Signed 16-bit integer audio depth. -/
def int16 : AudioDepth := ⟨1⟩
/-- Signed 24-bit integer audio depth. -/
def int24 : AudioDepth := ⟨2⟩
/-- 32-bit floating-point audio depth. -/
def float32 : AudioDepth := ⟨3⟩
/-- Unsigned 8-bit integer audio depth. -/
def uint8 : AudioDepth := ⟨8⟩
/-- Unsigned 16-bit integer audio depth. -/
def uint16 : AudioDepth := ⟨9⟩
/-- Unsigned 24-bit integer audio depth. -/
def uint24 : AudioDepth := ⟨10⟩
end AudioDepth

-- ── Channel configuration constants ──

/-- Allegro channel configuration (mono, stereo, surround, etc.). -/
structure ChannelConf where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace ChannelConf
/-- Mono (1 channel). -/
def conf1 : ChannelConf := ⟨16⟩
/-- Stereo (2 channels). -/
def conf2 : ChannelConf := ⟨32⟩
/-- 3 channels. -/
def conf3 : ChannelConf := ⟨48⟩
/-- 4 channels (quadraphonic). -/
def conf4 : ChannelConf := ⟨64⟩
/-- 5.1 surround (6 channels). -/
def conf51 : ChannelConf := ⟨81⟩
/-- 6.1 surround (7 channels). -/
def conf61 : ChannelConf := ⟨97⟩
/-- 7.1 surround (8 channels). -/
def conf71 : ChannelConf := ⟨113⟩
end ChannelConf

-- ── Mixer quality constants ──

/-- Allegro mixer interpolation quality. -/
structure MixerQuality where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace MixerQuality
/-- Point (nearest-neighbour) sample interpolation — fastest, lowest quality. -/
def point : MixerQuality := ⟨272⟩
/-- Linear sample interpolation — good balance of speed and quality. -/
def linear : MixerQuality := ⟨273⟩
/-- Cubic sample interpolation — highest quality, most CPU intensive. -/
def cubic : MixerQuality := ⟨274⟩
end MixerQuality

@[extern "allegro_al_play_sample"]
private opaque playSampleRaw : Sample → Float → Float → Float → UInt32 → IO UInt32

/-- Fire-and-forget playback. `playSample spl gain pan speed mode`
    where mode is a `Playmode` value (once, loop, bidir, loopOnce). -/
@[inline] def playSample (spl : Sample) (gain pan speed : Float) (mode : Playmode) : IO UInt32 :=
  playSampleRaw spl gain pan speed mode.val

/-- Stop all samples started by `playSample`. -/
@[extern "allegro_al_stop_samples"]
opaque stopSamples : IO Unit

/-- Get the sample's frequency (samples per second). -/
@[extern "allegro_al_get_sample_frequency"]
opaque getSampleFrequency : Sample → IO UInt32

/-- Get the number of sample frames in the sample. -/
@[extern "allegro_al_get_sample_length"]
opaque getSampleLength : Sample → IO UInt32

@[extern "allegro_al_get_sample_depth"]
private opaque getSampleDepthRaw : Sample → IO UInt32

/-- Get the audio depth of the sample. -/
@[inline] def getSampleDepth (spl : Sample) : IO AudioDepth := do
  let v ← getSampleDepthRaw spl
  return ⟨v⟩

@[extern "allegro_al_get_sample_channels"]
private opaque getSampleChannelsRaw : Sample → IO UInt32

/-- Get the channel configuration of the sample. -/
@[inline] def getSampleChannels (spl : Sample) : IO ChannelConf := do
  let v ← getSampleChannelsRaw spl
  return ⟨v⟩

-- ── Sample instance ──

/-- Create a sample instance for controlled playback. Returns null on failure. -/
@[extern "allegro_al_create_sample_instance"]
opaque createSampleInstance : Sample → IO SampleInstance

/-- Destroy a sample instance. -/
@[extern "allegro_al_destroy_sample_instance"]
opaque destroySampleInstance : SampleInstance → IO Unit

/-- Start playing a sample instance. Returns non-zero on success. -/
@[extern "allegro_al_play_sample_instance"]
opaque playSampleInstance : SampleInstance → IO UInt32

/-- Stop a playing sample instance. Returns non-zero on success. -/
@[extern "allegro_al_stop_sample_instance"]
opaque stopSampleInstance : SampleInstance → IO UInt32

/-- Check if a sample instance is playing. Returns 1 if playing. -/
@[extern "allegro_al_get_sample_instance_playing"]
opaque getSampleInstancePlaying : SampleInstance → IO UInt32

/-- Set the playing state of a sample instance (1 = play, 0 = stop). -/
@[extern "allegro_al_set_sample_instance_playing"]
opaque setSampleInstancePlaying : SampleInstance → UInt32 → IO UInt32

/-- Get the gain (volume) of a sample instance. -/
@[extern "allegro_al_get_sample_instance_gain"]
opaque getSampleInstanceGain : SampleInstance → IO Float

/-- Set the gain (volume) of a sample instance. Returns non-zero on success. -/
@[extern "allegro_al_set_sample_instance_gain"]
opaque setSampleInstanceGain : SampleInstance → Float → IO UInt32

/-- Get the stereo pan of a sample instance (−1.0 = left, 0.0 = centre, 1.0 = right). -/
@[extern "allegro_al_get_sample_instance_pan"]
opaque getSampleInstancePan : SampleInstance → IO Float

/-- Set the stereo pan. Returns non-zero on success. -/
@[extern "allegro_al_set_sample_instance_pan"]
opaque setSampleInstancePan : SampleInstance → Float → IO UInt32

/-- Get the playback speed multiplier. -/
@[extern "allegro_al_get_sample_instance_speed"]
opaque getSampleInstanceSpeed : SampleInstance → IO Float

/-- Set the playback speed multiplier. Returns non-zero on success. -/
@[extern "allegro_al_set_sample_instance_speed"]
opaque setSampleInstanceSpeed : SampleInstance → Float → IO UInt32

/-- Get the current playback position in sample frames. -/
@[extern "allegro_al_get_sample_instance_position"]
opaque getSampleInstancePosition : SampleInstance → IO UInt32

/-- Set the playback position in sample frames. Returns non-zero on success. -/
@[extern "allegro_al_set_sample_instance_position"]
opaque setSampleInstancePosition : SampleInstance → UInt32 → IO UInt32

/-- Get the total length of the sample instance in frames. -/
@[extern "allegro_al_get_sample_instance_length"]
opaque getSampleInstanceLength : SampleInstance → IO UInt32

@[extern "allegro_al_get_sample_instance_playmode"]
private opaque getSampleInstancePlaymodeRaw : SampleInstance → IO UInt32

/-- Get the playmode of a sample instance. -/
@[inline] def getSampleInstancePlaymode (inst : SampleInstance) : IO Playmode := do
  let v ← getSampleInstancePlaymodeRaw inst
  return ⟨v⟩

@[extern "allegro_al_set_sample_instance_playmode"]
private opaque setSampleInstancePlaymodeRaw : SampleInstance → UInt32 → IO UInt32

/-- Set the playmode of a sample instance (once, loop, etc.). Returns non-zero on success. -/
@[inline] def setSampleInstancePlaymode (inst : SampleInstance) (mode : Playmode) : IO UInt32 :=
  setSampleInstancePlaymodeRaw inst mode.val

/-- Detach a sample instance from its mixer. Returns non-zero on success. -/
@[extern "allegro_al_detach_sample_instance"]
opaque detachSampleInstance : SampleInstance → IO UInt32

/-- Attach a sample instance to a mixer for playback. Returns non-zero on success. -/
@[extern "allegro_al_attach_sample_instance_to_mixer"]
opaque attachSampleInstanceToMixer : SampleInstance → Mixer → IO UInt32

-- ── Audio stream ──

/-- Load a stream from file. `loadAudioStream path bufferCount samples` -/
@[extern "allegro_al_load_audio_stream"]
opaque loadAudioStream : String → UInt32 → UInt32 → IO AudioStream

/-- Convenience: load and immediately start playing via the default mixer. -/
@[extern "allegro_al_play_audio_stream"]
opaque playAudioStream : String → IO AudioStream

/-- Destroy an audio stream and free its resources. -/
@[extern "allegro_al_destroy_audio_stream"]
opaque destroyAudioStream : AudioStream → IO Unit

/-- Block until the stream finishes playing. -/
@[extern "allegro_al_drain_audio_stream"]
opaque drainAudioStream : AudioStream → IO Unit

/-- Rewind the audio stream to the beginning. Returns non-zero on success. -/
@[extern "allegro_al_rewind_audio_stream"]
opaque rewindAudioStream : AudioStream → IO UInt32

/-- Check if the audio stream is playing. Returns 1 if playing. -/
@[extern "allegro_al_get_audio_stream_playing"]
opaque getAudioStreamPlaying : AudioStream → IO UInt32

/-- Set the playing state of the audio stream. Returns non-zero on success. -/
@[extern "allegro_al_set_audio_stream_playing"]
opaque setAudioStreamPlaying : AudioStream → UInt32 → IO UInt32

/-- Get the gain (volume) of the audio stream. -/
@[extern "allegro_al_get_audio_stream_gain"]
opaque getAudioStreamGain : AudioStream → IO Float

/-- Set the gain (volume) of the audio stream. Returns non-zero on success. -/
@[extern "allegro_al_set_audio_stream_gain"]
opaque setAudioStreamGain : AudioStream → Float → IO UInt32

/-- Get the stereo pan of the audio stream. -/
@[extern "allegro_al_get_audio_stream_pan"]
opaque getAudioStreamPan : AudioStream → IO Float

/-- Set the stereo pan of the audio stream. Returns non-zero on success. -/
@[extern "allegro_al_set_audio_stream_pan"]
opaque setAudioStreamPan : AudioStream → Float → IO UInt32

/-- Get the playback speed multiplier of the audio stream. -/
@[extern "allegro_al_get_audio_stream_speed"]
opaque getAudioStreamSpeed : AudioStream → IO Float

/-- Set the playback speed multiplier of the audio stream. Returns non-zero on success. -/
@[extern "allegro_al_set_audio_stream_speed"]
opaque setAudioStreamSpeed : AudioStream → Float → IO UInt32

@[extern "allegro_al_get_audio_stream_playmode"]
private opaque getAudioStreamPlaymodeRaw : AudioStream → IO UInt32

/-- Get the playmode of the audio stream. -/
@[inline] def getAudioStreamPlaymode (stream : AudioStream) : IO Playmode := do
  let v ← getAudioStreamPlaymodeRaw stream
  return ⟨v⟩

@[extern "allegro_al_set_audio_stream_playmode"]
private opaque setAudioStreamPlaymodeRaw : AudioStream → UInt32 → IO UInt32

/-- Set the playmode of the audio stream (once, loop, etc.). Returns non-zero on success. -/
@[inline] def setAudioStreamPlaymode (stream : AudioStream) (mode : Playmode) : IO UInt32 :=
  setAudioStreamPlaymodeRaw stream mode.val

/-- Seek to a position in the audio stream (in seconds). Returns non-zero on success. -/
@[extern "allegro_al_seek_audio_stream_secs"]
opaque seekAudioStreamSecs : AudioStream → Float → IO UInt32

/-- Get the current playback position of the audio stream in seconds. -/
@[extern "allegro_al_get_audio_stream_position_secs"]
opaque getAudioStreamPositionSecs : AudioStream → IO Float

/-- Get the total length of the audio stream in seconds. -/
@[extern "allegro_al_get_audio_stream_length_secs"]
opaque getAudioStreamLengthSecs : AudioStream → IO Float

/-- Set the loop points of the audio stream in seconds. Returns non-zero on success. -/
@[extern "allegro_al_set_audio_stream_loop_secs"]
opaque setAudioStreamLoopSecs : AudioStream → Float → Float → IO UInt32

/-- Get the event source for the audio stream (emits fragment-consumed events). -/
@[extern "allegro_al_get_audio_stream_event_source"]
opaque getAudioStreamEventSource : AudioStream → IO UInt64

/-- Attach the audio stream to a mixer for playback. Returns non-zero on success. -/
@[extern "allegro_al_attach_audio_stream_to_mixer"]
opaque attachAudioStreamToMixer : AudioStream → Mixer → IO UInt32

/-- Detach the audio stream from its mixer. Returns non-zero on success. -/
@[extern "allegro_al_detach_audio_stream"]
opaque detachAudioStream : AudioStream → IO UInt32

-- ── Mixer ──

@[extern "allegro_al_create_mixer"]
private opaque createMixerRaw : UInt32 → UInt32 → UInt32 → IO Mixer

/-- Create a mixer. `createMixer frequency depth channelConf` -/
@[inline] def createMixer (freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO Mixer :=
  createMixerRaw freq depth.val chanConf.val

/-- Destroy a mixer and free its resources. -/
@[extern "allegro_al_destroy_mixer"]
opaque destroyMixer : Mixer → IO Unit

/-- Get the default mixer (created by `reserveSamples`). -/
@[extern "allegro_al_get_default_mixer"]
opaque getDefaultMixer : IO Mixer

/-- Set a mixer as the default mixer. Returns non-zero on success. -/
@[extern "allegro_al_set_default_mixer"]
opaque setDefaultMixer : Mixer → IO UInt32

/-- Restore the original default mixer. Returns non-zero on success. -/
@[extern "allegro_al_restore_default_mixer"]
opaque restoreDefaultMixer : IO UInt32

/-- Attach a mixer to another mixer as a sub-mixer. Returns non-zero on success. -/
@[extern "allegro_al_attach_mixer_to_mixer"]
opaque attachMixerToMixer : Mixer → Mixer → IO UInt32

/-- Detach a mixer from its parent mixer. Returns non-zero on success. -/
@[extern "allegro_al_detach_mixer"]
opaque detachMixer : Mixer → IO UInt32

/-- Get the mixer's output frequency in Hz. -/
@[extern "allegro_al_get_mixer_frequency"]
opaque getMixerFrequency : Mixer → IO UInt32

/-- Set the mixer's output frequency. Returns non-zero on success. -/
@[extern "allegro_al_set_mixer_frequency"]
opaque setMixerFrequency : Mixer → UInt32 → IO UInt32

/-- Get the mixer's gain (volume multiplier). -/
@[extern "allegro_al_get_mixer_gain"]
opaque getMixerGain : Mixer → IO Float

/-- Set the mixer's gain. Returns non-zero on success. -/
@[extern "allegro_al_set_mixer_gain"]
opaque setMixerGain : Mixer → Float → IO UInt32

@[extern "allegro_al_get_mixer_quality"]
private opaque getMixerQualityRaw : Mixer → IO UInt32

/-- Get the mixer's interpolation quality. -/
@[inline] def getMixerQuality (mixer : Mixer) : IO MixerQuality := do
  let v ← getMixerQualityRaw mixer
  return ⟨v⟩

@[extern "allegro_al_set_mixer_quality"]
private opaque setMixerQualityRaw : Mixer → UInt32 → IO UInt32

/-- Set the mixer's interpolation quality. Returns non-zero on success. -/
@[inline] def setMixerQuality (mixer : Mixer) (quality : MixerQuality) : IO UInt32 :=
  setMixerQualityRaw mixer quality.val

/-- Check if the mixer is playing. Returns 1 if playing. -/
@[extern "allegro_al_get_mixer_playing"]
opaque getMixerPlaying : Mixer → IO UInt32

/-- Set the mixer playing state. Returns non-zero on success. -/
@[extern "allegro_al_set_mixer_playing"]
opaque setMixerPlaying : Mixer → UInt32 → IO UInt32

-- ── Voice ──

@[extern "allegro_al_create_voice"]
private opaque createVoiceRaw : UInt32 → UInt32 → UInt32 → IO Voice

/-- Create a voice. `createVoice frequency depth channelConf` -/
@[inline] def createVoice (freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO Voice :=
  createVoiceRaw freq depth.val chanConf.val

/-- Destroy a voice and free its resources. -/
@[extern "allegro_al_destroy_voice"]
opaque destroyVoice : Voice → IO Unit

/-- Attach a mixer to a voice for output. Returns non-zero on success. -/
@[extern "allegro_al_attach_mixer_to_voice"]
opaque attachMixerToVoice : Mixer → Voice → IO UInt32

/-- Detach the mixer from a voice. -/
@[extern "allegro_al_detach_voice"]
opaque detachVoice : Voice → IO Unit

/-- Get the voice's output frequency in Hz. -/
@[extern "allegro_al_get_voice_frequency"]
opaque getVoiceFrequency : Voice → IO UInt32

/-- Check if the voice is playing. Returns 1 if playing. -/
@[extern "allegro_al_get_voice_playing"]
opaque getVoicePlaying : Voice → IO UInt32

/-- Set the voice playing state. Returns non-zero on success. -/
@[extern "allegro_al_set_voice_playing"]
opaque setVoicePlaying : Voice → UInt32 → IO UInt32

/-- Get the default voice. Returns null if none is set. -/
@[extern "allegro_al_get_default_voice"]
opaque getDefaultVoice : IO Voice

-- ── Version & utility ──

/-- Get the audio addon version (packed as major·minor·revision·release). -/
@[extern "allegro_al_get_allegro_audio_version"]
opaque getAudioVersion : IO UInt32

@[extern "allegro_al_get_channel_count"]
private opaque getChannelCountRaw : UInt32 → IO UInt32

/-- Get the number of channels for a channel configuration constant. -/
@[inline] def getChannelCount (conf : ChannelConf) : IO UInt32 :=
  getChannelCountRaw conf.val

@[extern "allegro_al_get_audio_depth_size"]
private opaque getAudioDepthSizeRaw : UInt32 → IO UInt32

/-- Get the byte size of one sample for the given audio depth. -/
@[inline] def getAudioDepthSize (depth : AudioDepth) : IO UInt32 :=
  getAudioDepthSizeRaw depth.val

/-- Get the acodec addon version (packed as major·minor·revision·release). -/
@[extern "allegro_al_get_allegro_acodec_version"]
opaque getAcodecVersion : IO UInt32

/-- Check if the acodec addon is initialised. Returns 1 if yes. -/
@[extern "allegro_al_is_acodec_addon_initialized"]
opaque isAcodecAddonInitialized : IO UInt32

-- ── Sample instance extra getters ──

/-- Get the playback frequency of a sample instance (Hz). -/
@[extern "allegro_al_get_sample_instance_frequency"]
opaque getSampleInstanceFrequency : SampleInstance → IO UInt32

@[extern "allegro_al_get_sample_instance_channels"]
private opaque getSampleInstanceChannelsRaw : SampleInstance → IO UInt32

/-- Get the channel configuration of a sample instance. -/
@[inline] def getSampleInstanceChannels (inst : SampleInstance) : IO ChannelConf := do
  let v ← getSampleInstanceChannelsRaw inst
  return ⟨v⟩

@[extern "allegro_al_get_sample_instance_depth"]
private opaque getSampleInstanceDepthRaw : SampleInstance → IO UInt32

/-- Get the audio depth of a sample instance. -/
@[inline] def getSampleInstanceDepth (inst : SampleInstance) : IO AudioDepth := do
  let v ← getSampleInstanceDepthRaw inst
  return ⟨v⟩

/-- Check if a sample instance is attached to a mixer or voice. Returns 1 if attached. -/
@[extern "allegro_al_get_sample_instance_attached"]
opaque getSampleInstanceAttached : SampleInstance → IO UInt32

/-- Get the time length of a sample instance in seconds. -/
@[extern "allegro_al_get_sample_instance_time"]
opaque getSampleInstanceTime : SampleInstance → IO Float

/-- Set the length of a sample instance in samples. Returns non-zero on success. -/
@[extern "allegro_al_set_sample_instance_length"]
opaque setSampleInstanceLength : SampleInstance → UInt32 → IO UInt32

-- ── Audio stream extra getters ──

/-- Get the audio stream's sample frequency (Hz). -/
@[extern "allegro_al_get_audio_stream_frequency"]
opaque getAudioStreamFrequency : AudioStream → IO UInt32

/-- Get the audio stream's buffer length in sample frames. -/
@[extern "allegro_al_get_audio_stream_length"]
opaque getAudioStreamLength : AudioStream → IO UInt32

/-- Get the total number of fragments in the stream buffer. -/
@[extern "allegro_al_get_audio_stream_fragments"]
opaque getAudioStreamFragments : AudioStream → IO UInt32

/-- Get the number of available (writable) fragments. -/
@[extern "allegro_al_get_available_audio_stream_fragments"]
opaque getAvailableAudioStreamFragments : AudioStream → IO UInt32

@[extern "allegro_al_get_audio_stream_channels"]
private opaque getAudioStreamChannelsRaw : AudioStream → IO UInt32

/-- Get the channel configuration of an audio stream. -/
@[inline] def getAudioStreamChannels (stream : AudioStream) : IO ChannelConf := do
  let v ← getAudioStreamChannelsRaw stream
  return ⟨v⟩

@[extern "allegro_al_get_audio_stream_depth"]
private opaque getAudioStreamDepthRaw : AudioStream → IO UInt32

/-- Get the audio depth of an audio stream. -/
@[inline] def getAudioStreamDepth (stream : AudioStream) : IO AudioDepth := do
  let v ← getAudioStreamDepthRaw stream
  return ⟨v⟩

/-- Check if an audio stream is attached to a mixer or voice. Returns 1 if attached. -/
@[extern "allegro_al_get_audio_stream_attached"]
opaque getAudioStreamAttached : AudioStream → IO UInt32

/-- Get the total number of samples played from the stream since it was started. -/
@[extern "allegro_al_get_audio_stream_played_samples"]
opaque getAudioStreamPlayedSamples : AudioStream → IO UInt64

-- ── Mixer extra getters ──

@[extern "allegro_al_get_mixer_channels"]
private opaque getMixerChannelsRaw : Mixer → IO UInt32

/-- Get the mixer's channel configuration. -/
@[inline] def getMixerChannels (mixer : Mixer) : IO ChannelConf := do
  let v ← getMixerChannelsRaw mixer
  return ⟨v⟩

@[extern "allegro_al_get_mixer_depth"]
private opaque getMixerDepthRaw : Mixer → IO UInt32

/-- Get the mixer's audio depth. -/
@[inline] def getMixerDepth (mixer : Mixer) : IO AudioDepth := do
  let v ← getMixerDepthRaw mixer
  return ⟨v⟩

/-- Check if a mixer is attached to another mixer or voice. Returns 1 if attached. -/
@[extern "allegro_al_get_mixer_attached"]
opaque getMixerAttached : Mixer → IO UInt32

/-- Check if a mixer has any attached sources. Returns 1 if yes. -/
@[extern "allegro_al_mixer_has_attachments"]
opaque mixerHasAttachments : Mixer → IO UInt32

-- ── Voice extra getters/setters ──

/-- Get the voice's current playback position in samples. -/
@[extern "allegro_al_get_voice_position"]
opaque getVoicePosition : Voice → IO UInt32

/-- Set the voice's playback position in samples. Returns non-zero on success. -/
@[extern "allegro_al_set_voice_position"]
opaque setVoicePosition : Voice → UInt32 → IO UInt32

@[extern "allegro_al_get_voice_channels"]
private opaque getVoiceChannelsRaw : Voice → IO UInt32

/-- Get the voice's channel configuration. -/
@[inline] def getVoiceChannels (voice : Voice) : IO ChannelConf := do
  let v ← getVoiceChannelsRaw voice
  return ⟨v⟩

@[extern "allegro_al_get_voice_depth"]
private opaque getVoiceDepthRaw : Voice → IO UInt32

/-- Get the voice's audio depth. -/
@[inline] def getVoiceDepth (voice : Voice) : IO AudioDepth := do
  let v ← getVoiceDepthRaw voice
  return ⟨v⟩

/-- Check if a voice has any attached sources. Returns 1 if yes. -/
@[extern "allegro_al_voice_has_attachments"]
opaque voiceHasAttachments : Voice → IO UInt32

-- ── Default voice setter ──

/-- Set (or clear) the default voice. Pass null handle to clear. -/
@[extern "allegro_al_set_default_voice"]
opaque setDefaultVoice : Voice → IO Unit

-- ── Sample save / identify ──

/-- Save a sample to a file by filename. Returns non-zero on success. -/
@[extern "allegro_al_save_sample"]
opaque saveSample : @&String → Sample → IO UInt32

/-- Identify the type of a sample file by filename (returns extension like ".wav"). -/
@[extern "allegro_al_identify_sample"]
opaque identifySample : @&String → IO String

-- ── Attach to voice ──

/-- Attach a sample instance directly to a voice. Returns non-zero on success. -/
@[extern "allegro_al_attach_sample_instance_to_voice"]
opaque attachSampleInstanceToVoice : SampleInstance → Voice → IO UInt32

/-- Attach an audio stream directly to a voice. Returns non-zero on success. -/
@[extern "allegro_al_attach_audio_stream_to_voice"]
opaque attachAudioStreamToVoice : AudioStream → Voice → IO UInt32

-- ── Device enumeration ──

/-- Get the number of audio output devices available. -/
@[extern "allegro_al_get_num_audio_output_devices"]
opaque getNumAudioOutputDevices : IO UInt32

/-- Get the name of audio output device at `index`. -/
@[extern "allegro_al_get_audio_device_name"]
opaque getAudioDeviceName : UInt32 → IO String

-- ── Sample data access ──

/-- Get the sample data currently set on a sample instance. Returns null (0) if none. -/
@[extern "allegro_al_get_sample"]
opaque getSample : SampleInstance → IO Sample

/-- Set the sample data on a sample instance. The instance must be stopped first.
    Returns 1 on success. -/
@[extern "allegro_al_set_sample"]
opaque setSample : SampleInstance → Sample → IO UInt32

-- ── Audio recorder (UNSTABLE) ──

@[extern "allegro_al_create_audio_recorder"]
private opaque createAudioRecorderRaw : UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO AudioRecorder

/-- Create an audio recorder.
    - `fragmentCount`: number of fragments to buffer
    - `samples`: samples per fragment
    - `freq`: recording frequency (e.g. 44100)
    - `depth`: audio depth constant (e.g. `audioDepthInt16`)
    - `chanConf`: channel configuration (e.g. `channelConf1`)
    Returns a recorder handle or null (0) on failure. -/
@[inline] def createAudioRecorder (fragmentCount samples freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO AudioRecorder :=
  createAudioRecorderRaw fragmentCount samples freq depth.val chanConf.val

/-- Start recording audio. Returns 1 on success. -/
@[extern "allegro_al_start_audio_recorder"]
opaque startAudioRecorder : AudioRecorder → IO UInt32

/-- Stop recording audio. -/
@[extern "allegro_al_stop_audio_recorder"]
opaque stopAudioRecorder : AudioRecorder → IO Unit

/-- Check if a recorder is currently recording. Returns 1 if yes. -/
@[extern "allegro_al_is_audio_recorder_recording"]
opaque isAudioRecorderRecording : AudioRecorder → IO UInt32

/-- Get the event source for recorder events (fragment ready, etc.). -/
@[extern "allegro_al_get_audio_recorder_event_source"]
opaque getAudioRecorderEventSource : AudioRecorder → IO UInt64

/-- Destroy an audio recorder and free its resources. -/
@[extern "allegro_al_destroy_audio_recorder"]
opaque destroyAudioRecorder : AudioRecorder → IO Unit

-- ── Sample ID ──

/-- An `ALLEGRO_SAMPLE_ID` packed into a `UInt64`.
    Returned by `playSampleWithId`; pass to `stopSample` / `lockSampleId`. -/
def SampleId := UInt64

instance : BEq SampleId := inferInstanceAs (BEq UInt64)
instance : Inhabited SampleId := inferInstanceAs (Inhabited UInt64)
instance : OfNat SampleId 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString SampleId := ⟨fun (h : UInt64) => s!"SampleId#{h}"⟩
instance : Repr SampleId := ⟨fun (h : UInt64) _ => .text s!"SampleId#{repr h}"⟩

@[extern "allegro_al_play_sample_with_id"]
private opaque playSampleWithIdRaw : Sample → Float → Float → Float → UInt32 → IO SampleId

/-- Play a sample and return its `SampleId` (0 on failure).
    Unlike `playSample`, this accepts a playmode constant directly
    and returns the ID needed for `stopSample`. -/
@[inline] def playSampleWithId (spl : Sample) (gain pan speed : Float) (mode : Playmode) : IO SampleId :=
  playSampleWithIdRaw spl gain pan speed mode.val

/-- Stop a specific playing sample identified by its `SampleId`. -/
@[extern "allegro_al_stop_sample"]
opaque stopSample : SampleId → IO Unit

/-- Lock a playing sample by ID, returning the underlying sample instance
    (UNSTABLE). Must call `unlockSampleId` when done. -/
@[extern "allegro_al_lock_sample_id"]
opaque lockSampleId : SampleId → IO SampleInstance

/-- Unlock a sample ID previously locked with `lockSampleId` (UNSTABLE). -/
@[extern "allegro_al_unlock_sample_id"]
opaque unlockSampleId : SampleId → IO Unit

-- ── Create audio stream from parameters ──

@[extern "allegro_al_create_audio_stream"]
private opaque createAudioStreamRawRaw : UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO AudioStream

/-- Create an audio stream (not from file).
    `bufferCount` fragments, `samples` per fragment, at `freq` Hz,
    with given `depth` and `chanConf`. Returns 0 on failure. -/
@[inline] def createAudioStreamRaw (bufferCount samples freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO AudioStream :=
  createAudioStreamRawRaw bufferCount samples freq depth.val chanConf.val

-- ── Create sample from raw buffer ──

@[extern "allegro_al_create_sample"]
private opaque createSampleRawRaw : UInt64 → UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO Sample

/-- Create a sample from a raw memory buffer.
    - `buf`: pointer to audio data (as UInt64)
    - `samples`: number of samples
    - `freq`: sample rate
    - `depth`: audio depth constant
    - `chanConf`: channel configuration
    - `freeBuf`: 1 to let Allegro free the buffer on destroy, 0 otherwise
    Returns 0 on failure. -/
@[inline] def createSampleRaw (buf : UInt64) (samples freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) (freeBuf : UInt32) : IO Sample :=
  createSampleRawRaw buf samples freq depth.val chanConf.val freeBuf

-- ── Raw sample data access ──

/-- Get a pointer to the raw sample data buffer (as UInt64). Returns 0 if null. -/
@[extern "allegro_al_get_sample_data"]
opaque getSampleData : Sample → IO UInt64

-- ── Fill silence ──

@[extern "allegro_al_fill_silence"]
private opaque fillSilenceRaw : UInt64 → UInt32 → UInt32 → UInt32 → IO Unit

/-- Fill a buffer with silence.
    - `buf`: pointer to audio buffer (as UInt64)
    - `samples`: number of samples to fill
    - `depth`: audio depth constant
    - `chanConf`: channel configuration -/
@[inline] def fillSilence (buf : UInt64) (samples : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO Unit :=
  fillSilenceRaw buf samples depth.val chanConf.val

-- ── Audio stream fragment access ──

/-- Get the address of the next available audio stream fragment buffer.
    Returns 0 (null) if no fragment is ready. -/
@[extern "allegro_al_get_audio_stream_fragment"]
opaque getAudioStreamFragment : AudioStream → IO UInt64

/-- Submit a filled audio stream fragment back to the stream.
    Returns 1 on success, 0 on failure. -/
@[extern "allegro_al_set_audio_stream_fragment"]
opaque setAudioStreamFragment : AudioStream → UInt64 → IO UInt32

-- ── Channel matrix (UNSTABLE) ──

/-- Set the channel mixing matrix for a sample instance.
    `matrix` is a ByteArray of packed 32-bit floats (rows × cols). -/
@[extern "allegro_al_set_sample_instance_channel_matrix"]
opaque setSampleInstanceChannelMatrix : SampleInstance → @&ByteArray → IO UInt32

/-- Set the channel mixing matrix for an audio stream.
    `matrix` is a ByteArray of packed 32-bit floats (rows × cols). -/
@[extern "allegro_al_set_audio_stream_channel_matrix"]
opaque setAudioStreamChannelMatrix : AudioStream → @&ByteArray → IO UInt32

-- ── Option-returning variants ──

/-- Load an audio sample, returning `none` on failure (file not found, codec error). -/
def loadSample? (filename : String) : IO (Option Sample) := liftOption (loadSample filename)

/-- Create a sample instance, returning `none` on failure (null sample, OOM). -/
def createSampleInstance? (spl : Sample) : IO (Option SampleInstance) :=
  liftOption (createSampleInstance spl)

/-- Load an audio stream, returning `none` on failure. -/
def loadAudioStream? (filename : String) (bufferCount bufferSamples : UInt32) : IO (Option AudioStream) :=
  liftOption (loadAudioStream filename bufferCount bufferSamples)

/-- Play an audio stream directly (convenience), returning `none` on failure. -/
def playAudioStream? (filename : String) : IO (Option AudioStream) :=
  liftOption (playAudioStream filename)

/-- Create a mixer, returning `none` on failure (bad parameters, OOM). -/
def createMixer? (freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO (Option Mixer) :=
  liftOption (createMixer freq depth chanConf)

/-- Get the default mixer, returning `none` if `reserveSamples` was not called. -/
def getDefaultMixer? : IO (Option Mixer) := liftOption getDefaultMixer

/-- Create a voice, returning `none` on failure (no audio device, bad parameters). -/
def createVoice? (freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO (Option Voice) :=
  liftOption (createVoice freq depth chanConf)

/-- Get the default voice, returning `none` if no default voice is set. -/
def getDefaultVoice? : IO (Option Voice) := liftOption getDefaultVoice

/-- Create an audio recorder, returning `none` on failure. -/
def createAudioRecorder? (fragmentCount samples freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO (Option AudioRecorder) :=
  liftOption (createAudioRecorder fragmentCount samples freq depth chanConf)

/-- Create an audio stream (from params), returning `none` on failure. -/
def createAudioStreamRaw? (bufferCount samples freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) : IO (Option AudioStream) :=
  liftOption (createAudioStreamRaw bufferCount samples freq depth chanConf)

/-- Create a sample from raw buffer, returning `none` on failure. -/
def createSampleRaw? (buf : UInt64) (samples freq : UInt32) (depth : AudioDepth) (chanConf : ChannelConf) (freeBuf : UInt32) : IO (Option Sample) :=
  liftOption (createSampleRaw buf samples freq depth chanConf freeBuf)

/-- Play a sample and get its ID, returning `none` on failure. -/
def playSampleWithId? (spl : Sample) (gain pan speed : Float) (playmode : Playmode) : IO (Option SampleId) :=
  liftOption (playSampleWithId spl gain pan speed playmode)

-- ── File-based audio I/O ──

/-- Load a sample from an open `AllegroFile`. `ident` is the format extension (e.g. `".wav"`). -/
@[extern "allegro_al_load_sample_f"]
opaque loadSampleF : UInt64 → String → IO Sample

/-- Save a sample to an open `AllegroFile`. `ident` is the format extension. Returns 1 on success. -/
@[extern "allegro_al_save_sample_f"]
opaque saveSampleF : UInt64 → String → Sample → IO UInt32

/-- Identify the audio format of an open file. Returns a format string or `""`. -/
@[extern "allegro_al_identify_sample_f"]
opaque identifySampleF : UInt64 → IO String

/-- Load an audio stream from an open `AllegroFile`.
    `ident` is the format extension, `bufferCount` and `samples` control buffering. -/
@[extern "allegro_al_load_audio_stream_f"]
opaque loadAudioStreamF : UInt64 → String → UInt32 → UInt32 → IO AudioStream

/-- Play an audio stream directly from an open `AllegroFile` (UNSTABLE).
    `ident` is the format extension. -/
@[extern "allegro_al_play_audio_stream_f"]
opaque playAudioStreamF : UInt64 → String → IO AudioStream

def loadSampleF? (fp : UInt64) (ident : String) : IO (Option Sample) :=
  liftOption (loadSampleF fp ident)

def loadAudioStreamF? (fp : UInt64) (ident : String) (bufCount samples : UInt32) : IO (Option AudioStream) :=
  liftOption (loadAudioStreamF fp ident bufCount samples)

def playAudioStreamF? (fp : UInt64) (ident : String) : IO (Option AudioStream) :=
  liftOption (playAudioStreamF fp ident)

end Allegro
