import Allegro

open Allegro

def main : IO Unit := do
  let okInit <- Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"
    return

  let okAudio <- Allegro.installAudio
  if okAudio == 0 then
    IO.eprintln "al_install_audio failed"

  let okAcodec <- Allegro.initAcodecAddon
  if okAcodec == 0 then
    IO.eprintln "al_init_acodec_addon failed"

  let _ <- Allegro.reserveSamples 1
  let sample <- Allegro.loadSample "data/beep.wav"
  if sample == 0 then
    IO.eprintln "audio sample not found: data/beep.wav"
  else
    let _ <- sample.play 1.0 0.0 1.0 0
    Allegro.rest 0.5
    sample.destroy

  Allegro.uninstallAudio
  Allegro.uninstallSystem
