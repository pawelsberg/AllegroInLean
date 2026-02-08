import Allegro.Core.System

/-!
Timer creation and control.

Includes start/stop and speed controls for timers.
-/
namespace Allegro

/-- Opaque handle to an Allegro timer. -/
def Timer := UInt64

instance : BEq Timer := inferInstanceAs (BEq UInt64)
instance : Inhabited Timer := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Timer := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Timer 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Timer := ⟨fun (h : UInt64) => s!"Timer#{h}"⟩
instance : Repr Timer := ⟨fun (h : UInt64) _ => .text s!"Timer#{repr h}"⟩

/-- The null timer handle. -/
def Timer.null : Timer := (0 : UInt64)

/-- Create a timer that ticks every `speedSecs` seconds. Returns a null handle on failure. -/
@[extern "allegro_al_create_timer"]
opaque createTimer : Float -> IO Timer

/-- Start a stopped timer. -/
@[extern "allegro_al_start_timer"]
opaque startTimer : Timer -> IO Unit

/-- Stop (pause) a running timer. -/
@[extern "allegro_al_stop_timer"]
opaque stopTimer : Timer -> IO Unit

/-- Get the timer's current tick count. -/
@[extern "allegro_al_get_timer_count"]
opaque getTimerCount : Timer -> IO UInt64

/-- Get the timer's tick interval in seconds. -/
@[extern "allegro_al_get_timer_speed"]
opaque getTimerSpeed : Timer -> IO Float

/-- Set the timer's tick interval in seconds. -/
@[extern "allegro_al_set_timer_speed"]
opaque setTimerSpeed : Timer -> Float -> IO Unit

/-- Destroy a timer and free its resources. -/
@[extern "allegro_al_destroy_timer"]
opaque destroyTimer : Timer -> IO Unit

/-- Resume a stopped timer without resetting its count (unlike `startTimer`). -/
@[extern "allegro_al_resume_timer"]
opaque resumeTimer : Timer -> IO Unit

/-- Check whether a timer is currently running. Returns 1 if started, 0 if stopped. -/
@[extern "allegro_al_get_timer_started"]
opaque getTimerStarted : Timer -> IO UInt32

/-- Set the timer's tick counter to the given value. -/
@[extern "allegro_al_set_timer_count"]
opaque setTimerCount : Timer -> UInt64 -> IO Unit

/-- Add `diff` to the timer's tick counter (use for relative adjustments). -/
@[extern "allegro_al_add_timer_count"]
opaque addTimerCount : Timer -> UInt64 -> IO Unit

-- ── Option-returning variants ──

/-- Create a timer, returning `none` on failure (speed ≤ 0, OOM). -/
def createTimer? (speedSecs : Float) : IO (Option Timer) := liftOption (createTimer speedSecs)

end Allegro
