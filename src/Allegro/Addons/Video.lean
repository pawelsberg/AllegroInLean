import Allegro.Core.Events
import Allegro.Core.Bitmap

/-!
# Video addon bindings

Video playback and streaming via Allegro 5. Supports common formats (e.g. Ogg
Theora) depending on the backends compiled into the Allegro video addon.

Requires the Allegro video addon library (`liballegro_video`), which in turn
depends on the audio addon (`liballegro_audio`) already linked.

## Quick start
```
let _ ← Allegro.initVideoAddon
let video ← Allegro.openVideo "intro.ogv"
Allegro.startVideo video mixer
-- in event loop: check for videoEventFrameShow, draw Allegro.getVideoFrame
Allegro.closeVideo video
Allegro.shutdownVideoAddon
```
-/
namespace Allegro

/-- Opaque handle to a video stream. -/
def Video := UInt64

instance : BEq Video := inferInstanceAs (BEq UInt64)
instance : Inhabited Video := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Video := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Video 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Video := ⟨fun (h : UInt64) => s!"Video#{h}"⟩
instance : Repr Video := ⟨fun (h : UInt64) _ => .text s!"Video#{repr h}"⟩

/-- The null video handle. -/
def Video.null : Video := (0 : UInt64)

-- ── Position type constants ──

/-- Allegro video position type. -/
structure VideoPosition where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace VideoPosition
/-- Actual playback position. -/
def actual : VideoPosition := ⟨0⟩
/-- Video decode position (may differ from actual). -/
def videoDecode : VideoPosition := ⟨1⟩
/-- Audio decode position (may differ from actual). -/
def audioDecode : VideoPosition := ⟨2⟩
end VideoPosition

-- ── Event type constants ──

/-- Event: a new video frame is ready to show. -/
def EventType.videoFrameShow : EventType := ⟨550⟩
/-- Event: the video has finished playing. -/
def EventType.videoFinished : EventType := ⟨551⟩

-- ── Addon lifecycle ──

/-- Initialise the video addon. Returns 1 on success. -/
@[extern "allegro_al_init_video_addon"]
opaque initVideoAddon : IO UInt32

/-- Returns 1 if the video addon is initialised. -/
@[extern "allegro_al_is_video_addon_initialized"]
opaque isVideoAddonInitialized : IO UInt32

/-- Shut down the video addon. -/
@[extern "allegro_al_shutdown_video_addon"]
opaque shutdownVideoAddon : IO Unit

/-- Return the version of the video addon (packed integer). -/
@[extern "allegro_al_get_allegro_video_version"]
opaque getVideoVersion : IO UInt32

-- ── Open / close ──

/-- Open a video file for playback. Returns a handle (0 on failure). -/
@[extern "allegro_al_open_video"]
opaque openVideo : String → IO Video

/-- Close a video and free its resources. -/
@[extern "allegro_al_close_video"]
opaque closeVideo : Video → IO Unit

-- ── Playback control ──

/-- Start video playback, routing audio to the given mixer. -/
@[extern "allegro_al_start_video"]
opaque startVideo : Video → UInt64 → IO Unit

/-- Start video playback, routing audio to the given voice. -/
@[extern "allegro_al_start_video_with_voice"]
opaque startVideoWithVoice : Video → UInt64 → IO Unit

/-- Set whether the video is playing (1) or paused (0). -/
@[extern "allegro_al_set_video_playing"]
opaque setVideoPlaying : Video → UInt32 → IO Unit

/-- Returns 1 if the video is currently playing. -/
@[extern "allegro_al_is_video_playing"]
opaque isVideoPlaying : Video → IO UInt32

/-- Seek to a position in seconds. Returns 1 on success. -/
@[extern "allegro_al_seek_video"]
opaque seekVideo : Video → Float → IO UInt32

-- ── Queries ──

/-- Get the event source for video events. -/
@[extern "allegro_al_get_video_event_source"]
opaque getVideoEventSource : Video → IO EventSource

/-- Get the audio sample rate of the video. -/
@[extern "allegro_al_get_video_audio_rate"]
opaque getVideoAudioRate : Video → IO Float

/-- Get the frames-per-second of the video. -/
@[extern "allegro_al_get_video_fps"]
opaque getVideoFps : Video → IO Float

/-- Get the scaled width of the video frame. -/
@[extern "allegro_al_get_video_scaled_width"]
opaque getVideoScaledWidth : Video → IO Float

/-- Get the scaled height of the video frame. -/
@[extern "allegro_al_get_video_scaled_height"]
opaque getVideoScaledHeight : Video → IO Float

/-- Get the current video frame as a bitmap (may be 0 if no frame ready). -/
@[extern "allegro_al_get_video_frame"]
opaque getVideoFrame : Video → IO Bitmap

/-- Get the playback position in seconds.
    Use `videoPositionActual`, `videoPositionVideoDecode`, or `videoPositionAudioDecode`. -/
@[extern "allegro_al_get_video_position"]
private opaque getVideoPositionRaw : Video → UInt32 → IO Float

@[inline] def getVideoPosition (v : Video) (which : VideoPosition) : IO Float :=
  getVideoPositionRaw v which.val

-- ── Identification ──

/-- Identify a video file by its contents, returning a format string (e.g. ".ogv"). -/
@[extern "allegro_al_identify_video"]
opaque identifyVideo : String → IO String

-- ── Option-returning variants ──

/-- Open a video file, returning `none` on failure. -/
def openVideo? (filename : String) : IO (Option Video) :=
  liftOption (openVideo filename)

-- ── File-based video I/O ──

/-- Open a video from an open `AllegroFile`. `ident` is the format hint (e.g. `".ogv"`). -/
@[extern "allegro_al_open_video_f"]
opaque openVideoF : UInt64 → String → IO Video

/-- Identify a video file type from an open `AllegroFile`. Returns a format string or `""`. -/
@[extern "allegro_al_identify_video_f"]
opaque identifyVideoF : UInt64 → IO String

def openVideoF? (fp : UInt64) (ident : String) : IO (Option Video) :=
  liftOption (openVideoF fp ident)

end Allegro
