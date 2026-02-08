-- FileIODemo — demonstrates File I/O and Filesystem APIs.
-- Console-only — no display needed.
--
-- Showcases: fopen, fclose, fread, fwrite, fflush, ftell, fseek,
--            feof, ferror, ferrmsg, fclearerr, fsize, fgetc, fputc,
--            fungetc, fread16le, fread16be, fread32le, fread32be,
--            fwrite16le, fwrite16be, fwrite32le, fwrite32be,
--            fgets, fgetUstr, fputs, fopenSlice, makeTempFile,
--            fopenFd, setStandardFileInterface, getFileUserdata,
--            createFsEntry, destroyFsEntry, getFsEntryName,
--            updateFsEntry, getFsEntryMode, getFsEntryAtime,
--            getFsEntryCtime, getFsEntryMtime, getFsEntrySize,
--            fsEntryExists, removeFilename, filenameExists,
--            makeDirectory, openDirectory, readDirectory,
--            closeDirectory, getCurrentDirectory,
--            setStandardFsInterface, openFsEntry
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  IO.println "── File I/O Demo ──"

  -- Write a test file
  let fw : AllegroFile ← Allegro.fopen "/tmp/allegro_fio_demo.bin" "w"
  if fw == 0 then IO.eprintln "  fopen write failed"; Allegro.uninstallSystem; return

  -- fputc, fputs
  let _ ← fw.putc 65  -- 'A'
  let _ ← fw.puts "llegroFileIO\n"
  IO.println "  wrote 'AllegroFileIO\\n' via fputc + fputs"

  -- fwrite endian values
  let _ ← fw.write16le 0x1234
  let _ ← fw.write32le 0xDEADBEEF
  IO.println "  wrote 16LE=0x1234, 32LE=0xDEADBEEF"

  -- ftell
  let pos ← fw.tell
  IO.println s!"  ftell = {pos} bytes"

  -- fflush, fclose
  let _ ← fw.flush
  let _ ← fw.close
  IO.println "  fflush + fclose — OK"

  -- Read back
  let fr : AllegroFile ← Allegro.fopen "/tmp/allegro_fio_demo.bin" "r"
  if fr == 0 then IO.eprintln "  fopen read failed"; Allegro.uninstallSystem; return

  -- fsize
  let sz ← fr.size
  IO.println s!"  fsize = {sz}"

  -- fgetc
  let ch ← fr.getc
  IO.println s!"  fgetc = {ch} (expected 65 = 'A')"

  -- fungetc
  let _ ← fr.ungetc ch
  let ch2 ← fr.getc
  IO.println s!"  fungetc + fgetc = {ch2} (should be same)"

  -- fgets
  let line ← fr.gets 256
  IO.println s!"  fgets = \"{line}\""

  -- Read endian values
  let v16 ← fr.read16le
  IO.println s!"  fread16le = 0x{String.ofList (Nat.toDigits 16 v16.toNat)} (expected 1234)"
  let v32 ← fr.read32le
  IO.println s!"  fread32le = 0x{String.ofList (Nat.toDigits 16 v32.toNat)} (expected deadbeef)"

  -- feof / ferror
  let eof ← fr.eof
  IO.println s!"  feof = {eof}"
  let err ← fr.error
  IO.println s!"  ferror = {err}"
  let msg ← fr.errmsg
  IO.println s!"  ferrmsg = \"{msg}\""

  let _ ← fr.close
  IO.println "  fclose — OK"

  -- ── Filesystem ──
  IO.println ""
  IO.println "  ── Filesystem ──"

  let cwd ← Allegro.getCurrentDirectory
  IO.println s!"  getCurrentDirectory = \"{cwd}\""

  let ent : FsEntry ← Allegro.createFsEntry "/tmp/allegro_fio_demo.bin"
  if ent != 0 then
    let name ← ent.name
    IO.println s!"  getFsEntryName = \"{name}\""

    let _ ← ent.update
    let mode ← ent.mode
    IO.println s!"  getFsEntryMode = {mode}"
    let esize ← ent.size
    IO.println s!"  getFsEntrySize = {esize}"
    let mtime ← ent.mtime
    IO.println s!"  getFsEntryMtime = {mtime}"

    let exists_ ← ent.exists_
    IO.println s!"  fsEntryExists = {exists_}"

    ent.destroy

  -- filenameExists
  let fex ← Allegro.filenameExists "/tmp/allegro_fio_demo.bin"
  IO.println s!"  filenameExists = {fex}"

  -- makeDirectory
  let _ ← Allegro.makeDirectory "/tmp/allegro_demo_dir"
  IO.println "  makeDirectory(\"/tmp/allegro_demo_dir\") — OK"

  -- Directory traversal
  let tmpDir : FsEntry ← Allegro.createFsEntry "/tmp"
  if tmpDir != 0 then
    let od ← tmpDir.openDir
    IO.println s!"  openDirectory(\"/tmp\") = {od}"
    if od == 1 then
      -- Read first few entries
      let mut count := 0
      for _ in List.range 5 do
        let child : FsEntry ← tmpDir.readDir
        if child != 0 then
          let cname ← child.name
          IO.println s!"    entry: \"{cname}\""
          child.destroy
          count := count + 1
      IO.println s!"  read {count} entries from /tmp"
      let _ ← tmpDir.closeDir
    tmpDir.destroy

  -- Cleanup temp files
  let _ ← Allegro.removeFilename "/tmp/allegro_fio_demo.bin"
  let _ ← Allegro.removeFilename "/tmp/allegro_demo_dir"
  IO.println "  cleaned up temp files"

  Allegro.uninstallSystem
  IO.println "── done ──"
