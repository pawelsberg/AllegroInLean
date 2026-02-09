import Allegro

open Allegro

def main : IO Unit := do
  IO.eprintln "[smoke:1] init"
  let okInit <- Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"
    return

  IO.eprintln "[smoke:2] initImageAddon"
  let okImage <- Allegro.initImageAddon
  if okImage == 0 then
    IO.eprintln "al_init_image_addon failed"

  IO.eprintln "[smoke:3] initFontAddon"
  Allegro.initFontAddon

  IO.eprintln "[smoke:4] initTtfAddon"
  let okTtf <- Allegro.initTtfAddon
  if okTtf == 0 then
    IO.eprintln "al_init_ttf_addon failed"

  IO.eprintln "[smoke:5] initPrimitivesAddon"
  let okPrim <- Allegro.initPrimitivesAddon
  if okPrim == 0 then
    IO.eprintln "al_init_primitives_addon failed"

  IO.eprintln "[smoke:6] installAudio"
  let okAudio <- Allegro.installAudio
  if okAudio == 0 then
    IO.eprintln "al_install_audio failed (non-fatal in headless CI)"

  if okAudio != 0 then
    IO.eprintln "[smoke:7] initAcodecAddon"
    let okAcodec <- Allegro.initAcodecAddon
    if okAcodec == 0 then
      IO.eprintln "al_init_acodec_addon failed"
    let _ <- Allegro.reserveSamples 1
    pure ()

  IO.eprintln "[smoke:8] createDisplay"
  let display : Display <- Allegro.createDisplay 320 200
  if display == 0 then
    IO.eprintln "createDisplay failed (non-fatal in headless CI)"

  IO.eprintln "[smoke:9] installKeyboard"
  let okKb <- Allegro.installKeyboard
  if okKb == 0 then
    IO.eprintln "al_install_keyboard failed"

  IO.eprintln "[smoke:10] installMouse"
  let okMouse <- Allegro.installMouse
  if okMouse == 0 then
    IO.eprintln "al_install_mouse failed (non-fatal in headless CI)"

  IO.eprintln "[smoke:11] event loop"
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

  IO.eprintln "[smoke:12] shutdown"
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownTtfAddon
  Allegro.shutdownFontAddon
  Allegro.shutdownImageAddon
  if okAudio != 0 then
    Allegro.uninstallAudio
  Allegro.uninstallSystem
  IO.println "ok"
