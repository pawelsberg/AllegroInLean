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

/-- Allegro primitive type (how vertices are interpreted). -/
structure PrimType where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace PrimType
/-- Draw vertices as a list of separate lines (pairs). -/
def lineList : PrimType := ⟨0⟩
/-- Draw vertices as a connected line strip. -/
def lineStrip : PrimType := ⟨1⟩
/-- Draw vertices as a closed line loop. -/
def lineLoop : PrimType := ⟨2⟩
/-- Draw vertices as a list of separate triangles (triples). -/
def triangleList : PrimType := ⟨3⟩
/-- Draw vertices as a connected triangle strip. -/
def triangleStrip : PrimType := ⟨4⟩
/-- Draw vertices as a triangle fan. -/
def triangleFan : PrimType := ⟨5⟩
/-- Draw vertices as separate points. -/
def pointList : PrimType := ⟨6⟩
end PrimType

-- ── Buffer flags ──

/-- Allegro vertex/index buffer flags (bitfield). -/
structure PrimBufferFlags where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

instance : OrOp PrimBufferFlags where or a b := ⟨a.val ||| b.val⟩
instance : AndOp PrimBufferFlags where and a b := ⟨a.val &&& b.val⟩

namespace PrimBufferFlags
/-- Buffer contents may be updated. -/
def stream : PrimBufferFlags := ⟨0x01⟩
/-- Buffer contents are fixed after creation. -/
def static : PrimBufferFlags := ⟨0x02⟩
/-- Buffer is dynamic but updated less frequently. -/
def dynamic : PrimBufferFlags := ⟨0x04⟩
/-- Buffer data can be read back (combine with |). -/
def readwrite : PrimBufferFlags := ⟨0x08⟩
end PrimBufferFlags

-- ── Line join / cap constants ──

/-- Allegro line join style. -/
structure LineJoin where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace LineJoin
/-- No joining between line segments. -/
def none : LineJoin := ⟨0⟩
/-- Bevel join — straight cut at the joint. -/
def bevel : LineJoin := ⟨1⟩
/-- Round join. -/
def round : LineJoin := ⟨2⟩
/-- Miter join — sharp corner. -/
def miter : LineJoin := ⟨3⟩
end LineJoin

/-- Allegro line cap style. -/
structure LineCap where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace LineCap
/-- No line cap. -/
def none : LineCap := ⟨0⟩
/-- Square cap — extends line by half-thickness. -/
def square : LineCap := ⟨1⟩
/-- Round cap. -/
def round : LineCap := ⟨2⟩
/-- Triangle cap. -/
def triangle : LineCap := ⟨3⟩
/-- Closed cap — joins first and last vertex. -/
def closed : LineCap := ⟨4⟩
end LineCap

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

@[extern "allegro_al_draw_polyline_rgb"]
private opaque drawPolylineRgbRaw : ByteArray → UInt32 → UInt32 → UInt32 → UInt32 → UInt32 → Float → Float → IO Unit

/-- Draw a polyline through the given points.
    `points` is a `ByteArray` of packed 32-bit floats `[x₁, y₁, x₂, y₂, …]`.
    Use `lineJoin*` and `lineCap*` constants for join/cap styles. -/
@[inline] def drawPolylineRgb (points : ByteArray) (r g b : UInt32) (join : LineJoin) (cap : LineCap) (thickness miterLimit : Float) : IO Unit :=
  drawPolylineRgbRaw points r g b join.val cap.val thickness miterLimit

-- ── Polygon ──

@[extern "allegro_al_draw_polygon_rgb"]
private opaque drawPolygonRgbRaw : ByteArray → UInt32 → UInt32 → UInt32 → UInt32 → Float → Float → IO Unit

/-- Draw an outlined polygon. `points` is a `ByteArray` of packed 32-bit floats
    `[x₁, y₁, x₂, y₂, …]`. Uses `lineJoin*` for the join style. -/
@[inline] def drawPolygonRgb (points : ByteArray) (r g b : UInt32) (join : LineJoin) (thickness miterLimit : Float) : IO Unit :=
  drawPolygonRgbRaw points r g b join.val thickness miterLimit

/-- Draw a filled polygon. `points` is a `ByteArray` of packed 32-bit floats
    `[x₁, y₁, x₂, y₂, …]`. -/
@[extern "allegro_al_draw_filled_polygon_rgb"]
opaque drawFilledPolygonRgb : ByteArray → UInt32 → UInt32 → UInt32 → IO Unit

-- ── Vertex buffer management ──

@[extern "allegro_al_create_vertex_buffer"]
private opaque createVertexBufferRaw : UInt64 → UInt32 → UInt32 → IO VertexBuffer

/-- Create a vertex buffer. `decl` is a vertex declaration handle (0 for default ALLEGRO_VERTEX).
    Returns 0 on failure. -/
@[inline] def createVertexBuffer (decl : UInt64) (numVerts : UInt32) (flags : PrimBufferFlags) : IO VertexBuffer :=
  createVertexBufferRaw decl numVerts flags.val

/-- Destroy a vertex buffer. -/
@[extern "allegro_al_destroy_vertex_buffer"]
opaque destroyVertexBuffer : VertexBuffer → IO Unit

/-- Get the number of vertices in a vertex buffer. -/
@[extern "allegro_al_get_vertex_buffer_size"]
opaque getVertexBufferSize : VertexBuffer → IO UInt32

-- ── Index buffer management ──

@[extern "allegro_al_create_index_buffer"]
private opaque createIndexBufferRaw : UInt32 → UInt32 → UInt32 → IO IndexBuffer

/-- Create an index buffer. `indexSize` is the byte size per index (2 or 4).
    Returns 0 on failure. -/
@[inline] def createIndexBuffer (indexSize numIndices : UInt32) (flags : PrimBufferFlags) : IO IndexBuffer :=
  createIndexBufferRaw indexSize numIndices flags.val

/-- Destroy an index buffer. -/
@[extern "allegro_al_destroy_index_buffer"]
opaque destroyIndexBuffer : IndexBuffer → IO Unit

/-- Get the number of indices in an index buffer. -/
@[extern "allegro_al_get_index_buffer_size"]
opaque getIndexBufferSize : IndexBuffer → IO UInt32

-- ── Drawing from buffers ──

@[extern "allegro_al_draw_vertex_buffer"]
private opaque drawVertexBufferRaw : VertexBuffer → UInt64 → UInt32 → UInt32 → UInt32 → IO UInt32

/-- Draw primitives from a vertex buffer.
    `drawVertexBuffer vb texture start end type` -/
@[inline] def drawVertexBuffer (vb : VertexBuffer) (texture : UInt64) (start stop : UInt32) (primType : PrimType) : IO UInt32 :=
  drawVertexBufferRaw vb texture start stop primType.val

@[extern "allegro_al_draw_indexed_buffer"]
private opaque drawIndexedBufferRaw : VertexBuffer → UInt64 → IndexBuffer → UInt32 → UInt32 → UInt32 → IO UInt32

/-- Draw indexed primitives from vertex + index buffers.
    `drawIndexedBuffer vb texture ib start end type` -/
@[inline] def drawIndexedBuffer (vb : VertexBuffer) (texture : UInt64) (ib : IndexBuffer) (start stop : UInt32) (primType : PrimType) : IO UInt32 :=
  drawIndexedBufferRaw vb texture ib start stop primType.val

-- ── Vertex / index buffer locking ──

@[extern "allegro_al_lock_vertex_buffer"]
private opaque lockVertexBufferRaw : VertexBuffer → UInt32 → UInt32 → UInt32 → IO UInt64

/-- Lock a region of a vertex buffer for CPU access. Returns a raw pointer (0 on failure).
    `lockVertexBuffer vb offset length flags` -/
@[inline] def lockVertexBuffer (vb : VertexBuffer) (offset length : UInt32) (flags : PrimBufferFlags) : IO UInt64 :=
  lockVertexBufferRaw vb offset length flags.val

/-- Unlock a previously locked vertex buffer. -/
@[extern "allegro_al_unlock_vertex_buffer"]
opaque unlockVertexBuffer : VertexBuffer → IO Unit

@[extern "allegro_al_lock_index_buffer"]
private opaque lockIndexBufferRaw : IndexBuffer → UInt32 → UInt32 → UInt32 → IO UInt64

/-- Lock a region of an index buffer for CPU access. Returns a raw pointer (0 on failure).
    `lockIndexBuffer ib offset length flags` -/
@[inline] def lockIndexBuffer (ib : IndexBuffer) (offset length : UInt32) (flags : PrimBufferFlags) : IO UInt64 :=
  lockIndexBufferRaw ib offset length flags.val

/-- Unlock a previously locked index buffer. -/
@[extern "allegro_al_unlock_index_buffer"]
opaque unlockIndexBuffer : IndexBuffer → IO Unit

-- ── Option-returning variants ──

/-- Create a vertex buffer, returning `none` on failure. -/
def createVertexBuffer? (decl : UInt64) (numVerts : UInt32) (flags : PrimBufferFlags) : IO (Option VertexBuffer) :=
  liftOption (createVertexBuffer decl numVerts flags)

/-- Create an index buffer, returning `none` on failure. -/
def createIndexBuffer? (indexSize numIndices : UInt32) (flags : PrimBufferFlags) : IO (Option IndexBuffer) :=
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

-- ── Vertex attribute constants ──

/-- Allegro vertex attribute type. -/
structure PrimAttr where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace PrimAttr
def position : PrimAttr := ⟨1⟩
def color : PrimAttr := ⟨2⟩
def texCoord : PrimAttr := ⟨3⟩
def texCoordPixel : PrimAttr := ⟨4⟩
end PrimAttr

-- ── Vertex storage constants ──

/-- Allegro vertex storage format. -/
structure PrimStorage where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

namespace PrimStorage
def float2 : PrimStorage := ⟨0⟩
def float3 : PrimStorage := ⟨1⟩
def short2 : PrimStorage := ⟨2⟩
def float1 : PrimStorage := ⟨3⟩
def float4 : PrimStorage := ⟨4⟩
def ubyte4 : PrimStorage := ⟨5⟩
def short4 : PrimStorage := ⟨6⟩
def normalizedUbyte4 : PrimStorage := ⟨7⟩
def normalizedShort2 : PrimStorage := ⟨8⟩
def normalizedShort4 : PrimStorage := ⟨9⟩
def normalizedUshort2 : PrimStorage := ⟨10⟩
def normalizedUshort4 : PrimStorage := ⟨11⟩
def halfFloat2 : PrimStorage := ⟨12⟩
def halfFloat4 : PrimStorage := ⟨13⟩
end PrimStorage

@[extern "allegro_al_create_vertex_decl"]
private opaque createVertexDeclRaw : @&Array (UInt32 × UInt32 × UInt32) → UInt32 → IO VertexDecl

/-- Create a custom vertex declaration from an array of `(attribute, storage, offset)` triples
    and a stride (bytes per vertex). Returns 0 on failure. -/
@[inline] def createVertexDecl (elems : Array (PrimAttr × PrimStorage × UInt32)) (stride : UInt32) : IO VertexDecl :=
  createVertexDeclRaw (elems.map fun (a, s, o) => (a.val, s.val, o)) stride

/-- Destroy a custom vertex declaration. -/
@[extern "allegro_al_destroy_vertex_decl"]
opaque destroyVertexDecl : VertexDecl → IO Unit

-- ════════════════════════════════════════════════════════════════════
-- Drawing raw primitives
-- ════════════════════════════════════════════════════════════════════

@[extern "allegro_al_draw_prim"]
private opaque drawPrimRaw : UInt64 → VertexDecl → UInt64 → UInt32 → UInt32 → UInt32 → IO UInt32

/-- Draw primitives from a vertex buffer.
    - `vtxs`: pointer to vertex data
    - `decl`: vertex declaration (0 for built-in `ALLEGRO_VERTEX`)
    - `texture`: bitmap texture (0 for none)
    - `start`, `end`: vertex range
    - `primType`: one of `primType*` constants
    Returns number of primitives drawn. -/
@[inline] def drawPrim (vtxs : UInt64) (decl : VertexDecl) (texture : UInt64) (start stop : UInt32) (primType : PrimType) : IO UInt32 :=
  drawPrimRaw vtxs decl texture start stop primType.val

@[extern "allegro_al_draw_indexed_prim"]
private opaque drawIndexedPrimRaw : UInt64 → VertexDecl → UInt64 → UInt64 → UInt32 → UInt32 → IO UInt32

/-- Draw indexed primitives from a vertex buffer.
    - `vtxs`: pointer to vertex data
    - `decl`: vertex declaration (0 for built-in `ALLEGRO_VERTEX`)
    - `texture`: bitmap texture (0 for none)
    - `indices`: pointer to int index array
    - `numVtx`: number of indices
    - `primType`: one of `primType*` constants
    Returns number of primitives drawn. -/
@[inline] def drawIndexedPrim (vtxs : UInt64) (decl : VertexDecl) (texture : UInt64) (indices : UInt64) (numVtx : UInt32) (primType : PrimType) : IO UInt32 :=
  drawIndexedPrimRaw vtxs decl texture indices numVtx primType.val

@[extern "allegro_al_draw_prim_ba"]
private opaque drawPrimBARaw : @&ByteArray → VertexDecl → UInt64 → UInt32 → UInt32 → UInt32 → IO UInt32

/-- Draw primitives from a ByteArray of vertex data (packed floats).
    When `decl` is 0, the built-in ALLEGRO_VERTEX format is used
    (9 floats/vertex: x y z u v r g b a = 36 bytes).
    - `start`, `end`: vertex range
    - `primType`: one of `primType*` constants
    Returns the number of primitives drawn. -/
@[inline] def drawPrimBA (data : ByteArray) (decl : VertexDecl) (texture : UInt64) (start stop : UInt32) (primType : PrimType) : IO UInt32 :=
  drawPrimBARaw data decl texture start stop primType.val

@[extern "allegro_al_draw_indexed_prim_ba"]
private opaque drawIndexedPrimBARaw : @&ByteArray → VertexDecl → UInt64 → @&Array UInt32 → UInt32 → UInt32 → IO UInt32

/-- Draw indexed primitives from a ByteArray of vertex data and an Array of indices.
    Uses the same vertex format as `drawPrimBA`.
    Returns the number of primitives drawn. -/
@[inline] def drawIndexedPrimBA (data : ByteArray) (decl : VertexDecl) (texture : UInt64) (indices : Array UInt32) (numVtx : UInt32) (primType : PrimType) : IO UInt32 :=
  drawIndexedPrimBARaw data decl texture indices numVtx primType.val

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


-- 
-- Color-accepting overloads
-- 

/-- Draw a line with a Color and thickness. -/
@[inline] def drawLine (x1 y1 x2 y2 : Float) (c : Color) (thickness : Float) : IO Unit :=
  drawLineRgb x1 y1 x2 y2 c.r c.g c.b thickness

/-- Draw an outlined rectangle with a Color and thickness. -/
@[inline] def drawRectangle (x1 y1 x2 y2 : Float) (c : Color) (thickness : Float) : IO Unit :=
  drawRectangleRgb x1 y1 x2 y2 c.r c.g c.b thickness

/-- Draw a filled rectangle with a Color. -/
@[inline] def drawFilledRectangle (x1 y1 x2 y2 : Float) (c : Color) : IO Unit :=
  drawFilledRectangleRgb x1 y1 x2 y2 c.r c.g c.b

/-- Draw an outlined circle with a Color and thickness. -/
@[inline] def drawCircle (cx cy radius : Float) (c : Color) (thickness : Float) : IO Unit :=
  drawCircleRgb cx cy radius c.r c.g c.b thickness

/-- Draw a filled circle with a Color. -/
@[inline] def drawFilledCircle (cx cy radius : Float) (c : Color) : IO Unit :=
  drawFilledCircleRgb cx cy radius c.r c.g c.b

/-- Draw an outlined triangle with a Color and thickness. -/
@[inline] def drawTriangle (x1 y1 x2 y2 x3 y3 : Float) (c : Color) (thickness : Float) : IO Unit :=
  drawTriangleRgb x1 y1 x2 y2 x3 y3 c.r c.g c.b thickness

/-- Draw a filled triangle with a Color. -/
@[inline] def drawFilledTriangle (x1 y1 x2 y2 x3 y3 : Float) (c : Color) : IO Unit :=
  drawFilledTriangleRgb x1 y1 x2 y2 x3 y3 c.r c.g c.b

/-- Draw an outlined ellipse with a Color and thickness. -/
@[inline] def drawEllipse (cx cy rx ry : Float) (c : Color) (thickness : Float) : IO Unit :=
  drawEllipseRgb cx cy rx ry c.r c.g c.b thickness

/-- Draw a filled ellipse with a Color. -/
@[inline] def drawFilledEllipse (cx cy rx ry : Float) (c : Color) : IO Unit :=
  drawFilledEllipseRgb cx cy rx ry c.r c.g c.b

/-- Draw an outlined rounded rectangle with a Color and thickness. -/
@[inline] def drawRoundedRectangle (x1 y1 x2 y2 rx ry : Float) (c : Color) (thickness : Float) : IO Unit :=
  drawRoundedRectangleRgb x1 y1 x2 y2 rx ry c.r c.g c.b thickness

/-- Draw a filled rounded rectangle with a Color. -/
@[inline] def drawFilledRoundedRectangle (x1 y1 x2 y2 rx ry : Float) (c : Color) : IO Unit :=
  drawFilledRoundedRectangleRgb x1 y1 x2 y2 rx ry c.r c.g c.b
end Allegro
