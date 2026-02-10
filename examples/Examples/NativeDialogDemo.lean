-- Native Dialog addon demo.
--
-- Exercises: message box, text log, and file chooser.
-- Requires GTK 3 on Linux. The Allegro native dialog library must be available.
--
-- On Wayland sessions, run with:  GDK_BACKEND=x11 lake exe allegroNativeDialogDemo
--
-- Showcases: initNativeDialogAddon, showNativeMessageBox,
--            openNativeTextLog, appendNativeTextLog, closeNativeTextLog,
--            createNativeFileDialog, showNativeFileDialog,
--            getNativeFileDialogCount, getNativeFileDialogPath,
--            destroyNativeFileDialog.
import Allegro

open Allegro

def main : IO Unit := do
  let okInit ← Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"; return

  let okDialog ← initNativeDialogAddon
  if okDialog == 0 then
    IO.eprintln "initNativeDialogAddon failed"; return

  let ver ← getNativeDialogVersion
  IO.println s!"Native dialog addon version: {ver}"

  -- ── Text log ──
  IO.println "Opening text log window..."
  let tl ← openNativeTextLog "AllegroInLean Text Log" TextLogFlags.monospace
  if (tl : UInt64) == 0 then
    IO.eprintln "openNativeTextLog failed"
  else
    tl.append "Hello from AllegroInLean!\n"
    tl.append s!"Native dialog version: {ver}\n"
    tl.append "This window uses a monospace font.\n"
    tl.append "Closing in a moment...\n"
    -- Short delay so the user can see the log
    IO.sleep 10000
    tl.close
    IO.println "Text log closed."

  -- ── Message box (no display parent) ──
  IO.println "Showing message box..."
  let btn ← showNativeMessageBox (0 : Display) "AllegroInLean"
    "Native Dialog Demo" "This is a test message box.\nClick OK to continue."
    "" MessageBoxFlags.none
  IO.println s!"Message box returned: {btn}"

  -- ── File chooser ──
  IO.println "Creating a file chooser dialog..."
  -- Create a small display so the file chooser has a parent window
  setNewDisplayFlags ⟨0⟩
  let display ← createDisplay 320 240
  if (display : UInt64) == 0 then
    IO.eprintln "createDisplay failed for file chooser parent"
  else
    let fc ← createNativeFileDialog "" "Select a file" "*.*" FileChooserFlags.fileMustExist
    if (fc : UInt64) == 0 then
      IO.eprintln "createNativeFileDialog failed"
    else
      let ok ← fc.present display
      if ok == 1 then
        let count ← fc.count
        IO.println s!"Files selected: {count}"
        for i in List.range count.toNat do
          let path ← fc.path i.toUInt32
          IO.println s!"  [{i}] {path}"
      else
        IO.println "File chooser was cancelled."
      fc.destroy
    display.destroy

  shutdownNativeDialogAddon
  IO.println "Done."
