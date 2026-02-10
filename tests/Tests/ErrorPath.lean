import Allegro
import Tests.Harness

/-!
# Error-path tests

Validates that passing invalid handles (0), bad file paths, and edge-case
values to Allegro FFI bindings results in graceful failure (default return
values) rather than crashes / segfaults.

These tests exercise the null-guards in the C shim layer.

Run: `lake build allegroErrorTest && .lake/build/bin/allegroErrorTest`
-/

open Allegro Harness

-- ── 1) Invalid-handle tests: Config ──

def testConfigInvalidHandle : IO Bool := do
  printSection "Config – invalid handle"
  let nullCfg : Config := 0
  -- getConfigValue on null config → empty string
  let v ← nullCfg.getValue "" "key"
  check "getConfigValue on null cfg returns empty" (v == "")
  -- setConfigValue on null config → no crash
  nullCfg.setValue "" "key" "val"
  check "setConfigValue on null cfg no crash" true
  -- addConfigSection on null config → no crash
  nullCfg.addSection "sec"
  check "addConfigSection on null cfg no crash" true
  -- removeConfigSection on null config → 0
  let r1 ← nullCfg.removeSection "sec"
  check "removeConfigSection on null cfg returns 0" (r1 == 0)
  -- removeConfigKey on null config → 0
  let r2 ← nullCfg.removeKey "" "key"
  check "removeConfigKey on null cfg returns 0" (r2 == 0)
  -- saveConfigFile with null config → 0
  let tmp ← IO.getEnv "TEMP" >>= fun
    | some t => pure t
    | none => IO.getEnv "TMP" >>= fun
      | some t => pure t
      | none => pure "/tmp"
  let r3 ← nullCfg.save s!"{tmp}/null_cfg_test.cfg"
  check "saveConfigFile with null cfg returns 0" (r3 == 0)
  -- destroyConfig 0 → no crash
  nullCfg.destroy
  check "destroyConfig 0 no crash" true
  -- mergeConfig with null → should not crash
  let merged : Config ← nullCfg.merge nullCfg
  check "mergeConfig (0,0) no crash" true
  -- mergeConfigInto with null → no crash
  nullCfg.mergeInto nullCfg
  check "mergeConfigInto (0,0) no crash" true
  -- destroy the merged handle if non-zero
  if merged != 0 then merged.destroy
  -- Config iteration with null → empty arrays
  let secs ← nullCfg.sections
  check "getConfigSections 0 → empty" (secs.size == 0)
  let ents ← nullCfg.entries ""
  check "getConfigEntries 0 → empty" (ents.size == 0)
  pure true

-- ── 2) Invalid-handle tests: Bitmap ──

def testBitmapInvalidHandle : IO Bool := do
  printSection "Bitmap – invalid handle"
  let null : Bitmap := 0
  -- getBitmapWidth/Height on null → 0
  let w ← null.width
  check "getBitmapWidth 0 returns 0" (w == 0)
  let h ← null.height
  check "getBitmapHeight 0 returns 0" (h == 0)
  -- getBitmapFlags/Format on null → 0
  let fl ← null.flags
  check "getBitmapFlags 0 returns 0" (fl.val == 0)
  let fmt ← null.format
  check "getBitmapFormat 0 returns 0" (fmt.val == 0)
  -- cloneBitmap null → 0
  let cl ← null.clone
  check "cloneBitmap 0 returns 0" (cl == 0)
  -- createSubBitmap null → 0
  let sb ← null.createSub 0 0 10 10
  check "createSubBitmap 0 returns 0" (sb == 0)
  -- isSubBitmap null → 0
  let isub ← null.isSub
  check "isSubBitmap 0 returns 0" (isub == 0)
  -- getParentBitmap null → 0
  let par ← null.parent
  check "getParentBitmap 0 returns 0" (par == 0)
  -- destroyBitmap 0 → no crash
  null.destroy
  check "destroyBitmap 0 no crash" true
  -- drawBitmap null → no crash
  null.draw 0.0 0.0 FlipFlags.none
  check "drawBitmap 0 no crash" true
  pure true

-- ── 3) Invalid-handle tests: Timer ──

def testTimerInvalidHandle : IO Bool := do
  printSection "Timer – invalid handle"
  let null : Timer := 0
  null.start
  check "startTimer 0 no crash" true
  null.stop
  check "stopTimer 0 no crash" true
  let c ← null.count
  check "getTimerCount 0 returns 0" (c == 0)
  let sp ← null.speed
  check "getTimerSpeed 0 returns 0.0" (sp == 0.0)
  null.setSpeed 1.0
  check "setTimerSpeed 0 no crash" true
  null.destroy
  check "destroyTimer 0 no crash" true
  pure true

-- ── 4) Invalid-handle tests: Event queue ──

def testEventsInvalidHandle : IO Bool := do
  printSection "Events – invalid handle"
  let nullQ : EventQueue := 0
  let nullE : Event := 0
  -- eventGetType on null event → 0
  let ty ← nullE.type
  check "eventGetType 0 returns 0" (ty.val == 0)
  -- eventGetTimestamp on null event → 0.0
  let ts ← nullE.timestamp
  check "eventGetTimestamp 0 returns 0.0" (ts == 0.0)
  -- eventGetKeyboardKeycode on null → 0
  let kc ← nullE.keyboardKeycode
  check "eventGetKeyboardKeycode 0 returns 0" (kc == 0)
  -- eventGetMouseX/Y on null → 0
  let mx ← nullE.mouseX
  check "eventGetMouseX 0 returns 0" (mx == 0)
  -- isEventQueueEmpty on null → 0  (no crash)
  let emp ← nullQ.isEmpty
  check "isEventQueueEmpty 0 no crash" true
  -- User event fields on null → 0
  let ud1 ← nullE.userData1
  check "eventGetUserData1 0 returns 0" (ud1 == 0)
  -- destroyEvent 0
  nullE.destroy
  check "destroyEvent 0 no crash" true
  -- destroyEventQueue 0
  nullQ.destroy
  check "destroyEventQueue 0 no crash" true
  -- Suppress warnings
  let _ := emp
  let _ := mx
  pure true

-- ── 5) Invalid-handle tests: Font ──

def testFontInvalidHandle : IO Bool := do
  printSection "Font – invalid handle"
  let null : Font := 0
  let tw ← null.textWidth "hello"
  check "getTextWidth 0 returns 0" (tw == 0)
  let lh ← null.lineHeight
  check "getFontLineHeight 0 returns 0" (lh == 0)
  let asc ← null.ascent
  check "getFontAscent 0 returns 0" (asc == 0)
  let desc ← null.descent
  check "getFontDescent 0 returns 0" (desc == 0)
  -- drawTextRgb with null font → no crash
  let left := Allegro.alignLeft
  null.drawTextRgb 255 255 255 10.0 10.0 left "test"
  check "drawTextRgb with null font no crash" true
  -- destroyFont 0
  null.destroy
  check "destroyFont 0 no crash" true
  pure true

-- ── 6) Invalid-handle tests: Audio ──

def testAudioInvalidHandle : IO Bool := do
  printSection "Audio – invalid handle"
  let nullSample : Sample := 0
  let nullInst : SampleInstance := 0
  let nullStream : AudioStream := 0
  let nullMixer : Mixer := 0
  let nullVoice : Voice := 0
  -- Sample queries on null
  let freq ← nullSample.frequency
  check "getSampleFrequency 0 returns 0" (freq == 0)
  let slen ← nullSample.length
  check "getSampleLength 0 returns 0" (slen == 0)
  let sdep ← nullSample.depth
  check "getSampleDepth 0 returns 0" (sdep.val == 0)
  let sch ← nullSample.channels
  check "getSampleChannels 0 returns 0" (sch.val == 0)
  -- playSample null → 0
  let ps ← nullSample.play 1.0 0.0 1.0 ⟨0⟩
  check "playSample 0 returns 0" (ps == 0)
  -- destroySample 0
  nullSample.destroy
  check "destroySample 0 no crash" true
  -- createSampleInstance null → 0
  let si ← Allegro.createSampleInstance nullSample
  check "createSampleInstance 0 returns 0" (si == 0)
  -- Sample instance operations on null → no crash, return 0/0.0
  let sig ← nullInst.gain
  check "getSampleInstanceGain 0 returns 0.0" (sig == 0.0)
  let sip ← nullInst.pan
  check "getSampleInstancePan 0 returns 0.0" (sip == 0.0)
  let sis ← nullInst.speed
  check "getSampleInstanceSpeed 0 returns 0.0" (sis == 0.0)
  let sipl ← nullInst.isPlaying
  check "getSampleInstancePlaying 0 returns 0" (sipl == 0)
  let sipos ← nullInst.position
  check "getSampleInstancePosition 0 returns 0" (sipos == 0)
  let silen ← nullInst.length
  check "getSampleInstanceLength 0 returns 0" (silen == 0)
  let sipm ← nullInst.playmode
  check "getSampleInstancePlaymode 0 returns 0" (sipm.val == 0)
  let pir ← nullInst.play
  check "playSampleInstance 0 returns 0" (pir == 0)
  let sir ← nullInst.stop
  check "stopSampleInstance 0 returns 0" (sir == 0)
  let det ← nullInst.detach
  check "detachSampleInstance 0 returns 0" (det == 0)
  let att ← nullInst.attachToMixer nullMixer
  check "attachSampleInstanceToMixer (0,0) returns 0" (att == 0)
  nullInst.destroy
  check "destroySampleInstance 0 no crash" true
  -- Audio stream operations on null
  let asg ← nullStream.gain
  check "getAudioStreamGain 0 returns 0.0" (asg == 0.0)
  let asp ← nullStream.pan
  check "getAudioStreamPan 0 returns 0.0" (asp == 0.0)
  let ass_ ← nullStream.speed
  check "getAudioStreamSpeed 0 returns 0.0" (ass_ == 0.0)
  let aspl ← nullStream.isPlaying
  check "getAudioStreamPlaying 0 returns 0" (aspl == 0)
  let aspm ← nullStream.playmode
  check "getAudioStreamPlaymode 0 returns 0" (aspm.val == 0)
  let aspos ← nullStream.positionSecs
  check "getAudioStreamPositionSecs 0 returns 0.0" (aspos == 0.0)
  let aslen ← nullStream.lengthSecs
  check "getAudioStreamLengthSecs 0 returns 0.0" (aslen == 0.0)
  let seek ← nullStream.seekSecs 0.0
  check "seekAudioStreamSecs 0 returns 0" (seek == 0)
  let rwnd ← nullStream.rewind
  check "rewindAudioStream 0 returns 0" (rwnd == 0)
  let sloop ← nullStream.setLoopSecs 0.0 1.0
  check "setAudioStreamLoopSecs 0 returns 0" (sloop == 0)
  let asev ← nullStream.eventSource
  check "getAudioStreamEventSource 0 returns 0" (asev == 0)
  let asm ← nullStream.attachToMixer nullMixer
  check "attachAudioStreamToMixer (0,0) returns 0" (asm == 0)
  let detas ← nullStream.detach
  check "detachAudioStream 0 returns 0" (detas == 0)
  nullStream.drain
  check "drainAudioStream 0 no crash" true
  nullStream.destroy
  check "destroyAudioStream 0 no crash" true
  -- Mixer operations on null
  let mg ← nullMixer.gain
  check "getMixerGain 0 returns 0.0" (mg == 0.0)
  let mf ← nullMixer.frequency
  check "getMixerFrequency 0 returns 0" (mf == 0)
  let mq ← nullMixer.quality
  check "getMixerQuality 0 returns 0" (mq.val == 0)
  let mp ← nullMixer.isPlaying
  check "getMixerPlaying 0 returns 0" (mp == 0)
  let smf ← nullMixer.setFrequency 44100
  check "setMixerFrequency 0 returns 0" (smf == 0)
  let smg ← nullMixer.setGain 1.0
  check "setMixerGain 0 returns 0" (smg == 0)
  let smq ← nullMixer.setQuality ⟨0⟩
  check "setMixerQuality 0 returns 0" (smq == 0)
  let smp ← nullMixer.setPlaying 1
  check "setMixerPlaying 0 returns 0" (smp == 0)
  let dmix ← nullMixer.detach
  check "detachMixer 0 returns 0" (dmix == 0)
  let amm ← nullMixer.attachToMixer nullMixer
  check "attachMixerToMixer (0,0) returns 0" (amm == 0)
  let sdm ← nullMixer.setAsDefault
  check "setDefaultMixer 0 returns 0" (sdm == 0)
  nullMixer.destroy
  check "destroyMixer 0 no crash" true
  -- Voice operations on null
  let vf ← nullVoice.frequency
  check "getVoiceFrequency 0 returns 0" (vf == 0)
  let vp ← nullVoice.isPlaying
  check "getVoicePlaying 0 returns 0" (vp == 0)
  let svp ← nullVoice.setPlaying 1
  check "setVoicePlaying 0 returns 0" (svp == 0)
  let amv ← nullMixer.attachToVoice nullVoice
  check "attachMixerToVoice (0,0) returns 0" (amv == 0)
  nullVoice.detach
  check "detachVoice 0 no crash" true
  nullVoice.destroy
  check "destroyVoice 0 no crash" true
  pure true

-- ── 7) Invalid-handle tests: Transform ──

def testTransformInvalidHandle : IO Bool := do
  printSection "Transform – invalid handle"
  let null : Transform := 0
  null.identity
  check "identityTransform 0 no crash" true
  null.translate 1.0 2.0
  check "translateTransform 0 no crash" true
  null.rotate 0.5
  check "rotateTransform 0 no crash" true
  null.scale 2.0 2.0
  check "scaleTransform 0 no crash" true
  null.invert
  check "invertTransform 0 no crash" true
  let ci ← null.checkInverse 0.001
  check "checkInverse 0 returns 0" (ci == 0)
  let (tx, _ty) ← null.transformCoords 1.0 2.0
  check "transformCoordinates 0 returns input (identity)" (tx == 1.0)
  null.destroy
  check "destroyTransform 0 no crash" true
  pure true

-- ── 8) Invalid-handle tests: Path ──

def testPathInvalidHandle : IO Bool := do
  printSection "Path – invalid handle"
  let null : Path := 0
  let s ← null.cstr 47  -- '/' separator
  check "pathCstr 0 returns empty" (s == "")
  let fn ← null.filename
  check "getPathFilename 0 returns empty" (fn == "")
  let dr ← null.drive
  check "getPathDrive 0 returns empty" (dr == "")
  let nc ← null.numComponents
  check "getPathNumComponents 0 returns 0" (nc == 0)
  let cl ← null.clone
  check "clonePath 0 returns 0" (cl == 0)
  let canon ← null.makeCanonical
  check "makePathCanonical 0 returns 0" (canon == 0)
  null.append "dir"
  check "appendPathComponent 0 no crash" true
  null.destroy
  check "destroyPath 0 no crash" true
  pure true

-- ── 9) Invalid-handle tests: Ustr ──

def testUstrInvalidHandle : IO Bool := do
  printSection "Ustr – invalid handle"
  let null : Ustr := 0
  let s ← null.cstr
  check "cstr 0 returns empty" (s == "")
  let sz ← null.size
  check "ustrSize 0 returns 0" (sz == 0)
  let len ← null.length
  check "ustrLength 0 returns 0" (len == 0)
  let d ← null.dup
  check "ustrDup 0 returns 0" (d == 0)
  null.appendCstr "hi"
  check "ustrAppendCstr 0 no crash" true
  null.free
  check "ustrFree 0 no crash" true
  -- Extended ustr null-handle tests
  let eq ← null.equal null
  check "ustrEqual 0 0 → 1 (both null)" (eq == 1)
  let cmp ← null.compare null
  check "ustrCompare 0 0 → 0" (cmp == 0)
  let hp ← null.hasPrefix "x"
  check "ustrHasPrefixCstr 0 → 0" (hp == 0)
  let hs ← null.hasSuffix "x"
  check "ustrHasSuffixCstr 0 → 0" (hs == 0)
  let fc ← null.findChr 0 65
  check "ustrFindChr 0 → max" (fc > 1000000)
  let fcs ← null.findCstr 0 "x"
  check "ustrFindCstr 0 → max" (fcs > 1000000)
  let ac ← null.assignCstr "x"
  check "ustrAssignCstr 0 → 0" (ac == 0)
  let tr ← null.truncate 0
  check "ustrTruncate 0 → 0" (tr == 0)
  let tw ← null.trimWs
  check "ustrTrimWs 0 → 0" (tw == 0)
  -- Extended ustr null-handle tests (new functions)
  let dsub ← null.dupSubstr 0 5
  check "ustrDupSubstr 0 → 0" (dsub == 0)
  let nxt ← null.next 0
  check "ustrNext 0 → 0 (unchanged)" (nxt == 0)
  let prv ← null.prev 0
  check "ustrPrev 0 → 0 (unchanged)" (prv == 0)
  let gnr ← null.getNextRaw 0
  let (gnCh, _) := Allegro.ustrUnpackGetNext gnr
  check "ustrGetNextRaw 0 → codepoint 0xFFFFFFFF" (gnCh == 0xFFFFFFFF)
  let pgr ← null.prevGetRaw 0
  let (pgCh, _) := Allegro.ustrUnpackPrevGet pgr
  check "ustrPrevGetRaw 0 → codepoint 0xFFFFFFFF" (pgCh == 0xFFFFFFFF)
  let ichr ← null.insertChr 0 65
  check "ustrInsertChr 0 → 0" (ichr == 0)
  let achr ← null.appendChr 65
  check "ustrAppendChr 0 → 0" (achr == 0)
  let rchr ← null.removeChr 0
  check "ustrRemoveChr 0 → 0" (rchr == 0)
  let asgn ← null.assign null
  check "ustrAssign 0 0 → 0" (asgn == 0)
  let rfcs ← null.rfindCstr 0 "x"
  check "ustrRfindCstr 0 → max" (rfcs > 1000000)
  let fset ← null.findSetCstr 0 "abc"
  check "ustrFindSetCstr 0 → max" (fset > 1000000)
  let fcset ← null.findCsetCstr 0 "abc"
  check "ustrFindCsetCstr 0 → max" (fcset > 1000000)
  let frep ← null.findReplaceCstr 0 "a" "b"
  check "ustrFindReplaceCstr 0 → 0" (frep == 0)
  pure true

-- ── 9b) State null-handle tests ──

def testStateInvalidHandle : IO Bool := do
  printSection "State – invalid handle"
  let null : State := 0
  -- store/restore on null → no crash
  null.store Allegro.stateAll
  check "storeState 0 no crash" true
  null.restore
  check "restoreState 0 no crash" true
  -- destroyState 0 → no crash
  null.destroy
  check "destroyState 0 no crash" true
  -- Double destroy
  null.destroy
  null.destroy
  check "destroyState 0 twice no crash" true
  pure true

-- ── 10) Invalid-handle tests: Display ──

def testDisplayInvalidHandle : IO Bool := do
  printSection "Display – invalid handle"
  let null : Display := 0
  let w ← null.width
  check "getDisplayWidth 0 returns 0" (w == 0)
  let h ← null.height
  check "getDisplayHeight 0 returns 0" (h == 0)
  let fl ← null.flags
  check "getDisplayFlags 0 returns 0" (fl.val == 0)
  let bb ← null.backbuffer
  check "getBackbuffer 0 returns 0" (bb == 0)
  null.destroy
  check "destroyDisplay 0 no crash" true
  -- Clipboard with null display
  let ct ← null.clipboardText
  check "getClipboardText 0 returns empty" (ct == "")
  let cs ← null.setClipboard "test"
  check "setClipboardText 0 returns 0" (cs == 0)
  let ch ← null.hasClipboardText
  check "clipboardHasText 0 returns 0" (ch == 0)
  -- Display extras with null display
  null.setIcon 0
  check "setDisplayIcon 0 0 no crash" true
  -- Mouse cursor with null handles
  let mc ← Allegro.createMouseCursor 0 0 0
  check "createMouseCursor null bitmap → 0" (mc == 0)
  let nullMC : MouseCursor := 0
  nullMC.destroy
  check "destroyMouseCursor 0 no crash" true
  let sm ← null.setMouseCursor nullMC
  check "setMouseCursor 0 0 → 0" (sm == 0)
  let ss ← null.setSystemCursor ⟨1⟩
  check "setSystemMouseCursor 0 → 0" (ss == 0)
  let mx ← null.setMouseXy 10 10
  check "setMouseXy 0 → 0" (mx == 0)
  let gm ← null.grabMouse
  check "grabMouse 0 → 0" (gm == 0)
  pure true

-- ── 11) Bad file paths ──

def testBadFilePaths : IO Bool := do
  printSection "Bad file paths"
  -- loadBitmap with nonexistent file → 0
  let bmp ← Allegro.loadBitmap "/nonexistent/image.png"
  check "loadBitmap bad path returns 0" (bmp == 0)
  -- loadBitmapFlags with nonexistent file → 0
  let bmpF ← Allegro.loadBitmapFlags "/nonexistent/image.png" 0
  check "loadBitmapFlags bad path returns 0" (bmpF == 0)
  -- loadFont with nonexistent file → 0
  let fnt ← Allegro.loadFont "/nonexistent/font.ttf" 16 0
  check "loadFont bad path returns 0" (fnt == 0)
  -- loadTtfFont with nonexistent file → 0
  let ttf ← Allegro.loadTtfFont "/nonexistent/font.ttf" 16 0
  check "loadTtfFont bad path returns 0" (ttf == 0)
  -- loadConfigFile with nonexistent file → 0
  let cfg ← Allegro.loadConfigFile "/nonexistent/config.cfg"
  check "loadConfigFile bad path returns 0" (cfg == 0)
  -- loadSample with nonexistent file → 0
  let spl ← Allegro.loadSample "/nonexistent/beep.wav"
  check "loadSample bad path returns 0" (spl == 0)
  -- loadAudioStream with nonexistent file → 0
  let stream ← Allegro.loadAudioStream "/nonexistent/music.ogg" 4 2048
  check "loadAudioStream bad path returns 0" (stream == 0)
  -- saveBitmap with null bitmap → 0
  let tmp ← IO.getEnv "TEMP" >>= fun
    | some t => pure t
    | none => IO.getEnv "TMP" >>= fun
      | some t => pure t
      | none => pure "/tmp"
  let sv ← Allegro.saveBitmap s!"{tmp}/test_null.png" 0
  check "saveBitmap null bitmap returns 0" (sv == 0)
  -- saveBitmap to unwritable path (with valid bitmap)
  let memFlag := Allegro.bitmapFlagMemory
  Allegro.setNewBitmapFlags memFlag
  let bmp2 : Bitmap ← Allegro.createBitmap 2 2
  let sv2 ← bmp2.save "/nonexistent_dir/test.png"
  check "saveBitmap bad dir returns 0" (sv2 == 0)
  bmp2.destroy
  pure true

-- ── 12) Edge cases ──

def testEdgeCases : IO Bool := do
  printSection "Edge cases"
  -- Zero-size bitmap
  let memFlag := Allegro.bitmapFlagMemory
  Allegro.setNewBitmapFlags memFlag
  let zb : Bitmap ← Allegro.createBitmap 0 0
  -- Allegro allows 0×0 bitmaps; just verify no crash and clean up
  check "createBitmap 0×0 no crash" true
  if zb != 0 then zb.destroy
  -- Color addon: empty/bad colour name → black (0,0,0)
  let (r, g, b) ← Allegro.colorNameToRgb ""
  check "colorNameToRgb empty string → (0,0,0)" (r == 0 && g == 0 && b == 0)
  -- Color addon: bad HTML string
  let (hr, hg, hb) ← Allegro.colorHtmlToRgb "not_a_color"
  check "colorHtmlToRgb bad string → (0,0,0)" (hr == 0 && hg == 0 && hb == 0)
  -- Config: empty section and key names
  let cfg : Config ← Allegro.createConfig
  cfg.setValue "" "" "val"
  let v ← cfg.getValue "" ""
  check "config empty section + key round-trip" (v == "val")
  -- Config: get missing key → empty string
  let miss ← cfg.getValue "nonexistent" "nokey"
  check "config missing key returns empty" (miss == "")
  cfg.destroy
  -- Timer with very small speed (edge case)
  let t : Timer ← Allegro.createTimer 0.0001
  let ok := t != 0
  check "createTimer very small speed succeeds" ok
  if t != 0 then t.destroy
  -- Ustr: empty string round-trip
  let u : Ustr ← Allegro.ustrNew ""
  let s ← u.cstr
  check "ustr empty string round-trip" (s == "")
  let sz ← u.size
  check "ustr empty string size = 0" (sz == 0)
  u.free
  -- Path: empty string
  let p : Path ← Allegro.createPath ""
  let ps ← p.cstr 47
  check "path empty string no crash" true
  let _ := ps
  p.destroy
  pure true

-- ── 13) Double-destroy safety ──

def testDoubleDestroy : IO Bool := do
  printSection "Double destroy safety"
  -- Create and destroy a config, then destroy the handle again (now dangling → 0 won't help,
  -- but at least destroying handle 0 must be safe)
  let nullCfg    : Config         := 0
  let nullBmp    : Bitmap         := 0
  let nullTimer  : Timer          := 0
  let nullFont   : Font           := 0
  let nullSample : Sample         := 0
  let nullInst   : SampleInstance := 0
  let nullStream : AudioStream    := 0
  let nullMixer  : Mixer          := 0
  let nullVoice  : Voice          := 0
  let nullTr     : Transform      := 0
  let nullPath   : Path           := 0
  let nullUstr   : Ustr           := 0
  let nullEvt    : Event          := 0
  let nullQ      : EventQueue     := 0
  let nullDisp   : Display        := 0
  nullCfg.destroy
  nullCfg.destroy
  check "destroyConfig 0 twice no crash" true
  nullBmp.destroy
  nullBmp.destroy
  check "destroyBitmap 0 twice no crash" true
  nullTimer.destroy
  nullTimer.destroy
  check "destroyTimer 0 twice no crash" true
  nullFont.destroy
  nullFont.destroy
  check "destroyFont 0 twice no crash" true
  nullSample.destroy
  nullSample.destroy
  check "destroySample 0 twice no crash" true
  nullInst.destroy
  nullInst.destroy
  check "destroySampleInstance 0 twice no crash" true
  nullStream.destroy
  nullStream.destroy
  check "destroyAudioStream 0 twice no crash" true
  nullMixer.destroy
  nullMixer.destroy
  check "destroyMixer 0 twice no crash" true
  nullVoice.destroy
  nullVoice.destroy
  check "destroyVoice 0 twice no crash" true
  nullTr.destroy
  nullTr.destroy
  check "destroyTransform 0 twice no crash" true
  nullPath.destroy
  nullPath.destroy
  check "destroyPath 0 twice no crash" true
  nullUstr.free
  nullUstr.free
  check "ustrFree 0 twice no crash" true
  nullEvt.destroy
  nullEvt.destroy
  check "destroyEvent 0 twice no crash" true
  nullQ.destroy
  nullQ.destroy
  check "destroyEventQueue 0 twice no crash" true
  nullDisp.destroy
  nullDisp.destroy
  check "destroyDisplay 0 twice no crash" true
  pure true

-- ── Option API error-path tests ──

def testOptionErrorPaths : IO Bool := do
  printSection "Option APIs – error paths"

  -- createTimer? with unusual speeds — Allegro may or may not return null
  let t0 ← Allegro.createTimer? 0.0
  check "createTimer? 0.0 no crash" true
  if let some t := t0 then t.destroy
  let tNeg ← Allegro.createTimer? (-1.0)
  check "createTimer? -1.0 no crash" true
  if let some t := tNeg then t.destroy

  -- loadBitmap? bad path → none
  let bmp1 ← Allegro.loadBitmap? ""
  check "loadBitmap? empty → none" bmp1.isNone
  let bmp2 ← Allegro.loadBitmap? "/nonexistent/x.png"
  check "loadBitmapFlags? bad → none" bmp2.isNone

  -- createBitmap? zero size → still succeeds (Allegro allows 0×0 on some platforms)
  -- Just ensure no crash
  let bmp3 ← Allegro.createBitmap? 0 0
  check "createBitmap? 0×0 no crash" true
  if let some b := bmp3 then
    b.destroy

  -- loadConfigFile? bad path → none
  let cfg1 ← Allegro.loadConfigFile? ""
  check "loadConfigFile? empty → none" cfg1.isNone
  let cfg2 ← Allegro.loadConfigFile? "/nonexistent/x.cfg"
  check "loadConfigFile? bad → none" cfg2.isNone

  -- getStandardPath? with bogus ID → none
  let p1 ← Allegro.getStandardPath? 9999
  check "getStandardPath? 9999 → none" p1.isNone

  -- loadFont? / loadBitmapFont? / loadBitmapFontFlags? bad paths → none
  let f1 ← Allegro.loadFont? "" 12 0
  check "loadFont? empty → none" f1.isNone
  let f2 ← Allegro.loadBitmapFont? "/nonexistent/font.png"
  check "loadBitmapFont? bad → none" f2.isNone
  let f3 ← Allegro.loadBitmapFontFlags? "/nonexistent/font.png" 0
  check "loadBitmapFontFlags? bad → none" f3.isNone

  -- loadTtfFont? / loadTtfFontStretch? bad paths → none
  let t1 ← Allegro.loadTtfFont? "" 16 0
  check "loadTtfFont? empty → none" t1.isNone
  let t2 ← Allegro.loadTtfFontStretch? "/nonexistent.ttf" 16 20 0
  check "loadTtfFontStretch? bad → none" t2.isNone

  -- loadSample? bad path → none
  let s1 ← Allegro.loadSample? ""
  check "loadSample? empty → none" s1.isNone
  let s2 ← Allegro.loadSample? "/nonexistent/beep.wav"
  check "loadSample? bad → none" s2.isNone

  -- loadAudioStream? bad path → none
  let as1 ← Allegro.loadAudioStream? "/nonexistent/music.ogg" 4 2048
  check "loadAudioStream? bad → none" as1.isNone

  -- createSampleInstance? with null sample → none
  let si1 ← Allegro.createSampleInstance? (0 : Allegro.Sample)
  check "createSampleInstance? null → none" si1.isNone

  -- getJoystick? out of range → none
  let _j1 ← Allegro.getJoystick? 0
  check "getJoystick? 0 no crash" true  -- may be none or some depending on hw
  let j2 ← Allegro.getJoystick? 999
  check "getJoystick? 999 → none" j2.isNone

  -- createMouseCursor? with null bitmap → none
  let mc1 ← Allegro.createMouseCursor? 0 0 0
  check "createMouseCursor? null → none" mc1.isNone

  -- getFallbackFont? with null font → none
  let fb1 ← Allegro.getFallbackFont? (0 : Allegro.Font)
  check "getFallbackFont? null → none" fb1.isNone

  -- getErrno / setErrno
  Allegro.setErrno 123
  let e ← Allegro.getErrno
  check "setErrno/getErrno 123" (e == 123)
  Allegro.setErrno 0
  let e0 ← Allegro.getErrno
  check "setErrno 0 / getErrno 0" (e0 == 0)

  pure true

-- ── Main ──

def main : IO UInt32 := do
  -- Initialize Allegro and all addons needed for testing
  let ok ← Allegro.init
  if ok == 0 then
    IO.eprintln "FATAL: al_init failed"
    return 1
  let _ ← Allegro.initImageAddon
  Allegro.initFontAddon
  let _ ← Allegro.initTtfAddon
  let _ ← Allegro.initPrimitivesAddon
  let audioOk ← Allegro.installAudio
  if audioOk != 0 then
    let _ ← Allegro.initAcodecAddon
    let _ ← Allegro.reserveSamples 1
    pure ()
  else
    IO.eprintln "WARNING: al_install_audio failed – audio error-path tests still run (null-handle)"

  -- On macOS / Cocoa, keyboard and mouse installation may require a display
  -- to be created first.
  let display : Display ← Allegro.createDisplay 320 200
  if display == 0 then
    IO.eprintln "WARNING: createDisplay failed (non-fatal)"

  let _ ← Allegro.installKeyboard
  let _ ← Allegro.installMouse
  let _ ← Allegro.installJoystick

  IO.println "═══════════════════════════════"
  IO.println "  Error-path / robustness tests"
  IO.println "═══════════════════════════════"

  let _ ← testConfigInvalidHandle
  let _ ← testBitmapInvalidHandle
  let _ ← testTimerInvalidHandle
  let _ ← testEventsInvalidHandle
  let _ ← testFontInvalidHandle
  let _ ← testAudioInvalidHandle
  let _ ← testTransformInvalidHandle
  let _ ← testPathInvalidHandle
  let _ ← testUstrInvalidHandle
  let _ ← testStateInvalidHandle
  let _ ← testDisplayInvalidHandle
  let _ ← testBadFilePaths
  let _ ← testEdgeCases
  let _ ← testDoubleDestroy
  let _ ← testOptionErrorPaths

  -- Shutdown
  if display != 0 then display.destroy
  if audioOk != 0 then
    Allegro.uninstallAudio
  Allegro.shutdownFontAddon
  Allegro.shutdownTtfAddon
  Allegro.shutdownImageAddon
  Allegro.shutdownPrimitivesAddon
  Allegro.uninstallSystem

  IO.println "═══════════════════════════════"
  IO.println "  All error-path tests complete"
  IO.println "═══════════════════════════════"
  Harness.summary
