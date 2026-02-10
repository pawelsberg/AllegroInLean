-- TransformExtrasDemo — demonstrates gap-fill 3D Transform APIs.
-- Graphical — needs a display for transform operations.
--
-- Showcases: translateTransform3d, rotateTransform3d, scaleTransform3d,
--            transformCoordinates3d, transformCoordinates3dProjective,
--            transformCoordinates4d, buildCameraTransform,
--            getCurrentInverseTransform, transposeTransform
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.initPrimitivesAddon

  IO.println "── Transform Extras (3D) Demo ──"

  Allegro.setNewDisplayFlags ⟨0⟩
  let display ← Allegro.createDisplay 320 200
  if display == 0 then
    IO.eprintln "  createDisplay failed"; Allegro.uninstallSystem; return

  -- Create a 3D transform
  let t ← Allegro.createTransform
  t.identity

  -- 3D translation
  t.translate3d 10.0 20.0 30.0
  IO.println "  translateTransform3d(10,20,30) — OK"

  -- 3D rotation around Y axis, 45 degrees
  t.rotate3d 0.0 1.0 0.0 0.785
  IO.println "  rotateTransform3d(Y, 0.785 rad) — OK"

  -- 3D scaling
  t.scale3d 2.0 2.0 2.0
  IO.println "  scaleTransform3d(2,2,2) — OK"

  -- transformCoordinates3d — transform a point
  let (x1, y1, z1) ← t.transformCoords3d 1.0 0.0 0.0
  IO.println s!"  transformCoordinates3d(1,0,0) = ({x1}, {y1}, {z1})"

  -- transformCoordinates3dProjective
  let (px, py, pz) ← t.transformCoords3dProjective 1.0 0.0 0.0
  IO.println s!"  transformCoordinates3dProjective(1,0,0) = ({px}, {py}, {pz})"

  -- transformCoordinates4d
  let (hx, hy, hz, hw) ← t.transformCoords4d 1.0 0.0 0.0 1.0
  IO.println s!"  transformCoordinates4d(1,0,0,1) = ({hx}, {hy}, {hz}, {hw})"

  -- transposeTransform
  t.transpose
  IO.println "  transposeTransform — OK"

  -- Build a camera (look-at) transform
  let cam ← Allegro.createTransform
  cam.buildCamera
    0.0 0.0 5.0    -- position: (0,0,5)
    0.0 0.0 0.0    -- look-at:  origin
    0.0 1.0 0.0    -- up:       Y
  IO.println "  buildCameraTransform — OK"

  -- Apply it and get the inverse
  cam.use
  let inv ← Allegro.getCurrentInverseTransform
  IO.println s!"  getCurrentInverseTransform = {inv} (non-zero expected)"

  cam.destroy
  t.destroy
  display.destroy
  Allegro.shutdownPrimitivesAddon
  Allegro.uninstallSystem
  IO.println "── done ──"
