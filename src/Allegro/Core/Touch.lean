/-!
Touch input device bindings for Allegro 5.

Install the touch input subsystem, access event sources, and
configure mouse emulation from touch events.

## Typical usage
```
let ok ← Allegro.installTouchInput
if ok != 0 then
  let src ← Allegro.getTouchInputEventSource
  Allegro.registerEventSource queue src
  -- handle TOUCH_BEGIN / TOUCH_END / TOUCH_MOVE events --
  Allegro.uninstallTouchInput
```
-/
namespace Allegro

-- ── Installation ──

/-- Install the touch input driver. Returns non-zero on success. -/
@[extern "allegro_al_install_touch_input"]
opaque installTouchInput : IO UInt32

/-- Uninstall the touch input driver. -/
@[extern "allegro_al_uninstall_touch_input"]
opaque uninstallTouchInput : IO Unit

/-- Check if touch input is installed. Returns 1 if yes. -/
@[extern "allegro_al_is_touch_input_installed"]
opaque isTouchInputInstalled : IO UInt32

-- ── Event sources ──

/-- Get the event source for touch input events. -/
@[extern "allegro_al_get_touch_input_event_source"]
opaque getTouchInputEventSource : IO UInt64

/-- Event source that translates touch events into mouse events. -/
@[extern "allegro_al_get_touch_input_mouse_emulation_event_source"]
opaque getTouchInputMouseEmulationEventSource : IO UInt64

-- ── Mouse emulation ──

/-- Set the mouse emulation mode (how touch events map to mouse events). -/
@[extern "allegro_al_set_mouse_emulation_mode"]
opaque setMouseEmulationMode : UInt32 → IO Unit

/-- Get the current mouse emulation mode. -/
@[extern "allegro_al_get_mouse_emulation_mode"]
opaque getMouseEmulationMode : IO UInt32

-- ── Mouse emulation mode constants ──

/-- Disable mouse emulation from touch. -/
def mouseEmulationNone : UInt32 := 0
/-- Transparent: touch generates both touch and mouse events. -/
def mouseEmulationTransparent : UInt32 := 1
/-- Inclusive: touch generates mouse events for all fingers. -/
def mouseEmulationInclusive : UInt32 := 2
/-- Exclusive: only the primary finger generates mouse events. -/
def mouseEmulationExclusive : UInt32 := 3
/-- 5.0.x compatibility mode. -/
def mouseEmulation50x : UInt32 := 4

-- ════════════════════════════════════════════════════════════════════════════
-- Touch input state
-- ════════════════════════════════════════════════════════════════════════════

/-- Opaque handle to an ALLEGRO_TOUCH_INPUT_STATE snapshot. -/
def TouchInputState := UInt64

instance : BEq TouchInputState := inferInstanceAs (BEq UInt64)
instance : Inhabited TouchInputState := inferInstanceAs (Inhabited UInt64)
instance : OfNat TouchInputState 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString TouchInputState := ⟨fun (h : UInt64) => s!"TouchInputState#{h}"⟩
instance : Repr TouchInputState := ⟨fun (h : UInt64) _ => .text s!"TouchInputState#{repr h}"⟩

/-- Maximum number of simultaneous touch points. -/
def touchInputMaxTouchCount : UInt32 := 16

/-- Allocate a touch input state buffer. Free with `destroyTouchInputState`. -/
@[extern "allegro_al_create_touch_input_state"]
opaque createTouchInputState : IO TouchInputState

/-- Free a touch input state buffer. -/
@[extern "allegro_al_destroy_touch_input_state"]
opaque destroyTouchInputState : TouchInputState → IO Unit

/-- Snapshot the current state of all touch inputs. -/
@[extern "allegro_al_get_touch_input_state"]
opaque getTouchInputState : TouchInputState → IO Unit

/-- Read touch data for slot `index` (0–15) from a state snapshot.
    Returns `(id, x, y, dx, dy, primary)` where `id == 0` means unused slot. -/
@[extern "allegro_al_touch_input_state_get_touch"]
opaque touchInputStateGetTouch : TouchInputState → UInt32 → IO (UInt32 × Float × Float × Float × Float × UInt32)

end Allegro
