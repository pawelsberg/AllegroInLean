import Allegro.Core.System

/-!
Joystick input device bindings for Allegro 5.

Install the joystick subsystem, enumerate connected joysticks, query
their properties (sticks, axes, buttons), and poll state.

## Typical usage
```
let _ ← Allegro.installJoystick
let n ← Allegro.getNumJoysticks
if n > 0 then
  let joy ← Allegro.getJoystick 0
  let name ← Allegro.getJoystickName joy
  IO.println s!"Joystick 0: {name}"
  -- register event source and handle joystick events --
  let src ← Allegro.getJoystickEventSource
  Allegro.registerEventSource queue src
  Allegro.releaseJoystick joy
Allegro.uninstallJoystick
```
-/
namespace Allegro

/-- Opaque handle to a joystick device. -/
def Joystick := UInt64

instance : BEq Joystick := inferInstanceAs (BEq UInt64)
instance : Inhabited Joystick := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Joystick := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Joystick 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Joystick := ⟨fun (h : UInt64) => s!"Joystick#{h}"⟩
instance : Repr Joystick := ⟨fun (h : UInt64) _ => .text s!"Joystick#{repr h}"⟩

/-- Opaque handle to a joystick state snapshot. -/
def JoystickState := UInt64

instance : BEq JoystickState := inferInstanceAs (BEq UInt64)
instance : Inhabited JoystickState := inferInstanceAs (Inhabited UInt64)
instance : OfNat JoystickState 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString JoystickState := ⟨fun (h : UInt64) => s!"JoystickState#{h}"⟩
instance : Repr JoystickState := ⟨fun (h : UInt64) _ => .text s!"JoystickState#{repr h}"⟩

-- ── Installation ──

/-- Install the joystick driver. Returns non-zero on success. -/
@[extern "allegro_al_install_joystick"]
opaque installJoystick : IO UInt32

/-- Uninstall the joystick driver. -/
@[extern "allegro_al_uninstall_joystick"]
opaque uninstallJoystick : IO Unit

/-- Check if the joystick driver is installed. Returns 1 if yes. -/
@[extern "allegro_al_is_joystick_installed"]
opaque isJoystickInstalled : IO UInt32

/-- Call after receiving ALLEGRO_EVENT_JOYSTICK_CONFIGURATION to refresh. -/
@[extern "allegro_al_reconfigure_joysticks"]
opaque reconfigureJoysticks : IO UInt32

-- ── Enumeration ──

/-- Get the number of joysticks currently connected. -/
@[extern "allegro_al_get_num_joysticks"]
opaque getNumJoysticks : IO UInt32

/-- Get a joystick handle by index (0-based). Returns null on failure. -/
@[extern "allegro_al_get_joystick"]
opaque getJoystick : UInt32 → IO Joystick

/-- Release a joystick handle obtained from `getJoystick`. -/
@[extern "allegro_al_release_joystick"]
opaque releaseJoystick : Joystick → IO Unit

/-- Check if a joystick handle still refers to an active device. Returns 1 if active. -/
@[extern "allegro_al_get_joystick_active"]
opaque getJoystickActive : Joystick → IO UInt32

-- ── Properties ──

/-- Get the human-readable name of a joystick. -/
@[extern "allegro_al_get_joystick_name"]
opaque getJoystickName : Joystick → IO String

/-- Get the number of stick (directional) groups on the joystick. -/
@[extern "allegro_al_get_joystick_num_sticks"]
opaque getJoystickNumSticks : Joystick → IO UInt32

/-- Get the name of a stick group by index. -/
@[extern "allegro_al_get_joystick_stick_name"]
opaque getJoystickStickName : Joystick → UInt32 → IO String

/-- Get the number of axes on the given stick group. -/
@[extern "allegro_al_get_joystick_num_axes"]
opaque getJoystickNumAxes : Joystick → UInt32 → IO UInt32

/-- Get the name of an axis within a stick group. -/
@[extern "allegro_al_get_joystick_axis_name"]
opaque getJoystickAxisName : Joystick → UInt32 → UInt32 → IO String

/-- Get the number of buttons on the joystick. -/
@[extern "allegro_al_get_joystick_num_buttons"]
opaque getJoystickNumButtons : Joystick → IO UInt32

/-- Get the name of a button by index. -/
@[extern "allegro_al_get_joystick_button_name"]
opaque getJoystickButtonName : Joystick → UInt32 → IO String

/-- Get the flags for a stick (directional group) — analog, digital, etc. -/
@[extern "allegro_al_get_joystick_stick_flags"]
opaque getJoystickStickFlags : Joystick → UInt32 → IO UInt32

-- ── Stick flag constants ──

/-- Stick flag: digital (D-pad style) input. -/
def joystickFlagDigital : UInt32 := 1
/-- Stick flag: analog (continuous range) input. -/
def joystickFlagAnalog : UInt32 := 2

-- ── Joystick type constants (5.2.11, UNSTABLE) ──

/-- Joystick type: unknown. -/
def joystickTypeUnknown : UInt32 := 0
/-- Joystick type: gamepad. -/
def joystickTypeGamepad : UInt32 := 1

-- ── 5.2.11 — GUID / type / mappings (UNSTABLE) ──

/-- Get the GUID of a joystick as a 32-character hex string (5.2.11). -/
@[extern "allegro_al_get_joystick_guid"]
opaque getJoystickGuid : Joystick → IO String

/-- Get the joystick type — 0 = unknown, 1 = gamepad (5.2.11). -/
@[extern "allegro_al_get_joystick_type"]
opaque getJoystickType : Joystick → IO UInt32

/-- Load a joystick mapping database from a file path (5.2.11).
    Returns 1 on success. -/
@[extern "allegro_al_set_joystick_mappings"]
opaque setJoystickMappings : @&String → IO UInt32

-- ── Gamepad button constants (5.2.11) ──

def gamepadButtonA : UInt32 := 0
def gamepadButtonB : UInt32 := 1
def gamepadButtonX : UInt32 := 2
def gamepadButtonY : UInt32 := 3
def gamepadButtonLeftShoulder : UInt32 := 4
def gamepadButtonRightShoulder : UInt32 := 5
def gamepadButtonBack : UInt32 := 6
def gamepadButtonStart : UInt32 := 7
def gamepadButtonGuide : UInt32 := 8
def gamepadButtonLeftThumb : UInt32 := 9
def gamepadButtonRightThumb : UInt32 := 10

-- ── Gamepad stick constants (5.2.11) ──

def gamepadStickDpad : UInt32 := 0
def gamepadStickLeftThumb : UInt32 := 1
def gamepadStickRightThumb : UInt32 := 2
def gamepadStickLeftTrigger : UInt32 := 3
def gamepadStickRightTrigger : UInt32 := 4

-- ── State polling ──

/-- Allocate a joystick state snapshot buffer. Free with `destroyJoystickState`. -/
@[extern "allegro_al_create_joystick_state"]
opaque createJoystickState : IO JoystickState

/-- Free a joystick state snapshot buffer. -/
@[extern "allegro_al_destroy_joystick_state"]
opaque destroyJoystickState : JoystickState → IO Unit

/-- Snapshot the current joystick state. -/
@[extern "allegro_al_get_joystick_state"]
opaque getJoystickState : Joystick → JoystickState → IO Unit

/-- Read axis position (-1.0 to 1.0) from a state snapshot. -/
@[extern "allegro_al_joystick_state_get_axis"]
opaque joystickStateGetAxis : JoystickState → UInt32 → UInt32 → IO Float

/-- Read button state (0 or non-zero) from a state snapshot. -/
@[extern "allegro_al_joystick_state_get_button"]
opaque joystickStateGetButton : JoystickState → UInt32 → IO UInt32

-- ── Event source ──

/-- Get the global joystick event source. -/
@[extern "allegro_al_get_joystick_event_source"]
opaque getJoystickEventSource : IO UInt64

-- ── Option-returning variants ──

/-- Get joystick by index, returning `none` if index is out of range. -/
def getJoystick? (index : UInt32) : IO (Option Joystick) := liftOption (getJoystick index)

-- ── File-based joystick mappings ──

/-- Load joystick mappings from an open `AllegroFile`. Returns 1 on success. -/
@[extern "allegro_al_set_joystick_mappings_f"]
opaque setJoystickMappingsF : UInt64 → IO UInt32

end Allegro
