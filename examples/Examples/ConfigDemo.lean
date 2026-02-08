-- Config subsystem demo.
--
-- Creates a config, populates it with sections and keys, saves it to
-- a temporary file, reloads it, and prints the values.  No display needed.
--
-- Showcases: createConfig, setConfigValue, getConfigValue, saveConfigFile,
--            loadConfigFile, addConfigSection, getConfigSections,
--            getConfigEntries, mergeConfig, destroyConfig.
import Allegro

open Allegro

def main : IO Unit := do
  let okInit ← Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"; return

  IO.println "── Config Demo ──"

  -- Create a fresh config and populate it
  let cfg ← Allegro.createConfig
  cfg.setValue "" "title" "My Lean Game"
  cfg.setValue "" "version" "0.1.0"
  cfg.addSection "video"
  cfg.setValue "video" "width" "1280"
  cfg.setValue "video" "height" "720"
  cfg.setValue "video" "fullscreen" "false"
  cfg.addSection "audio"
  cfg.setValue "audio" "volume" "80"

  -- Read back and print
  let title ← cfg.getValue "" "title"
  IO.println s!"  title     = {title}"
  let width ← cfg.getValue "video" "width"
  let height ← cfg.getValue "video" "height"
  IO.println s!"  video     = {width}×{height}"
  let vol ← cfg.getValue "audio" "volume"
  IO.println s!"  volume    = {vol}"

  -- List sections
  let sections ← cfg.sections
  IO.println s!"  sections  = {sections}"

  -- List keys in [video]
  let videoKeys ← cfg.entries "video"
  IO.println s!"  video keys = {videoKeys}"

  -- Save, then reload
  let tmpFile := "/tmp/allegro_config_demo.cfg"
  let ok ← cfg.save tmpFile
  IO.println s!"  saved → {tmpFile} (ok={ok})"
  cfg.destroy

  let cfg2 ← Allegro.loadConfigFile tmpFile
  if cfg2 == (0 : UInt64) then
    IO.eprintln "  loadConfigFile failed"; return
  let title2 ← cfg2.getValue "" "title"
  IO.println s!"  reloaded title = {title2}"

  -- Merge demo: override width
  let patch ← Allegro.createConfig
  patch.setValue "video" "width" "1920"
  let merged ← cfg2.merge patch
  let newW ← merged.getValue "video" "width"
  IO.println s!"  merged width   = {newW}"

  patch.destroy
  merged.destroy
  cfg2.destroy
  Allegro.uninstallSystem
  IO.println "── done ──"
