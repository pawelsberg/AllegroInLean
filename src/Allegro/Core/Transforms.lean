/-!
Transform creation and manipulation for Allegro 5.

Provides 2D (and projection) matrix transforms: translate, rotate, scale,
compose, invert, and coordinate mapping. Transforms are heap-allocated
handles that must be destroyed when no longer needed.

## Typical usage
```
let t ← Allegro.createTransform        -- identity by default
Allegro.translateTransform t 100.0 50.0
Allegro.rotateTransform t 0.5
Allegro.useTransform t
-- draw stuff --
Allegro.destroyTransform t
```
-/
namespace Allegro

/-- Opaque handle to a 2D/3D transform matrix. -/
def Transform := UInt64

instance : BEq Transform := inferInstanceAs (BEq UInt64)
instance : Inhabited Transform := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Transform := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Transform 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Transform := ⟨fun (h : UInt64) => s!"Transform#{h}"⟩
instance : Repr Transform := ⟨fun (h : UInt64) _ => .text s!"Transform#{repr h}"⟩

/-- The null transform handle. -/
def Transform.null : Transform := (0 : UInt64)

/-- Allocate a new identity transform. Must be freed with `destroyTransform`. -/
@[extern "allegro_al_create_transform"]
opaque createTransform : IO Transform

/-- Free a transform previously obtained from `createTransform` or `getCurrentTransform`. -/
@[extern "allegro_al_destroy_transform"]
opaque destroyTransform : Transform → IO Unit

/-- Reset a transform to the identity matrix. -/
@[extern "allegro_al_identity_transform"]
opaque identityTransform : Transform → IO Unit

/-- Copy the contents of `src` into `dest`. -/
@[extern "allegro_al_copy_transform"]
opaque copyTransform (dest : Transform) (src : Transform) : IO Unit

/-- Make `transform` the current transform used for drawing. -/
@[extern "allegro_al_use_transform"]
opaque useTransform : Transform → IO Unit

/-- Get a copy of the current transform. Caller must free the result. -/
@[extern "allegro_al_get_current_transform"]
opaque getCurrentTransform : IO Transform

/-- Apply a translation to the transform. -/
@[extern "allegro_al_translate_transform"]
opaque translateTransform : Transform → Float → Float → IO Unit

/-- Apply a rotation (in radians) to the transform. -/
@[extern "allegro_al_rotate_transform"]
opaque rotateTransform : Transform → Float → IO Unit

/-- Apply a scaling to the transform. -/
@[extern "allegro_al_scale_transform"]
opaque scaleTransform : Transform → Float → Float → IO Unit

/-- Build a transform from position, scale and rotation in one call.
    `buildTransform t x y sx sy theta` -/
@[extern "allegro_al_build_transform"]
opaque buildTransform : Transform → Float → Float → Float → Float → Float → IO Unit

/-- Compose: `transform := transform * other`. -/
@[extern "allegro_al_compose_transform"]
opaque composeTransform : Transform → Transform → IO Unit

/-- Invert the transform in place. -/
@[extern "allegro_al_invert_transform"]
opaque invertTransform : Transform → IO Unit

/-- Check if the transform is invertible within `tolerance`. Returns 1 if yes. -/
@[extern "allegro_al_check_inverse"]
opaque checkInverse : Transform → Float → IO UInt32

/-- Transform coordinates: returns `(x', y')` in one call. -/
@[extern "allegro_al_transform_coordinates"]
opaque transformCoordinates : Transform → Float → Float → IO (Float × Float)

/-- Set the current projection transform. -/
@[extern "allegro_al_use_projection_transform"]
opaque useProjectionTransform : Transform → IO Unit

/-- Get a copy of the current projection transform. Caller must free the result. -/
@[extern "allegro_al_get_current_projection_transform"]
opaque getCurrentProjectionTransform : IO Transform

/-- Set up an orthographic projection transform.
    `orthographicTransform t left top near right bottom far` -/
@[extern "allegro_al_orthographic_transform"]
opaque orthographicTransform : Transform → Float → Float → Float → Float → Float → Float → IO Unit

/-- Set up a perspective projection transform.
    `perspectiveTransform t left top near right bottom far` -/
@[extern "allegro_al_perspective_transform"]
opaque perspectiveTransform : Transform → Float → Float → Float → Float → Float → Float → IO Unit

/-- Apply a horizontal shear to the transform. -/
@[extern "allegro_al_horizontal_shear_transform"]
opaque horizontalShearTransform : Transform → Float → IO Unit

/-- Apply a vertical shear to the transform. -/
@[extern "allegro_al_vertical_shear_transform"]
opaque verticalShearTransform : Transform → Float → IO Unit

-- ── 3D transforms ──

/-- Apply a 3D translation to the transform. -/
@[extern "allegro_al_translate_transform_3d"]
opaque translateTransform3d : Transform → Float → Float → Float → IO Unit

/-- Apply a 3D rotation around axis `(x, y, z)` by `angle` radians. -/
@[extern "allegro_al_rotate_transform_3d"]
opaque rotateTransform3d : Transform → Float → Float → Float → Float → IO Unit

/-- Apply a 3D scaling to the transform. -/
@[extern "allegro_al_scale_transform_3d"]
opaque scaleTransform3d : Transform → Float → Float → Float → IO Unit

/-- Transform 3D coordinates, returning `(x', y', z')`. -/
@[extern "allegro_al_transform_coordinates_3d"]
opaque transformCoordinates3d : Transform → Float → Float → Float → IO (Float × Float × Float)

/-- Transform 3D coordinates with perspective division, returning `(x', y', z')`. -/
@[extern "allegro_al_transform_coordinates_3d_projective"]
opaque transformCoordinates3dProjective : Transform → Float → Float → Float → IO (Float × Float × Float)

/-- Transform 4D (homogeneous) coordinates, returning `(x', y', z', w')`. -/
@[extern "allegro_al_transform_coordinates_4d"]
opaque transformCoordinates4d : Transform → Float → Float → Float → Float → IO (Float × Float × Float × Float)

/-- Build a camera (look-at) transform.
    `buildCameraTransform t posX posY posZ lookX lookY lookZ upX upY upZ` -/
@[extern "allegro_al_build_camera_transform"]
opaque buildCameraTransform : Transform → Float → Float → Float → Float → Float → Float → Float → Float → Float → IO Unit

/-- Get a copy of the inverse of the current transform. Caller must free the result. -/
@[extern "allegro_al_get_current_inverse_transform"]
opaque getCurrentInverseTransform : IO Transform

/-- Transpose a transformation matrix in place. -/
@[extern "allegro_al_transpose_transform"]
opaque transposeTransform : Transform → IO Unit

end Allegro
