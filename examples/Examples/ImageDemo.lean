import Allegro

open Allegro

def main : IO Unit := do
  let okInit <- Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"
    return

  let okImage <- Allegro.initImageAddon
  if okImage == 0 then
    IO.eprintln "al_init_image_addon failed"

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

  let bmp <- Allegro.loadBitmap "data/sample.png"
  let hasBmp := bmp != 0
  if !hasBmp then
    IO.eprintln "image not found: data/sample.png"

  while true do
    queue.waitFor event
    let evType <- event.type
    if evType == evDisplayClose then
      break
    else if evType == evTimer then
      Allegro.clearToColorRgb 20 20 20
      if hasBmp then
        bmp.draw 100 80 0
      Allegro.flipDisplay

  if hasBmp then
    bmp.destroy
  event.destroy
  queue.destroy
  timer.destroy
  display.destroy
  Allegro.shutdownImageAddon
  Allegro.uninstallSystem
