import Allegro

open Allegro

def main : IO Unit := do
  let okInit <- Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"
    return

  let okPrim <- Allegro.initPrimitivesAddon
  if okPrim == 0 then
    IO.eprintln "al_init_primitives_addon failed"

  let _ <- Allegro.createDisplay 640 480
  let display <- Allegro.getCurrentDisplay
  let timer <- Allegro.createTimer (1.0 / 60.0)
  let queue <- Allegro.createEventQueue
  let displaySource <- display.eventSource
  let timerSource <- timer.eventSource
  queue.registerSource displaySource
  queue.registerSource timerSource
  timer.start

  let evDisplayClose := Allegro.eventTypeDisplayClose
  let evTimer := Allegro.eventTypeTimer
  let event <- Allegro.createEvent

  while true do
    queue.waitFor event
    let evType <- event.type
    if evType == evDisplayClose then
      break
    else if evType == evTimer then
      Allegro.clearToColorRgb 5 5 5
      Allegro.drawLineRgb 20 20 620 20 255 255 255 2
      Allegro.drawRectangleRgb 40 60 200 180 0 200 255 2
      Allegro.drawFilledRectangleRgb 260 60 420 180 20 160 80
      Allegro.drawCircleRgb 120 320 60 200 50 50 2
      Allegro.drawFilledCircleRgb 320 320 50 50 200 50
      Allegro.drawTriangleRgb 420 260 600 300 520 420 255 200 0 2
      Allegro.flipDisplay

  event.destroy
  queue.destroy
  timer.destroy
  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.uninstallSystem
