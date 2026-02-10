import Allegro

/-!
# VideoDemo — Video playback

Demonstrates the Allegro Video addon by opening an Ogg Theora (`.ogv`)
video file, routing its audio to the default mixer, and rendering each
decoded frame scaled to fill the display window.

Controls:
- **Space** — pause / resume
- **ESC** or close window — quit

Run: `lake build allegroVideoDemo && .lake/build/bin/allegroVideoDemo`
-/

open Allegro

def screenW : UInt32 := 640
def screenH : UInt32 := 480

def main : IO Unit := do
  -- ── Initialisation ──
  let ok ← Allegro.init
  if ok == 0 then
    IO.eprintln "Failed to initialise Allegro"
    return

  let _ ← Allegro.initImageAddon
  Allegro.initFontAddon
  let _ ← Allegro.initTtfAddon
  let _ ← Allegro.installAudio
  let _ ← Allegro.initAcodecAddon
  let _ ← Allegro.reserveSamples 1
  let _ ← Allegro.installKeyboard

  let okVideo ← Allegro.initVideoAddon
  if okVideo == 0 then
    IO.eprintln "Failed to initialise video addon"
    return

  Allegro.setNewDisplayFlags ⟨0⟩
  let display ← Allegro.createDisplay screenW screenH
  if display == 0 then
    IO.eprintln "Failed to create display"
    return
  display.setTitle "Allegro Video Demo"

  -- Load font for overlay text
  let font : Font ← Allegro.loadTtfFont "data/DejaVuSans.ttf" 18 0
  let font : Font ← if font == 0 then Allegro.createBuiltinFont else pure font

  -- ── Open video ──
  let videoPath := "data/sample.ogv"
  let video : Video ← Allegro.openVideo videoPath
  if video == 0 then
    IO.eprintln s!"Failed to open video: {videoPath}"
    font.destroy
    display.destroy
    Allegro.shutdownVideoAddon
    Allegro.uninstallAudio
    return

  -- Route video audio to the default mixer
  let mixer ← Allegro.getDefaultMixer
  video.start mixer

  -- ── Event setup ──
  let timer ← Allegro.createTimer (1.0 / 60.0)
  let queue ← Allegro.createEventQueue
  let evt   ← Allegro.createEvent

  let dispSrc ← display.eventSource
  queue.registerSource dispSrc
  let kbSrc ← Allegro.getKeyboardEventSource
  queue.registerSource kbSrc
  let timerSrc ← timer.eventSource
  queue.registerSource timerSrc
  let vidSrc ← video.eventSource
  queue.registerSource vidSrc

  timer.start

  -- Constants
  let evtKeyDown      := Allegro.EventType.keyDown
  let evtDisplayClose := Allegro.EventType.displayClose
  let evtTimer        := Allegro.EventType.timer
  let evtFrameShow    := Allegro.EventType.videoFrameShow
  let evtFinished     := Allegro.EventType.videoFinished
  let keyEsc          := Allegro.KeyCode.escape
  let keySpace        := Allegro.KeyCode.space

  let mut running := true
  let mut redraw  := false
  let mut paused  := false
  let mut finished := false

  while running do
    queue.waitFor evt
    let eType ← evt.type

    if eType == evtDisplayClose then
      running := false
    else if eType == evtKeyDown then
      let kc ← evt.keyboardKeycode
      if kc == keyEsc.val then
        running := false
      else if kc == keySpace.val then
        paused := !paused
        video.setPlaying (if paused then 0 else 1)
    else if eType == evtFrameShow then
      redraw := true
    else if eType == evtFinished then
      finished := true
      redraw := true
    else if eType == evtTimer then
      redraw := true

    -- Draw when caught up
    if redraw && (← queue.isEmpty) == 1 then
      Allegro.clearToColorRgb 0 0 0

      -- Get current frame
      let frame : Bitmap ← video.frame
      if frame != 0 then
        let fw ← frame.width
        let fh ← frame.height
        -- Scale to fill display while preserving aspect ratio
        let sw := screenW.toFloat
        let sh := screenH.toFloat
        let fwf := fw.toFloat
        let fhf := fh.toFloat
        let scaleW := sw / fwf
        let scaleH := sh / fhf
        let scale := if scaleW < scaleH then scaleW else scaleH
        let dw := fwf * scale
        let dh := fhf * scale
        let dx := (sw - dw) / 2.0
        let dy := (sh - dh) / 2.0
        frame.drawScaled 0 0 fwf fhf dx dy dw dh FlipFlags.none

      -- Position overlay
      let pos ← video.position Allegro.VideoPosition.actual
      let posStr := if finished then "Finished"
                    else if paused then s!"Paused  {pos.toString.take 5}s"
                    else s!"Playing {pos.toString.take 5}s"
      font.drawTextRgb 255 255 100 8 8 Allegro.TextAlign.left posStr

      if finished then
        font.drawTextRgb 200 200 200 (screenW.toFloat / 2) (screenH.toFloat / 2)
          Allegro.TextAlign.centre "Video ended — press ESC to exit"

      Allegro.flipDisplay
      redraw := false

  -- ── Cleanup ──
  timer.stop
  timer.destroy
  evt.destroy
  queue.destroy
  video.close
  Allegro.shutdownVideoAddon
  font.destroy
  display.destroy
  Allegro.uninstallAudio
  Allegro.shutdownFontAddon
  Allegro.shutdownImageAddon
