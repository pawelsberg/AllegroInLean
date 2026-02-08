-- Ustr (Unicode string) subsystem demo.
--
-- Creates, manipulates, searches, and iterates Allegro Unicode strings.
-- Console-only — no display needed.
--
-- Showcases: ustrNew, ustrCstr, ustrLength, ustrSize, ustrDup,
--            ustrAppendCstr, ustrInsertCstr, ustrFindCstr, ustrFindChr,
--            ustrDupSubstr, ustrEqual, ustrCompare, ustrHasPrefixCstr,
--            ustrHasSuffixCstr, ustrTrimWs, ustrSetChr, ustrGetNextRaw,
--            ustrFindReplaceCstr, ustrFree.
import Allegro

open Allegro

def main : IO Unit := do
  let okInit ← Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"; return

  IO.println "── Ustr Demo ──"

  -- Create and inspect
  let u ← Allegro.ustrNew "Hello, Allegro!"
  let len ← u.length
  let sz ← u.size
  let s ← u.cstr
  IO.println s!"  created  : \"{s}\"  (length={len}, bytes={sz})"

  -- Append
  u.appendCstr " 🎮"
  let s2 ← u.cstr
  IO.println s!"  appended : \"{s2}\""

  -- Duplicate
  let u2 ← u.dup
  let s3 ← u2.cstr
  IO.println s!"  dup      : \"{s3}\""

  -- Search
  let pos ← u.findCstr 0 "Allegro"
  IO.println s!"  find \"Allegro\" → byte offset {pos}"
  let posX ← u.findCstr 0 "missing"
  IO.println s!"  find \"missing\" → byte offset {posX} (max = not found)"

  -- Substring
  let sub ← u.dupSubstr 7 14
  let subS ← sub.cstr
  IO.println s!"  substr[7..14] : \"{subS}\""
  sub.free

  -- Comparison
  let a ← Allegro.ustrNew "abc"
  let b ← Allegro.ustrNew "abc"
  let c ← Allegro.ustrNew "xyz"
  let eqAb ← a.equal b
  let eqAc ← a.equal c
  IO.println s!"  \"abc\" == \"abc\" → {eqAb}"
  IO.println s!"  \"abc\" == \"xyz\" → {eqAc}"

  -- Prefix / suffix
  let hasPre ← u.hasPrefix "Hello"
  let hasSuf ← u.hasSuffix "Lean"
  IO.println s!"  starts with \"Hello\" → {hasPre}"
  IO.println s!"  ends with \"Lean\"   → {hasSuf}"

  -- Trim whitespace
  let ws ← Allegro.ustrNew "   padded   "
  let _ ← ws.trimWs
  let wsS ← ws.cstr
  IO.println s!"  trimmed  : \"{wsS}\""
  ws.free

  -- Find & replace
  let fr ← Allegro.ustrNew "one fish two fish red fish blue fish"
  let _ ← fr.findReplaceCstr 0 "fish" "cat"
  let frS ← fr.cstr
  IO.println s!"  replaced : \"{frS}\""
  fr.free

  -- Iterate codepoints with ustrGetNextRaw
  IO.print "  iterate \"abc\": "
  let iter ← Allegro.ustrNew "abc"
  let iterLen ← iter.length
  let posRef ← IO.mkRef (0 : UInt32)
  for _ in [:iterLen.toNat] do
    let p ← posRef.get
    let packed ← iter.getNextRaw p
    let (cp, nextPos) := Allegro.ustrUnpackGetNext packed
    IO.print s!"U+{cp} "
    posRef.set nextPos
  IO.println ""
  iter.free

  -- Cleanup
  a.free
  b.free
  c.free
  u2.free
  u.free
  Allegro.uninstallSystem
  IO.println "── done ──"
