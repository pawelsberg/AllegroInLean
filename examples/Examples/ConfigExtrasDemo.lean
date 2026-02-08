-- ConfigExtrasDemo — demonstrates gap-fill Config file-handle APIs.
-- Console-only — no display needed.
--
-- Showcases: loadConfigFileF, saveConfigFileF
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  IO.println "── Config Extras Demo ──"

  -- Create a config, populate it
  let cfg ← Allegro.createConfig
  if cfg == 0 then IO.eprintln "  createConfig failed"; Allegro.uninstallSystem; return

  cfg.setValue "video" "width" "1920"
  cfg.setValue "video" "height" "1080"
  cfg.setValue "audio" "volume" "75"
  IO.println "  Created config with [video] and [audio] sections"

  -- saveConfigFileF — save to an ALLEGRO_FILE
  let fw ← Allegro.fopen "/tmp/allegro_config_demo.ini" "w"
  if fw != 0 then
    let saved ← Allegro.saveConfigFileF fw cfg
    IO.println s!"  saveConfigFileF = {saved}"
    -- Note: fclose not needed — saveConfigFileF closes the file
  else
    IO.println "  fopen for write failed"

  cfg.destroy

  -- loadConfigFileF — reload from ALLEGRO_FILE
  let fr ← Allegro.fopen "/tmp/allegro_config_demo.ini" "r"
  if fr != 0 then
    let cfg2 ← Allegro.loadConfigFileF fr
    -- Note: fclose not needed — loadConfigFileF closes the file
    if cfg2 != 0 then
      let w ← cfg2.getValue "video" "width"
      let v ← cfg2.getValue "audio" "volume"
      IO.println s!"  loadConfigFileF → video.width = \"{w}\", audio.volume = \"{v}\""
      cfg2.destroy
    else
      IO.println "  loadConfigFileF returned null"
  else
    IO.println "  fopen for read failed"

  Allegro.uninstallSystem
  IO.println "── done ──"
