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

  let _ <- Allegro.createDisplay 640 200
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

  let font : Font <- Allegro.loadTtfFont "data/DejaVuSans.ttf" 24 0
  let hasFont := font != 0
  if !hasFont then
    IO.eprintln "ttf not found: data/DejaVuSans.ttf"

  while true do
    queue.waitFor event
    let evType <- event.type
    if evType == evDisplayClose then
      break
    else if evType == evTimer then
      Allegro.clearToColorRgb 20 10 10
      if hasFont then
        font.drawTextRgb 255 255 0 20 80 TextAlign.left "Hello from Allegro TTF"
      Allegro.flipDisplay

  if hasFont then
    font.destroy
  event.destroy
  queue.destroy
  timer.destroy
  display.destroy
  Allegro.shutdownTtfAddon
  Allegro.shutdownFontAddon
  Allegro.uninstallSystem
