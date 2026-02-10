-- VideoFileDemo — demonstrates gap-fill Video addon file-based APIs.
-- Console-only — no display needed (just tests the call paths).
--
-- Showcases: openVideoF, identifyVideoF
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.initVideoAddon
  let _ ← Allegro.installAudio
  let _ ← Allegro.initAcodecAddon

  IO.println "── Video File Demo ──"

  -- identifyVideoF — open a file and try to identify video type
  let idf ← Allegro.fopen "data/sample.ogv" "rb"
  if idf != 0 then
    let vtype ← Allegro.identifyVideoF idf
    IO.println s!"  identifyVideoF = \"{vtype}\""
  else
    IO.println "  fopen(data/sample.ogv) for identify failed — skipping"

  -- openVideoF — open a video from ALLEGRO_FILE
  let vf ← Allegro.fopen "data/sample.ogv" "rb"
  if vf != 0 then
    let video ← Allegro.openVideoF vf ".ogv"
    IO.println s!"  openVideoF = {video}"
    if video != 0 then
      let pos ← video.position Allegro.videoPositionActual
      IO.println s!"  getVideoPosition = {pos}"
      video.close
      IO.println "  closeVideo — OK"
  else
    IO.println "  fopen(data/sample.ogv) failed — skipping openVideoF"

  Allegro.uninstallAudio
  Allegro.shutdownVideoAddon
  Allegro.uninstallSystem
  IO.println "── done ──"
