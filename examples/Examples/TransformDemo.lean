-- Transform & Blending demo.
--
-- Draws several shapes that rotate and pulse using transforms, with
-- semi-transparent blending. Use arrow keys to translate the scene,
-- W/S to zoom, and Escape to quit.
--
-- Showcases: Transforms, Blending, Keyboard state polling, Timer-driven game loop
import Allegro

open Allegro

def main : IO Unit := do
  -- ── Init ──
  let okInit ← Allegro.init
  if okInit == 0 then
    IO.eprintln "al_init failed"; return

  let _ ← Allegro.installKeyboard
  let _ ← Allegro.installMouse
  let _ ← Allegro.initPrimitivesAddon
  Allegro.initFontAddon

  let flags := Allegro.fullscreenWindowFlag
  Allegro.setNewDisplayFlags flags
  let _ ← Allegro.createDisplay 800 600

  let display : Display ← Allegro.getCurrentDisplay
  let dw ← display.width
  let dh ← display.height
  let hw := Float.ofScientific dw.toNat true 0 / 2.0
  let hh := Float.ofScientific dh.toNat true 0 / 2.0

  let timer ← Allegro.createTimer (1.0 / 60.0)
  let queue ← Allegro.createEventQueue

  let displaySrc ← display.eventSource
  let kbSrc ← Allegro.getKeyboardEventSource
  let timerSrc ← timer.eventSource

  queue.registerSource displaySrc
  queue.registerSource kbSrc
  queue.registerSource timerSrc
  timer.start

  let evDisplayClose := Allegro.eventTypeDisplayClose
  let evTimer := Allegro.eventTypeTimer
  let event ← Allegro.createEvent
  let kbState ← Allegro.createKeyboardState

  let kEsc := Allegro.keyEscape
  let kLeft := Allegro.keyLeft
  let kRight := Allegro.keyRight
  let kUp := Allegro.keyUp
  let kDown := Allegro.keyArrowDown
  let kPlus := Allegro.keyW  -- W to zoom in
  let kMinus := Allegro.keyS -- S to zoom out

  -- Blending constants
  let bAdd := Allegro.blendAdd
  let bAlpha := Allegro.blendAlpha
  let bInvAlpha := Allegro.blendInverseAlpha
  let bOne := Allegro.blendOne

  let builtinFont : Font ← Allegro.createBuiltinFont

  -- Mutable state
  let angleRef ← IO.mkRef (0.0 : Float)
  let panXRef ← IO.mkRef (0.0 : Float)
  let panYRef ← IO.mkRef (0.0 : Float)
  let zoomRef ← IO.mkRef (1.5 : Float)
  let doneRef ← IO.mkRef false

  while true do
    let done ← doneRef.get
    if done then break

    queue.waitFor event
    let evType ← event.type

    if evType == evDisplayClose then
      doneRef.set true

    else if evType == evTimer then do
      -- Poll keyboard
      kbState.get
      let escDown ← kbState.keyDown kEsc
      if escDown != 0 then
        doneRef.set true

      let leftDown ← kbState.keyDown kLeft
      let rightDown ← kbState.keyDown kRight
      let upDown ← kbState.keyDown kUp
      let downDown ← kbState.keyDown kDown
      let plusDown ← kbState.keyDown kPlus
      let minusDown ← kbState.keyDown kMinus

      let panSpeed := 4.0
      if leftDown != 0 then panXRef.modify (· - panSpeed)
      if rightDown != 0 then panXRef.modify (· + panSpeed)
      if upDown != 0 then panYRef.modify (· - panSpeed)
      if downDown != 0 then panYRef.modify (· + panSpeed)
      if plusDown != 0 then zoomRef.modify (· + 0.01)
      if minusDown != 0 then zoomRef.modify fun z => max 0.1 (z - 0.01)

      angleRef.modify (· + 0.02)

      -- ── Draw ──
      let angle ← angleRef.get
      let panX ← panXRef.get
      let panY ← panYRef.get
      let zoom ← zoomRef.get

      -- Clear background
      Allegro.clearToColorRgb 20 20 40

      -- Camera: world (0,0) → screen centre; zoom scales around world origin
      let camera ← Allegro.createTransform
      camera.translate (0.0 - panX) (0.0 - panY)
      camera.scale zoom zoom
      camera.translate hw hh

      -- ── Shape 1: rotating filled rectangle (opaque) ──
      let t1 ← Allegro.createTransform
      t1.build 0.0 0.0 1.0 1.0 angle
      t1.compose camera
      t1.use
      Allegro.setBlender bAdd bOne bInvAlpha
      Allegro.drawFilledRectangleRgb (-60.0) (-40.0) 60.0 40.0 200 60 60
      t1.destroy

      -- ── Shape 2: rotating + pulsing circle (semi-transparent) ──
      let pulse := 1.0 + 0.3 * Float.sin (angle * 2.0)
      let t2 ← Allegro.createTransform
      t2.build (-150.0) (-100.0) pulse pulse (0.0 - angle * 0.5)
      t2.compose camera
      t2.use
      Allegro.setBlender bAdd bAlpha bInvAlpha
      Allegro.drawFilledCircleRgb 0.0 0.0 50.0 60 180 220
      t2.destroy

      -- ── Shape 3: orbiting triangle ──
      let t3 ← Allegro.createTransform
      let orbitX := 200.0 * Float.cos angle
      let orbitY := 200.0 * Float.sin angle
      t3.build orbitX orbitY 1.0 1.0 (angle * 3.0)
      t3.compose camera
      t3.use
      Allegro.setBlender bAdd bOne bInvAlpha
      Allegro.drawTriangleRgb (-25.0) 20.0 25.0 20.0 0.0 (-25.0) 100 220 100 2.0
      t3.destroy

      -- ── Shape 4: rotating line star ──
      let t4 ← Allegro.createTransform
      t4.build 150.0 100.0 1.0 1.0 (angle * 1.5)
      t4.compose camera
      t4.use
      Allegro.drawLineRgb (-40.0) 0.0 40.0 0.0 255 255 100 2.0
      Allegro.drawLineRgb 0.0 (-40.0) 0.0 40.0 255 255 100 2.0
      Allegro.drawLineRgb (-28.0) (-28.0) 28.0 28.0 255 200 50 2.0
      Allegro.drawLineRgb (-28.0) 28.0 28.0 (-28.0) 255 200 50 2.0
      t4.destroy

      -- ── HUD (identity transform, on top) ──
      let identity ← Allegro.createTransform
      identity.use
      Allegro.setBlender bAdd bAlpha bInvAlpha
      builtinFont.drawTextRgb 220 220 220 10.0 10.0 0
        "Arrows=pan  W/S=zoom  Esc=quit"
      let zoomStr := s!"zoom: {zoom}"
      builtinFont.drawTextRgb 220 220 220 10.0 26.0 0 zoomStr
      identity.destroy
      camera.destroy

      Allegro.flipDisplay

  -- ── Cleanup ──
  builtinFont.destroy
  Allegro.destroyKeyboardState kbState
  event.destroy
  queue.destroy
  timer.destroy
  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownFontAddon
  Allegro.uninstallSystem
