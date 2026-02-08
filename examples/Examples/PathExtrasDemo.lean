-- PathExtrasDemo — demonstrates gap-fill Path APIs.
-- Console-only — no display needed.
--
-- Showcases: createPathForDirectory, insertPathComponent,
--            removePathComponent, replacePathComponent, getPathTail,
--            dropPathTail, joinPaths, rebasePath, pathUstr,
--            setPathDrive, setPathFilename, getPathExtension,
--            setPathExtension, getPathBasename
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  IO.println "── Path Extras Demo ──"

  -- createPathForDirectory — creates a path with trailing separator
  let dir ← Allegro.createPathForDirectory "/usr/local/share/"
  if dir != 0 then
    let s ← dir.cstr (0x2F : UInt32)
    IO.println s!"  createPathForDirectory = \"{s}\""

    -- insertPathComponent at index 0
    dir.insertComponent (0 : UInt32) "opt"
    let s2 ← dir.cstr (0x2F : UInt32)
    IO.println s!"  insertPathComponent(0, \"opt\") = \"{s2}\""

    -- replacePathComponent at index 0
    dir.replaceComponent (0 : UInt32) "var"
    let s3 ← dir.cstr (0x2F : UInt32)
    IO.println s!"  replacePathComponent(0, \"var\") = \"{s3}\""

    -- getPathTail
    let tail ← dir.tail
    IO.println s!"  getPathTail = \"{tail}\""

    -- dropPathTail
    dir.dropTail
    let s4 ← dir.cstr (0x2F : UInt32)
    IO.println s!"  dropPathTail → \"{s4}\""

    -- removePathComponent
    dir.removeComponent (0 : UInt32)
    let s5 ← dir.cstr (0x2F : UInt32)
    IO.println s!"  removePathComponent(0) → \"{s5}\""

    dir.destroy

  -- Path manipulation: drive, filename, extension
  let p ← Allegro.createPath "/home/user/document.txt"
  if p != 0 then
    -- setPathDrive (Linux: usually empty, Windows: "C:")
    p.setDrive "D:"
    let drv ← p.drive
    IO.println s!"  setPathDrive(\"D:\") → getPathDrive = \"{drv}\""

    -- setPathFilename
    p.setFilename "readme.md"
    let fn ← p.filename
    IO.println s!"  setPathFilename(\"readme.md\") → getPathFilename = \"{fn}\""

    -- getPathExtension / setPathExtension
    let ext ← p.extension
    IO.println s!"  getPathExtension = \"{ext}\""
    let ok2 ← p.setExtension ".rst"
    IO.println s!"  setPathExtension(\".rst\") = {ok2}"
    let ext2 ← p.extension
    IO.println s!"  getPathExtension after set = \"{ext2}\""

    -- getPathBasename (filename without extension)
    let base ← p.basename
    IO.println s!"  getPathBasename = \"{base}\""

    -- pathUstr — get the path as a USTR handle (sep char 0x2F = '/')
    let ustr ← p.ustr (0x2F : UInt32)
    IO.println s!"  pathUstr = {ustr} (non-zero expected)"

    p.destroy

  -- joinPaths / rebasePath
  let basePath ← Allegro.createPath "/home/user/"
  let rel  ← Allegro.createPath "docs/file.txt"
  if basePath != 0 && rel != 0 then
    let j ← basePath.join rel
    IO.println s!"  joinPaths = {j}"
    let js ← basePath.cstr (0x2F : UInt32)
    IO.println s!"  after join: \"{js}\""

    -- rebasePath
    let base2 ← Allegro.createPath "/opt/"
    let rel2  ← Allegro.createPath "lib/foo.so"
    if base2 != 0 && rel2 != 0 then
      let r ← base2.rebase rel2
      IO.println s!"  rebasePath = {r}"
      let rs ← rel2.cstr (0x2F : UInt32)
      IO.println s!"  after rebase: \"{rs}\""
      base2.destroy
      rel2.destroy

    basePath.destroy
    rel.destroy

  Allegro.uninstallSystem
  IO.println "── done ──"
