import Allegro

open Allegro

def main : IO Unit := do
  let okInit <- Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"
    return

  let flags := Allegro.DisplayFlags.fullscreenWindow
  Allegro.setNewDisplayFlags flags
  let _ <- Allegro.createDisplay 1024 768

  let display <- Allegro.getCurrentDisplay
  let timer <- Allegro.createTimer (1.0 / 60.0)
  let queue <- Allegro.createEventQueue
  let displaySource <- display.eventSource
  let timerSource <- timer.eventSource

  queue.registerSource displaySource
  queue.registerSource timerSource
  timer.start

  let evDisplayClose := Allegro.EventType.displayClose
  let evTimer := Allegro.EventType.timer
  let event <- Allegro.createEvent

  while true do
    queue.waitFor event
    let evType <- event.type
    if evType == evDisplayClose then
      break
    else if evType == evTimer then
      Allegro.flipDisplay

  event.destroy
  queue.destroy
  timer.destroy
  display.destroy
  Allegro.uninstallSystem
