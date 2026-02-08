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
let _ ← Allegro.playSample spl 1.0 0.0 1.0 0  -- gain pan speed loop?
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
let _ ← Allegro.setAudioStreamPlaymode stream Allegro.playmodeLoop
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

/-- Fire-and-forget playback. `playSample spl gain pan speed loopFlag`
    where loopFlag = 0 for once, non-zero for loop. -/
@[extern "allegro_al_play_sample"]
opaque playSample : Sample → Float → Float → Float → UInt32 → IO UInt32

/-- Stop all samples started by `playSample`. -/
@[extern "allegro_al_stop_samples"]
opaque stopSamples : IO Unit

/-- Get the sample's frequency (samples per second). -/
@[extern "allegro_al_get_sample_frequency"]
opaque getSampleFrequency : Sample → IO UInt32

/-- Get the number of sample frames in the sample. -/
@[extern "allegro_al_get_sample_length"]
opaque getSampleLength : Sample → IO UInt32

/-- Get the audio depth of the sample. -/
@[extern "allegro_al_get_sample_depth"]
opaque getSampleDepth : Sample → IO UInt32

/-- Get the channel configuration of the sample. -/
@[extern "allegro_al_get_sample_channels"]
opaque getSampleChannels : Sample → IO UInt32

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

/-- Get the playmode of a sample instance. -/
@[extern "allegro_al_get_sample_instance_playmode"]
opaque getSampleInstancePlaymode : SampleInstance → IO UInt32

/-- Set the playmode of a sample instance (once, loop, etc.). Returns non-zero on success. -/
@[extern "allegro_al_set_sample_instance_playmode"]
opaque setSampleInstancePlaymode : SampleInstance → UInt32 → IO UInt32

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

/-- Get the playmode of the audio stream. -/
@[extern "allegro_al_get_audio_stream_playmode"]
opaque getAudioStreamPlaymode : AudioStream → IO UInt32

/-- Set the playmode of the audio stream (once, loop, etc.). Returns non-zero on success. -/
@[extern "allegro_al_set_audio_stream_playmode"]
opaque setAudioStreamPlaymode : AudioStream → UInt32 → IO UInt32

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

/-- Create a mixer. `createMixer frequency depth channelConf` -/
@[extern "allegro_al_create_mixer"]
opaque createMixer : UInt32 → UInt32 → UInt32 → IO Mixer

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

/-- Get the mixer's interpolation quality. -/
@[extern "allegro_al_get_mixer_quality"]
opaque getMixerQuality : Mixer → IO UInt32

/-- Set the mixer's interpolation quality. Returns non-zero on success. -/
@[extern "allegro_al_set_mixer_quality"]
opaque setMixerQuality : Mixer → UInt32 → IO UInt32

/-- Check if the mixer is playing. Returns 1 if playing. -/
@[extern "allegro_al_get_mixer_playing"]
opaque getMixerPlaying : Mixer → IO UInt32

/-- Set the mixer playing state. Returns non-zero on success. -/
@[extern "allegro_al_set_mixer_playing"]
opaque setMixerPlaying : Mixer → UInt32 → IO UInt32

-- ── Voice ──

/-- Create a voice. `createVoice frequency depth channelConf` -/
@[extern "allegro_al_create_voice"]
opaque createVoice : UInt32 → UInt32 → UInt32 → IO Voice

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

/-- Get the number of channels for a channel configuration constant. -/
@[extern "allegro_al_get_channel_count"]
opaque getChannelCount : UInt32 → IO UInt32

/-- Get the byte size of one sample for the given audio depth. -/
@[extern "allegro_al_get_audio_depth_size"]
opaque getAudioDepthSize : UInt32 → IO UInt32

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

/-- Get the channel configuration of a sample instance. -/
@[extern "allegro_al_get_sample_instance_channels"]
opaque getSampleInstanceChannels : SampleInstance → IO UInt32

/-- Get the audio depth of a sample instance. -/
@[extern "allegro_al_get_sample_instance_depth"]
opaque getSampleInstanceDepth : SampleInstance → IO UInt32

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

/-- Get the channel configuration of an audio stream. -/
@[extern "allegro_al_get_audio_stream_channels"]
opaque getAudioStreamChannels : AudioStream → IO UInt32

/-- Get the audio depth of an audio stream. -/
@[extern "allegro_al_get_audio_stream_depth"]
opaque getAudioStreamDepth : AudioStream → IO UInt32

/-- Check if an audio stream is attached to a mixer or voice. Returns 1 if attached. -/
@[extern "allegro_al_get_audio_stream_attached"]
opaque getAudioStreamAttached : AudioStream → IO UInt32

/-- Get the total number of samples played from the stream since it was started. -/
@[extern "allegro_al_get_audio_stream_played_samples"]
opaque getAudioStreamPlayedSamples : AudioStream → IO UInt64

-- ── Mixer extra getters ──

/-- Get the mixer's channel configuration. -/
@[extern "allegro_al_get_mixer_channels"]
opaque getMixerChannels : Mixer → IO UInt32

/-- Get the mixer's audio depth. -/
@[extern "allegro_al_get_mixer_depth"]
opaque getMixerDepth : Mixer → IO UInt32

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

/-- Get the voice's channel configuration. -/
@[extern "allegro_al_get_voice_channels"]
opaque getVoiceChannels : Voice → IO UInt32

/-- Get the voice's audio depth. -/
@[extern "allegro_al_get_voice_depth"]
opaque getVoiceDepth : Voice → IO UInt32

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

-- ── Playmode constants ──

/-- Play the sample/stream once, then stop. -/
def playmodeOnce : UInt32 := 256
/-- Loop the sample/stream continuously. -/
def playmodeLoop : UInt32 := 257
/-- Loop the sample/stream in bidirectional (ping-pong) mode. -/
def playmodeBidir : UInt32 := 258
/-- Play the sample loop section once (loop start → loop end), then stop. -/
def playmodeLoopOnce : UInt32 := 261

-- ── Audio depth constants ──

/-- Signed 8-bit integer audio depth. -/
def audioDepthInt8 : UInt32 := 0
/-- Signed 16-bit integer audio depth. -/
def audioDepthInt16 : UInt32 := 1
/-- Signed 24-bit integer audio depth. -/
def audioDepthInt24 : UInt32 := 2
/-- 32-bit floating-point audio depth. -/
def audioDepthFloat32 : UInt32 := 3
/-- Unsigned 8-bit integer audio depth. -/
def audioDepthUint8 : UInt32 := 8
/-- Unsigned 16-bit integer audio depth. -/
def audioDepthUint16 : UInt32 := 9
/-- Unsigned 24-bit integer audio depth. -/
def audioDepthUint24 : UInt32 := 10

-- ── Channel configuration constants ──

/-- Mono (1 channel). -/
def channelConf1 : UInt32 := 16
/-- Stereo (2 channels). -/
def channelConf2 : UInt32 := 32
/-- 3 channels. -/
def channelConf3 : UInt32 := 48
/-- 4 channels (quadraphonic). -/
def channelConf4 : UInt32 := 64
/-- 5.1 surround (6 channels). -/
def channelConf51 : UInt32 := 81
/-- 6.1 surround (7 channels). -/
def channelConf61 : UInt32 := 97
/-- 7.1 surround (8 channels). -/
def channelConf71 : UInt32 := 113

-- ── Mixer quality constants ──

/-- Point (nearest-neighbour) sample interpolation — fastest, lowest quality. -/
def mixerQualityPoint : UInt32 := 272
/-- Linear sample interpolation — good balance of speed and quality. -/
def mixerQualityLinear : UInt32 := 273
/-- Cubic sample interpolation — highest quality, most CPU intensive. -/
def mixerQualityCubic : UInt32 := 274

-- ── Sample data access ──

/-- Get the sample data currently set on a sample instance. Returns null (0) if none. -/
@[extern "allegro_al_get_sample"]
opaque getSample : SampleInstance → IO Sample

/-- Set the sample data on a sample instance. The instance must be stopped first.
    Returns 1 on success. -/
@[extern "allegro_al_set_sample"]
opaque setSample : SampleInstance → Sample → IO UInt32

-- ── Audio recorder (UNSTABLE) ──

/-- Create an audio recorder.
    - `fragmentCount`: number of fragments to buffer
    - `samples`: samples per fragment
    - `freq`: recording frequency (e.g. 44100)
    - `depth`: audio depth constant (e.g. `audioDepthInt16`)
    - `chanConf`: channel configuration (e.g. `channelConf1`)
    Returns a recorder handle or null (0) on failure. -/
@[extern "allegro_al_create_audio_recorder"]
opaque createAudioRecorder : UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO AudioRecorder

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

/-- Play a sample and return its `SampleId` (0 on failure).
    Unlike `playSample`, this accepts a playmode constant directly
    and returns the ID needed for `stopSample`. -/
@[extern "allegro_al_play_sample_with_id"]
opaque playSampleWithId : Sample → Float → Float → Float → UInt32 → IO SampleId

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

/-- Create an audio stream (not from file).
    `bufferCount` fragments, `samples` per fragment, at `freq` Hz,
    with given `depth` and `chanConf`. Returns 0 on failure. -/
@[extern "allegro_al_create_audio_stream"]
opaque createAudioStreamRaw : UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO AudioStream

-- ── Create sample from raw buffer ──

/-- Create a sample from a raw memory buffer.
    - `buf`: pointer to audio data (as UInt64)
    - `samples`: number of samples
    - `freq`: sample rate
    - `depth`: audio depth constant
    - `chanConf`: channel configuration
    - `freeBuf`: 1 to let Allegro free the buffer on destroy, 0 otherwise
    Returns 0 on failure. -/
@[extern "allegro_al_create_sample"]
opaque createSampleRaw : UInt64 → UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → IO Sample

-- ── Raw sample data access ──

/-- Get a pointer to the raw sample data buffer (as UInt64). Returns 0 if null. -/
@[extern "allegro_al_get_sample_data"]
opaque getSampleData : Sample → IO UInt64

-- ── Fill silence ──

/-- Fill a buffer with silence.
    - `buf`: pointer to audio buffer (as UInt64)
    - `samples`: number of samples to fill
    - `depth`: audio depth constant
    - `chanConf`: channel configuration -/
@[extern "allegro_al_fill_silence"]
opaque fillSilence : UInt64 → UInt32 → UInt32 → UInt32 → IO Unit

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
def createMixer? (freq depth chanConf : UInt32) : IO (Option Mixer) :=
  liftOption (createMixer freq depth chanConf)

/-- Get the default mixer, returning `none` if `reserveSamples` was not called. -/
def getDefaultMixer? : IO (Option Mixer) := liftOption getDefaultMixer

/-- Create a voice, returning `none` on failure (no audio device, bad parameters). -/
def createVoice? (freq depth chanConf : UInt32) : IO (Option Voice) :=
  liftOption (createVoice freq depth chanConf)

/-- Get the default voice, returning `none` if no default voice is set. -/
def getDefaultVoice? : IO (Option Voice) := liftOption getDefaultVoice

/-- Create an audio recorder, returning `none` on failure. -/
def createAudioRecorder? (fragmentCount samples freq depth chanConf : UInt32) : IO (Option AudioRecorder) :=
  liftOption (createAudioRecorder fragmentCount samples freq depth chanConf)

/-- Create an audio stream (from params), returning `none` on failure. -/
def createAudioStreamRaw? (bufferCount samples freq depth chanConf : UInt32) : IO (Option AudioStream) :=
  liftOption (createAudioStreamRaw bufferCount samples freq depth chanConf)

/-- Create a sample from raw buffer, returning `none` on failure. -/
def createSampleRaw? (buf : UInt64) (samples freq depth chanConf freeBuf : UInt32) : IO (Option Sample) :=
  liftOption (createSampleRaw buf samples freq depth chanConf freeBuf)

/-- Play a sample and get its ID, returning `none` on failure. -/
def playSampleWithId? (spl : Sample) (gain pan speed : Float) (playmode : UInt32) : IO (Option SampleId) :=
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
