import Allegro.Core.Input

/-!
Event queue, event type constants, and event field accessors for Allegro 5.

Covers the full event lifecycle: queue management, waiting/polling,
event type identification, and field extraction for keyboard, mouse,
display, timer, joystick, touch, and user events.

## Typical event loop
```
let queue ← Allegro.createEventQueue
let event ← Allegro.createEvent
Allegro.registerEventSource queue displaySrc
while true do
  Allegro.waitForEvent queue event
  let evType ← Allegro.eventGetType event
  if evType == Allegro.EventType.displayClose then break
Allegro.destroyEvent event
Allegro.destroyEventQueue queue
```
-/
namespace Allegro

/-- Opaque handle to an Allegro event queue. -/
def EventQueue := UInt64

instance : BEq EventQueue := inferInstanceAs (BEq UInt64)
instance : Inhabited EventQueue := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq EventQueue := inferInstanceAs (DecidableEq UInt64)
instance : OfNat EventQueue 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString EventQueue := ⟨fun (h : UInt64) => s!"EventQueue#{h}"⟩
instance : Repr EventQueue := ⟨fun (h : UInt64) _ => .text s!"EventQueue#{repr h}"⟩

/-- Opaque handle to an Allegro event source. -/
def EventSource := UInt64

instance : BEq EventSource := inferInstanceAs (BEq UInt64)
instance : Inhabited EventSource := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq EventSource := inferInstanceAs (DecidableEq UInt64)
instance : OfNat EventSource 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString EventSource := ⟨fun (h : UInt64) => s!"EventSource#{h}"⟩
instance : Repr EventSource := ⟨fun (h : UInt64) _ => .text s!"EventSource#{repr h}"⟩

/-- Opaque handle to an Allegro event. -/
def Event := UInt64

instance : BEq Event := inferInstanceAs (BEq UInt64)
instance : Inhabited Event := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Event := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Event 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Event := ⟨fun (h : UInt64) => s!"Event#{h}"⟩
instance : Repr Event := ⟨fun (h : UInt64) _ => .text s!"Event#{repr h}"⟩

-- ── Event queue lifecycle ──

/-- Create a new event queue. -/
@[extern "allegro_al_create_event_queue"]
opaque createEventQueue : IO EventQueue

/-- Destroy an event queue and free its resources. -/
@[extern "allegro_al_destroy_event_queue"]
opaque destroyEventQueue : EventQueue → IO Unit

/-- Register an event source with the queue so its events are collected. -/
@[extern "allegro_al_register_event_source"]
opaque registerEventSource : EventQueue → EventSource → IO Unit

/-- Unregister an event source from the queue. -/
@[extern "allegro_al_unregister_event_source"]
opaque unregisterEventSource : EventQueue → EventSource → IO Unit

/-- Check if an event source is registered with the queue. Returns 1 if registered. -/
@[extern "allegro_al_is_event_source_registered"]
opaque isEventSourceRegistered : EventQueue → EventSource → IO UInt32

/-- Get user data attached to an event source. -/
@[extern "allegro_al_get_event_source_data"]
opaque getEventSourceData : EventSource → IO UInt64

/-- Set user data on an event source. -/
@[extern "allegro_al_set_event_source_data"]
opaque setEventSourceData : EventSource → UInt64 → IO Unit

/-- Discard all events currently in the queue. -/
@[extern "allegro_al_flush_event_queue"]
opaque flushEventQueue : EventQueue → IO Unit

/-- Check if the event queue is paused. Returns 1 if paused. -/
@[extern "allegro_al_is_event_queue_paused"]
opaque isEventQueuePaused : EventQueue → IO UInt32

/-- Pause (1) or unpause (0) the event queue. -/
@[extern "allegro_al_pause_event_queue"]
opaque pauseEventQueue : EventQueue → UInt32 → IO Unit

-- ── Event source helpers ──

/-- Get the event source associated with a display. -/
@[extern "allegro_al_get_display_event_source"]
opaque getDisplayEventSource : UInt64 → IO EventSource

/-- Get the event source associated with a timer. -/
@[extern "allegro_al_get_timer_event_source"]
opaque getTimerEventSource : UInt64 → IO EventSource

-- ── Event allocation ──

/-- Allocate a heap event buffer. Free with `destroyEvent`. -/
@[extern "allegro_al_create_event"]
opaque createEvent : IO Event

/-- Free a heap event buffer. -/
@[extern "allegro_al_destroy_event"]
opaque destroyEvent : Event → IO Unit

-- ── Waiting and polling ──

/-- Block until an event arrives. -/
@[extern "allegro_al_wait_for_event"]
opaque waitForEvent : EventQueue → Event → IO Unit

/-- Wait up to `secs` seconds. Returns 1 if an event was received. -/
@[extern "allegro_al_wait_for_event_timed"]
opaque waitForEventTimed : EventQueue → Event → Float → IO UInt32

/-- Non-blocking: get the next event. Returns 1 if one was available. -/
@[extern "allegro_al_get_next_event"]
opaque getNextEvent : EventQueue → Event → IO UInt32

/-- Peek at the next event without removing it. Returns 1 if available. -/
@[extern "allegro_al_peek_next_event"]
opaque peekNextEvent : EventQueue → Event → IO UInt32

/-- Drop the next event without reading it. Returns 1 if one was dropped. -/
@[extern "allegro_al_drop_next_event"]
opaque dropNextEvent : EventQueue → IO UInt32

/-- Check if the event queue is empty. Returns 1 if empty. -/
@[extern "allegro_al_is_event_queue_empty"]
opaque isEventQueueEmpty : EventQueue → IO UInt32

-- ════════════════════════════════════════════════════════════════════
-- EventType — strongly-typed event type identifier
-- ════════════════════════════════════════════════════════════════════

/-- Allegro event type identifier. -/
structure EventType where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Inhabited, Repr

namespace EventType
-- Joystick events
def joystickAxis : EventType := ⟨1⟩
def joystickButtonDown : EventType := ⟨2⟩
def joystickButtonUp : EventType := ⟨3⟩
def joystickConfiguration : EventType := ⟨4⟩
-- Keyboard events
def keyDown : EventType := ⟨10⟩
def keyChar : EventType := ⟨11⟩
def keyUp : EventType := ⟨12⟩
-- Mouse events
def mouseAxes : EventType := ⟨20⟩
def mouseButtonDown : EventType := ⟨21⟩
def mouseButtonUp : EventType := ⟨22⟩
def mouseEnterDisplay : EventType := ⟨23⟩
def mouseLeaveDisplay : EventType := ⟨24⟩
def mouseWarped : EventType := ⟨25⟩
-- Timer events
def timer : EventType := ⟨30⟩
-- Display events
def displayExpose : EventType := ⟨40⟩
def displayResize : EventType := ⟨41⟩
def displayClose : EventType := ⟨42⟩
def displayLost : EventType := ⟨43⟩
def displayFound : EventType := ⟨44⟩
def displaySwitchIn : EventType := ⟨45⟩
def displaySwitchOut : EventType := ⟨46⟩
def displayOrientation : EventType := ⟨47⟩
def displayHaltDrawing : EventType := ⟨48⟩
def displayResumeDrawing : EventType := ⟨49⟩
-- Touch events
def touchBegin : EventType := ⟨50⟩
def touchEnd : EventType := ⟨51⟩
def touchMove : EventType := ⟨52⟩
def touchCancel : EventType := ⟨53⟩
-- Display connect/disconnect events
def displayConnected : EventType := ⟨60⟩
def displayDisconnected : EventType := ⟨61⟩
end EventType

-- ── General event fields ──

/-- Get the type code of an event. -/
@[extern "allegro_al_event_get_type"]
private opaque eventGetTypeRaw : Event → IO UInt32

@[inline] def eventGetType (ev : Event) : IO EventType := do
  let v ← eventGetTypeRaw ev
  return ⟨v⟩

/-- Timestamp (seconds since Allegro init) of any event. -/
@[extern "allegro_al_event_get_timestamp"]
opaque eventGetTimestamp : Event → IO Float

/-- The event source that generated this event. -/
@[extern "allegro_al_event_get_source"]
opaque eventGetSource : Event → IO UInt64

-- ── Keyboard event fields ──

/-- Get the keycode from a keyboard event. -/
@[extern "allegro_al_event_get_keyboard_keycode"]
private opaque eventGetKeyboardKeycodeRaw : Event → IO UInt32

/-- Get the keyboard keycode from a KEY_DOWN / KEY_UP / KEY_CHAR event. -/
@[inline] def eventGetKeyboardKeycode (ev : Event) : IO KeyCode := do
  let v ← eventGetKeyboardKeycodeRaw ev
  return ⟨v⟩

/-- Get the Unicode character from a KEY_CHAR event. -/
@[extern "allegro_al_event_get_keyboard_unichar"]
opaque eventGetKeyboardUnichar : Event → IO UInt32

/-- Get the modifier flags from a keyboard event. -/
@[extern "allegro_al_event_get_keyboard_modifiers"]
opaque eventGetKeyboardModifiers : Event → IO UInt32

/-- Get whether a keyboard event is a key repeat. Returns 1 if repeated. -/
@[extern "allegro_al_event_get_keyboard_repeat"]
opaque eventGetKeyboardRepeat : Event → IO UInt32

-- ── Mouse event fields ──

/-- Get the mouse X position from a mouse event. -/
@[extern "allegro_al_event_get_mouse_x"]
opaque eventGetMouseX : Event → IO UInt32

/-- Get the mouse Y position from a mouse event. -/
@[extern "allegro_al_event_get_mouse_y"]
opaque eventGetMouseY : Event → IO UInt32

/-- Get the mouse Z axis (vertical scroll wheel) from a mouse event. -/
@[extern "allegro_al_event_get_mouse_z"]
opaque eventGetMouseZ : Event → IO UInt32

/-- Get the mouse W axis (horizontal scroll wheel) from a mouse event. -/
@[extern "allegro_al_event_get_mouse_w"]
opaque eventGetMouseW : Event → IO UInt32

/-- Get the mouse X movement delta from a mouse event. -/
@[extern "allegro_al_event_get_mouse_dx"]
opaque eventGetMouseDx : Event → IO UInt32

/-- Get the mouse Y movement delta from a mouse event. -/
@[extern "allegro_al_event_get_mouse_dy"]
opaque eventGetMouseDy : Event → IO UInt32

/-- Get the mouse Z axis (scroll wheel) delta from a mouse event. -/
@[extern "allegro_al_event_get_mouse_dz"]
opaque eventGetMouseDz : Event → IO UInt32

/-- Get the mouse W axis (horizontal scroll) delta from a mouse event. -/
@[extern "allegro_al_event_get_mouse_dw"]
opaque eventGetMouseDw : Event → IO UInt32

/-- Get the pen/tablet pressure from a mouse event (0.0–1.0). -/
@[extern "allegro_al_event_get_mouse_pressure"]
opaque eventGetMousePressure : Event → IO Float

/-- Get the mouse button number from a mouse event (1-based). -/
@[extern "allegro_al_event_get_mouse_button"]
private opaque eventGetMouseButtonRaw : Event → IO UInt32

/-- Get the mouse button number (1-based) from a mouse button event. -/
@[inline] def eventGetMouseButton (ev : Event) : IO UInt32 := do
  eventGetMouseButtonRaw ev

-- ── Display event fields ──

/-- Get the X position from a display event. -/
@[extern "allegro_al_event_get_display_x"]
opaque eventGetDisplayX : Event → IO UInt32

/-- Get the Y position from a display event. -/
@[extern "allegro_al_event_get_display_y"]
opaque eventGetDisplayY : Event → IO UInt32

/-- Get the width from a display resize event. -/
@[extern "allegro_al_event_get_display_width"]
opaque eventGetDisplayWidth : Event → IO UInt32

/-- Get the height from a display resize event. -/
@[extern "allegro_al_event_get_display_height"]
opaque eventGetDisplayHeight : Event → IO UInt32

/-- Get the orientation from a display orientation event. -/
@[extern "allegro_al_event_get_display_orientation"]
opaque eventGetDisplayOrientation : Event → IO UInt32

/-- Get the display handle from a display event. -/
@[extern "allegro_al_event_get_display_source"]
opaque eventGetDisplaySource : Event → IO UInt64

-- ── Timer event fields ──

/-- Get the timer tick count from a timer event. -/
@[extern "allegro_al_event_get_timer_count"]
opaque eventGetTimerCount : Event → IO UInt64

/-- Get the timing error (seconds late) from a timer event. -/
@[extern "allegro_al_event_get_timer_error"]
opaque eventGetTimerError : Event → IO Float

/-- Get the timestamp from a timer event. -/
@[extern "allegro_al_event_get_timer_timestamp"]
opaque eventGetTimerTimestamp : Event → IO Float

-- ── Joystick event fields ──

/-- The joystick handle from a joystick event. -/
@[extern "allegro_al_event_get_joystick_id"]
opaque eventGetJoystickId : Event → IO UInt64

/-- Get the stick index from a joystick axis event. -/
@[extern "allegro_al_event_get_joystick_stick"]
opaque eventGetJoystickStick : Event → IO UInt32

/-- Get the axis index from a joystick axis event. -/
@[extern "allegro_al_event_get_joystick_axis"]
opaque eventGetJoystickAxis : Event → IO UInt32

/-- Get the axis position (−1.0 to 1.0) from a joystick axis event. -/
@[extern "allegro_al_event_get_joystick_pos"]
opaque eventGetJoystickPos : Event → IO Float

/-- Get the button index from a joystick button event. -/
@[extern "allegro_al_event_get_joystick_button"]
opaque eventGetJoystickButton : Event → IO UInt32

-- ── Touch event fields ──

/-- Get the touch finger ID from a touch event. -/
@[extern "allegro_al_event_get_touch_id"]
opaque eventGetTouchId : Event → IO UInt32

/-- Get the touch X position from a touch event. -/
@[extern "allegro_al_event_get_touch_x"]
opaque eventGetTouchX : Event → IO Float

/-- Get the touch Y position from a touch event. -/
@[extern "allegro_al_event_get_touch_y"]
opaque eventGetTouchY : Event → IO Float

/-- Get the touch X delta from a touch move event. -/
@[extern "allegro_al_event_get_touch_dx"]
opaque eventGetTouchDx : Event → IO Float

/-- Get the touch Y delta from a touch move event. -/
@[extern "allegro_al_event_get_touch_dy"]
opaque eventGetTouchDy : Event → IO Float

/-- Check if this touch is the primary finger. Returns 1 if primary. -/
@[extern "allegro_al_event_get_touch_primary"]
opaque eventGetTouchPrimary : Event → IO UInt32

-- ── User event fields ──

/-- Get the first user data word from a user event. -/
@[extern "allegro_al_event_get_user_data1"]
opaque eventGetUserData1 : Event → IO UInt64

/-- Get the second user data word from a user event. -/
@[extern "allegro_al_event_get_user_data2"]
opaque eventGetUserData2 : Event → IO UInt64

/-- Get the third user data word from a user event. -/
@[extern "allegro_al_event_get_user_data3"]
opaque eventGetUserData3 : Event → IO UInt64

/-- Get the fourth user data word from a user event. -/
@[extern "allegro_al_event_get_user_data4"]
opaque eventGetUserData4 : Event → IO UInt64

-- ── User event source ──

/-- Create and initialise a user event source. -/
@[extern "allegro_al_init_user_event_source"]
opaque initUserEventSource : IO EventSource

/-- Destroy a user event source (frees underlying memory). -/
@[extern "allegro_al_destroy_user_event_source"]
opaque destroyUserEventSource : EventSource → IO Unit

/-- Emit a user event with four data words. Returns 1 on success. -/
@[extern "allegro_al_emit_user_event"]
opaque emitUserEvent : EventSource → UInt64 → UInt64 → UInt64 → UInt64 → IO UInt32

-- ════════════════════════════════════════════════════════════════════
-- EventData  — stack-allocated, GC-managed, zero-lifetime event value
-- ════════════════════════════════════════════════════════════════════

/-- All interesting fields from an Allegro event, packed into a single
    GC-managed value.  No `createEvent`/`destroyEvent` needed.

    Field interpretation depends on `type`:
    * **Keyboard** (10–12): `a`=keycode, `b`=unichar, `c`=modifiers, `d`=repeat
    * **Mouse** (20–25): `a`=x `b`=y `c`=z `d`=w `e`=dx `f`=dy `g`=dz `h`=dw
      `i`=button, `fv1`=pressure
    * **Timer** (30): `fv1`=error, `fv2`=timestamp, `u64v`=count
    * **Display** (40–61): `a`=x `b`=y `c`=width `d`=height `i`=orientation,
      `u64v`=display source handle
    * **Joystick** (1–4): `a`=stick `b`=axis `i`=button `fv1`=pos `u64v`=joystick id
    * **Touch** (50–53): `fv1`=x `fv2`=y, `i`=primary, `u64v`=touch id
    * **User** (≥512): `u64v`=data1
-/
structure EventData where
  /-- Event type constant (e.g. `EventType.keyDown`). -/
  type      : EventType
  /-- Seconds since Allegro init. -/
  timestamp : Float
  /-- The event source pointer (as UInt64). -/
  source    : UInt64
  /-- Generic integer slot (keycode / mouse.x / display.x / stick / …). -/
  a         : UInt32
  /-- Generic integer slot (unichar / mouse.y / display.y / axis / …). -/
  b         : UInt32
  /-- Generic integer slot (modifiers / mouse.z / display.width / …). -/
  c         : UInt32
  /-- Generic integer slot (repeat / mouse.w / display.height / …). -/
  d         : UInt32
  /-- Generic integer slot (mouse.dx / …). -/
  e         : UInt32
  /-- Generic integer slot (mouse.dy / …). -/
  f         : UInt32
  /-- Generic integer slot (mouse.dz / …). -/
  g         : UInt32
  /-- Generic integer slot (mouse.dw / …). -/
  h         : UInt32
  /-- Generic integer slot (button / orientation / primary / …). -/
  i         : UInt32
  /-- Float slot (pressure / joystick.pos / touch.x / timer.error). -/
  fv1       : Float
  /-- Float slot (touch.y / timer.timestamp). -/
  fv2       : Float
  /-- UInt64 slot (timer.count / joystick.id / touch.id / user.data1). -/
  u64v      : UInt64
  deriving Repr

instance : Inhabited EventData where
  default := {
    type := default, timestamp := 0.0, source := 0,
    a := 0, b := 0, c := 0, d := 0, e := 0, f := 0, g := 0, h := 0, i := 0,
    fv1 := 0.0, fv2 := 0.0, u64v := 0
  }

instance : BEq EventData where
  beq x y :=
    x.type == y.type && x.timestamp == y.timestamp && x.source == y.source &&
    x.a == y.a && x.b == y.b && x.c == y.c && x.d == y.d &&
    x.e == y.e && x.f == y.f && x.g == y.g && x.h == y.h &&
    x.i == y.i && x.fv1 == y.fv1 && x.fv2 == y.fv2 && x.u64v == y.u64v

-- ── Convenience accessors ──

/-- Keyboard keycode (valid for keyboard events). -/
abbrev EventData.keycode (ed : EventData) : KeyCode := ⟨ed.a⟩
/-- Keyboard unichar (valid for KEY_CHAR events). -/
abbrev EventData.unichar (ed : EventData) : UInt32 := ed.b
/-- Keyboard modifiers (valid for keyboard events). -/
abbrev EventData.modifiers (ed : EventData) : UInt32 := ed.c
/-- Mouse X position. -/
abbrev EventData.mouseX (ed : EventData) : UInt32 := ed.a
/-- Mouse Y position. -/
abbrev EventData.mouseY (ed : EventData) : UInt32 := ed.b
/-- Mouse button number. -/
abbrev EventData.mouseButton (ed : EventData) : UInt32 := ed.i
/-- Mouse pressure (tablet). -/
abbrev EventData.mousePressure (ed : EventData) : Float := ed.fv1
/-- Display width (resize events). -/
abbrev EventData.displayWidth (ed : EventData) : UInt32 := ed.c
/-- Display height (resize events). -/
abbrev EventData.displayHeight (ed : EventData) : UInt32 := ed.d
/-- Timer tick count. -/
abbrev EventData.timerCount (ed : EventData) : UInt64 := ed.u64v

-- ── Stack-allocated event functions ──

/-- Block until an event arrives. Returns the event as a pure value
    (stack-allocated on the C side, no malloc/free needed). -/
@[extern "allegro_al_wait_for_event_data"]
opaque waitForEventData : EventQueue → IO EventData

/-- Wait up to `secs` seconds. Returns `(gotEvent, data)`.
    If `gotEvent == 0`, `data` is zero-filled. -/
@[extern "allegro_al_wait_for_event_timed_data"]
opaque waitForEventTimedData : EventQueue → Float → IO (UInt32 × EventData)

/-- Non-blocking: get the next event. Returns `(gotEvent, data)`. -/
@[extern "allegro_al_get_next_event_data"]
opaque getNextEventData : EventQueue → IO (UInt32 × EventData)

/-- Peek at the next event without removing it. Returns `(gotEvent, data)`. -/
@[extern "allegro_al_peek_next_event_data"]
opaque peekNextEventData : EventQueue → IO (UInt32 × EventData)

-- ════════════════════════════════════════════════════════════════════
-- Timeout
-- ════════════════════════════════════════════════════════════════════

/-- Opaque handle to an ALLEGRO_TIMEOUT. -/
def Timeout := UInt64

instance : BEq Timeout := inferInstanceAs (BEq UInt64)
instance : Inhabited Timeout := inferInstanceAs (Inhabited UInt64)
instance : OfNat Timeout 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Timeout := ⟨fun (h : UInt64) => s!"Timeout#{h}"⟩
instance : Repr Timeout := ⟨fun (h : UInt64) _ => .text s!"Timeout#{repr h}"⟩

/-- Allocate a timeout structure. Free with `destroyTimeout`. -/
@[extern "allegro_al_create_timeout"]
opaque createTimeout : IO Timeout

/-- Free a timeout structure. -/
@[extern "allegro_al_destroy_timeout"]
opaque destroyTimeout : Timeout → IO Unit

/-- Initialise a timeout to expire `seconds` from now. -/
@[extern "allegro_al_init_timeout"]
opaque initTimeout : Timeout → Float → IO Unit

/-- Wait for an event with an absolute timeout.
    Returns `(gotEvent, data)`. If `gotEvent == 0`, the timeout expired. -/
@[extern "allegro_al_wait_for_event_until_data"]
opaque waitForEventUntilData : EventQueue → Timeout → IO (UInt32 × EventData)

/-- Decrease the reference count of a user event (raw event pointer). -/
@[extern "allegro_al_unref_user_event"]
opaque unrefUserEvent : UInt64 → IO Unit

end Allegro
