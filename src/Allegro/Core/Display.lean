import Allegro.Core.System

/-!
Display management for Allegro 5.

Create and manage windows, display properties, options, flags, and render state.

## Display flags
Combine flags with bitwise OR before passing to `setNewDisplayFlags`:
```
Allegro.setNewDisplayFlags (Allegro.DisplayFlags.fullscreenWindow ||| Allegro.DisplayFlags.resizable)
```

## Display options
Set hints before display creation:
```
Allegro.setNewDisplayOption Allegro.DisplayOption.vsync 1 Allegro.DisplayOptionImportance.suggest
```

## Clipping
Restrict drawing to a sub-region of the target bitmap:
```
Allegro.setClippingRectangle 10 10 200 150
-- draw stuff clipped to that rect --
Allegro.resetClippingRectangle
```
-/
namespace Allegro

/-- Opaque handle to an Allegro display (window). -/
def Display := UInt64

instance : BEq Display := inferInstanceAs (BEq UInt64)
instance : Inhabited Display := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Display := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Display 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Display := ⟨fun (h : UInt64) => s!"Display#{h}"⟩
instance : Repr Display := ⟨fun (h : UInt64) _ => .text s!"Display#{repr h}"⟩

/-- The null display handle. -/
def Display.null : Display := (0 : UInt64)

-- ── Display flag constants ──

/-- Allegro display creation flags (bitfield). -/
structure DisplayFlags where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

instance : OrOp DisplayFlags where or a b := ⟨a.val ||| b.val⟩
instance : AndOp DisplayFlags where and a b := ⟨a.val &&& b.val⟩

namespace DisplayFlags
/-- Windowed mode (default). -/
def windowed : DisplayFlags := ⟨1⟩
/-- Exclusive fullscreen mode. -/
def fullscreen : DisplayFlags := ⟨2⟩
/-- Require an OpenGL context. -/
def opengl : DisplayFlags := ⟨4⟩
/-- Allow the user to resize the window. -/
def resizable : DisplayFlags := ⟨16⟩
/-- Remove the window frame/decorations. -/
def noframe : DisplayFlags := ⟨32⟩
/-- Generate expose events for the display. -/
def generateExposeEvents : DisplayFlags := ⟨64⟩
/-- Require an OpenGL 3.0+ context. -/
def opengl30 : DisplayFlags := ⟨128⟩
/-- Require a forward-compatible OpenGL context. -/
def openglForwardCompatible : DisplayFlags := ⟨256⟩
/-- Fullscreen window (borderless, desktop resolution). -/
def fullscreenWindow : DisplayFlags := ⟨512⟩
/-- Require the programmable pipeline (shaders). -/
def programmablePipeline : DisplayFlags := ⟨2048⟩
/-- Create the window maximised. -/
def maximized : DisplayFlags := ⟨8192⟩
end DisplayFlags

-- ── Display option constants ──

/-- Allegro display option identifier. -/
structure DisplayOption where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace DisplayOption
/-- Option: red channel bits. -/
def redSize : DisplayOption := ⟨0⟩
/-- Option: green channel bits. -/
def greenSize : DisplayOption := ⟨1⟩
/-- Option: blue channel bits. -/
def blueSize : DisplayOption := ⟨2⟩
/-- Option: alpha channel bits. -/
def alphaSize : DisplayOption := ⟨3⟩
/-- Option: total colour depth in bits. -/
def colorSize : DisplayOption := ⟨14⟩
/-- Option: depth buffer bits. -/
def depthSize : DisplayOption := ⟨15⟩
/-- Option: stencil buffer bits. -/
def stencilSize : DisplayOption := ⟨16⟩
/-- Option: number of multisample buffers. -/
def sampleBuffers : DisplayOption := ⟨17⟩
/-- Option: number of multisample samples. -/
def samples : DisplayOption := ⟨18⟩
/-- Option: use floating-point colour buffer. -/
def floatColor : DisplayOption := ⟨20⟩
/-- Option: use floating-point depth buffer. -/
def floatDepth : DisplayOption := ⟨21⟩
/-- Option: use single buffering. -/
def singleBuffer : DisplayOption := ⟨22⟩
/-- Option: swap method (0 = undefined, 1 = copy, 2 = flip). -/
def swapMethod : DisplayOption := ⟨23⟩
/-- Option: require a compatible display. -/
def compatibleDisplay : DisplayOption := ⟨24⟩
/-- Option: support partial display updates. -/
def updateDisplayRegion : DisplayOption := ⟨25⟩
/-- Option: vertical sync (0 = off, 1 = on, 2 = adaptive). -/
def vsync : DisplayOption := ⟨26⟩
/-- Option: maximum bitmap texture size. -/
def maxBitmapSize : DisplayOption := ⟨27⟩
/-- Option: support non-power-of-two bitmaps. -/
def supportNpotBitmap : DisplayOption := ⟨28⟩
/-- Option: support separate alpha blending. -/
def supportSeparateAlpha : DisplayOption := ⟨30⟩
/-- Option: auto-convert bitmaps to the display format. -/
def autoConvertBitmaps : DisplayOption := ⟨31⟩
/-- Option: required OpenGL major version. -/
def openglMajorVersion : DisplayOption := ⟨33⟩
/-- Option: required OpenGL minor version. -/
def openglMinorVersion : DisplayOption := ⟨34⟩
end DisplayOption

-- ── Display option importance ──

/-- Allegro display option importance. -/
structure DisplayOptionImportance where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace DisplayOptionImportance
/-- Option importance: no preference. -/
def dontcare : DisplayOptionImportance := ⟨0⟩
/-- Option importance: the option is required; fail if unavailable. -/
def require : DisplayOptionImportance := ⟨1⟩
/-- Option importance: prefer this value but fall back gracefully. -/
def suggest : DisplayOptionImportance := ⟨2⟩
end DisplayOptionImportance

-- ── Display creation setup ──

@[extern "allegro_al_set_new_display_flags"]
private opaque setNewDisplayFlagsRaw : UInt32 → IO Unit

/-- Set flags for the next display to be created. -/
@[inline] def setNewDisplayFlags (flags : DisplayFlags) : IO Unit :=
  setNewDisplayFlagsRaw flags.val

@[extern "allegro_al_get_new_display_flags"]
private opaque getNewDisplayFlagsRaw : IO UInt32

/-- Get the flags that will be used for the next display creation. -/
@[inline] def getNewDisplayFlags : IO DisplayFlags := do
  let v ← getNewDisplayFlagsRaw
  return ⟨v⟩

@[extern "allegro_al_set_new_display_option"]
private opaque setNewDisplayOptionRaw : UInt32 → UInt32 → UInt32 → IO Unit

/-- Set a display option hint. `setNewDisplayOption option value importance` -/
@[inline] def setNewDisplayOption (option : DisplayOption) (value : UInt32) (importance : DisplayOptionImportance) : IO Unit :=
  setNewDisplayOptionRaw option.val value importance.val

@[extern "allegro_al_get_new_display_option"]
private opaque getNewDisplayOptionRaw : UInt32 → IO UInt32

/-- Get the current value of a display creation option. -/
@[inline] def getNewDisplayOption (option : DisplayOption) : IO UInt32 :=
  getNewDisplayOptionRaw option.val

/-- Reset all display options to defaults. -/
@[extern "allegro_al_reset_new_display_options"]
opaque resetNewDisplayOptions : IO Unit

/-- Set the refresh rate hint for the next display creation. -/
@[extern "allegro_al_set_new_display_refresh_rate"]
opaque setNewDisplayRefreshRate : UInt32 → IO Unit

/-- Get the refresh rate hint for the next display creation. -/
@[extern "allegro_al_get_new_display_refresh_rate"]
opaque getNewDisplayRefreshRate : IO UInt32

/-- Set the window title for the next display creation. -/
@[extern "allegro_al_set_new_window_title"]
opaque setNewWindowTitle : String → IO Unit

/-- Get the window title that will be used for the next display creation. -/
@[extern "allegro_al_get_new_window_title"]
opaque getNewWindowTitle : IO String

/-- Set the video adapter (monitor index) for the next display creation. -/
@[extern "allegro_al_set_new_display_adapter"]
opaque setNewDisplayAdapter : UInt32 → IO Unit

/-- Get the video adapter (monitor index) for the next display creation. -/
@[extern "allegro_al_get_new_display_adapter"]
opaque getNewDisplayAdapter : IO UInt32

/-- Set the window position for the next display creation. -/
@[extern "allegro_al_set_new_window_position"]
opaque setNewWindowPosition : Int32 → Int32 → IO Unit

/-- Get the window position for the next display creation as `(x, y)`. -/
@[extern "allegro_al_get_new_window_position"]
opaque getNewWindowPosition : IO (Int32 × Int32)

-- ── Display lifecycle ──

/-- Create a display (window) with the given width and height. Returns null on failure. -/
@[extern "allegro_al_create_display"]
opaque createDisplay : UInt32 → UInt32 → IO Display

/-- Destroy a display and free its resources. -/
@[extern "allegro_al_destroy_display"]
opaque destroyDisplay : Display → IO Unit

/-- Get the display associated with the current target bitmap. Returns null if none. -/
@[extern "allegro_al_get_current_display"]
opaque getCurrentDisplay : IO Display

-- ── Display properties ──

/-- Get the width of the display in pixels. -/
@[extern "allegro_al_get_display_width"]
opaque getDisplayWidth : Display → IO UInt32

/-- Get the height of the display in pixels. -/
@[extern "allegro_al_get_display_height"]
opaque getDisplayHeight : Display → IO UInt32

/-- Resize the display. Returns non-zero on success. -/
@[extern "allegro_al_resize_display"]
opaque resizeDisplay : Display → UInt32 → UInt32 → IO UInt32

/-- Acknowledge a display resize (call in response to a resize event). Returns non-zero on success. -/
@[extern "allegro_al_acknowledge_resize"]
opaque acknowledgeResize : Display → IO UInt32

/-- Acknowledge that drawing has halted (call in response to DISPLAY_HALT_DRAWING). -/
@[extern "allegro_al_acknowledge_drawing_halt"]
opaque acknowledgeDrawingHalt : Display → IO Unit

/-- Acknowledge that drawing can resume (call in response to DISPLAY_RESUME_DRAWING). -/
@[extern "allegro_al_acknowledge_drawing_resume"]
opaque acknowledgeDrawingResume : Display → IO Unit

@[extern "allegro_al_get_display_flags"]
private opaque getDisplayFlagsRaw : Display → IO UInt32

/-- Get the flags of the display. -/
@[inline] def getDisplayFlags (display : Display) : IO DisplayFlags := do
  let v ← getDisplayFlagsRaw display
  return ⟨v⟩

@[extern "allegro_al_set_display_flag"]
private opaque setDisplayFlagRaw : Display → UInt32 → UInt32 → IO UInt32

/-- Toggle a display flag on/off. Returns 1 on success. -/
@[inline] def setDisplayFlag (display : Display) (flag : DisplayFlags) (onoff : UInt32) : IO UInt32 :=
  setDisplayFlagRaw display flag.val onoff

@[extern "allegro_al_get_display_option"]
private opaque getDisplayOptionRaw : Display → UInt32 → IO UInt32

/-- Query a display option on a live display. -/
@[inline] def getDisplayOption (display : Display) (option : DisplayOption) : IO UInt32 :=
  getDisplayOptionRaw display option.val

/-- Get the pixel format of a display. -/
@[extern "allegro_al_get_display_format"]
opaque getDisplayFormat : Display → IO UInt32

/-- Get the refresh rate of a display. -/
@[extern "allegro_al_get_display_refresh_rate"]
opaque getDisplayRefreshRate : Display → IO UInt32

-- ── Display orientation constants ──

/-- Allegro display orientation flags (bitfield). -/
structure DisplayOrientation where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

instance : OrOp DisplayOrientation where or a b := ⟨a.val ||| b.val⟩
instance : AndOp DisplayOrientation where and a b := ⟨a.val &&& b.val⟩

namespace DisplayOrientation
/-- Display orientation: unknown. -/
def unknown : DisplayOrientation := ⟨0⟩
/-- Display orientation: 0° (normal upright). -/
def degrees0 : DisplayOrientation := ⟨1⟩
/-- Display orientation: 90° clockwise. -/
def degrees90 : DisplayOrientation := ⟨2⟩
/-- Display orientation: 180° (upside down). -/
def degrees180 : DisplayOrientation := ⟨4⟩
/-- Display orientation: 270° clockwise. -/
def degrees270 : DisplayOrientation := ⟨8⟩
/-- Display orientation: portrait (0° or 180°). -/
def portrait : DisplayOrientation := ⟨5⟩
/-- Display orientation: landscape (90° or 270°). -/
def landscape : DisplayOrientation := ⟨10⟩
/-- Display orientation: all orientations. -/
def all : DisplayOrientation := ⟨15⟩
/-- Display orientation: face up (tablet lying flat, screen up). -/
def faceUp : DisplayOrientation := ⟨16⟩
/-- Display orientation: face down (tablet lying flat, screen down). -/
def faceDown : DisplayOrientation := ⟨32⟩
end DisplayOrientation

@[extern "allegro_al_get_display_orientation"]
private opaque getDisplayOrientationRaw : Display → IO UInt32

/-- Get the orientation of a display (rotation). Returns one of the `displayOrientation*` constants. -/
@[inline] def getDisplayOrientation (display : Display) : IO DisplayOrientation := do
  let v ← getDisplayOrientationRaw display
  return ⟨v⟩

/-- Get the video adapter index of a display. -/
@[extern "allegro_al_get_display_adapter"]
opaque getDisplayAdapter : Display → IO UInt32

@[extern "allegro_al_set_display_option_live"]
private opaque setDisplayOptionLiveRaw : Display → UInt32 → UInt32 → IO Unit

/-- Set a display option on an existing display. -/
@[inline] def setDisplayOptionLive (display : Display) (option : DisplayOption) (value : UInt32) : IO Unit :=
  setDisplayOptionLiveRaw display option.val value

-- ── Window management ──

/-- Set the title of the display window. -/
@[extern "allegro_al_set_window_title"]
opaque setWindowTitle : Display → @& String → IO Unit

/-- Set the position of the display window on screen. -/
@[extern "allegro_al_set_window_position"]
opaque setWindowPosition : Display → Int32 → Int32 → IO Unit

/-- Set min/max size constraints on a resizable window. Returns 1 on success. -/
@[extern "allegro_al_set_window_constraints"]
opaque setWindowConstraints : Display → UInt32 → UInt32 → UInt32 → UInt32 → IO UInt32

/-- Apply or remove previously set window constraints. Pass 1 to apply, 0 to remove. -/
@[extern "allegro_al_apply_window_constraints"]
opaque applyWindowConstraints : Display → UInt32 → IO Unit

-- ── Display surface ──

/-- Copy a region of the backbuffer to the display. -/
@[extern "allegro_al_update_display_region"]
opaque updateDisplayRegion : Int32 → Int32 → Int32 → Int32 → IO Unit

/-- Get the backbuffer bitmap of a display. -/
@[extern "allegro_al_get_backbuffer"]
opaque getBackbuffer : Display → IO UInt64

/-- Set the target bitmap to the display's backbuffer. -/
@[extern "allegro_al_set_target_backbuffer"]
opaque setTargetBackbuffer : Display → IO Unit

/-- Flip the display backbuffer to the screen (present the frame). -/
@[extern "allegro_al_flip_display"]
opaque flipDisplay : IO Unit

-- ── Clipping rectangle ──

/-- Restrict drawing to a rectangle. `setClippingRectangle x y w h` -/
@[extern "allegro_al_set_clipping_rectangle"]
opaque setClippingRectangle : UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

/-- Reset the clipping rectangle to the full target bitmap. -/
@[extern "allegro_al_reset_clipping_rectangle"]
opaque resetClippingRectangle : IO Unit

-- ── Render state ──

/-- Enable/disable deferred bitmap drawing. 1 = hold, 0 = flush. -/
@[extern "allegro_al_hold_bitmap_drawing"]
opaque holdBitmapDrawing : UInt32 → IO Unit

/-- Check if bitmap drawing is currently held. Returns 1 if held. -/
@[extern "allegro_al_is_bitmap_drawing_held"]
opaque isBitmapDrawingHeld : IO UInt32

-- ── Clipboard ──

/-- Get the clipboard text. Returns `""` if empty or unavailable. -/
@[extern "allegro_al_get_clipboard_text"]
opaque getClipboardText : Display → IO String

/-- Set the clipboard text. Returns 1 on success. -/
@[extern "allegro_al_set_clipboard_text"]
opaque setClipboardText : Display → String → IO UInt32

/-- Check whether the clipboard contains text. Returns 1 if yes. -/
@[extern "allegro_al_clipboard_has_text"]
opaque clipboardHasText : Display → IO UInt32

-- ── Monitor info ──

/-- Get the number of video adapters (monitors) connected. -/
@[extern "allegro_al_get_num_video_adapters"]
opaque getNumVideoAdapters : IO UInt32

/-- Get the DPI of monitor `adapter`. Returns 0 on failure. -/
@[extern "allegro_al_get_monitor_dpi"]
opaque getMonitorDpi : UInt32 → IO UInt32

-- ── Fullscreen display modes ──

/-- Get the number of available fullscreen display modes. -/
@[extern "allegro_al_get_num_display_modes"]
opaque getNumDisplayModes : IO UInt32

-- ── Display extras ──

/-- Set the display icon (window/taskbar icon). The bitmap is not consumed. -/
@[extern "allegro_al_set_display_icon"]
opaque setDisplayIcon : Display → UInt64 → IO Unit

/-- Inhibit or allow the screensaver. Pass 1 to inhibit, 0 to allow.
    Returns 1 on success. -/
@[extern "allegro_al_inhibit_screensaver"]
opaque inhibitScreensaver : UInt32 → IO UInt32

/-- Check if a bitmap is compatible with the current display. Returns 1 if compatible. -/
@[extern "allegro_al_is_compatible_bitmap"]
opaque isCompatibleBitmap : UInt64 → IO UInt32

/-- Wait for the next vertical retrace. Returns 1 on success. -/
@[extern "allegro_al_wait_for_vsync"]
opaque waitForVsync : IO UInt32

/-- Force backup of all dirty bitmaps belonging to the display. -/
@[extern "allegro_al_backup_dirty_bitmaps"]
opaque backupDirtyBitmaps : Display → IO Unit

-- ════════════════════════════════════════════════════════════════════
-- Tuple-returning queries  (single FFI call → full result)
-- ════════════════════════════════════════════════════════════════════

/-- Get the window position as `(x, y)` in one call. -/
@[extern "allegro_al_get_window_position"]
opaque getWindowPosition : Display → IO (Int32 × Int32)

/-- Get the clipping rectangle as `(x, y, w, h)` in one call. -/
@[extern "allegro_al_get_clipping_rectangle"]
opaque getClippingRectangle : IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Get window border/decoration sizes as `(left, top, right, bottom)`. -/
@[extern "allegro_al_get_window_borders"]
opaque getWindowBorders : Display → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Get the current window size constraints as `(minW, minH, maxW, maxH)`. -/
@[extern "allegro_al_get_window_constraints"]
opaque getWindowConstraints : Display → IO (UInt32 × UInt32 × UInt32 × UInt32)

/-- Get monitor `adapter`'s desktop area as `(x1, y1, x2, y2)` in one call. -/
@[extern "allegro_al_get_monitor_info"]
opaque getMonitorInfo : UInt32 → IO (Int32 × Int32 × Int32 × Int32)

/-- Get fullscreen display mode at `index` as `(width, height, format, refreshRate)`. -/
@[extern "allegro_al_get_display_mode"]
opaque getDisplayMode : UInt32 → IO (UInt32 × UInt32 × UInt32 × UInt32)

-- ── Option-returning variants ──

/-- Create a display, returning `none` on failure (bad flags, driver error, etc.). -/
def createDisplay? (w h : UInt32) : IO (Option Display) := liftOption (createDisplay w h)

/-- Get the current display, returning `none` if no display is current. -/
def getCurrentDisplay? : IO (Option Display) := liftOption getCurrentDisplay

-- ── Render state ──

/-- Clear the depth buffer to the given value (typically 1.0). -/
@[extern "allegro_al_clear_depth_buffer"]
opaque clearDepthBuffer : Float → IO Unit

-- ── Render state constants ──

/-- Allegro render state identifier. -/
structure RenderState where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace RenderState
/-- Render state: enable/disable alpha testing (0 = off, 1 = on). -/
def alphaTest : RenderState := ⟨0x0010⟩
/-- Render state: set the write mask (bitmask of `WriteMask` flags). -/
def writeMask : RenderState := ⟨0x0011⟩
/-- Render state: enable/disable depth testing (0 = off, 1 = on). -/
def depthTest : RenderState := ⟨0x0012⟩
/-- Render state: set the depth comparison function (`RenderFunction`). -/
def depthFunction : RenderState := ⟨0x0013⟩
/-- Render state: set the alpha comparison function (`RenderFunction`). -/
def alphaFunction : RenderState := ⟨0x0014⟩
/-- Render state: set the alpha test reference value (0–255). -/
def alphaTestValue : RenderState := ⟨0x0015⟩
end RenderState

-- ── Render function constants ──

/-- Allegro render comparison function. -/
structure RenderFunction where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace RenderFunction
/-- Render function: never pass. -/
def never : RenderFunction := ⟨0⟩
/-- Render function: always pass. -/
def always : RenderFunction := ⟨1⟩
/-- Render function: pass if less than. -/
def less : RenderFunction := ⟨2⟩
/-- Render function: pass if equal. -/
def equal : RenderFunction := ⟨3⟩
/-- Render function: pass if less than or equal. -/
def lessEqual : RenderFunction := ⟨4⟩
/-- Render function: pass if greater than. -/
def greater : RenderFunction := ⟨5⟩
/-- Render function: pass if not equal. -/
def notEqual : RenderFunction := ⟨6⟩
/-- Render function: pass if greater than or equal. -/
def greaterEqual : RenderFunction := ⟨7⟩
end RenderFunction

-- ── Write mask flags ──

/-- Allegro write mask flags (bitfield). -/
structure WriteMask where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

instance : OrOp WriteMask where or a b := ⟨a.val ||| b.val⟩
instance : AndOp WriteMask where and a b := ⟨a.val &&& b.val⟩

namespace WriteMask
/-- Write mask: red channel. -/
def red : WriteMask := ⟨1⟩
/-- Write mask: green channel. -/
def green : WriteMask := ⟨2⟩
/-- Write mask: blue channel. -/
def blue : WriteMask := ⟨4⟩
/-- Write mask: alpha channel. -/
def alpha : WriteMask := ⟨8⟩
/-- Write mask: depth buffer. -/
def depth : WriteMask := ⟨16⟩
/-- Write mask: all RGB channels. -/
def rgb : WriteMask := ⟨7⟩
/-- Write mask: all RGBA channels. -/
def rgba : WriteMask := ⟨15⟩
end WriteMask

@[extern "allegro_al_get_render_state"]
private opaque getRenderStateRaw : UInt32 → IO UInt32

/-- Get a render state value. See `renderState*` constants. -/
@[inline] def getRenderState (state : RenderState) : IO UInt32 :=
  getRenderStateRaw state.val

@[extern "allegro_al_set_render_state"]
private opaque setRenderStateRaw : UInt32 → UInt32 → IO Unit

/-- Set a render state value. See `renderState*` and `renderFunction*` constants. -/
@[inline] def setRenderState (state : RenderState) (value : UInt32) : IO Unit :=
  setRenderStateRaw state.val value

-- ── Monitor extras ──

/-- Get the refresh rate of monitor `adapter`. Returns 0 on failure. Added in Allegro 5.2.9. -/
@[extern "allegro_al_get_monitor_refresh_rate"]
opaque getMonitorRefreshRate : UInt32 → IO UInt32

-- ── Display icons ──

/-- Set one or more window icons for a display.
    Pass an `Array Bitmap` of icons (typically at different sizes). -/
@[extern "allegro_al_set_display_icons"]
opaque setDisplayIcons : Display → @&Array Bitmap → IO Unit

end Allegro
