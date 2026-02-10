import Allegro

open Allegro

def main : IO Unit := do
  let okInit <- Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"
    return

  let okKb <- Allegro.installKeyboard
  if okKb == 0 then
    IO.eprintln "al_install_keyboard failed"

  let okMouse <- Allegro.installMouse
  if okMouse == 0 then
    IO.eprintln "al_install_mouse failed"

  let _ <- Allegro.createDisplay 640 480
  let display <- Allegro.getCurrentDisplay
  let timer <- Allegro.createTimer (1.0 / 60.0)
  let queue <- Allegro.createEventQueue
  let displaySource <- display.eventSource
  let keyboardSource <- Allegro.getKeyboardEventSource
  let mouseSource <- Allegro.getMouseEventSource
  let timerSource <- timer.eventSource

  queue.registerSource displaySource
  queue.registerSource keyboardSource
  queue.registerSource mouseSource
  queue.registerSource timerSource
  timer.start

  let evDisplayClose := Allegro.EventType.displayClose
  let evKeyDown := Allegro.EventType.keyDown
  let evMouseButtonDown := Allegro.EventType.mouseButtonDown
  let evTimer := Allegro.EventType.timer
  let event <- Allegro.createEvent

  while true do
    queue.waitFor event
    let evType <- event.type
    if evType == evDisplayClose then
      break
    else if evType == evKeyDown then
      let key <- event.keyboardKeycode
      IO.println s!"KEY_DOWN:{key}"
    else if evType == evMouseButtonDown then
      let btn <- event.mouseButton
      IO.println s!"MOUSE_BUTTON_DOWN:{btn}"
    else if evType == evTimer then
      pure ()

  event.destroy
  queue.destroy
  timer.destroy
  display.destroy
  Allegro.uninstallSystem
