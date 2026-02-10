import Allegro

/-!
# GameLoopDemo — "Catch the Stars" mini-game

An end-to-end sample combining:
- Fixed-timestep game loop (60 FPS timer)
- Keyboard input (arrow keys to move, ESC to quit)
- Primitives drawing (player paddle, falling stars, background)
- Font rendering (score display, title, game-over text)
- Audio playback (beep on star catch)

Run: `lake build allegroGameLoopDemo && .lake/build/bin/allegroGameLoopDemo`
-/

open Allegro

-- ── Constants ──

def screenW : Float := 640
def screenH : Float := 480
def paddleW : Float := 80
def paddleH : Float := 16
def paddleSpeed : Float := 6
def starSize  : Float := 10
def maxStars  : Nat := 12
def starSpawnInterval : Nat := 40  -- ticks between new stars
def initialFallSpeed : Float := 2.0
def speedIncrement : Float := 0.002  -- gets faster over time

-- ── Star state ──

structure Star where
  x : Float
  y : Float
  speed : Float
  r : UInt32
  g : UInt32
  b : UInt32

-- ── Game state ──

structure GameState where
  paddleX    : Float
  stars      : Array Star
  score      : Nat
  tickCount  : Nat
  fallSpeed  : Float
  gameOver   : Bool
  leftHeld   : Bool
  rightHeld  : Bool

def initState : GameState :=
  { paddleX   := (screenW - paddleW) / 2
  , stars     := #[]
  , score     := 0
  , tickCount := 0
  , fallSpeed := initialFallSpeed
  , gameOver  := false
  , leftHeld  := false
  , rightHeld := false
  }

-- ── Pseudo-random via LCG ──

def lcgNext (seed : UInt64) : UInt64 :=
  seed * 6364136223846793005 + 1442695040888963407

def lcgFloat (seed : UInt64) (lo hi : Float) : Float :=
  let frac := (seed.toFloat / 18446744073709551616.0)  -- 2^64
  lo + frac * (hi - lo)

-- ── Star spawning ──

def spawnStar (seed : UInt64) (fallSpd : Float) : Star × UInt64 :=
  let s1 := lcgNext seed
  let sx := lcgFloat s1 (starSize) (screenW - starSize)
  let s2 := lcgNext s1
  let sr := (s2.toNat % 156 + 100).toUInt32
  let s3 := lcgNext s2
  let sg := (s3.toNat % 156 + 100).toUInt32
  let s4 := lcgNext s3
  let sb := (s4.toNat % 156 + 100).toUInt32
  let star : Star := { x := sx, y := -starSize, speed := fallSpd, r := sr, g := sg, b := sb }
  (star, s4)

-- ── Update logic ──

def updatePaddle (gs : GameState) : GameState :=
  let dx := (if gs.rightHeld then paddleSpeed else 0) - (if gs.leftHeld then paddleSpeed else 0)
  let nx := gs.paddleX + dx
  let nx := if nx < 0 then 0 else if nx > screenW - paddleW then screenW - paddleW else nx
  { gs with paddleX := nx }

def updateStars (gs : GameState) : GameState × Nat := Id.run do
  let paddleY := screenH - 40
  let mut kept : Array Star := #[]
  let mut caught : Nat := 0
  for star in gs.stars do
    let ny := star.y + star.speed
    if ny > screenH + starSize then
      -- missed — fell off bottom
      kept := kept
    else if ny + starSize >= paddleY && ny - starSize <= paddleY + paddleH &&
            star.x >= gs.paddleX - starSize && star.x <= gs.paddleX + paddleW + starSize then
      caught := caught + 1
    else
      kept := kept.push { star with y := ny }
  return ({ gs with stars := kept, score := gs.score + caught }, caught)

def updateTick (gs : GameState) (seed : UInt64) : GameState × UInt64 :=
  if gs.gameOver then (gs, seed)
  else
    let gs := updatePaddle gs
    let (gs, _caught) := updateStars gs
    let gs := { gs with tickCount := gs.tickCount + 1, fallSpeed := gs.fallSpeed + speedIncrement }
    -- spawn new star periodically
    if gs.tickCount % starSpawnInterval == 0 && gs.stars.size < maxStars then
      let (star, seed') := spawnStar seed gs.fallSpeed
      ({ gs with stars := gs.stars.push star }, seed')
    else
      (gs, seed)

-- ── Drawing ──

def drawStars (stars : Array Star) : IO Unit := do
  for star in stars do
    -- Draw a 4-pointed star shape using filled triangles
    let cx := star.x
    let cy := star.y
    let s := starSize
    -- Vertical diamond
    Allegro.drawFilledTriangleRgb cx (cy - s) (cx - s/2) cy cx (cy + s) star.r star.g star.b
    Allegro.drawFilledTriangleRgb cx (cy - s) (cx + s/2) cy cx (cy + s) star.r star.g star.b
    -- Horizontal diamond
    Allegro.drawFilledTriangleRgb (cx - s) cy cx (cy - s/2) (cx + s) cy star.r star.g star.b
    Allegro.drawFilledTriangleRgb (cx - s) cy cx (cy + s/2) (cx + s) cy star.r star.g star.b

def drawScene (gs : GameState) (font : Allegro.Font) : IO Unit := do
  -- Background
  Allegro.clearToColorRgb 10 10 30

  -- Stars
  drawStars gs.stars

  -- Paddle
  let paddleY := screenH - 40
  Allegro.drawFilledRoundedRectangleRgb gs.paddleX paddleY (gs.paddleX + paddleW) (paddleY + paddleH) 4 4 100 200 255

  -- Score
  let centre := Allegro.alignCentre
  Allegro.drawTextRgb font 255 255 100 (screenW / 2) 10 centre s!"Score: {gs.score}"

  -- Game over overlay
  if gs.gameOver then
    Allegro.drawTextRgb font 255 80 80 (screenW / 2) (screenH / 2 - 20) centre "GAME OVER"
    Allegro.drawTextRgb font 200 200 200 (screenW / 2) (screenH / 2 + 20) centre "Press ESC to exit"

  Allegro.flipDisplay

-- ── Main ──

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then
    IO.eprintln "Failed to initialise Allegro"
    return

  let _ ← Allegro.initImageAddon
  Allegro.initFontAddon
  let _ ← Allegro.initTtfAddon
  let _ ← Allegro.initPrimitivesAddon
  let _ ← Allegro.installAudio
  let _ ← Allegro.initAcodecAddon
  let _ ← Allegro.installKeyboard

  Allegro.setNewDisplayFlags ⟨0⟩
  let display ← Allegro.createDisplay screenW.toUInt32 screenH.toUInt32
  if display == 0 then
    IO.eprintln "Failed to create display"
    return

  -- Load font
  let font : Font ← Allegro.loadTtfFont "data/DejaVuSans.ttf" 20 0
  let font : Font ← if font == 0 then Allegro.createBuiltinFont else pure font

  -- Reserve samples and load beep
  let _ ← Allegro.reserveSamples 4
  let beep : Sample ← Allegro.loadSample "data/beep.wav"

  -- Timer at 60 FPS
  let timer ← Allegro.createTimer (1.0 / 60.0)

  -- Event queue and pre-allocated event struct
  let queue ← Allegro.createEventQueue
  let evt ← Allegro.createEvent
  let dispSrc ← display.eventSource
  queue.registerSource dispSrc
  let kbSrc ← Allegro.getKeyboardEventSource
  queue.registerSource kbSrc
  let timerSrc ← timer.eventSource
  queue.registerSource timerSrc

  timer.start

  -- Key constants
  let keyLeft  := Allegro.keyLeft
  let keyRight := Allegro.keyRight
  let keyEsc   := Allegro.keyEscape

  -- Event type constants
  let evtKeyDown      := Allegro.eventTypeKeyDown
  let evtKeyUp        := Allegro.eventTypeKeyUp
  let evtDisplayClose := Allegro.eventTypeDisplayClose
  let evtTimer        := Allegro.eventTypeTimer

  let mut gs := initState
  let mut seed : UInt64 := 123456789
  let mut redraw := false
  let mut running := true

  while running do
    queue.waitFor evt
    let eType ← evt.type

    if eType == evtDisplayClose then
      running := false
    else if eType == evtKeyDown then
      let kc : KeyCode := ⟨← evt.keyboardKeycode⟩
      if kc == keyEsc then
        running := false
      else if kc == keyLeft then
        gs := { gs with leftHeld := true }
      else if kc == keyRight then
        gs := { gs with rightHeld := true }
    else if eType == evtKeyUp then
      let kc : KeyCode := ⟨← evt.keyboardKeycode⟩
      if kc == keyLeft then
        gs := { gs with leftHeld := false }
      else if kc == keyRight then
        gs := { gs with rightHeld := false }
    else if eType == evtTimer then
      -- Update game
      let oldScore := gs.score
      let (gs', seed') := updateTick gs seed
      gs := gs'
      seed := seed'
      -- Play beep on catch
      if gs.score > oldScore && beep != 0 then
        let _ ← beep.play 1.0 0.0 1.0 Playmode.once
        pure ()
      redraw := true

    -- Draw at most once per iteration when caught up on events
    if redraw && (← queue.isEmpty) == 1 then
      drawScene gs font
      redraw := false

  -- Cleanup
  timer.stop
  timer.destroy
  evt.destroy
  queue.destroy
  if beep != 0 then beep.destroy
  font.destroy
  display.destroy
  Allegro.uninstallAudio
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownTtfAddon
  Allegro.shutdownFontAddon
  Allegro.shutdownImageAddon
