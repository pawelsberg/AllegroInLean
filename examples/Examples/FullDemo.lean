import Allegro

open Allegro

def main : IO Unit := do
  let okInit <- Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"
    return

  Allegro.initFontAddon
  let okTtf <- Allegro.initTtfAddon
  if okTtf == 0 then
    IO.eprintln "al_init_ttf_addon failed"
    return

  let okPrim <- Allegro.initPrimitivesAddon
  if okPrim == 0 then
    IO.eprintln "al_init_primitives_addon failed"
    return

  let okImage <- Allegro.initImageAddon
  if okImage == 0 then
    IO.eprintln "al_init_image_addon failed"
    return

  let okAudio <- Allegro.installAudio
  if okAudio == 0 then
    IO.eprintln "al_install_audio failed"

  let okKb <- Allegro.installKeyboard
  if okKb == 0 then
    IO.eprintln "al_install_keyboard failed"

  let okMouse <- Allegro.installMouse
  if okMouse == 0 then
    IO.eprintln "al_install_mouse failed"

  let resPathKind <- Allegro.standardPathResources
  let path <- Allegro.getStandardPath resPathKind
  path.append "data"
  let pathStr <- path.cstr (UInt32.ofNat '\\'.toNat)
  let _ <- Allegro.changeDirectory pathStr
  path.destroy

  let flags := Allegro.fullscreenWindowFlag
  Allegro.setNewDisplayFlags flags
  let _ <- Allegro.createDisplay 1024 768

  let display : Display <- Allegro.getCurrentDisplay
  let dw <- display.width
  let dh <- display.height
  IO.println s!"DISPLAY_WIDTH:{dw}"
  IO.println s!"DISPLAY_HEIGHT:{dh}"

  let timer <- Allegro.createTimer (1.0 / 60.0)
  let eventQueue <- Allegro.createEventQueue
  let displaySource <- display.eventSource
  let keyboardSource <- Allegro.getKeyboardEventSource
  let mouseSource <- Allegro.getMouseEventSource
  let timerSource <- timer.eventSource

  eventQueue.registerSource displaySource
  eventQueue.registerSource keyboardSource
  eventQueue.registerSource mouseSource
  eventQueue.registerSource timerSource

  timer.start

  let evKeyDown := Allegro.eventTypeKeyDown
  let evKeyUp := Allegro.eventTypeKeyUp
  let evDisplayClose := Allegro.eventTypeDisplayClose
  let evMouseAxes := Allegro.eventTypeMouseAxes
  let evMouseButtonDown := Allegro.eventTypeMouseButtonDown
  let evMouseButtonUp := Allegro.eventTypeMouseButtonUp
  let evTimer := Allegro.eventTypeTimer

  let event <- Allegro.createEvent

  let loopBody : IO Bool := do
    eventQueue.waitFor event
    let evType <- event.type
    if evType == evKeyDown then
      let key <- event.keyboardKeycode
      IO.println s!"KEY_DOWN:{key}"
      pure false
    else if evType == evKeyUp then
      let key <- event.keyboardKeycode
      IO.println s!"KEY_UP:{key}"
      pure false
    else if evType == evDisplayClose then
      pure true
    else if evType == evMouseAxes then
      let mx <- event.mouseX
      let my <- event.mouseY
      IO.println s!"MOUSE_AXES:{mx},{my}"
      pure false
    else if evType == evMouseButtonDown then
      let btn <- event.mouseButton
      IO.println s!"MOUSE_BUTTON_DOWN:{btn}"
      pure false
    else if evType == evMouseButtonUp then
      let btn <- event.mouseButton
      IO.println s!"MOUSE_BUTTON_UP:{btn}"
      pure false
    else if evType == evTimer then
      Allegro.flipDisplay
      pure false
    else
      pure false

  while true do
    let shouldExit <- loopBody
    if shouldExit then
      break

  event.destroy
  eventQueue.destroy
  timer.destroy
  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownFontAddon
  Allegro.shutdownImageAddon
  Allegro.uninstallSystem
