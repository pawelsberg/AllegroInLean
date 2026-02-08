-- UstrExtrasDemo — demonstrates gap-fill Ustr APIs.
-- Console-only — no display needed.
--
-- Showcases: cstrDup, ustrToBuffer, refCstr, refBuffer, refUstr,
--            ustrNewFromUtf16, ustrEncodeUtf16, utf16Encode
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return

  IO.println "── Ustr Extras Demo ──"

  -- Create a test string
  let u ← Allegro.ustrNew "Hello, Allegro!"
  if u == 0 then IO.eprintln "  ustrNew failed"; Allegro.uninstallSystem; return

  -- cstrDup — creates a new C string copy
  let dup ← u.cstrDup
  IO.println s!"  cstrDup = \"{dup}\""

  -- ustrToBuffer — copy into a buffer as String
  let buf ← u.toBuffer
  IO.println s!"  ustrToBuffer = \"{buf}\""

  -- refCstr — read-only USTR reference to a C string
  let rc ← Allegro.refCstr "ref_test"
  if rc != 0 then
    let s ← rc.cstr
    IO.println s!"  refCstr → ustrCstr = \"{s}\""

  -- refBuffer — read-only USTR reference from raw pointer + length
  -- We need a valid raw pointer; use a small sample's data buffer
  let _ ← Allegro.installAudio
  let _ ← Allegro.initAcodecAddon
  let testSpl ← Allegro.loadSample "data/beep.wav"
  if testSpl != 0 then
    let dataPtr ← testSpl.sampleData
    if dataPtr != 0 then
      let refB ← Allegro.refBuffer dataPtr 4
      IO.println s!"  refBuffer(dataPtr,4) = {refB} (non-zero = OK)"
    else
      IO.println "  getSampleData returned null — skipping refBuffer"
    testSpl.destroy
  else
    IO.println "  loadSample failed — skipping refBuffer"
  Allegro.uninstallAudio

  -- refUstr — read-only reference to substring
  let rsub ← u.ref (0 : UInt32) (5 : UInt32)
  if rsub != 0 then
    let s ← rsub.cstr
    IO.println s!"  refUstr(0,5) → ustrCstr = \"{s}\""

  -- UTF-16 round-trip
  -- utf16Encode — encode a single codepoint (€ = U+20AC) → (word1, word2, written)
  let (w1, w2, written) ← Allegro.utf16Encode (0x20AC : UInt32)
  IO.println s!"  utf16Encode(U+20AC) = ({w1}, {w2}), written={written}"

  -- ustrNewFromUtf16 — create from UTF-16 data
  -- Use a simple ASCII-range string encoded as UTF-16LE
  -- "Hi" = [0x48, 0x00, 0x69, 0x00, 0x00, 0x00] (null-terminated UTF-16LE)
  let u16 ← Allegro.ustrNewFromUtf16 (ByteArray.mk #[0x48, 0x00, 0x69, 0x00, 0x00, 0x00])
  if u16 != 0 then
    let s ← u16.cstr
    IO.println s!"  ustrNewFromUtf16([H,i]) → \"{s}\""
    -- ustrEncodeUtf16 — encode back to UTF-16 → ByteArray
    let encoded ← u16.encodeUtf16
    IO.println s!"  ustrEncodeUtf16: {encoded.size} bytes"
    u16.free

  u.free
  Allegro.uninstallSystem
  IO.println "── done ──"
