import Allegro.Core.System

/-!
Input device installation, state queries, and key constants for Allegro 5.

Keyboard and mouse install helpers, event source access, state polling,
and common keycode constants.

Key constants are pure `def` values (no IO needed):
```
let kbState ← Allegro.createKeyboardState
Allegro.getKeyboardState kbState
let isDown ← Allegro.keyDown kbState Allegro.keyEscape
Allegro.destroyKeyboardState kbState
```
-/
namespace Allegro

-- ── Installation ──

/-- Install the keyboard driver. Returns non-zero on success. -/
@[extern "allegro_al_install_keyboard"]
opaque installKeyboard : IO UInt32

/-- Install the mouse driver. Returns non-zero on success. -/
@[extern "allegro_al_install_mouse"]
opaque installMouse : IO UInt32

/-- Check whether the keyboard driver is installed. Returns 1 if installed. -/
@[extern "allegro_al_is_keyboard_installed"]
opaque isKeyboardInstalled : IO UInt32

/-- Uninstall the keyboard driver. -/
@[extern "allegro_al_uninstall_keyboard"]
opaque uninstallKeyboard : IO Unit

/-- Check whether the mouse driver is installed. Returns 1 if installed. -/
@[extern "allegro_al_is_mouse_installed"]
opaque isMouseInstalled : IO UInt32

/-- Uninstall the mouse driver. -/
@[extern "allegro_al_uninstall_mouse"]
opaque uninstallMouse : IO Unit

-- ── Event sources ──

/-- Get the keyboard event source for registering with an event queue. -/
@[extern "allegro_al_get_keyboard_event_source"]
opaque getKeyboardEventSource : IO UInt64

/-- Get the mouse event source for registering with an event queue. -/
@[extern "allegro_al_get_mouse_event_source"]
opaque getMouseEventSource : IO UInt64

-- ── Keyboard helpers ──

/-- Convert a keycode to its human-readable name (e.g. "Escape"). -/
@[extern "allegro_al_keycode_to_name"]
opaque keycodeToName : UInt32 → IO String

/-- Check if keyboard LED indicators can be set on this platform. Returns 1 if supported. -/
@[extern "allegro_al_can_set_keyboard_leds"]
opaque canSetKeyboardLeds : IO UInt32

/-- Set keyboard LED indicators. `leds` is a bitmask. Returns 1 on success. -/
@[extern "allegro_al_set_keyboard_leds"]
opaque setKeyboardLeds : UInt32 → IO UInt32

/-- Clear the recorded keyboard state for a display (pass 0 for all displays). -/
@[extern "allegro_al_clear_keyboard_state"]
opaque clearKeyboardState : UInt64 → IO Unit

-- ── Mouse helpers ──

/-- Get the number of buttons on the mouse. -/
@[extern "allegro_al_get_mouse_num_buttons"]
opaque getMouseNumButtons : IO UInt32

/-- Get the number of axes on the mouse (typically 4: x, y, z/wheel, w). -/
@[extern "allegro_al_get_mouse_num_axes"]
opaque getMouseNumAxes : IO UInt32

/-- Set the mouse wheel position (z axis). Returns 1 on success. -/
@[extern "allegro_al_set_mouse_z"]
opaque setMouseZ : UInt32 → IO UInt32

/-- Set the 4th mouse axis (horizontal wheel / w). Returns 1 on success. -/
@[extern "allegro_al_set_mouse_w"]
opaque setMouseW : UInt32 → IO UInt32

/-- Set an arbitrary mouse axis value. Returns 1 on success. -/
@[extern "allegro_al_set_mouse_axis"]
opaque setMouseAxis : UInt32 → UInt32 → IO UInt32

/-- Check if the mouse cursor position can be retrieved. Returns 1 if available. -/
@[extern "allegro_al_can_get_mouse_cursor_position"]
opaque canGetMouseCursorPosition : IO UInt32

/-- Get the mouse wheel precision (events per click). -/
@[extern "allegro_al_get_mouse_wheel_precision"]
opaque getMouseWheelPrecision : IO UInt32

/-- Set the scroll wheel precision (events per click). -/
@[extern "allegro_al_set_mouse_wheel_precision"]
opaque setMouseWheelPrecision : Float → IO Unit

/-- Hide the mouse cursor on the given display. Returns 1 on success. -/
@[extern "allegro_al_hide_mouse_cursor"]
opaque hideMouseCursor : UInt64 → IO UInt32

/-- Show the mouse cursor on the given display. Returns 1 on success. -/
@[extern "allegro_al_show_mouse_cursor"]
opaque showMouseCursor : UInt64 → IO UInt32

-- ── Keyboard state ──

/-- Opaque handle to a keyboard state snapshot. -/
def KeyboardState := UInt64

instance : BEq KeyboardState := inferInstanceAs (BEq UInt64)
instance : Inhabited KeyboardState := inferInstanceAs (Inhabited UInt64)
instance : OfNat KeyboardState 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString KeyboardState := ⟨fun (h : UInt64) => s!"KeyboardState#{h}"⟩
instance : Repr KeyboardState := ⟨fun (h : UInt64) _ => .text s!"KeyboardState#{repr h}"⟩

/-- Allocate a keyboard state struct. Free with `destroyKeyboardState`. -/
@[extern "allegro_al_create_keyboard_state"]
opaque createKeyboardState : IO KeyboardState

/-- Free a keyboard state struct. -/
@[extern "allegro_al_destroy_keyboard_state"]
opaque destroyKeyboardState : KeyboardState → IO Unit

/-- Snapshot the current keyboard state. -/
@[extern "allegro_al_get_keyboard_state"]
opaque getKeyboardState : KeyboardState → IO Unit

/-- Check whether `keycode` is held down in the given state. Returns 1 if pressed. -/
@[extern "allegro_al_key_down"]
opaque keyDown : KeyboardState → UInt32 → IO UInt32

-- ── Mouse state ──

/-- Opaque handle to a mouse state snapshot. -/
def MouseState := UInt64

instance : BEq MouseState := inferInstanceAs (BEq UInt64)
instance : Inhabited MouseState := inferInstanceAs (Inhabited UInt64)
instance : OfNat MouseState 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString MouseState := ⟨fun (h : UInt64) => s!"MouseState#{h}"⟩
instance : Repr MouseState := ⟨fun (h : UInt64) _ => .text s!"MouseState#{repr h}"⟩

/-- Allocate a mouse state struct. Free with `destroyMouseState`. -/
@[extern "allegro_al_create_mouse_state"]
opaque createMouseState : IO MouseState

/-- Free a mouse state struct. -/
@[extern "allegro_al_destroy_mouse_state"]
opaque destroyMouseState : MouseState → IO Unit

/-- Snapshot the current mouse state. -/
@[extern "allegro_al_get_mouse_state"]
opaque getMouseState : MouseState → IO Unit

/-- Check whether `button` (1-based) is held down. Returns 1 if pressed. -/
@[extern "allegro_al_mouse_button_down"]
opaque mouseButtonDown : MouseState → UInt32 → IO UInt32

/-- Get an axis value from the mouse state (0=x, 1=y, 2=z/wheel, 3=w). -/
@[extern "allegro_al_get_mouse_state_axis"]
opaque getMouseStateAxis : MouseState → UInt32 → IO UInt32

-- ── Mouse cursor ──

/-- Opaque handle to a mouse cursor. -/
def MouseCursor := UInt64

instance : BEq MouseCursor := inferInstanceAs (BEq UInt64)
instance : Inhabited MouseCursor := inferInstanceAs (Inhabited UInt64)
instance : OfNat MouseCursor 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString MouseCursor := ⟨fun (h : UInt64) => s!"MouseCursor#{h}"⟩
instance : Repr MouseCursor := ⟨fun (h : UInt64) _ => .text s!"MouseCursor#{repr h}"⟩

/-- Create a custom mouse cursor from a bitmap. `createMouseCursor bitmap xfocus yfocus`
    The focus point is the "hot spot" (tip of arrow, etc.).
    Returns 0 on failure. Free with `destroyMouseCursor`. -/
@[extern "allegro_al_create_mouse_cursor"]
opaque createMouseCursor : UInt64 → Int32 → Int32 → IO MouseCursor

/-- Destroy a custom mouse cursor. -/
@[extern "allegro_al_destroy_mouse_cursor"]
opaque destroyMouseCursor : MouseCursor → IO Unit

/-- Set a custom mouse cursor for a display. Returns 1 on success. -/
@[extern "allegro_al_set_mouse_cursor"]
opaque setMouseCursor : UInt64 → MouseCursor → IO UInt32

/-- Set a system (OS-native) mouse cursor for a display. Returns 1 on success. -/
@[extern "allegro_al_set_system_mouse_cursor"]
opaque setSystemMouseCursor : UInt64 → UInt32 → IO UInt32

/-- Get the current global mouse cursor position as `(x, y)` in one call. -/
@[extern "allegro_al_get_mouse_cursor_position"]
opaque getMouseCursorPosition : IO (UInt32 × UInt32)

/-- Warp (move) the mouse cursor to (x, y) relative to the display. Returns 1 on success. -/
@[extern "allegro_al_set_mouse_xy"]
opaque setMouseXy : UInt64 → Int32 → Int32 → IO UInt32

/-- Confine the mouse to the display. Returns 1 on success. -/
@[extern "allegro_al_grab_mouse"]
opaque grabMouse : UInt64 → IO UInt32

/-- Release a grabbed mouse. Returns 1 on success. -/
@[extern "allegro_al_ungrab_mouse"]
opaque ungrabMouse : IO UInt32

-- ── System mouse cursor constants ──

/-- No cursor (hidden). -/
def systemCursorNone : UInt32 := 0
/-- Default operating system cursor. -/
def systemCursorDefault : UInt32 := 1
/-- Standard arrow cursor. -/
def systemCursorArrow : UInt32 := 2
/-- Busy / wait cursor. -/
def systemCursorBusy : UInt32 := 3
/-- Help / question mark cursor. -/
def systemCursorQuestion : UInt32 := 4
/-- Text edit / I-beam cursor. -/
def systemCursorEdit : UInt32 := 5
/-- Move / drag cursor. -/
def systemCursorMove : UInt32 := 6
/-- Resize north cursor. -/
def systemCursorResizeN : UInt32 := 7
/-- Resize west cursor. -/
def systemCursorResizeW : UInt32 := 8
/-- Resize south cursor. -/
def systemCursorResizeS : UInt32 := 9
/-- Resize east cursor. -/
def systemCursorResizeE : UInt32 := 10
/-- Resize north-west cursor. -/
def systemCursorResizeNW : UInt32 := 11
/-- Resize south-west cursor. -/
def systemCursorResizeSW : UInt32 := 12
/-- Resize south-east cursor. -/
def systemCursorResizeSE : UInt32 := 13
/-- Resize north-east cursor. -/
def systemCursorResizeNE : UInt32 := 14
/-- Background progress cursor (arrow + spinner). -/
def systemCursorProgress : UInt32 := 15
/-- Precision / crosshair cursor. -/
def systemCursorPrecision : UInt32 := 16
/-- Hyperlink / hand cursor. -/
def systemCursorLink : UInt32 := 17
/-- Alternate selection cursor. -/
def systemCursorAltSelect : UInt32 := 18
/-- Unavailable / not-allowed cursor. -/
def systemCursorUnavailable : UInt32 := 19

-- ── Key constants: letters ──

/-- Keycode for A. -/
def keyA : UInt32 := 1
/-- Keycode for B. -/
def keyB : UInt32 := 2
/-- Keycode for C. -/
def keyC : UInt32 := 3
/-- Keycode for D. -/
def keyD : UInt32 := 4
/-- Keycode for E. -/
def keyE : UInt32 := 5
/-- Keycode for F. -/
def keyF : UInt32 := 6
/-- Keycode for G. -/
def keyG : UInt32 := 7
/-- Keycode for H. -/
def keyH : UInt32 := 8
/-- Keycode for I. -/
def keyI : UInt32 := 9
/-- Keycode for J. -/
def keyJ : UInt32 := 10
/-- Keycode for K. -/
def keyK : UInt32 := 11
/-- Keycode for L. -/
def keyL : UInt32 := 12
/-- Keycode for M. -/
def keyM : UInt32 := 13
/-- Keycode for N. -/
def keyN : UInt32 := 14
/-- Keycode for O. -/
def keyO : UInt32 := 15
/-- Keycode for P. -/
def keyP : UInt32 := 16
/-- Keycode for Q. -/
def keyQ : UInt32 := 17
/-- Keycode for R. -/
def keyR : UInt32 := 18
/-- Keycode for S. -/
def keyS : UInt32 := 19
/-- Keycode for T. -/
def keyT : UInt32 := 20
/-- Keycode for U. -/
def keyU : UInt32 := 21
/-- Keycode for V. -/
def keyV : UInt32 := 22
/-- Keycode for W. -/
def keyW : UInt32 := 23
/-- Keycode for X. -/
def keyX : UInt32 := 24
/-- Keycode for Y. -/
def keyY : UInt32 := 25
/-- Keycode for Z. -/
def keyZ : UInt32 := 26

-- ── Key constants: digits ──

/-- Keycode for 0. -/
def key0 : UInt32 := 27
/-- Keycode for 1. -/
def key1 : UInt32 := 28
/-- Keycode for 2. -/
def key2 : UInt32 := 29
/-- Keycode for 3. -/
def key3 : UInt32 := 30
/-- Keycode for 4. -/
def key4 : UInt32 := 31
/-- Keycode for 5. -/
def key5 : UInt32 := 32
/-- Keycode for 6. -/
def key6 : UInt32 := 33
/-- Keycode for 7. -/
def key7 : UInt32 := 34
/-- Keycode for 8. -/
def key8 : UInt32 := 35
/-- Keycode for 9. -/
def key9 : UInt32 := 36

-- ── Key constants: special ──

/-- Keycode for Escape. -/
def keyEscape : UInt32 := 59
/-- Keycode for Space. -/
def keySpace : UInt32 := 75
/-- Keycode for Enter / Return. -/
def keyEnter : UInt32 := 67
/-- Keycode for Tab. -/
def keyTab : UInt32 := 64
/-- Keycode for Backspace. -/
def keyBackspace : UInt32 := 63
/-- Keycode for Delete. -/
def keyDelete : UInt32 := 77
/-- Keycode for Insert. -/
def keyInsert : UInt32 := 76
/-- Keycode for Home. -/
def keyHome : UInt32 := 78
/-- Keycode for End. -/
def keyEnd : UInt32 := 79
/-- Keycode for Page Up. -/
def keyPgUp : UInt32 := 80
/-- Keycode for Page Down. -/
def keyPgDn : UInt32 := 81

-- ── Key constants: arrows ──

/-- Keycode for Left arrow. -/
def keyLeft : UInt32 := 82
/-- Keycode for Right arrow. -/
def keyRight : UInt32 := 83
/-- Keycode for Up arrow. -/
def keyUp : UInt32 := 84
/-- Keycode for Down arrow. -/
def keyArrowDown : UInt32 := 85

-- ── Key constants: modifiers ──

/-- Keycode for Left Shift. -/
def keyLShift : UInt32 := 215
/-- Keycode for Right Shift. -/
def keyRShift : UInt32 := 216
/-- Keycode for Left Control. -/
def keyLCtrl : UInt32 := 217
/-- Keycode for Right Control. -/
def keyRCtrl : UInt32 := 218
/-- Keycode for Alt. -/
def keyAlt : UInt32 := 219
/-- Keycode for AltGr (right Alt on international keyboards). -/
def keyAltGr : UInt32 := 220

-- ── Key constants: function keys ──

/-- Keycode for F1. -/
def keyF1 : UInt32 := 47
/-- Keycode for F2. -/
def keyF2 : UInt32 := 48
/-- Keycode for F3. -/
def keyF3 : UInt32 := 49
/-- Keycode for F4. -/
def keyF4 : UInt32 := 50
/-- Keycode for F5. -/
def keyF5 : UInt32 := 51
/-- Keycode for F6. -/
def keyF6 : UInt32 := 52
/-- Keycode for F7. -/
def keyF7 : UInt32 := 53
/-- Keycode for F8. -/
def keyF8 : UInt32 := 54
/-- Keycode for F9. -/
def keyF9 : UInt32 := 55
/-- Keycode for F10. -/
def keyF10 : UInt32 := 56
/-- Keycode for F11. -/
def keyF11 : UInt32 := 57
/-- Keycode for F12. -/
def keyF12 : UInt32 := 58

-- ── Option-returning variants ──

/-- Create a custom mouse cursor, returning `none` on failure (null bitmap, platform error). -/
def createMouseCursor? (bmp : UInt64) (xfocus yfocus : Int32) : IO (Option MouseCursor) :=
  liftOption (createMouseCursor bmp xfocus yfocus)

end Allegro
