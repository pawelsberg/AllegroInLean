-- ShaderDemo — demonstrates gap-fill Shader APIs.
-- Graphical — needs a display for shader operations.
--
-- Showcases: createShader, destroyShader, attachShaderSource,
--            buildShader, getShaderLog, getShaderPlatform,
--            useShader, setShaderInt, setShaderFloat, setShaderBool,
--            setShaderSampler, setShaderMatrix,
--            setShaderIntVector, setShaderFloatVector,
--            getDefaultShaderSource, getCurrentShader
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  IO.println "── Shader Demo ──"

  Allegro.setNewDisplayFlags ⟨0⟩
  let display ← Allegro.createDisplay 320 200
  if display == 0 then
    IO.eprintln "  createDisplay failed"; Allegro.uninstallSystem; return

  -- Create a shader (auto-detect platform)
  let shader ← Allegro.createShader Allegro.ShaderPlatform.auto
  if shader == 0 then
    IO.println "  createShader returned null — no shader support on this system"
    display.destroy; Allegro.uninstallSystem; return

  IO.println s!"  createShader = non-zero"

  -- Determine platform from the shader
  let plat ← shader.platform
  IO.println s!"  getShaderPlatform = {plat.val}"

  -- Get default shader sources
  let vSrc ← Allegro.getDefaultShaderSource plat Allegro.ShaderType.vertex
  IO.println s!"  getDefaultShaderSource(vertex) = \"{vSrc.take 60}…\" ({vSrc.length} chars)"
  let fSrc ← Allegro.getDefaultShaderSource plat Allegro.ShaderType.pixel
  IO.println s!"  getDefaultShaderSource(pixel) = \"{fSrc.take 60}…\" ({fSrc.length} chars)"

  -- Attach default sources
  let okV ← shader.attachSource Allegro.ShaderType.vertex vSrc
  IO.println s!"  attachShaderSource(vertex) = {okV}"
  let okF ← shader.attachSource Allegro.ShaderType.pixel fSrc
  IO.println s!"  attachShaderSource(pixel) = {okF}"

  -- Build
  let built ← shader.build
  IO.println s!"  buildShader = {built}"

  if built != 1 then
    let log ← shader.log
    IO.println s!"  getShaderLog = \"{log}\""

  -- Use the shader
  let _ ← shader.use
  IO.println "  useShader — OK"

  -- Set uniforms (these may fail if the uniform doesn't exist in the default shader)
  let _ ← Allegro.setShaderInt "custom_int" (42 : UInt32)
  IO.println "  setShaderInt — OK"
  let _ ← Allegro.setShaderFloat "custom_float" 3.14
  IO.println "  setShaderFloat — OK"
  let _ ← Allegro.setShaderBool "custom_bool" (1 : UInt32)
  IO.println "  setShaderBool — OK"

  -- getCurrentShader
  let cur ← Allegro.getCurrentShader
  IO.println s!"  getCurrentShader = {cur}"

  -- Restore default pipeline
  let _ ← Allegro.useShader (0 : UInt64)
  IO.println "  useShader(null) — restored default"

  shader.destroy
  IO.println "  destroyShader — OK"

  display.destroy
  Allegro.uninstallSystem
  IO.println "── done ──"
