-- Path subsystem demo.
--
-- Creates, clones, and inspects Allegro path objects. Also queries
-- standard platform paths.  Console-only — no display needed.
--
-- Showcases: createPath, clonePath, pathCstr, getPathDrive,
--            getPathFilename, getPathNumComponents, getPathComponent,
--            appendPathComponent, makePathCanonical, getStandardPath,
--            standardPathResources, destroyPath.
import Allegro

open Allegro

def main : IO Unit := do
  let okInit ← Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"; return

  IO.println "── Path Demo ──"

  -- Create from string
  let p ← Allegro.createPath "/usr/local/share/games/myapp/"
  let pStr ← p.cstr 47  -- 47 = '/' separator
  IO.println s!"  created  : \"{pStr}\""

  -- Inspect components
  let n ← p.numComponents
  IO.println s!"  components ({n}):"
  for i in [:n.toNat] do
    let comp ← p.component i.toUInt32
    IO.println s!"    [{i}] \"{comp}\""

  let drive ← p.drive
  IO.println s!"  drive    : \"{drive}\""
  let fname ← p.filename
  IO.println s!"  filename : \"{fname}\""

  -- Clone and modify
  let p2 ← p.clone
  p2.append "data"
  let p2Str ← p2.cstr 47
  IO.println s!"  cloned+append : \"{p2Str}\""

  -- Make canonical
  let p3 ← Allegro.createPath "/foo/bar/../baz/./qux/"
  let _ ← p3.makeCanonical
  let p3Str ← p3.cstr 47
  IO.println s!"  canonical(\"/foo/bar/../baz/./qux/\") → \"{p3Str}\""

  -- Standard paths
  let resId ← Allegro.standardPathResources
  IO.println s!"  RESOURCES path id = {resId}"
  let stdPath ← Allegro.getStandardPath resId
  if stdPath != (0 : UInt64) then
    let sp ← stdPath.cstr 47
    IO.println s!"  resources path   = \"{sp}\""
    stdPath.destroy
  else
    IO.println "  resources path   = (not available)"

  -- Cleanup
  p3.destroy
  p2.destroy
  p.destroy
  Allegro.uninstallSystem
  IO.println "── done ──"
