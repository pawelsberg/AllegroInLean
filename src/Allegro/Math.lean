/-!
# Common Math Utilities for Game Development

Provides frequently-needed math helpers that are missing from the Lean 4
standard library. These appear in virtually every game built with AllegroInLean.

## Highlights
- `toFloat` — convert `Nat`/`UInt32` to `Float` without verbose `Float.ofScientific`
- `clampF`, `lerpF`, `distF`, `absF` — basic game math
- `pi`, `tau` — common constants
-/
namespace Allegro

-- ── Conversion helpers ──

/-- Convert a `Nat` to `Float`. Eliminates the verbose `Float.ofScientific n false 0` pattern. -/
@[inline] def toFloat (n : Nat) : Float := Float.ofScientific n false 0

/-- Convert a `UInt32` to `Float`. -/
@[inline] def u32ToFloat (n : UInt32) : Float := Float.ofScientific n.toNat false 0

/-- Convert an `Int` to `Float`. -/
@[inline] def intToFloat (n : Int) : Float :=
  match n with
  | Int.ofNat k => Float.ofScientific k false 0
  | Int.negSucc k => -(Float.ofScientific (k + 1) false 0)

-- ── Constants ──

/-- π ≈ 3.14159265358979323846 -/
def pi : Float := 3.14159265358979323846

/-- τ = 2π ≈ 6.28318530717958647692 -/
def tau : Float := 6.28318530717958647692

-- ── Basic math operations ──

/-- Absolute value for Float. -/
@[inline] def absF (x : Float) : Float := if x < 0.0 then -x else x

/-- Clamp a Float to the range [lo, hi]. -/
@[inline] def clampF (lo hi x : Float) : Float :=
  if x < lo then lo
  else if x > hi then hi
  else x

/-- Linear interpolation from `a` to `b` by factor `t` (0.0–1.0). -/
@[inline] def lerpF (a b t : Float) : Float := a + (b - a) * t

/-- Euclidean distance between two 2D points. -/
@[inline] def distF (x1 y1 x2 y2 : Float) : Float :=
  let dx := x2 - x1
  let dy := y2 - y1
  Float.sqrt (dx * dx + dy * dy)

/-- Squared distance between two 2D points (avoids `sqrt`, useful for comparisons). -/
@[inline] def distSqF (x1 y1 x2 y2 : Float) : Float :=
  let dx := x2 - x1
  let dy := y2 - y1
  dx * dx + dy * dy

/-- Minimum of two Floats. -/
@[inline] def minF (a b : Float) : Float := if a ≤ b then a else b

/-- Maximum of two Floats. -/
@[inline] def maxF (a b : Float) : Float := if a ≥ b then a else b

/-- Wrap an angle to the range [0, 2π). -/
@[inline] def wrapAngle (angle : Float) : Float :=
  let a := angle - Float.floor (angle / tau) * tau
  if a < 0.0 then a + tau else a

/-- Convert degrees to radians. -/
@[inline] def degToRad (deg : Float) : Float := deg * pi / 180.0

/-- Convert radians to degrees. -/
@[inline] def radToDeg (rad : Float) : Float := rad * 180.0 / pi

/-- Sign of a Float: -1.0, 0.0, or 1.0. -/
@[inline] def signF (x : Float) : Float :=
  if x > 0.0 then 1.0
  else if x < 0.0 then -1.0
  else 0.0

end Allegro
