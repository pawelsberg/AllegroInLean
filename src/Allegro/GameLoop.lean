import Allegro.Core
import Allegro.Addons
import Allegro.Resource

/-!
# High-Level Game Loop Combinator

Eliminates the ~35 lines of boilerplate that every game/demo repeats:
create timer → create event queue → register sources → `while running do
queue.waitFor …` → check `queue.isEmpty` before redraw → cleanup in reverse order.

## Example
```
Allegro.runGameLoop { width := 800, height := 600, fps := 60.0 } (fun _display => do
    return { playerX := 400.0, playerY := 300.0 }
  )
  (fun state event => do
    match event with
    | .tick => return { state with playerX := state.playerX + 1.0 }
    | .keyDown kc => if kc == Allegro.KeyCode.escape then return none else return some state
    | .quit => return none
    | _ => return some state
  )
  (fun state display => do
    Allegro.clearToColorRgb 0 0 0
    Allegro.drawFilledCircleRgb state.playerX state.playerY 10.0 255 255 0
    Allegro.flipDisplay
  )
```
-/
namespace Allegro

/-- Addons to initialise automatically. -/
inductive AddonFlag where
  | primitives
  | image
  | font
  | ttf
  | audio
  | acodec
  | keyboard
  | mouse
  | joystick
  | nativeDialogs
  deriving BEq, Repr

/-- Configuration for `runGameLoop`. All fields have sensible defaults. -/
structure GameConfig where
  /-- Display width in pixels. -/
  width        : UInt32 := 640
  /-- Display height in pixels. -/
  height       : UInt32 := 480
  /-- Target frames per second. -/
  fps          : Float  := 60.0
  /-- Addons to initialise. -/
  initAddons   : List AddonFlag := [.primitives, .font, .image, .keyboard, .mouse]
  /-- Window title. -/
  windowTitle  : String := "Allegro Game"
  deriving Repr

/-- Events delivered to the game's event handler. -/
inductive GameEvent where
  /-- A timer tick (update game state). -/
  | tick
  /-- A key was pressed. -/
  | keyDown (key : KeyCode)
  /-- A key was released. -/
  | keyUp (key : KeyCode)
  /-- A character was typed (KEY_CHAR event). -/
  | keyChar (key : KeyCode) (unichar : UInt32)
  /-- Mouse moved to position (x, y). -/
  | mouseMove (x y : Float)
  /-- Mouse button pressed. -/
  | mouseDown (button : UInt32) (x y : Float)
  /-- Mouse button released. -/
  | mouseUp (button : UInt32) (x y : Float)
  /-- Display close button pressed. -/
  | quit
  /-- Display was resized. -/
  | resize (w h : UInt32)
  /-- An event not covered by the above variants; provides the raw event type. -/
  | other (evType : EventType)
  deriving Repr

private def initAddon (flag : AddonFlag) : IO Unit := do
  match flag with
  | .primitives    => let _ ← initPrimitivesAddon; pure ()
  | .image         => let _ ← initImageAddon; pure ()
  | .font          => let _ ← initFontAddon; pure ()
  | .ttf           => let _ ← initTtfAddon; pure ()
  | .audio         => let _ ← installAudio; let _ ← initAcodecAddon; let _ ← reserveSamples 16; pure ()
  | .acodec        => let _ ← initAcodecAddon; pure ()
  | .keyboard      => let _ ← installKeyboard; pure ()
  | .mouse         => let _ ← installMouse; pure ()
  | .joystick      => let _ ← installJoystick; pure ()
  | .nativeDialogs => let _ ← initNativeDialogAddon; pure ()

/-- Run a game loop with automatic setup and teardown.

    - `cfg`: game configuration (display size, fps, addons)
    - `initState`: called with the display handle to create the initial game state
    - `onEvent`: called for each event; return `some newState` to continue or `none` to quit
    - `draw`: called once per frame after all events are processed

    All Allegro resources (display, timer, event queue) are managed automatically. -/
def runGameLoop (cfg : GameConfig)
    (initState : Display → IO σ)
    (onEvent : σ → GameEvent → IO (Option σ))
    (draw : σ → Display → IO Unit) : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then
    IO.eprintln "Allegro.init failed"
    return
  -- Initialise requested addons
  for flag in cfg.initAddons do
    initAddon flag
  withDisplay cfg.width cfg.height fun display => do
    setWindowTitle display cfg.windowTitle
    withTimer (1.0 / cfg.fps) fun timer => do
      withEventQueue fun queue => do
        let dispSrc ← getDisplayEventSource display
        registerEventSource queue dispSrc
        let timerSrc ← getTimerEventSource timer
        registerEventSource queue timerSrc
        -- Register keyboard/mouse if initialised
        let kbInstalled ← isKeyboardInstalled
        if kbInstalled != 0 then
          let kbSrc ← getKeyboardEventSource
          registerEventSource queue kbSrc
        let msInstalled ← isMouseInstalled
        if msInstalled != 0 then
          let msSrc ← getMouseEventSource
          registerEventSource queue msSrc
        startTimer timer
        let mut state ← initState display
        let mut running := true
        let mut redraw := false
        while running do
          let evData ← waitForEventData queue
          let gameEvent ←
            if evData.type == EventType.displayClose then
              pure GameEvent.quit
            else if evData.type == EventType.timer then
              pure GameEvent.tick
            else if evData.type == EventType.keyDown then
              pure (GameEvent.keyDown ⟨evData.a⟩)
            else if evData.type == EventType.keyUp then
              pure (GameEvent.keyUp ⟨evData.a⟩)
            else if evData.type == EventType.keyChar then
              pure (GameEvent.keyChar ⟨evData.a⟩ evData.b)
            else if evData.type == EventType.mouseAxes then
              let xf := Float.ofScientific evData.a.toNat false 0
              let yf := Float.ofScientific evData.b.toNat false 0
              pure (GameEvent.mouseMove xf yf)
            else if evData.type == EventType.mouseButtonDown then
              let xf := Float.ofScientific evData.a.toNat false 0
              let yf := Float.ofScientific evData.b.toNat false 0
              pure (GameEvent.mouseDown evData.i xf yf)
            else if evData.type == EventType.mouseButtonUp then
              let xf := Float.ofScientific evData.a.toNat false 0
              let yf := Float.ofScientific evData.b.toNat false 0
              pure (GameEvent.mouseUp evData.i xf yf)
            else if evData.type == EventType.displayResize then
              let _ ← acknowledgeResize display
              pure (GameEvent.resize evData.c evData.d)
            else
              pure (GameEvent.other evData.type)
          match gameEvent with
          | GameEvent.tick => redraw := true; state ← match ← onEvent state gameEvent with
              | some s => pure s
              | none => do running := false; pure state
          | GameEvent.quit => running := false
          | _ => state ← match ← onEvent state gameEvent with
              | some s => pure s
              | none => do running := false; pure state
          -- Draw when queue is empty and we have a pending tick
          if redraw then
            let empty ← isEventQueueEmpty queue
            if empty != 0 then
              redraw := false
              draw state display

end Allegro
