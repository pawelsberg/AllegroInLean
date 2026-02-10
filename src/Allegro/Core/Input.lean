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

-- ── Key constants ──

/-- Allegro keyboard key code. -/
structure KeyCode where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace KeyCode
-- Letters
def a : KeyCode := ⟨1⟩
def b : KeyCode := ⟨2⟩
def c : KeyCode := ⟨3⟩
def d : KeyCode := ⟨4⟩
def e : KeyCode := ⟨5⟩
def f : KeyCode := ⟨6⟩
def g : KeyCode := ⟨7⟩
def h : KeyCode := ⟨8⟩
def i : KeyCode := ⟨9⟩
def j : KeyCode := ⟨10⟩
def k : KeyCode := ⟨11⟩
def l : KeyCode := ⟨12⟩
def m : KeyCode := ⟨13⟩
def n : KeyCode := ⟨14⟩
def o : KeyCode := ⟨15⟩
def p : KeyCode := ⟨16⟩
def q : KeyCode := ⟨17⟩
def r : KeyCode := ⟨18⟩
def s : KeyCode := ⟨19⟩
def t : KeyCode := ⟨20⟩
def u : KeyCode := ⟨21⟩
def v : KeyCode := ⟨22⟩
def w : KeyCode := ⟨23⟩
def x : KeyCode := ⟨24⟩
def y : KeyCode := ⟨25⟩
def z : KeyCode := ⟨26⟩
-- Digits
def num0 : KeyCode := ⟨27⟩
def num1 : KeyCode := ⟨28⟩
def num2 : KeyCode := ⟨29⟩
def num3 : KeyCode := ⟨30⟩
def num4 : KeyCode := ⟨31⟩
def num5 : KeyCode := ⟨32⟩
def num6 : KeyCode := ⟨33⟩
def num7 : KeyCode := ⟨34⟩
def num8 : KeyCode := ⟨35⟩
def num9 : KeyCode := ⟨36⟩
-- Special keys
/-- Keycode for Escape. -/
def escape : KeyCode := ⟨59⟩
/-- Keycode for Space. -/
def space : KeyCode := ⟨75⟩
/-- Keycode for Enter / Return. -/
def enter : KeyCode := ⟨67⟩
/-- Keycode for Tab. -/
def tab : KeyCode := ⟨64⟩
/-- Keycode for Backspace. -/
def backspace : KeyCode := ⟨63⟩
/-- Keycode for Delete. -/
def delete : KeyCode := ⟨77⟩
/-- Keycode for Insert. -/
def insert : KeyCode := ⟨76⟩
/-- Keycode for Home. -/
def home : KeyCode := ⟨78⟩
/-- Keycode for End. -/
def «end» : KeyCode := ⟨79⟩
/-- Keycode for Page Up. -/
def pgUp : KeyCode := ⟨80⟩
/-- Keycode for Page Down. -/
def pgDn : KeyCode := ⟨81⟩
-- Arrow keys
/-- Keycode for Left arrow. -/
def left : KeyCode := ⟨82⟩
/-- Keycode for Right arrow. -/
def right : KeyCode := ⟨83⟩
/-- Keycode for Up arrow. -/
def up : KeyCode := ⟨84⟩
/-- Keycode for Down arrow. -/
def down : KeyCode := ⟨85⟩
-- Modifier keys
/-- Keycode for Left Shift. -/
def lShift : KeyCode := ⟨215⟩
/-- Keycode for Right Shift. -/
def rShift : KeyCode := ⟨216⟩
/-- Keycode for Left Control. -/
def lCtrl : KeyCode := ⟨217⟩
/-- Keycode for Right Control. -/
def rCtrl : KeyCode := ⟨218⟩
/-- Keycode for Alt. -/
def alt : KeyCode := ⟨219⟩
/-- Keycode for AltGr (right Alt on international keyboards). -/
def altGr : KeyCode := ⟨220⟩
-- Function keys
def f1 : KeyCode := ⟨47⟩
def f2 : KeyCode := ⟨48⟩
def f3 : KeyCode := ⟨49⟩
def f4 : KeyCode := ⟨50⟩
def f5 : KeyCode := ⟨51⟩
def f6 : KeyCode := ⟨52⟩
def f7 : KeyCode := ⟨53⟩
def f8 : KeyCode := ⟨54⟩
def f9 : KeyCode := ⟨55⟩
def f10 : KeyCode := ⟨56⟩
def f11 : KeyCode := ⟨57⟩
def f12 : KeyCode := ⟨58⟩
end KeyCode

-- Backward-compatible aliases
def keyA := KeyCode.a
def keyB := KeyCode.b
def keyC := KeyCode.c
def keyD := KeyCode.d
def keyE := KeyCode.e
def keyF := KeyCode.f
def keyG := KeyCode.g
def keyH := KeyCode.h
def keyI := KeyCode.i
def keyJ := KeyCode.j
def keyK := KeyCode.k
def keyL := KeyCode.l
def keyM := KeyCode.m
def keyN := KeyCode.n
def keyO := KeyCode.o
def keyP := KeyCode.p
def keyQ := KeyCode.q
def keyR := KeyCode.r
def keyS := KeyCode.s
def keyT := KeyCode.t
def keyU := KeyCode.u
def keyV := KeyCode.v
def keyW := KeyCode.w
def keyX := KeyCode.x
def keyY := KeyCode.y
def keyZ := KeyCode.z
def key0 := KeyCode.num0
def key1 := KeyCode.num1
def key2 := KeyCode.num2
def key3 := KeyCode.num3
def key4 := KeyCode.num4
def key5 := KeyCode.num5
def key6 := KeyCode.num6
def key7 := KeyCode.num7
def key8 := KeyCode.num8
def key9 := KeyCode.num9
def keyEscape := KeyCode.escape
def keySpace := KeyCode.space
def keyEnter := KeyCode.enter
def keyTab := KeyCode.tab
def keyBackspace := KeyCode.backspace
def keyDelete := KeyCode.delete
def keyInsert := KeyCode.insert
def keyHome := KeyCode.home
def keyEnd := KeyCode.«end»
def keyPgUp := KeyCode.pgUp
def keyPgDn := KeyCode.pgDn
def keyLeft := KeyCode.left
def keyRight := KeyCode.right
def keyUp := KeyCode.up
def keyArrowDown := KeyCode.down
def keyLShift := KeyCode.lShift
def keyRShift := KeyCode.rShift
def keyLCtrl := KeyCode.lCtrl
def keyRCtrl := KeyCode.rCtrl
def keyAlt := KeyCode.alt
def keyAltGr := KeyCode.altGr
def keyF1 := KeyCode.f1
def keyF2 := KeyCode.f2
def keyF3 := KeyCode.f3
def keyF4 := KeyCode.f4
def keyF5 := KeyCode.f5
def keyF6 := KeyCode.f6
def keyF7 := KeyCode.f7
def keyF8 := KeyCode.f8
def keyF9 := KeyCode.f9
def keyF10 := KeyCode.f10
def keyF11 := KeyCode.f11
def keyF12 := KeyCode.f12

/-- Convert a keycode to its human-readable name (e.g. "Escape"). -/
@[extern "allegro_al_keycode_to_name"]
private opaque keycodeToNameRaw : UInt32 → IO String

@[inline] def keycodeToName (key : KeyCode) : IO String :=
  keycodeToNameRaw key.val

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
private opaque keyDownRaw : KeyboardState → UInt32 → IO UInt32

@[inline] def keyDown (ks : KeyboardState) (key : KeyCode) : IO UInt32 :=
  keyDownRaw ks key.val

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

-- ── System mouse cursor constants ──

/-- Allegro system (OS-native) mouse cursor identifier. -/
structure SystemCursor where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace SystemCursor
/-- No cursor (hidden). -/
def none : SystemCursor := ⟨0⟩
/-- Default operating system cursor. -/
def default : SystemCursor := ⟨1⟩
/-- Standard arrow cursor. -/
def arrow : SystemCursor := ⟨2⟩
/-- Busy / wait cursor. -/
def busy : SystemCursor := ⟨3⟩
/-- Help / question mark cursor. -/
def question : SystemCursor := ⟨4⟩
/-- Text edit / I-beam cursor. -/
def edit : SystemCursor := ⟨5⟩
/-- Move / drag cursor. -/
def move : SystemCursor := ⟨6⟩
/-- Resize north cursor. -/
def resizeN : SystemCursor := ⟨7⟩
/-- Resize west cursor. -/
def resizeW : SystemCursor := ⟨8⟩
/-- Resize south cursor. -/
def resizeS : SystemCursor := ⟨9⟩
/-- Resize east cursor. -/
def resizeE : SystemCursor := ⟨10⟩
/-- Resize north-west cursor. -/
def resizeNW : SystemCursor := ⟨11⟩
/-- Resize south-west cursor. -/
def resizeSW : SystemCursor := ⟨12⟩
/-- Resize south-east cursor. -/
def resizeSE : SystemCursor := ⟨13⟩
/-- Resize north-east cursor. -/
def resizeNE : SystemCursor := ⟨14⟩
/-- Background progress cursor (arrow + spinner). -/
def progress : SystemCursor := ⟨15⟩
/-- Precision / crosshair cursor. -/
def precision : SystemCursor := ⟨16⟩
/-- Hyperlink / hand cursor. -/
def link : SystemCursor := ⟨17⟩
/-- Alternate selection cursor. -/
def altSelect : SystemCursor := ⟨18⟩
/-- Unavailable / not-allowed cursor. -/
def unavailable : SystemCursor := ⟨19⟩
end SystemCursor

-- Backward-compatible aliases
def systemCursorNone := SystemCursor.none
def systemCursorDefault := SystemCursor.default
def systemCursorArrow := SystemCursor.arrow
def systemCursorBusy := SystemCursor.busy
def systemCursorQuestion := SystemCursor.question
def systemCursorEdit := SystemCursor.edit
def systemCursorMove := SystemCursor.move
def systemCursorResizeN := SystemCursor.resizeN
def systemCursorResizeW := SystemCursor.resizeW
def systemCursorResizeS := SystemCursor.resizeS
def systemCursorResizeE := SystemCursor.resizeE
def systemCursorResizeNW := SystemCursor.resizeNW
def systemCursorResizeSW := SystemCursor.resizeSW
def systemCursorResizeSE := SystemCursor.resizeSE
def systemCursorResizeNE := SystemCursor.resizeNE
def systemCursorProgress := SystemCursor.progress
def systemCursorPrecision := SystemCursor.precision
def systemCursorLink := SystemCursor.link
def systemCursorAltSelect := SystemCursor.altSelect
def systemCursorUnavailable := SystemCursor.unavailable

/-- Set a system (OS-native) mouse cursor for a display. Returns 1 on success. -/
@[extern "allegro_al_set_system_mouse_cursor"]
private opaque setSystemMouseCursorRaw : UInt64 → UInt32 → IO UInt32

@[inline] def setSystemMouseCursor (display : UInt64) (cursor : SystemCursor) : IO UInt32 :=
  setSystemMouseCursorRaw display cursor.val

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

-- ── Option-returning variants ──

/-- Create a custom mouse cursor, returning `none` on failure (null bitmap, platform error). -/
def createMouseCursor? (bmp : UInt64) (xfocus yfocus : Int32) : IO (Option MouseCursor) :=
  liftOption (createMouseCursor bmp xfocus yfocus)

end Allegro
