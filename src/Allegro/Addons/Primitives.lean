import Allegro.Core.System

/-!
Primitives addon bindings for Allegro 5.

Draw geometric shapes: lines, triangles, rectangles, rounded rectangles,
circles, ellipses, arcs, elliptical arcs, pieslices, splines, polylines,
polygons, and ribbons — both outlined and filled variants. Vertex and
index buffer management for custom primitives.

All colour-accepting functions use an RGB triplet
(UInt32 × UInt32 × UInt32, each 0-255).

Array-based functions (polyline, polygon, ribbon) accept a `ByteArray`
containing packed little-endian 32-bit floats, where each consecutive pair
of floats is an (x, y) coordinate. Use the `packPoints` helper to build
these from a list of `(Float × Float)` pairs.

## Quick start
```
let _ ← Allegro.initPrimitivesAddon
Allegro.drawFilledCircleRgb 320.0 240.0 50.0 255 100 50
Allegro.drawSplineRgb 10 10  100 50  200 150  300 100  255 255 0 2.0
Allegro.shutdownPrimitivesAddon
```
-/
namespace Allegro

-- ── Handle types ──

/-- Opaque handle to a vertex buffer (GPU-side vertex storage). -/
def VertexBuffer := UInt64

instance : BEq VertexBuffer := inferInstanceAs (BEq UInt64)
instance : Inhabited VertexBuffer := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq VertexBuffer := inferInstanceAs (DecidableEq UInt64)
instance : OfNat VertexBuffer 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString VertexBuffer := ⟨fun (h : UInt64) => s!"VertexBuffer#{h}"⟩
instance : Repr VertexBuffer := ⟨fun (h : UInt64) _ => .text s!"VertexBuffer#{repr h}"⟩

/-- The null vertex buffer handle. -/
def VertexBuffer.null : VertexBuffer := (0 : UInt64)

/-- Opaque handle to an index buffer (GPU-side index storage). -/
def IndexBuffer := UInt64

instance : BEq IndexBuffer := inferInstanceAs (BEq UInt64)
instance : Inhabited IndexBuffer := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq IndexBuffer := inferInstanceAs (DecidableEq UInt64)
instance : OfNat IndexBuffer 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString IndexBuffer := ⟨fun (h : UInt64) => s!"IndexBuffer#{h}"⟩
instance : Repr IndexBuffer := ⟨fun (h : UInt64) _ => .text s!"IndexBuffer#{repr h}"⟩

/-- The null index buffer handle. -/
def IndexBuffer.null : IndexBuffer := (0 : UInt64)

-- ── Prim type constants ──

/-- Draw vertices as a list of separate lines (pairs). -/
def primTypeLineList : UInt32 := 0
/-- Draw vertices as a connected line strip. -/
def primTypeLineStrip : UInt32 := 1
/-- Draw vertices as a closed line loop. -/
def primTypeLineLoop : UInt32 := 2
/-- Draw vertices as a list of separate triangles (triples). -/
def primTypeTriangleList : UInt32 := 3
/-- Draw vertices as a connected triangle strip. -/
def primTypeTriangleStrip : UInt32 := 4
/-- Draw vertices as a triangle fan. -/
def primTypeTriangleFan : UInt32 := 5
/-- Draw vertices as separate points. -/
def primTypePointList : UInt32 := 6

-- ── Buffer flags ──

/-- Vertex/index buffer contents may be updated. -/
def primBufferStream : UInt32 := 0x01
/-- Vertex/index buffer contents are fixed after creation. -/
def primBufferStatic : UInt32 := 0x02
/-- Vertex/index buffer is dynamic but updated less frequently. -/
def primBufferDynamic : UInt32 := 0x04
/-- Buffer data can be read back (combine with |). -/
def primBufferReadwrite : UInt32 := 0x08

-- ── Line join / cap constants ──

/-- No joining between line segments. -/
def lineJoinNone : UInt32 := 0
/-- Bevel join — straight cut at the joint. -/
def lineJoinBevel : UInt32 := 1
/-- Round join. -/
def lineJoinRound : UInt32 := 2
/-- Miter join — sharp corner. -/
def lineJoinMiter : UInt32 := 3

/-- No line cap. -/
def lineCapNone : UInt32 := 0
/-- Square cap — extends line by half-thickness. -/
def lineCapSquare : UInt32 := 1
/-- Round cap. -/
def lineCapRound : UInt32 := 2
/-- Triangle cap. -/
def lineCapTriangle : UInt32 := 3
/-- Closed cap — joins first and last vertex. -/
def lineCapClosed : UInt32 := 4

-- ── Addon lifecycle ──

/-- Initialise the primitives addon. Returns non-zero on success. -/
@[extern "allegro_al_init_primitives_addon"]
opaque initPrimitivesAddon : IO UInt32

/-- Shut down the primitives addon. -/
@[extern "allegro_al_shutdown_primitives_addon"]
opaque shutdownPrimitivesAddon : IO Unit

/-- Check if the primitives addon is initialised. Returns 1 if yes. -/
@[extern "allegro_al_is_primitives_addon_initialized"]
opaque isPrimitivesAddonInitialized : IO UInt32

-- ── Line ──

/-- Draw a line from (x1,y1) to (x2,y2) with an RGB colour and thickness. -/
@[extern "allegro_al_draw_line_rgb"]
opaque drawLineRgb : Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

-- ── Triangle ──

/-- Draw an outlined triangle with an RGB colour and thickness. -/
@[extern "allegro_al_draw_triangle_rgb"]
opaque drawTriangleRgb : Float → Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

/-- Draw a filled triangle with an RGB colour. -/
@[extern "allegro_al_draw_filled_triangle_rgb"]
opaque drawFilledTriangleRgb : Float → Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Rectangle ──

/-- Draw an outlined rectangle with an RGB colour and thickness. -/
@[extern "allegro_al_draw_rectangle_rgb"]
opaque drawRectangleRgb : Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

/-- Draw a filled rectangle with an RGB colour. -/
@[extern "allegro_al_draw_filled_rectangle_rgb"]
opaque drawFilledRectangleRgb : Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Rounded rectangle ──

/-- `drawRoundedRectangleRgb x1 y1 x2 y2 rx ry r g b thickness` -/
@[extern "allegro_al_draw_rounded_rectangle_rgb"]
opaque drawRoundedRectangleRgb : Float → Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

/-- `drawFilledRoundedRectangleRgb x1 y1 x2 y2 rx ry r g b` -/
@[extern "allegro_al_draw_filled_rounded_rectangle_rgb"]
opaque drawFilledRoundedRectangleRgb : Float → Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Circle ──

/-- Draw an outlined circle with an RGB colour and thickness. -/
@[extern "allegro_al_draw_circle_rgb"]
opaque drawCircleRgb : Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

/-- Draw a filled circle with an RGB colour. -/
@[extern "allegro_al_draw_filled_circle_rgb"]
opaque drawFilledCircleRgb : Float → Float → Float → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Ellipse ──

/-- `drawEllipseRgb cx cy rx ry r g b thickness` -/
@[extern "allegro_al_draw_ellipse_rgb"]
opaque drawEllipseRgb : Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

/-- `drawFilledEllipseRgb cx cy rx ry r g b` -/
@[extern "allegro_al_draw_filled_ellipse_rgb"]
opaque drawFilledEllipseRgb : Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Arc ──

/-- `drawArcRgb cx cy radius startTheta deltaTheta r g b thickness` -/
@[extern "allegro_al_draw_arc_rgb"]
opaque drawArcRgb : Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

/-- `drawEllipticalArcRgb cx cy rx ry startTheta deltaTheta r g b thickness` -/
@[extern "allegro_al_draw_elliptical_arc_rgb"]
opaque drawEllipticalArcRgb : Float → Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

-- ── Pieslice ──

/-- `drawPiesliceRgb cx cy radius startTheta deltaTheta r g b thickness` -/
@[extern "allegro_al_draw_pieslice_rgb"]
opaque drawPiesliceRgb : Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

/-- `drawFilledPiesliceRgb cx cy radius startTheta deltaTheta r g b` -/
@[extern "allegro_al_draw_filled_pieslice_rgb"]
opaque drawFilledPiesliceRgb : Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Version ──

/-- Return the version of the primitives addon (packed integer). -/
@[extern "allegro_al_get_primitives_version"]
opaque getPrimitivesVersion : IO UInt32

-- ── Spline ──

/-- Draw a cubic Bézier spline through four control points.
    `drawSplineRgb x1 y1 x2 y2 x3 y3 x4 y4 r g b thickness` -/
@[extern "allegro_al_draw_spline_rgb"]
opaque drawSplineRgb : Float → Float → Float → Float → Float → Float → Float → Float → UInt32 → UInt32 → UInt32 → Float → IO Unit

-- ── Ribbon ──

/-- Draw a ribbon (sequence of thick line segments) through points.
    `points` is a `ByteArray` of packed 32-bit floats `[x₁, y₁, x₂, y₂, …]`.
    Use `packPoints` to build this from coordinate pairs.
    `numSegments` is the number of interpolation segments (0 = one per point). -/
@[extern "allegro_al_draw_ribbon_rgb"]
opaque drawRibbonRgb : ByteArray → UInt32 → UInt32 → UInt32 → Float → UInt32 → IO Unit

-- ── Polyline ──

/-- Draw a polyline through the given points.
    `points` is a `ByteArray` of packed 32-bit floats `[x₁, y₁, x₂, y₂, …]`.
    Use `lineJoin*` and `lineCap*` constants for join/cap styles. -/
@[extern "allegro_al_draw_polyline_rgb"]
opaque drawPolylineRgb : ByteArray → UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → Float → Float → IO Unit

-- ── Polygon ──

/-- Draw an outlined polygon. `points` is a `ByteArray` of packed 32-bit floats
    `[x₁, y₁, x₂, y₂, …]`. Uses `lineJoin*` for the join style. -/
@[extern "allegro_al_draw_polygon_rgb"]
opaque drawPolygonRgb : ByteArray → UInt32 → UInt32 → UInt32 → UInt32 → Float → Float → IO Unit

/-- Draw a filled polygon. `points` is a `ByteArray` of packed 32-bit floats
    `[x₁, y₁, x₂, y₂, …]`. -/
@[extern "allegro_al_draw_filled_polygon_rgb"]
opaque drawFilledPolygonRgb : ByteArray → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Vertex buffer management ──

/-- Create a vertex buffer. `decl` is a vertex declaration handle (0 for default ALLEGRO_VERTEX).
    Returns 0 on failure. -/
@[extern "allegro_al_create_vertex_buffer"]
opaque createVertexBuffer : UInt64 → UInt32 → UInt32 → IO VertexBuffer

/-- Destroy a vertex buffer. -/
@[extern "allegro_al_destroy_vertex_buffer"]
opaque destroyVertexBuffer : VertexBuffer → IO Unit

/-- Get the number of vertices in a vertex buffer. -/
@[extern "allegro_al_get_vertex_buffer_size"]
opaque getVertexBufferSize : VertexBuffer → IO UInt32

-- ── Index buffer management ──

/-- Create an index buffer. `indexSize` is the byte size per index (2 or 4).
    Returns 0 on failure. -/
@[extern "allegro_al_create_index_buffer"]
opaque createIndexBuffer : UInt32 → UInt32 → UInt32 → IO IndexBuffer

/-- Destroy an index buffer. -/
@[extern "allegro_al_destroy_index_buffer"]
opaque destroyIndexBuffer : IndexBuffer → IO Unit

/-- Get the number of indices in an index buffer. -/
@[extern "allegro_al_get_index_buffer_size"]
opaque getIndexBufferSize : IndexBuffer → IO UInt32

-- ── Drawing from buffers ──

/-- Draw primitives from a vertex buffer.
    `drawVertexBuffer vb texture start end type` -/
@[extern "allegro_al_draw_vertex_buffer"]
opaque drawVertexBuffer : VertexBuffer → UInt64 → UInt32 → UInt32 → UInt32 → IO UInt32

/-- Draw indexed primitives from vertex + index buffers.
    `drawIndexedBuffer vb texture ib start end type` -/
@[extern "allegro_al_draw_indexed_buffer"]
opaque drawIndexedBuffer : VertexBuffer → UInt64 → IndexBuffer → UInt32 → UInt32 → UInt32 → IO UInt32

-- ── Vertex / index buffer locking ──

/-- Lock a region of a vertex buffer for CPU access. Returns a raw pointer (0 on failure).
    `lockVertexBuffer vb offset length flags` -/
@[extern "allegro_al_lock_vertex_buffer"]
opaque lockVertexBuffer : VertexBuffer → UInt32 → UInt32 → UInt32 → IO UInt64

/-- Unlock a previously locked vertex buffer. -/
@[extern "allegro_al_unlock_vertex_buffer"]
opaque unlockVertexBuffer : VertexBuffer → IO Unit

/-- Lock a region of an index buffer for CPU access. Returns a raw pointer (0 on failure).
    `lockIndexBuffer ib offset length flags` -/
@[extern "allegro_al_lock_index_buffer"]
opaque lockIndexBuffer : IndexBuffer → UInt32 → UInt32 → UInt32 → IO UInt64

/-- Unlock a previously locked index buffer. -/
@[extern "allegro_al_unlock_index_buffer"]
opaque unlockIndexBuffer : IndexBuffer → IO Unit

-- ── Option-returning variants ──

/-- Create a vertex buffer, returning `none` on failure. -/
def createVertexBuffer? (decl : UInt64) (numVerts flags : UInt32) : IO (Option VertexBuffer) :=
  liftOption (createVertexBuffer decl numVerts flags)

/-- Create an index buffer, returning `none` on failure. -/
def createIndexBuffer? (indexSize numIndices flags : UInt32) : IO (Option IndexBuffer) :=
  liftOption (createIndexBuffer indexSize numIndices flags)

-- ════════════════════════════════════════════════════════════════════
-- Vertex declarations
-- ════════════════════════════════════════════════════════════════════

/-- Opaque handle to a custom vertex declaration. -/
def VertexDecl := UInt64

instance : BEq VertexDecl := inferInstanceAs (BEq UInt64)
instance : Inhabited VertexDecl := inferInstanceAs (Inhabited UInt64)
instance : OfNat VertexDecl 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString VertexDecl := ⟨fun (h : UInt64) => s!"VertexDecl#{h}"⟩
instance : Repr VertexDecl := ⟨fun (h : UInt64) _ => .text s!"VertexDecl#{repr h}"⟩

/-- Create a custom vertex declaration from an array of `(attribute, storage, offset)` triples
    and a stride (bytes per vertex). Returns 0 on failure. -/
@[extern "allegro_al_create_vertex_decl"]
opaque createVertexDecl : @&Array (UInt32 × UInt32 × UInt32) → UInt32 → IO VertexDecl

/-- Destroy a custom vertex declaration. -/
@[extern "allegro_al_destroy_vertex_decl"]
opaque destroyVertexDecl : VertexDecl → IO Unit

-- ── Vertex attribute constants ──

def primAttrPosition : UInt32 := 1
def primAttrColor : UInt32 := 2
def primAttrTexCoord : UInt32 := 3
def primAttrTexCoordPixel : UInt32 := 4

-- ── Vertex storage constants ──

def primStorageFloat2 : UInt32 := 0
def primStorageFloat3 : UInt32 := 1
def primStorageShort2 : UInt32 := 2
def primStorageFloat1 : UInt32 := 3
def primStorageFloat4 : UInt32 := 4
def primStorageUbyte4 : UInt32 := 5
def primStorageShort4 : UInt32 := 6
def primStorageNormalizedUbyte4 : UInt32 := 7
def primStorageNormalizedShort2 : UInt32 := 8
def primStorageNormalizedShort4 : UInt32 := 9
def primStorageNormalizedUshort2 : UInt32 := 10
def primStorageNormalizedUshort4 : UInt32 := 11
def primStorageHalfFloat2 : UInt32 := 12
def primStorageHalfFloat4 : UInt32 := 13

-- ════════════════════════════════════════════════════════════════════
-- Drawing raw primitives
-- ════════════════════════════════════════════════════════════════════

/-- Draw primitives from a vertex buffer.
    - `vtxs`: pointer to vertex data
    - `decl`: vertex declaration (0 for built-in `ALLEGRO_VERTEX`)
    - `texture`: bitmap texture (0 for none)
    - `start`, `end`: vertex range
    - `primType`: one of `primType*` constants
    Returns number of primitives drawn. -/
@[extern "allegro_al_draw_prim"]
opaque drawPrim : UInt64 → VertexDecl → UInt64 → UInt32 → UInt32 → UInt32 → IO UInt32

/-- Draw indexed primitives from a vertex buffer.
    - `vtxs`: pointer to vertex data
    - `decl`: vertex declaration (0 for built-in `ALLEGRO_VERTEX`)
    - `texture`: bitmap texture (0 for none)
    - `indices`: pointer to int index array
    - `numVtx`: number of indices
    - `primType`: one of `primType*` constants
    Returns number of primitives drawn. -/
@[extern "allegro_al_draw_indexed_prim"]
opaque drawIndexedPrim : UInt64 → VertexDecl → UInt64 → UInt64 → UInt32 → UInt32 → IO UInt32

/-- Draw primitives from a ByteArray of vertex data (packed floats).
    When `decl` is 0, the built-in ALLEGRO_VERTEX format is used
    (9 floats/vertex: x y z u v r g b a = 36 bytes).
    - `start`, `end`: vertex range
    - `primType`: one of `primType*` constants
    Returns the number of primitives drawn. -/
@[extern "allegro_al_draw_prim_ba"]
opaque drawPrimBA : @&ByteArray → VertexDecl → UInt64 → UInt32 → UInt32 → UInt32 → IO UInt32

/-- Draw indexed primitives from a ByteArray of vertex data and an Array of indices.
    Uses the same vertex format as `drawPrimBA`.
    Returns the number of primitives drawn. -/
@[extern "allegro_al_draw_indexed_prim_ba"]
opaque drawIndexedPrimBA : @&ByteArray → VertexDecl → UInt64 → @&Array UInt32 → UInt32 → UInt32 → IO UInt32

-- ══════════════════════════════════════════════════════════════════
-- Calculation functions (return ByteArray of packed floats)
-- ══════════════════════════════════════════════════════════════════

/-- Calculate vertices for an arc and return them as a ByteArray of packed `(x, y)` floats.
    - `cx`, `cy`: center
    - `rx`, `ry`: radii
    - `startTheta`, `deltaTheta`: angles in radians
    - `thickness`: line thickness (0 for thin)
    - `numPoints`: number of points on the arc -/
@[extern "allegro_al_calculate_arc"]
opaque calculateArc : Float → Float → Float → Float → Float → Float → Float → UInt32 → IO ByteArray

/-- Calculate vertices for a cubic Bézier spline. Takes four control points
    `(x₁,y₁)…(x₄,y₄)`, a thickness, and number of segments.
    Returns a ByteArray of packed `(x, y)` floats. -/
@[extern "allegro_al_calculate_spline"]
opaque calculateSpline : Float → Float → Float → Float → Float → Float → Float → Float → Float → UInt32 → IO ByteArray

/-- Calculate vertices for a ribbon (polyline with thickness).
    - `points`: ByteArray of packed `(x, y)` float pairs
    - `thickness`: ribbon thickness
    - `numSegments`: number of segments
    Returns a ByteArray of packed `(x, y)` floats. -/
@[extern "allegro_al_calculate_ribbon"]
opaque calculateRibbon : @&ByteArray → Float → UInt32 → IO ByteArray

/-- Draw a filled polygon with holes.
    - `vertices`: ByteArray of packed `(x, y)` float pairs for all vertices
    - `vertexCounts`: Array of UInt32 where each element is the vertex count for
      a contour — first contour is the outer boundary, remaining are holes
    - `r`, `g`, `b`: fill colour (0-255) -/
@[extern "allegro_al_draw_filled_polygon_with_holes"]
opaque drawFilledPolygonWithHolesRgb : @&ByteArray → @&Array UInt32 → UInt32 → UInt32 → UInt32 → IO Unit

/-- Triangulate a polygon (with optional holes), returning an array of index triples.
    - `vertices`: ByteArray of packed `(x, y)` float pairs
    - `vertexCounts`: Array of UInt32 where each element is a contour's vertex count
      (first = outer boundary, remaining = holes)
    Returns `Array (UInt32 × UInt32 × UInt32)` of triangle vertex indices. -/
@[extern "allegro_al_triangulate_polygon"]
opaque triangulatePolygon : @&ByteArray → @&Array UInt32 → IO (Array (UInt32 × UInt32 × UInt32))

-- ── Point packing helper ──

/-- Pack an array of `Float` values into a `ByteArray` of packed 32-bit floats
    suitable for `drawPolylineRgb`, `drawPolygonRgb`, `drawRibbonRgb`, etc.
    Pass coordinates as `#[x₁, y₁, x₂, y₂, …]`. -/
@[extern "allegro_pack_floats"]
opaque packFloats : @&Array Float → ByteArray

/-- Pack a list of (x, y) coordinate pairs into a `ByteArray` of packed 32-bit floats. -/
def packPoints (pts : List (Float × Float)) : ByteArray :=
  let arr := pts.foldl (fun acc (x, y) => acc.push x |>.push y) #[]
  packFloats arr

end Allegro
