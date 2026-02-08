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
  if evType == Allegro.eventTypeDisplayClose then break
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

-- ── General event fields ──

/-- Get the type code of an event. -/
@[extern "allegro_al_event_get_type"]
opaque eventGetType : Event → IO UInt32

/-- Timestamp (seconds since Allegro init) of any event. -/
@[extern "allegro_al_event_get_timestamp"]
opaque eventGetTimestamp : Event → IO Float

/-- The event source that generated this event. -/
@[extern "allegro_al_event_get_source"]
opaque eventGetSource : Event → IO UInt64

-- ── Keyboard event fields ──

/-- Get the keycode from a keyboard event. -/
@[extern "allegro_al_event_get_keyboard_keycode"]
opaque eventGetKeyboardKeycode : Event → IO UInt32

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
opaque eventGetMouseButton : Event → IO UInt32

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
  /-- Event type constant (e.g. `eventTypeKeyDown`). -/
  type      : UInt32
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
  deriving BEq, Inhabited, Repr

-- ── Convenience accessors ──

/-- Keyboard keycode (valid for keyboard events). -/
abbrev EventData.keycode (ed : EventData) : UInt32 := ed.a
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

-- ── Event type constants: keyboard ──

/-- A keyboard key was pressed down. -/
def eventTypeKeyDown : UInt32 := 10
/-- A keyboard key was released. -/
def eventTypeKeyUp : UInt32 := 12
/-- A character was typed (includes auto-repeat). -/
def eventTypeKeyChar : UInt32 := 11

-- ── Event type constants: display ──

/-- The user clicked the window close button. -/
def eventTypeDisplayClose : UInt32 := 42
/-- The display was resized. -/
def eventTypeDisplayResize : UInt32 := 41
/-- A display region needs repainting. -/
def eventTypeDisplayExpose : UInt32 := 40
/-- The display lost input focus. -/
def eventTypeDisplaySwitchOut : UInt32 := 46
/-- The display gained input focus. -/
def eventTypeDisplaySwitchIn : UInt32 := 45
/-- The display's OpenGL context was lost. -/
def eventTypeDisplayLost : UInt32 := 43
/-- The display's OpenGL context was restored. -/
def eventTypeDisplayFound : UInt32 := 44
/-- The display orientation changed (mobile). -/
def eventTypeDisplayOrientation : UInt32 := 47
/-- The OS requests that drawing be halted. -/
def eventTypeDisplayHaltDrawing : UInt32 := 48
/-- Drawing may resume after a halt. -/
def eventTypeDisplayResumeDrawing : UInt32 := 49
/-- A new monitor was connected. -/
def eventTypeDisplayConnected : UInt32 := 60
/-- A monitor was disconnected. -/
def eventTypeDisplayDisconnected : UInt32 := 61

-- ── Event type constants: mouse ──

/-- Mouse axes changed (movement or scroll). -/
def eventTypeMouseAxes : UInt32 := 20
/-- A mouse button was pressed. -/
def eventTypeMouseButtonDown : UInt32 := 21
/-- A mouse button was released. -/
def eventTypeMouseButtonUp : UInt32 := 22
/-- The mouse cursor entered the display window. -/
def eventTypeMouseEnterDisplay : UInt32 := 23
/-- The mouse cursor left the display window. -/
def eventTypeMouseLeaveDisplay : UInt32 := 24
/-- The mouse was warped (programmatically moved). -/
def eventTypeMouseWarped : UInt32 := 25

-- ── Event type constants: timer ──

/-- A timer ticked. -/
def eventTypeTimer : UInt32 := 30

-- ── Event type constants: joystick ──

/-- A joystick axis changed. -/
def eventTypeJoystickAxis : UInt32 := 1
/-- A joystick button was pressed. -/
def eventTypeJoystickButtonDown : UInt32 := 2
/-- A joystick button was released. -/
def eventTypeJoystickButtonUp : UInt32 := 3
/-- Joystick configuration changed (device added/removed). -/
def eventTypeJoystickConfiguration : UInt32 := 4

-- ── Event type constants: touch ──

/-- A touch input began (finger down). -/
def eventTypeTouchBegin : UInt32 := 50
/-- A touch input ended (finger up). -/
def eventTypeTouchEnd : UInt32 := 51
/-- A touch input moved (finger dragged). -/
def eventTypeTouchMove : UInt32 := 52
/-- A touch input was cancelled. -/
def eventTypeTouchCancel : UInt32 := 53

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
