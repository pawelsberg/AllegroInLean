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

  Allegro.initFontAddon

  let okTtf <- Allegro.initTtfAddon
  if okTtf == 0 then
    IO.eprintln "al_init_ttf_addon failed"

  let okPrim <- Allegro.initPrimitivesAddon
  if okPrim == 0 then
    IO.eprintln "al_init_primitives_addon failed"

  let okAudio <- Allegro.installAudio
  if okAudio == 0 then
    IO.eprintln "al_install_audio failed (non-fatal in headless CI)"

  if okAudio != 0 then
    let okAcodec <- Allegro.initAcodecAddon
    if okAcodec == 0 then
      IO.eprintln "al_init_acodec_addon failed"
    let _ <- Allegro.reserveSamples 1
    pure ()

  -- On macOS / Cocoa the display and mouse driver use
  -- dispatch_sync(dispatch_get_main_queue()) which deadlocks when
  -- called from the main thread without a Cocoa run loop.
  -- The C shims return 0 in that case; we handle it gracefully.
  let display : Display <- Allegro.createDisplay 320 200
  if display == 0 then
    IO.eprintln "createDisplay failed (non-fatal in headless CI)"

  let okKb <- Allegro.installKeyboard
  if okKb == 0 then
    IO.eprintln "al_install_keyboard failed"

  let okMouse <- Allegro.installMouse
  if okMouse == 0 then
    IO.eprintln "al_install_mouse failed (non-fatal in headless CI)"

  if display != 0 then
    let timer : Timer <- Allegro.createTimer (1.0 / 60.0)
    let queue : EventQueue <- Allegro.createEventQueue
    let displaySource <- display.eventSource
    let timerSource <- timer.eventSource
    queue.registerSource displaySource
    queue.registerSource timerSource
    let event : Event <- Allegro.createEvent

    event.destroy
    queue.destroy
    timer.destroy
    display.destroy

  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownTtfAddon
  Allegro.shutdownFontAddon
  Allegro.shutdownImageAddon
  if okAudio != 0 then
    Allegro.uninstallAudio
  Allegro.uninstallSystem
  IO.println "ok"
