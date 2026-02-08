import Allegro.Core.System

/-!
# Allegro 5 Haptic (force-feedback) bindings (`haptic.h`)

**Unstable API** — requires `ALLEGRO_UNSTABLE` (set centrally in `allegro_ffi.h`).

Provides force-feedback / vibration support. Haptic devices can be
obtained from mice, keyboards, joysticks, displays, or touch inputs.

## Capability flags
- `hapticRumble`    (1)   — simple rumble
- `hapticPeriodic`  (2)   — periodic effect
- `hapticConstant`  (4)   — constant force
- `hapticSpring`    (8)   — spring
- `hapticFriction`  (16)  — friction
- `hapticDamper`    (32)  — damper
- `hapticInertia`   (64)  — inertia
- `hapticRamp`      (128) — ramp
- `hapticGainCap`   (4096)      — supports gain
- `hapticAutocenterCap` (8192)  — supports autocenter
-/
namespace Allegro

/-- Opaque handle to a haptic device (`ALLEGRO_HAPTIC *`). -/
def Haptic := UInt64

instance : BEq Haptic := inferInstanceAs (BEq UInt64)
instance : Inhabited Haptic := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Haptic := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Haptic 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Haptic := ⟨fun (h : UInt64) => s!"Haptic#{h}"⟩
instance : Repr Haptic := ⟨fun (h : UInt64) _ => .text s!"Haptic#{repr h}"⟩

/-- The null haptic handle. -/
def Haptic.null : Haptic := (0 : UInt64)

/-- Opaque handle to a haptic effect ID (`ALLEGRO_HAPTIC_EFFECT_ID *`). -/
def HapticEffectId := UInt64

instance : BEq HapticEffectId := inferInstanceAs (BEq UInt64)
instance : Inhabited HapticEffectId := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq HapticEffectId := inferInstanceAs (DecidableEq UInt64)
instance : OfNat HapticEffectId 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString HapticEffectId := ⟨fun (h : UInt64) => s!"HapticEffectId#{h}"⟩
instance : Repr HapticEffectId := ⟨fun (h : UInt64) _ => .text s!"HapticEffectId#{repr h}"⟩

/-- The null haptic effect ID. -/
def HapticEffectId.null : HapticEffectId := (0 : UInt64)

-- ── Capability flags ──

/-- Haptic capability: simple rumble. -/
def hapticRumble     : UInt32 := 1
/-- Haptic capability: periodic effect. -/
def hapticPeriodic   : UInt32 := 2
/-- Haptic capability: constant force. -/
def hapticConstant   : UInt32 := 4
/-- Haptic capability: spring. -/
def hapticSpring     : UInt32 := 8
/-- Haptic capability: friction. -/
def hapticFriction   : UInt32 := 16
/-- Haptic capability: damper. -/
def hapticDamper     : UInt32 := 32
/-- Haptic capability: inertia. -/
def hapticInertia    : UInt32 := 64
/-- Haptic capability: ramp. -/
def hapticRamp       : UInt32 := 128
/-- Haptic capability: gain control. -/
def hapticGainCap    : UInt32 := 4096
/-- Haptic capability: autocenter. -/
def hapticAutocenterCap : UInt32 := 8192

-- ── Install / uninstall ──

/-- Install the haptic subsystem. Returns 1 on success. -/
@[extern "allegro_al_install_haptic"]
opaque installHaptic : IO UInt32

/-- Uninstall the haptic subsystem. -/
@[extern "allegro_al_uninstall_haptic"]
opaque uninstallHaptic : IO Unit

/-- Check if haptic subsystem is installed. Returns 1 if installed. -/
@[extern "allegro_al_is_haptic_installed"]
opaque isHapticInstalled : IO UInt32

-- ── Device detection ──

/-- Check if the mouse supports haptic feedback. -/
@[extern "allegro_al_is_mouse_haptic"]
opaque isMouseHaptic : IO UInt32

/-- Check if a joystick supports haptic feedback. -/
@[extern "allegro_al_is_joystick_haptic"]
opaque isJoystickHaptic : UInt64 → IO UInt32

/-- Check if the keyboard supports haptic feedback. -/
@[extern "allegro_al_is_keyboard_haptic"]
opaque isKeyboardHaptic : IO UInt32

/-- Check if a display supports haptic feedback. -/
@[extern "allegro_al_is_display_haptic"]
opaque isDisplayHaptic : UInt64 → IO UInt32

/-- Check if the touch input supports haptic feedback. -/
@[extern "allegro_al_is_touch_input_haptic"]
opaque isTouchInputHaptic : IO UInt32

-- ── Get haptic from device ──

/-- Get haptic device from the mouse. -/
@[extern "allegro_al_get_haptic_from_mouse"]
opaque getHapticFromMouse : IO Haptic

/-- Get haptic device from a joystick. -/
@[extern "allegro_al_get_haptic_from_joystick"]
opaque getHapticFromJoystick : UInt64 → IO Haptic

/-- Get haptic device from the keyboard. -/
@[extern "allegro_al_get_haptic_from_keyboard"]
opaque getHapticFromKeyboard : IO Haptic

/-- Get haptic device from a display. -/
@[extern "allegro_al_get_haptic_from_display"]
opaque getHapticFromDisplay : UInt64 → IO Haptic

/-- Get haptic device from touch input. -/
@[extern "allegro_al_get_haptic_from_touch_input"]
opaque getHapticFromTouchInput : IO Haptic

-- ── Release / query ──

/-- Release a haptic device. Returns 1 on success. -/
@[extern "allegro_al_release_haptic"]
opaque releaseHaptic : Haptic → IO UInt32

/-- Check if a haptic device is active. Returns 1 if active. -/
@[extern "allegro_al_is_haptic_active"]
opaque isHapticActive : Haptic → IO UInt32

/-- Get the capability flags of a haptic device. -/
@[extern "allegro_al_get_haptic_capabilities"]
opaque getHapticCapabilities : Haptic → IO UInt32

/-- Check if a haptic device supports a specific capability. -/
@[extern "allegro_al_is_haptic_capable"]
opaque isHapticCapable : Haptic → UInt32 → IO UInt32

-- ── Gain / autocenter ──

/-- Set the gain (overall strength) of a haptic device (0.0–1.0). -/
@[extern "allegro_al_set_haptic_gain"]
opaque setHapticGain : Haptic → Float → IO UInt32

/-- Get the gain of a haptic device. -/
@[extern "allegro_al_get_haptic_gain"]
opaque getHapticGain : Haptic → IO Float

/-- Set the autocenter intensity of a haptic device (0.0–1.0). -/
@[extern "allegro_al_set_haptic_autocenter"]
opaque setHapticAutocenter : Haptic → Float → IO UInt32

/-- Get the autocenter intensity of a haptic device. -/
@[extern "allegro_al_get_haptic_autocenter"]
opaque getHapticAutocenter : Haptic → IO Float

-- ── Max effects ──

/-- Get the maximum number of simultaneous haptic effects. -/
@[extern "allegro_al_get_max_haptic_effects"]
opaque getMaxHapticEffects : Haptic → IO UInt32

-- ── Rumble (simple vibration) ──

/-- Start a simple rumble effect. Returns a `HapticEffectId`, or null on failure. -/
@[extern "allegro_al_rumble_haptic"]
opaque rumbleHaptic : Haptic → Float → Float → IO HapticEffectId

-- ── Effect lifecycle ──

/-- Stop a playing haptic effect. Returns 1 on success. -/
@[extern "allegro_al_stop_haptic_effect"]
opaque stopHapticEffect : HapticEffectId → IO UInt32

/-- Check if a haptic effect is currently playing. Returns 1 if playing. -/
@[extern "allegro_al_is_haptic_effect_playing"]
opaque isHapticEffectPlaying : HapticEffectId → IO UInt32

/-- Release a haptic effect (frees the effect ID). Returns 1 on success. -/
@[extern "allegro_al_release_haptic_effect"]
opaque releaseHapticEffect : HapticEffectId → IO UInt32

end Allegro
