-- PrimitivesExtrasDemo — demonstrates gap-fill Primitives APIs.
-- Graphical — needs a display for drawing operations.
--
-- Showcases: drawPrim (via drawPrimBA), drawIndexedPrim (via drawIndexedPrimBA),
--            drawFilledPolygonWithHoles, triangulatePolygon,
--            calculateArc, calculateSpline, calculateRibbon,
--            createVertexDecl, destroyVertexDecl,
--            lockVertexBuffer, unlockVertexBuffer,
--            lockIndexBuffer, unlockIndexBuffer, destroyIndexBuffer,
--            getPrimitivesVersion
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.initPrimitivesAddon
  let _ ← Allegro.initImageAddon

  IO.println "── Primitives Extras Demo ──"

  Allegro.setNewDisplayFlags ⟨0⟩
  let display ← Allegro.createDisplay 640 480
  if display == 0 then
    IO.eprintln "  createDisplay failed"; Allegro.uninstallSystem; return

  let ver ← Allegro.getPrimitivesVersion
  IO.println s!"  getPrimitivesVersion = {ver}"

  Allegro.clearToColorRgb 0 0 0

  -- ── drawPrimBA: draw a triangle from packed vertex data ──
  -- ALLEGRO_VERTEX layout: x y z u v r g b a (9 × f32 = 36 bytes/vertex)
  let triVtx := Allegro.packFloats #[
    -- Red vertex
    100.0, 400.0, 0.0,  0.0, 0.0,  1.0, 0.0, 0.0, 1.0,
    -- Green vertex
    320.0, 50.0, 0.0,   0.0, 0.0,  0.0, 1.0, 0.0, 1.0,
    -- Blue vertex
    540.0, 400.0, 0.0,  0.0, 0.0,  0.0, 0.0, 1.0, 1.0
  ]
  let drawn ← Allegro.drawPrimBA triVtx 0 0 0 3 Allegro.PrimType.triangleList
  IO.println s!"  drawPrimBA triangle = {drawn} primitives drawn"

  -- ── drawIndexedPrimBA: draw the same triangle with an index array ──
  let drawn2 ← Allegro.drawIndexedPrimBA triVtx 0 0 #[0, 1, 2] 3 Allegro.PrimType.triangleList
  IO.println s!"  drawIndexedPrimBA triangle = {drawn2} primitives drawn"

  -- ── calculateArc: compute arc vertices ──
  let arcPts ← Allegro.calculateArc 320.0 240.0 100.0 100.0 0.0 6.28 2.0 32
  IO.println s!"  calculateArc → {arcPts.size} bytes"

  -- ── calculateSpline: compute Bézier spline ──
  let splPts ← Allegro.calculateSpline 50.0 50.0 150.0 100.0 450.0 380.0 590.0 430.0 2.0 32
  IO.println s!"  calculateSpline → {splPts.size} bytes"

  -- ── calculateRibbon ──
  let ribPts := Allegro.packPoints [(50.0, 50.0), (200.0, 100.0), (400.0, 200.0), (600.0, 300.0)]
  let ribbon ← Allegro.calculateRibbon ribPts 4.0 3
  IO.println s!"  calculateRibbon → {ribbon.size} bytes"

  -- ── triangulatePolygon ──
  let polyVerts := Allegro.packPoints [(0.0, 0.0), (0.0, 100.0), (100.0, 100.0), (100.0, 0.0)]
  let tris ← Allegro.triangulatePolygon polyVerts #[(4 : UInt32)]
  IO.println s!"  triangulatePolygon → {tris.size} triangles"

  -- ── drawFilledPolygonWithHolesRgb ──
  Allegro.drawFilledPolygonWithHolesRgb polyVerts #[(4 : UInt32)] 255 200 0
  IO.println "  drawFilledPolygonWithHolesRgb — OK"

  -- ── createVertexDecl / destroyVertexDecl ──
  let decl ← Allegro.createVertexDecl
    #[(Allegro.PrimAttr.position, Allegro.PrimStorage.float3, 0),
      (Allegro.PrimAttr.color, Allegro.PrimStorage.float4, 20)]
    36
  IO.println s!"  createVertexDecl = {decl}"
  if decl != 0 then
    decl.destroy
    IO.println "  destroyVertexDecl — OK"

  -- ── Vertex/Index buffer lifecycle ──
  let vb ← Allegro.createVertexBuffer 0 4 Allegro.PrimBufferFlags.static
  if vb != 0 then
    let ptr ← vb.lock 0 4 ⟨0⟩
    IO.println s!"  lockVertexBuffer = {ptr}"
    if ptr != 0 then
      vb.unlock
      IO.println "  unlockVertexBuffer — OK"
    vb.destroy
    IO.println "  destroyVertexBuffer — OK"
  else
    IO.println "  createVertexBuffer returned null (GPU not available — OK)"

  -- ── Index buffer lifecycle ──
  let ib ← Allegro.createIndexBuffer (4 : UInt32) (6 : UInt32) Allegro.PrimBufferFlags.static
  if ib != 0 then
    let iptr ← ib.lock (0 : UInt32) (6 : UInt32) ⟨0⟩
    IO.println s!"  lockIndexBuffer = {iptr}"
    if iptr != 0 then
      ib.unlock
      IO.println "  unlockIndexBuffer — OK"
    ib.destroy
    IO.println "  destroyIndexBuffer — OK"
  else
    IO.println "  createIndexBuffer returned null (GPU not available — OK)"

  Allegro.flipDisplay
  IO.println "  flipDisplay — triangle visible for 1 second"
  Allegro.rest 1.0

  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.shutdownImageAddon
  Allegro.uninstallSystem
  IO.println "── done ──"
