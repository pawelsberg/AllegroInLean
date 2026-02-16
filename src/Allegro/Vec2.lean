import Allegro.Math

/-!
# 2D Vector Type for Game Development

A simple `Vec2` type for ergonomic coordinate handling.
Drawing functions still take separate `Float` parameters — use `v.x` / `v.y`
to pass them — but game state can use `Vec2` instead of pairs of floats.

## Example
```
let pos := Vec2.mk 100.0 200.0
let vel := Vec2.mk 3.0 (-1.5)
let newPos := pos + vel.scale dt
drawFilledCircleRgb newPos.x newPos.y 5.0 255 255 0
```
-/
namespace Allegro

/-- A 2D vector / point with Float components. -/
structure Vec2 where
  /-- X component. -/
  x : Float
  /-- Y component. -/
  y : Float
  deriving Inhabited, BEq, Repr

namespace Vec2

/-- The zero vector (0, 0). -/
def zero : Vec2 := ⟨0.0, 0.0⟩

/-- Component-wise addition. -/
@[inline] def add (a b : Vec2) : Vec2 := ⟨a.x + b.x, a.y + b.y⟩

/-- Component-wise subtraction. -/
@[inline] def sub (a b : Vec2) : Vec2 := ⟨a.x - b.x, a.y - b.y⟩

/-- Scale both components by a scalar. -/
@[inline] def scale (v : Vec2) (s : Float) : Vec2 := ⟨v.x * s, v.y * s⟩

/-- Negate both components. -/
@[inline] def neg (v : Vec2) : Vec2 := ⟨-v.x, -v.y⟩

/-- Dot product of two vectors. -/
@[inline] def dot (a b : Vec2) : Float := a.x * b.x + a.y * b.y

/-- Squared length (avoids sqrt). -/
@[inline] def lengthSq (v : Vec2) : Float := v.x * v.x + v.y * v.y

/-- Length (magnitude) of the vector. -/
@[inline] def length (v : Vec2) : Float := Float.sqrt (v.lengthSq)

/-- Distance between two points. -/
@[inline] def dist (a b : Vec2) : Float := (a.sub b).length

/-- Squared distance between two points. -/
@[inline] def distSq (a b : Vec2) : Float := (a.sub b).lengthSq

/-- Normalize to unit length. Returns zero vector if length is near zero. -/
def normalize (v : Vec2) : Vec2 :=
  let len := v.length
  if len < 1.0e-10 then zero
  else ⟨v.x / len, v.y / len⟩

/-- Linear interpolation between two vectors. -/
@[inline] def lerp (a b : Vec2) (t : Float) : Vec2 :=
  ⟨Allegro.lerpF a.x b.x t, Allegro.lerpF a.y b.y t⟩

/-- Rotate a vector by an angle (radians). -/
@[inline] def rotate (v : Vec2) (angle : Float) : Vec2 :=
  let c := Float.cos angle
  let s := Float.sin angle
  ⟨v.x * c - v.y * s, v.x * s + v.y * c⟩

/-- Angle from the positive X axis (radians, in [-π, π]). -/
@[inline] def angle (v : Vec2) : Float := Float.atan2 v.y v.x

/-- Perpendicular vector (rotated 90° counter-clockwise). -/
@[inline] def perp (v : Vec2) : Vec2 := ⟨-v.y, v.x⟩

/-- Clamp each component independently. -/
@[inline] def clamp (v : Vec2) (lo hi : Vec2) : Vec2 :=
  ⟨Allegro.clampF lo.x hi.x v.x, Allegro.clampF lo.y hi.y v.y⟩

end Vec2

-- Operator instances
instance : Add Vec2 where add := Vec2.add
instance : Sub Vec2 where sub := Vec2.sub
instance : Neg Vec2 where neg := Vec2.neg
instance : HMul Vec2 Float Vec2 where hMul v s := v.scale s
instance : HMul Float Vec2 Vec2 where hMul s v := v.scale s
instance : ToString Vec2 where toString v := s!"({v.x}, {v.y})"

end Allegro
