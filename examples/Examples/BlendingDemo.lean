-- Blending demo.
--
-- Draws overlapping semi-transparent shapes using different blend modes
-- so you can see how source and destination combine.  Press Escape or
-- close the window to quit.
--
-- Showcases: setBlender, getBlender, setSeparateBlender, getSeparateBlender,
--            clearToColorRgba, drawTintedBitmapRgba, blend constants,
--            drawFilledRectangleRgb, drawFilledCircleRgb, drawTextRgb.
import Allegro

open Allegro

def main : IO Unit := do
  -- ── Init ──
  let okInit ← Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"; return

  let _ ← Allegro.installKeyboard
  let _ ← Allegro.initPrimitivesAddon
  Allegro.initFontAddon

  let _ ← Allegro.createDisplay 640 480
  let display : Display ← Allegro.getCurrentDisplay
  let timer ← Allegro.createTimer (1.0 / 60.0)
  let queue ← Allegro.createEventQueue

  let displaySrc ← display.eventSource
  let kbSrc ← Allegro.getKeyboardEventSource
  let timerSrc ← timer.eventSource
  queue.registerSource displaySrc
  queue.registerSource kbSrc
  queue.registerSource timerSrc
  timer.start

  let evClose := Allegro.eventTypeDisplayClose
  let evTimer := Allegro.eventTypeTimer
  let evKeyDown := Allegro.eventTypeKeyDown
  let event ← Allegro.createEvent

  let font : Font ← Allegro.createBuiltinFont

  -- Blend constants
  let bAdd := Allegro.blendAdd
  let bSrcMinusDest := Allegro.blendSrcMinusDest
  let bOne := Allegro.blendOne
  let bAlpha := Allegro.blendAlpha
  let bInvAlpha := Allegro.blendInverseAlpha
  let bZero := Allegro.blendZero
  let bSrcColor := Allegro.blendSrcColor

  -- Cycle through blend modes with Space
  let modeRef ← IO.mkRef (0 : Nat)
  let doneRef ← IO.mkRef false

  while true do
    let done ← doneRef.get
    if done then break

    queue.waitFor event
    let evType ← event.type

    if evType == evClose then
      doneRef.set true

    else if evType == evKeyDown then
      let key ← event.keyboardKeycode
      if key == Allegro.keyEscape then
        doneRef.set true
      else if key == Allegro.keySpace then
        modeRef.modify (· + 1)

    else if evType == evTimer then
      let mode ← modeRef.get
      let modeIdx := mode % 4

      -- Clear with slight transparency
      Allegro.clearToColorRgba 20 20 30 255

      -- Set blend mode based on current selection
      let label ← match modeIdx with
        | 0 => do
          Allegro.setBlender bAdd bAlpha bInvAlpha
          pure "ADD / ALPHA / INV_ALPHA  (default)"
        | 1 => do
          Allegro.setBlender bAdd bOne bOne
          pure "ADD / ONE / ONE  (additive)"
        | 2 => do
          Allegro.setBlender bSrcMinusDest bOne bOne
          pure "SRC_MINUS_DEST / ONE / ONE  (subtract)"
        | _ => do
          Allegro.setBlender bAdd bSrcColor bZero
          pure "ADD / SRC_COLOR / ZERO  (multiply)"

      -- Draw overlapping shapes
      -- Red rectangle
      Allegro.drawFilledRectangleRgb 100 100 350 300 220 40 40
      -- Green rectangle (overlapping)
      Allegro.drawFilledRectangleRgb 200 150 450 350 40 200 40
      -- Blue circle (overlapping both)
      Allegro.drawFilledCircleRgb 350.0 250.0 120.0 40 40 220

      -- Query and display the current blender
      let (op, src, dst) ← Allegro.getBlender
      let blenderInfo := s!"blender: op={op} src={src} dst={dst}"

      -- Reset to normal blending for HUD text
      Allegro.setBlender bAdd bAlpha bInvAlpha
      font.drawTextRgb 255 255 255 10.0 10.0 0 label
      font.drawTextRgb 200 200 200 10.0 26.0 0 blenderInfo
      font.drawTextRgb 180 180 180 10.0 450.0 0
        "Space = cycle blend mode   Esc = quit"

      Allegro.flipDisplay

  -- ── Cleanup ──
  font.destroy
  event.destroy
  queue.destroy
  timer.destroy
  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownFontAddon
  Allegro.uninstallSystem
