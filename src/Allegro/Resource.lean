import Allegro.Core
import Allegro.Addons

/-!
# RAII-style resource wrappers for Allegro 5

Each `with*` function creates (or loads) a resource, passes it to a
callback, and **guarantees** destruction via `try / finally` — even if
the callback throws.

## Example
```
Allegro.withDisplay 640 480 fun display => do
  Allegro.withEventQueue fun queue => do
    Allegro.withEvent fun event => do
      -- game loop --
      pure ()
```

All wrappers are polymorphic in the return type (`IO α`), so they
compose naturally with `do`-notation.
-/

namespace Allegro

-- ── Display ──

/-- Create a display of size `w × h`, run `f`, then destroy it. -/
def withDisplay (w h : UInt32) (f : Display → IO α) : IO α := do
  let d ← createDisplay w h
  try f d finally destroyDisplay d

-- ── Timer ──

/-- Create a timer with the given `speed` (seconds per tick), run `f`, then destroy it. -/
def withTimer (speed : Float) (f : Timer → IO α) : IO α := do
  let t ← createTimer speed
  try f t finally destroyTimer t

-- ── Bitmap ──

/-- Create a bitmap of size `w × h`, run `f`, then destroy it. -/
def withBitmap (w h : UInt32) (f : Bitmap → IO α) : IO α := do
  let b ← createBitmap w h
  try f b finally destroyBitmap b

/-- Load a bitmap from `path`, run `f`, then destroy it. -/
def withLoadedBitmap (path : String) (f : Bitmap → IO α) : IO α := do
  let b ← loadBitmap path
  try f b finally destroyBitmap b

-- ── Events ──

/-- Create an event queue, run `f`, then destroy it. -/
def withEventQueue (f : EventQueue → IO α) : IO α := do
  let q ← createEventQueue
  try f q finally destroyEventQueue q

/-- Create an event handle, run `f`, then destroy it. -/
def withEvent (f : Event → IO α) : IO α := do
  let e ← createEvent
  try f e finally destroyEvent e

-- ── Config ──

/-- Create an empty config, run `f`, then destroy it. -/
def withConfig (f : Config → IO α) : IO α := do
  let c ← createConfig
  try f c finally destroyConfig c

/-- Load a config from `path`, run `f`, then destroy it. -/
def withLoadedConfig (path : String) (f : Config → IO α) : IO α := do
  let c ← loadConfigFile path
  try f c finally destroyConfig c

-- ── Transform ──

/-- Create an identity transform, run `f`, then destroy it. -/
def withTransform (f : Transform → IO α) : IO α := do
  let t ← createTransform
  try f t finally destroyTransform t

-- ── Font ──

/-- Load a bitmap font from `path`, run `f`, then destroy it. -/
def withFont (path : String) (size : Int32) (flags : UInt32) (f : Font → IO α) : IO α := do
  let font ← loadFont path size flags
  try f font finally destroyFont font

/-- Load a TTF font from `path` at the given pixel `size`, run `f`, then destroy it. -/
def withTtfFont (path : String) (size : Int32) (flags : UInt32) (f : Font → IO α) : IO α := do
  let font ← loadTtfFont path size flags
  try f font finally destroyFont font

/-- Use the builtin 8×8 font, run `f`, then destroy it. -/
def withBuiltinFont (f : Font → IO α) : IO α := do
  let font ← createBuiltinFont
  try f font finally destroyFont font

-- ── Path ──

/-- Create a path from `str`, run `f`, then destroy it. -/
def withPath (str : String) (f : Path → IO α) : IO α := do
  let p ← createPath str
  try f p finally destroyPath p

-- ── Ustr ──

/-- Create a ustr from `str`, run `f`, then free it. -/
def withUstr (str : String) (f : Ustr → IO α) : IO α := do
  let u ← ustrNew str
  try f u finally ustrFree u

-- ── Audio: Sample ──

/-- Load a sample from `path`, run `f`, then destroy it. -/
def withSample (path : String) (f : Sample → IO α) : IO α := do
  let s ← loadSample path
  try f s finally destroySample s

/-- Create a sample instance from `sample`, run `f`, then destroy it. -/
def withSampleInstance (sample : Sample) (f : SampleInstance → IO α) : IO α := do
  let inst ← createSampleInstance sample
  try f inst finally destroySampleInstance inst

/-- Load an audio stream from `path`, run `f`, then destroy it. -/
def withAudioStream (path : String) (buffers samples : UInt32) (f : AudioStream → IO α) : IO α := do
  let s ← loadAudioStream path buffers samples
  try f s finally destroyAudioStream s

-- ── Input state ──

/-- Create a keyboard state snapshot handle, run `f`, then free it. -/
def withKeyboardState (f : KeyboardState → IO α) : IO α := do
  let ks ← createKeyboardState
  try f ks finally destroyKeyboardState ks

/-- Create a mouse state snapshot handle, run `f`, then free it. -/
def withMouseState (f : MouseState → IO α) : IO α := do
  let ms ← createMouseState
  try f ms finally destroyMouseState ms

/-- Create a joystick state snapshot handle, run `f`, then free it. -/
def withJoystickState (f : JoystickState → IO α) : IO α := do
  let js ← createJoystickState
  try f js finally destroyJoystickState js

-- ── Mouse cursor ──

/-- Create a custom mouse cursor from a bitmap, run `f`, then destroy it. -/
def withMouseCursor (bitmap : UInt64) (xfocus yfocus : Int32) (f : MouseCursor → IO α) : IO α := do
  let cur ← createMouseCursor bitmap xfocus yfocus
  try f cur finally destroyMouseCursor cur

-- ── State ──

/-- Create a state buffer, run `f`, then free it. -/
def withState (f : State → IO α) : IO α := do
  let s ← createState
  try f s finally destroyState s

end Allegro
