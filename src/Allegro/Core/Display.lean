import Allegro.Core.System

/-!
Display management for Allegro 5.

Create and manage windows, display properties, options, flags, and render state.

## Display flags
Combine flags with bitwise OR before passing to `setNewDisplayFlags`:
```
Allegro.setNewDisplayFlags (Allegro.fullscreenWindowFlag ||| Allegro.resizableFlag)
```

## Display options
Set hints before display creation:
```
Allegro.setNewDisplayOption Allegro.displayOptionVsync 1 Allegro.importanceSuggest
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

/-- Exclusive fullscreen mode. -/
def fullscreenFlag : UInt32 := 2
/-- Fullscreen window (borderless, desktop resolution). -/
def fullscreenWindowFlag : UInt32 := 512
/-- Windowed mode (default). -/
def windowedFlag : UInt32 := 1
/-- Allow the user to resize the window. -/
def resizableFlag : UInt32 := 16
/-- Require an OpenGL context. -/
def openglFlag : UInt32 := 4
/-- Require an OpenGL 3.0+ context. -/
def opengl30Flag : UInt32 := 128
/-- Require a forward-compatible OpenGL context. -/
def openglForwardCompatibleFlag : UInt32 := 256
/-- Remove the window frame/decorations. -/
def noframeFlag : UInt32 := 32
/-- Generate expose events for the display. -/
def generateExposeEventsFlag : UInt32 := 64
/-- Create the window maximised. -/
def maximizedFlag : UInt32 := 8192
/-- Require the programmable pipeline (shaders). -/
def programmablePipelineFlag : UInt32 := 2048

-- ── Display option constants ──

/-- Option: total colour depth in bits. -/
def displayOptionColorSize : UInt32 := 14
/-- Option: red channel bits. -/
def displayOptionRedSize : UInt32 := 0
/-- Option: green channel bits. -/
def displayOptionGreenSize : UInt32 := 1
/-- Option: blue channel bits. -/
def displayOptionBlueSize : UInt32 := 2
/-- Option: alpha channel bits. -/
def displayOptionAlphaSize : UInt32 := 3
/-- Option: depth buffer bits. -/
def displayOptionDepthSize : UInt32 := 15
/-- Option: stencil buffer bits. -/
def displayOptionStencilSize : UInt32 := 16
/-- Option: number of multisample buffers. -/
def displayOptionSampleBuffers : UInt32 := 17
/-- Option: number of multisample samples. -/
def displayOptionSamples : UInt32 := 18
/-- Option: use floating-point colour buffer. -/
def displayOptionFloatColor : UInt32 := 20
/-- Option: use floating-point depth buffer. -/
def displayOptionFloatDepth : UInt32 := 21
/-- Option: use single buffering. -/
def displayOptionSingleBuffer : UInt32 := 22
/-- Option: swap method (0 = undefined, 1 = copy, 2 = flip). -/
def displayOptionSwapMethod : UInt32 := 23
/-- Option: require a compatible display. -/
def displayOptionCompatibleDisplay : UInt32 := 24
/-- Option: support partial display updates. -/
def displayOptionUpdateDisplayRegion : UInt32 := 25
/-- Option: vertical sync (0 = off, 1 = on, 2 = adaptive). -/
def displayOptionVsync : UInt32 := 26
/-- Option: maximum bitmap texture size. -/
def displayOptionMaxBitmapSize : UInt32 := 27
/-- Option: support non-power-of-two bitmaps. -/
def displayOptionSupportNpotBitmap : UInt32 := 28
/-- Option: support separate alpha blending. -/
def displayOptionSupportSeparateAlpha : UInt32 := 30
/-- Option: auto-convert bitmaps to the display format. -/
def displayOptionAutoConvertBitmaps : UInt32 := 31
/-- Option: required OpenGL major version. -/
def displayOptionOpenglMajorVersion : UInt32 := 33
/-- Option: required OpenGL minor version. -/
def displayOptionOpenglMinorVersion : UInt32 := 34

-- ── Display option importance ──

/-- Option importance: no preference. -/
def importanceDontcare : UInt32 := 0
/-- Option importance: the option is required; fail if unavailable. -/
def importanceRequire : UInt32 := 1
/-- Option importance: prefer this value but fall back gracefully. -/
def importanceSuggest : UInt32 := 2

-- ── Display creation setup ──

/-- Set flags for the next display to be created. -/
@[extern "allegro_al_set_new_display_flags"]
opaque setNewDisplayFlags : UInt32 → IO Unit

/-- Get the flags that will be used for the next display creation. -/
@[extern "allegro_al_get_new_display_flags"]
opaque getNewDisplayFlags : IO UInt32

/-- Set a display option hint. `setNewDisplayOption option value importance` -/
@[extern "allegro_al_set_new_display_option"]
opaque setNewDisplayOption : UInt32 → UInt32 → UInt32 → IO Unit

/-- Get the current value of a display creation option. -/
@[extern "allegro_al_get_new_display_option"]
opaque getNewDisplayOption : UInt32 → IO UInt32

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
opaque setNewWindowPosition : UInt32 → UInt32 → IO Unit

/-- Get the window position for the next display creation as `(x, y)`. -/
@[extern "allegro_al_get_new_window_position"]
opaque getNewWindowPosition : IO (UInt32 × UInt32)

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

/-- Get the flags of the display. -/
@[extern "allegro_al_get_display_flags"]
opaque getDisplayFlags : Display → IO UInt32

/-- Toggle a display flag on/off. Returns 1 on success. -/
@[extern "allegro_al_set_display_flag"]
opaque setDisplayFlag : Display → UInt32 → UInt32 → IO UInt32

/-- Query a display option on a live display. -/
@[extern "allegro_al_get_display_option"]
opaque getDisplayOption : Display → UInt32 → IO UInt32

/-- Get the pixel format of a display. -/
@[extern "allegro_al_get_display_format"]
opaque getDisplayFormat : Display → IO UInt32

/-- Get the refresh rate of a display. -/
@[extern "allegro_al_get_display_refresh_rate"]
opaque getDisplayRefreshRate : Display → IO UInt32

/-- Get the orientation of a display (rotation). Returns one of the `displayOrientation*` constants. -/
@[extern "allegro_al_get_display_orientation"]
opaque getDisplayOrientation : Display → IO UInt32

/-- Get the video adapter index of a display. -/
@[extern "allegro_al_get_display_adapter"]
opaque getDisplayAdapter : Display → IO UInt32

/-- Set a display option on an existing display. -/
@[extern "allegro_al_set_display_option_live"]
opaque setDisplayOptionLive : Display → UInt32 → UInt32 → IO Unit

-- ── Window management ──

/-- Set the title of the display window. -/
@[extern "allegro_al_set_window_title"]
opaque setWindowTitle : Display → String → IO Unit

/-- Set the position of the display window on screen. -/
@[extern "allegro_al_set_window_position"]
opaque setWindowPosition : Display → UInt32 → UInt32 → IO Unit

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
opaque getWindowPosition : Display → IO (UInt32 × UInt32)

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
opaque getMonitorInfo : UInt32 → IO (UInt32 × UInt32 × UInt32 × UInt32)

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

/-- Get a render state value. See `renderState*` constants. -/
@[extern "allegro_al_get_render_state"]
opaque getRenderState : UInt32 → IO UInt32

/-- Set a render state value. See `renderState*` and `renderFunction*` constants. -/
@[extern "allegro_al_set_render_state"]
opaque setRenderState : UInt32 → UInt32 → IO Unit

-- ── Render state constants ──

/-- Render state: enable/disable alpha testing (0 = off, 1 = on). -/
def renderStateAlphaTest : UInt32 := 0x0010
/-- Render state: set the write mask (bitmask of `writeMask*` flags). -/
def renderStateWriteMask : UInt32 := 0x0011
/-- Render state: enable/disable depth testing (0 = off, 1 = on). -/
def renderStateDepthTest : UInt32 := 0x0012
/-- Render state: set the depth comparison function (`renderFunction*`). -/
def renderStateDepthFunction : UInt32 := 0x0013
/-- Render state: set the alpha comparison function (`renderFunction*`). -/
def renderStateAlphaFunction : UInt32 := 0x0014
/-- Render state: set the alpha test reference value (0–255). -/
def renderStateAlphaTestValue : UInt32 := 0x0015

-- ── Render function constants ──

/-- Render function: never pass. -/
def renderFunctionNever : UInt32 := 0
/-- Render function: always pass. -/
def renderFunctionAlways : UInt32 := 1
/-- Render function: pass if less than. -/
def renderFunctionLess : UInt32 := 2
/-- Render function: pass if equal. -/
def renderFunctionEqual : UInt32 := 3
/-- Render function: pass if less than or equal. -/
def renderFunctionLessEqual : UInt32 := 4
/-- Render function: pass if greater than. -/
def renderFunctionGreater : UInt32 := 5
/-- Render function: pass if not equal. -/
def renderFunctionNotEqual : UInt32 := 6
/-- Render function: pass if greater than or equal. -/
def renderFunctionGreaterEqual : UInt32 := 7

-- ── Write mask flags ──

/-- Write mask: red channel. -/
def writeMaskRed : UInt32 := 1
/-- Write mask: green channel. -/
def writeMaskGreen : UInt32 := 2
/-- Write mask: blue channel. -/
def writeMaskBlue : UInt32 := 4
/-- Write mask: alpha channel. -/
def writeMaskAlpha : UInt32 := 8
/-- Write mask: depth buffer. -/
def writeMaskDepth : UInt32 := 16
/-- Write mask: all RGB channels. -/
def writeMaskRGB : UInt32 := 7
/-- Write mask: all RGBA channels. -/
def writeMaskRGBA : UInt32 := 15

-- ── Display orientation constants ──

/-- Display orientation: unknown. -/
def displayOrientationUnknown : UInt32 := 0
/-- Display orientation: 0° (normal upright). -/
def displayOrientation0Degrees : UInt32 := 1
/-- Display orientation: 90° clockwise. -/
def displayOrientation90Degrees : UInt32 := 2
/-- Display orientation: 180° (upside down). -/
def displayOrientation180Degrees : UInt32 := 4
/-- Display orientation: 270° clockwise. -/
def displayOrientation270Degrees : UInt32 := 8
/-- Display orientation: portrait (0° or 180°). -/
def displayOrientationPortrait : UInt32 := 5
/-- Display orientation: landscape (90° or 270°). -/
def displayOrientationLandscape : UInt32 := 10
/-- Display orientation: all orientations. -/
def displayOrientationAll : UInt32 := 15
/-- Display orientation: face up (tablet lying flat, screen up). -/
def displayOrientationFaceUp : UInt32 := 16
/-- Display orientation: face down (tablet lying flat, screen down). -/
def displayOrientationFaceDown : UInt32 := 32

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
