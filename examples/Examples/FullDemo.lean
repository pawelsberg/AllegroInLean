import Allegro

open Allegro

def main : IO Unit := do
  Allegro.initOrFail

  Allegro.initFontAddon
  let _ ← Allegro.initTtfAddon
  let _ ← Allegro.initPrimitivesAddon
  let _ ← Allegro.initImageAddon
  let _ ← Allegro.installAudio
  let _ ← Allegro.installKeyboard
  let _ ← Allegro.installMouse

  let resPathKind ← Allegro.standardPathResources
  let path ← Allegro.getStandardPath resPathKind
  path.append "data"
  let pathStr ← path.cstr (UInt32.ofNat '\\'.toNat)
  let _ ← Allegro.changeDirectory pathStr
  path.destroy

  Allegro.setNewDisplayFlags Allegro.DisplayFlags.fullscreenWindow
  let some display ← Allegro.createDisplay? 1024 768
    | do IO.eprintln "createDisplay failed"; return

  let dw ← display.width
  let dh ← display.height
  IO.println s!"DISPLAY_WIDTH:{dw}"
  IO.println s!"DISPLAY_HEIGHT:{dh}"

  let some timer ← Allegro.createTimer? (1.0 / 60.0)
    | do IO.eprintln "createTimer failed"; return
  let eventQueue ← Allegro.createEventQueue

  eventQueue.registerSource (← display.eventSource)
  eventQueue.registerSource (← Allegro.getKeyboardEventSource)
  eventQueue.registerSource (← Allegro.getMouseEventSource)
  eventQueue.registerSource (← timer.eventSource)

  timer.start

  let event ← Allegro.createEvent

  let mut running := true
  while running do
    eventQueue.waitFor event
    let evType ← event.type
    if evType == EventType.keyDown then
      let key ← event.keyboardKeycode
      IO.println s!"KEY_DOWN:{key.val}"
    else if evType == EventType.keyUp then
      let key ← event.keyboardKeycode
      IO.println s!"KEY_UP:{key.val}"
    else if evType == EventType.displayClose then
      running := false
    else if evType == EventType.mouseAxes then
      let mx ← event.mouseX
      let my ← event.mouseY
      IO.println s!"MOUSE_AXES:{mx},{my}"
    else if evType == EventType.mouseButtonDown then
      let btn ← event.mouseButton
      IO.println s!"MOUSE_BUTTON_DOWN:{btn}"
    else if evType == EventType.mouseButtonUp then
      let btn ← event.mouseButton
      IO.println s!"MOUSE_BUTTON_UP:{btn}"
    else if evType == EventType.timer then
      Allegro.flipDisplay

  event.destroy
  eventQueue.destroy
  timer.destroy
  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownFontAddon
  Allegro.shutdownImageAddon
  Allegro.uninstallSystem
