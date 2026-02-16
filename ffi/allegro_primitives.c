#include "allegro_ffi.h"
#include <string.h>
#include <allegro5/allegro_primitives.h>

/* ── Addon lifecycle ── */

lean_object* allegro_al_init_primitives_addon(void) {
    return io_ok_uint32(al_init_primitives_addon() ? 1u : 0u);
}

lean_object* allegro_al_shutdown_primitives_addon(void) {
    al_shutdown_primitives_addon();
    return io_ok_unit();
}

lean_object* allegro_al_is_primitives_addon_initialized(void) {
    return io_ok_uint32(al_is_primitives_addon_initialized() ? 1u : 0u);
}

/* ── Line ── */

lean_object* allegro_al_draw_line_rgb(
    double x1, double y1, double x2, double y2,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_line((float)x1, (float)y1, (float)x2, (float)y2, color, (float)thickness);
    return io_ok_unit();
}

/* ── Triangle ── */

lean_object* allegro_al_draw_triangle_rgb(
    double x1, double y1, double x2, double y2, double x3, double y3,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_triangle((float)x1, (float)y1, (float)x2, (float)y2, (float)x3, (float)y3, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_triangle_rgb(
    double x1, double y1, double x2, double y2, double x3, double y3,
    uint32_t r, uint32_t g, uint32_t b) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_filled_triangle((float)x1, (float)y1, (float)x2, (float)y2, (float)x3, (float)y3, color);
    return io_ok_unit();
}

/* ── Rectangle ── */

lean_object* allegro_al_draw_rectangle_rgb(
    double x1, double y1, double x2, double y2,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_rectangle((float)x1, (float)y1, (float)x2, (float)y2, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_rectangle_rgb(
        double x1, double y1, double x2, double y2,
        uint32_t r, uint32_t g, uint32_t b) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_filled_rectangle((float)x1, (float)y1, (float)x2, (float)y2, color);
    return io_ok_unit();
}

/* ── Rounded rectangle ── */

lean_object* allegro_al_draw_rounded_rectangle_rgb(
    double x1, double y1, double x2, double y2,
    double rx, double ry,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_rounded_rectangle((float)x1, (float)y1, (float)x2, (float)y2,
                              (float)rx, (float)ry, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_rounded_rectangle_rgb(
    double x1, double y1, double x2, double y2,
    double rx, double ry,
    uint32_t r, uint32_t g, uint32_t b) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_filled_rounded_rectangle((float)x1, (float)y1, (float)x2, (float)y2,
                                     (float)rx, (float)ry, color);
    return io_ok_unit();
}

/* ── Circle ── */

lean_object* allegro_al_draw_circle_rgb(
    double cx, double cy, double radius,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_circle((float)cx, (float)cy, (float)radius, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_circle_rgb(
    double cx, double cy, double radius,
    uint32_t r, uint32_t g, uint32_t b) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_filled_circle((float)cx, (float)cy, (float)radius, color);
    return io_ok_unit();
}

/* ── Ellipse ── */

lean_object* allegro_al_draw_ellipse_rgb(
    double cx, double cy, double rx, double ry,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_ellipse((float)cx, (float)cy, (float)rx, (float)ry, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_ellipse_rgb(
    double cx, double cy, double rx, double ry,
    uint32_t r, uint32_t g, uint32_t b) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_filled_ellipse((float)cx, (float)cy, (float)rx, (float)ry, color);
    return io_ok_unit();
}

/* ── Arc ── */

lean_object* allegro_al_draw_arc_rgb(
    double cx, double cy, double r_,
    double startTheta, double deltaTheta,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_arc((float)cx, (float)cy, (float)r_, (float)startTheta, (float)deltaTheta,
                color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_elliptical_arc_rgb(
    double cx, double cy, double rx, double ry,
    double startTheta, double deltaTheta,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_elliptical_arc((float)cx, (float)cy, (float)rx, (float)ry,
                           (float)startTheta, (float)deltaTheta, color, (float)thickness);
    return io_ok_unit();
}

/* ── Pieslice ── */

lean_object* allegro_al_draw_pieslice_rgb(
    double cx, double cy, double r_,
    double startTheta, double deltaTheta,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_pieslice((float)cx, (float)cy, (float)r_, (float)startTheta, (float)deltaTheta,
                     color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_pieslice_rgb(
    double cx, double cy, double r_,
    double startTheta, double deltaTheta,
    uint32_t r, uint32_t g, uint32_t b) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_filled_pieslice((float)cx, (float)cy, (float)r_, (float)startTheta, (float)deltaTheta, color);
    return io_ok_unit();
}

/* ── Version ── */

lean_object* allegro_al_get_primitives_version(void) {
    return io_ok_uint32(al_get_allegro_primitives_version());
}

/* ════════════════════════════════════════════════════════════════════
   RGBA variants — accept an alpha channel for transparency/blending.
   Uses al_map_rgba instead of al_map_rgb.
   ════════════════════════════════════════════════════════════════════ */

lean_object* allegro_al_draw_line_rgba(
    double x1, double y1, double x2, double y2,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_line((float)x1, (float)y1, (float)x2, (float)y2, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_triangle_rgba(
    double x1, double y1, double x2, double y2, double x3, double y3,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_triangle((float)x1, (float)y1, (float)x2, (float)y2, (float)x3, (float)y3, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_triangle_rgba(
    double x1, double y1, double x2, double y2, double x3, double y3,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_filled_triangle((float)x1, (float)y1, (float)x2, (float)y2, (float)x3, (float)y3, color);
    return io_ok_unit();
}

lean_object* allegro_al_draw_rectangle_rgba(
    double x1, double y1, double x2, double y2,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_rectangle((float)x1, (float)y1, (float)x2, (float)y2, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_rectangle_rgba(
    double x1, double y1, double x2, double y2,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_filled_rectangle((float)x1, (float)y1, (float)x2, (float)y2, color);
    return io_ok_unit();
}

lean_object* allegro_al_draw_rounded_rectangle_rgba(
    double x1, double y1, double x2, double y2,
    double rx, double ry,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_rounded_rectangle((float)x1, (float)y1, (float)x2, (float)y2,
                              (float)rx, (float)ry, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_rounded_rectangle_rgba(
    double x1, double y1, double x2, double y2,
    double rx, double ry,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_filled_rounded_rectangle((float)x1, (float)y1, (float)x2, (float)y2,
                                     (float)rx, (float)ry, color);
    return io_ok_unit();
}

lean_object* allegro_al_draw_circle_rgba(
    double cx, double cy, double radius,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_circle((float)cx, (float)cy, (float)radius, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_circle_rgba(
    double cx, double cy, double radius,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_filled_circle((float)cx, (float)cy, (float)radius, color);
    return io_ok_unit();
}

lean_object* allegro_al_draw_ellipse_rgba(
    double cx, double cy, double rx, double ry,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a,
    double thickness) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_ellipse((float)cx, (float)cy, (float)rx, (float)ry, color, (float)thickness);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_ellipse_rgba(
    double cx, double cy, double rx, double ry,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
    ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
    al_draw_filled_ellipse((float)cx, (float)cy, (float)rx, (float)ry, color);
    return io_ok_unit();
}

/* ── Spline ── */

lean_object* allegro_al_draw_spline_rgb(
    double x1, double y1, double x2, double y2,
    double x3, double y3, double x4, double y4,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness) {
    float pts[8] = {
        (float)x1, (float)y1, (float)x2, (float)y2,
        (float)x3, (float)y3, (float)x4, (float)y4
    };
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_spline(pts, color, (float)thickness);
    return io_ok_unit();
}

/* ── Ribbon ──
   Takes a Lean ByteArray of packed 32-bit floats (little-endian, 4 bytes each).
   Each pair is (x, y). */

lean_object* allegro_al_draw_ribbon_rgb(
    lean_object* pointsObj,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness, uint32_t numSegments) {
    size_t len = lean_sarray_byte_size(pointsObj);
    const float *pts = (const float *)lean_sarray_cptr(pointsObj);
    /* Each point is 2 floats = 8 bytes. */
    int npts = (int)(len / (2 * sizeof(float)));
    if (npts < 2) return io_ok_unit();
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_ribbon(pts, 2 * sizeof(float), color, (float)thickness,
                   numSegments > 0 ? (int)numSegments : npts);
    return io_ok_unit();
}

/* ── Polyline ── */

lean_object* allegro_al_draw_polyline_rgb(
    lean_object* pointsObj,
    uint32_t joinStyle, uint32_t capStyle,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness, double miterLimit) {
    size_t len = lean_sarray_byte_size(pointsObj);
    const float *pts = (const float *)lean_sarray_cptr(pointsObj);
    int npts = (int)(len / (2 * sizeof(float)));
    if (npts < 2) return io_ok_unit();
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_polyline(pts, 2 * sizeof(float), npts,
                     (int)joinStyle, (int)capStyle,
                     color, (float)thickness, (float)miterLimit);
    return io_ok_unit();
}

/* ── Polygon ── */

lean_object* allegro_al_draw_polygon_rgb(
    lean_object* pointsObj,
    uint32_t joinStyle,
    uint32_t r, uint32_t g, uint32_t b,
    double thickness, double miterLimit) {
    size_t len = lean_sarray_byte_size(pointsObj);
    const float *pts = (const float *)lean_sarray_cptr(pointsObj);
    int npts = (int)(len / (2 * sizeof(float)));
    if (npts < 3) return io_ok_unit();
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_polygon(pts, npts, (int)joinStyle, color, (float)thickness, (float)miterLimit);
    return io_ok_unit();
}

lean_object* allegro_al_draw_filled_polygon_rgb(
    lean_object* pointsObj,
    uint32_t r, uint32_t g, uint32_t b) {
    size_t len = lean_sarray_byte_size(pointsObj);
    const float *pts = (const float *)lean_sarray_cptr(pointsObj);
    int npts = (int)(len / (2 * sizeof(float)));
    if (npts < 3) return io_ok_unit();
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_filled_polygon(pts, npts, color);
    return io_ok_unit();
}

/* ── Vertex & index buffer management ── */

lean_object* allegro_al_create_vertex_buffer(uint64_t decl, uint32_t numVertices, uint32_t flags) {
    ALLEGRO_VERTEX_BUFFER *vb = al_create_vertex_buffer(
        decl != 0 ? (ALLEGRO_VERTEX_DECL *)u64_to_ptr(decl) : NULL,
        NULL, (int)numVertices, (int)flags);
    return io_ok_uint64(ptr_to_u64(vb));
}

lean_object* allegro_al_destroy_vertex_buffer(uint64_t vb) {
    if (vb != 0) al_destroy_vertex_buffer((ALLEGRO_VERTEX_BUFFER *)u64_to_ptr(vb));
    return io_ok_unit();
}

lean_object* allegro_al_get_vertex_buffer_size(uint64_t vb) {
    if (vb == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_vertex_buffer_size((ALLEGRO_VERTEX_BUFFER *)u64_to_ptr(vb)));
}

lean_object* allegro_al_create_index_buffer(uint32_t indexSize, uint32_t numIndices, uint32_t flags) {
    ALLEGRO_INDEX_BUFFER *ib = al_create_index_buffer((int)indexSize, NULL, (int)numIndices, (int)flags);
    return io_ok_uint64(ptr_to_u64(ib));
}

lean_object* allegro_al_destroy_index_buffer(uint64_t ib) {
    if (ib != 0) al_destroy_index_buffer((ALLEGRO_INDEX_BUFFER *)u64_to_ptr(ib));
    return io_ok_unit();
}

lean_object* allegro_al_get_index_buffer_size(uint64_t ib) {
    if (ib == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_index_buffer_size((ALLEGRO_INDEX_BUFFER *)u64_to_ptr(ib)));
}

/* ── Draw vertex / index buffer ── */

lean_object* allegro_al_draw_vertex_buffer(uint64_t vb, uint64_t texture,
                                            uint32_t start, uint32_t end, uint32_t type) {
    if (vb == 0) return io_ok_uint32(0);
    int n = al_draw_vertex_buffer(
        (ALLEGRO_VERTEX_BUFFER *)u64_to_ptr(vb),
        texture != 0 ? (ALLEGRO_BITMAP *)u64_to_ptr(texture) : NULL,
        (int)start, (int)end, (int)type);
    return io_ok_uint32((uint32_t)n);
}

lean_object* allegro_al_draw_indexed_buffer(uint64_t vb, uint64_t texture, uint64_t ib,
                                             uint32_t start, uint32_t end, uint32_t type) {
    if (vb == 0 || ib == 0) return io_ok_uint32(0);
    int n = al_draw_indexed_buffer(
        (ALLEGRO_VERTEX_BUFFER *)u64_to_ptr(vb),
        texture != 0 ? (ALLEGRO_BITMAP *)u64_to_ptr(texture) : NULL,
        (ALLEGRO_INDEX_BUFFER *)u64_to_ptr(ib),
        (int)start, (int)end, (int)type);
    return io_ok_uint32((uint32_t)n);
}

/* ── Vertex / index buffer locking ── */

lean_object* allegro_al_lock_vertex_buffer(uint64_t vb, uint32_t offset, uint32_t length, uint32_t flags) {
    if (vb == 0) return io_ok_uint64(0);
    void *ptr = al_lock_vertex_buffer(
        (ALLEGRO_VERTEX_BUFFER *)u64_to_ptr(vb), (int)offset, (int)length, (int)flags);
    return io_ok_uint64(ptr_to_u64(ptr));
}

lean_object* allegro_al_unlock_vertex_buffer(uint64_t vb) {
    if (vb != 0)
        al_unlock_vertex_buffer((ALLEGRO_VERTEX_BUFFER *)u64_to_ptr(vb));
    return io_ok_unit();
}

lean_object* allegro_al_lock_index_buffer(uint64_t ib, uint32_t offset, uint32_t length, uint32_t flags) {
    if (ib == 0) return io_ok_uint64(0);
    void *ptr = al_lock_index_buffer(
        (ALLEGRO_INDEX_BUFFER *)u64_to_ptr(ib), (int)offset, (int)length, (int)flags);
    return io_ok_uint64(ptr_to_u64(ptr));
}

lean_object* allegro_al_unlock_index_buffer(uint64_t ib) {
    if (ib != 0)
        al_unlock_index_buffer((ALLEGRO_INDEX_BUFFER *)u64_to_ptr(ib));
    return io_ok_unit();
}

/* ── Float packing helper ──
   Convert a Lean Array Float (64-bit doubles) into a ByteArray of packed 32-bit floats.
   This is a pure function (no IO). */

lean_object* allegro_pack_floats(b_lean_obj_arg arr) {
    size_t n = lean_array_size(arr);
    size_t byteLen = n * sizeof(float);
    /* Allocate a ByteArray with capacity = byteLen */
    lean_object* ba = lean_alloc_sarray(1, 0, byteLen);
    uint8_t *dst = lean_sarray_cptr(ba);
    for (size_t i = 0; i < n; i++) {
        lean_object* elem = lean_array_get_core(arr, i);
        double d = lean_unbox_float(elem);
        float f = (float)d;
        memcpy(dst + i * sizeof(float), &f, sizeof(float));
    }
    /* Set the size */
    lean_sarray_set_size(ba, byteLen);
    return ba;
}

/* ── Vertex declaration ── */

lean_object* allegro_al_create_vertex_decl(b_lean_obj_arg elements, uint32_t stride) {
    /* elements is a Lean Array (UInt32 × UInt32 × UInt32) — (attribute, storage, offset) triples.
       We build a C array of ALLEGRO_VERTEX_ELEMENT terminated by {0,0,0}. */
    size_t n = lean_array_size(elements);
    ALLEGRO_VERTEX_ELEMENT *elems =
        (ALLEGRO_VERTEX_ELEMENT *)alloca((n + 1) * sizeof(ALLEGRO_VERTEX_ELEMENT));
    for (size_t i = 0; i < n; i++) {
        lean_object* triple = lean_array_get_core(elements, i);
        /* Lean tuple: (a, (b, c)) */
        lean_object* a_obj = lean_ctor_get(triple, 0);
        lean_object* bc    = lean_ctor_get(triple, 1);
        lean_object* b_obj = lean_ctor_get(bc, 0);
        lean_object* c_obj = lean_ctor_get(bc, 1);
        elems[i].attribute = (int)lean_unbox_uint32(a_obj);
        elems[i].storage   = (int)lean_unbox_uint32(b_obj);
        elems[i].offset    = (int)lean_unbox_uint32(c_obj);
    }
    /* Terminator */
    elems[n].attribute = 0;
    elems[n].storage   = 0;
    elems[n].offset    = 0;
    ALLEGRO_VERTEX_DECL *decl = al_create_vertex_decl(elems, (int)stride);
    return io_ok_uint64(ptr_to_u64(decl));
}

lean_object* allegro_al_destroy_vertex_decl(uint64_t decl) {
    if (decl != 0)
        al_destroy_vertex_decl((ALLEGRO_VERTEX_DECL *)u64_to_ptr(decl));
    return io_ok_unit();
}

/* ── Draw primitives ── */

lean_object* allegro_al_draw_prim(uint64_t vtxs, uint64_t decl, uint64_t texture,
                                   uint32_t start, uint32_t end, uint32_t type) {
    if (vtxs == 0) return io_ok_uint32(0);
    int drawn = al_draw_prim(
        u64_to_ptr(vtxs),
        decl ? (ALLEGRO_VERTEX_DECL *)u64_to_ptr(decl) : NULL,
        texture ? (ALLEGRO_BITMAP *)u64_to_ptr(texture) : NULL,
        (int)start, (int)end, (int)type);
    return io_ok_uint32((uint32_t)drawn);
}

lean_object* allegro_al_draw_indexed_prim(uint64_t vtxs, uint64_t decl, uint64_t texture,
                                           uint64_t indices, uint32_t numVtx, uint32_t type) {
    if (vtxs == 0 || indices == 0) return io_ok_uint32(0);
    int drawn = al_draw_indexed_prim(
        u64_to_ptr(vtxs),
        decl ? (ALLEGRO_VERTEX_DECL *)u64_to_ptr(decl) : NULL,
        texture ? (ALLEGRO_BITMAP *)u64_to_ptr(texture) : NULL,
        (const int *)u64_to_ptr(indices), (int)numVtx, (int)type);
    return io_ok_uint32((uint32_t)drawn);
}

/* ── Draw primitives from ByteArray (Lean-friendly) ── */

lean_object* allegro_al_draw_prim_ba(b_lean_obj_arg vtxData, uint64_t decl,
                                      uint64_t texture, uint32_t start,
                                      uint32_t end, uint32_t type) {
    size_t sz = lean_sarray_size(vtxData);
    if (sz == 0) return io_ok_uint32(0);
    const void *data = lean_sarray_cptr(vtxData);
    int drawn = al_draw_prim(
        data,
        decl ? (ALLEGRO_VERTEX_DECL *)u64_to_ptr(decl) : NULL,
        texture ? (ALLEGRO_BITMAP *)u64_to_ptr(texture) : NULL,
        (int)start, (int)end, (int)type);
    return io_ok_uint32((uint32_t)(drawn > 0 ? drawn : 0));
}

lean_object* allegro_al_draw_indexed_prim_ba(b_lean_obj_arg vtxData, uint64_t decl,
                                              uint64_t texture, b_lean_obj_arg indices,
                                              uint32_t numVtx, uint32_t type) {
    size_t sz = lean_sarray_size(vtxData);
    if (sz == 0) return io_ok_uint32(0);
    const void *data = lean_sarray_cptr(vtxData);
    size_t n = lean_array_size(indices);
    int *idx = (int *)alloca(n * sizeof(int));
    for (size_t i = 0; i < n; i++) {
        idx[i] = (int)lean_unbox_uint32(lean_array_get_core(indices, i));
    }
    int drawn = al_draw_indexed_prim(
        data,
        decl ? (ALLEGRO_VERTEX_DECL *)u64_to_ptr(decl) : NULL,
        texture ? (ALLEGRO_BITMAP *)u64_to_ptr(texture) : NULL,
        idx, (int)numVtx, (int)type);
    return io_ok_uint32((uint32_t)(drawn > 0 ? drawn : 0));
}

lean_object* allegro_al_get_allegro_primitives_version(void) {
    return io_ok_uint32(al_get_allegro_primitives_version());
}

/* ── Calculate arc ── */

lean_object* allegro_al_calculate_arc(double cx, double cy, double rx, double ry,
                                       double startTheta, double deltaTheta,
                                       double thickness, uint32_t numPoints) {
    /* Each point is (x, y). For thick arcs, numPoints*2 vertices are generated. */
    int n = (int)numPoints;
    int numVerts = (thickness > 0.0) ? (n * 2) : n;
    size_t byteLen = (size_t)numVerts * 2 * sizeof(float);
    lean_object* ba = lean_alloc_sarray(1, byteLen, byteLen);
    float *dest = (float *)lean_sarray_cptr(ba);
    al_calculate_arc(dest, 2 * (int)sizeof(float),
                     (float)cx, (float)cy, (float)rx, (float)ry,
                     (float)startTheta, (float)deltaTheta,
                     (float)thickness, n);
    return lean_io_result_mk_ok(ba);
}

/* ── Calculate spline ── */

lean_object* allegro_al_calculate_spline(double x1, double y1, double x2, double y2,
                                          double x3, double y3, double x4, double y4,
                                          double thickness, uint32_t numSegments) {
    float points[8] = { (float)x1, (float)y1, (float)x2, (float)y2,
                         (float)x3, (float)y3, (float)x4, (float)y4 };
    int n = (int)numSegments + 1;
    int numVerts = (thickness > 0.0) ? (n * 2) : n;
    size_t byteLen = (size_t)numVerts * 2 * sizeof(float);
    lean_object* ba = lean_alloc_sarray(1, byteLen, byteLen);
    float *dest = (float *)lean_sarray_cptr(ba);
    al_calculate_spline(dest, 2 * (int)sizeof(float),
                        points, (float)thickness, (int)numSegments);
    return lean_io_result_mk_ok(ba);
}

/* ── Calculate ribbon ── */

lean_object* allegro_al_calculate_ribbon(b_lean_obj_arg pointsBA, double thickness,
                                          uint32_t numSegments) {
    const float *pts = (const float *)lean_sarray_cptr(pointsBA);
    int n = (int)numSegments + 1;
    int numVerts = (thickness > 0.0) ? (n * 2) : n;
    size_t byteLen = (size_t)numVerts * 2 * sizeof(float);
    lean_object* ba = lean_alloc_sarray(1, byteLen, byteLen);
    float *dest = (float *)lean_sarray_cptr(ba);
    al_calculate_ribbon(dest, 2 * (int)sizeof(float),
                        pts, 2 * (int)sizeof(float),
                        (float)thickness, (int)numSegments);
    return lean_io_result_mk_ok(ba);
}

/* ── Draw filled polygon with holes ── */

lean_object* allegro_al_draw_filled_polygon_with_holes(
        b_lean_obj_arg verticesBA,
        b_lean_obj_arg vertexCountsArr,
        uint32_t r, uint32_t g, uint32_t b) {
    const float *vertices = (const float *)lean_sarray_cptr(verticesBA);
    size_t nCounts = lean_array_size(vertexCountsArr);
    /* Build a 0-terminated int array */
    int *vcounts = (int *)alloca((nCounts + 1) * sizeof(int));
    for (size_t i = 0; i < nCounts; i++) {
        lean_object* elem = lean_array_get_core(vertexCountsArr, i);
        vcounts[i] = (int)lean_unbox_uint32(elem);
    }
    vcounts[nCounts] = 0;
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_filled_polygon_with_holes(vertices, vcounts, color);
    return io_ok_unit();
}

/* ── Callback-collecting triangulate_polygon ── */

typedef struct {
    int *indices;
    size_t count;
    size_t capacity;
} triangulate_data_t;

static void triangulate_emit_cb(int a, int b, int c, void *extra) {
    triangulate_data_t *d = (triangulate_data_t *)extra;
    if (d->count + 3 > d->capacity) {
        d->capacity = d->capacity ? d->capacity * 2 : 64;
        d->indices = (int *)realloc(d->indices, d->capacity * sizeof(int));
    }
    d->indices[d->count++] = a;
    d->indices[d->count++] = b;
    d->indices[d->count++] = c;
}

lean_object* allegro_al_triangulate_polygon(b_lean_obj_arg verticesBA,
                                             b_lean_obj_arg vertexCountsArr) {
    const float *vertices = (const float *)lean_sarray_cptr(verticesBA);
    size_t nCounts = lean_array_size(vertexCountsArr);
    int *vcounts = (int *)alloca((nCounts + 1) * sizeof(int));
    for (size_t i = 0; i < nCounts; i++) {
        lean_object* elem = lean_array_get_core(vertexCountsArr, i);
        vcounts[i] = (int)lean_unbox_uint32(elem);
    }
    vcounts[nCounts] = 0;

    triangulate_data_t data = {NULL, 0, 0};
    al_triangulate_polygon(vertices, 2 * (int)sizeof(float),
                           vcounts, triangulate_emit_cb, &data);

    size_t numTri = data.count / 3;
    lean_object *arr = lean_alloc_array(numTri, numTri);
    for (size_t i = 0; i < numTri; i++) {
        lean_object* t = mk_pair(
            lean_box_uint32((uint32_t)data.indices[i*3]),
            mk_pair(lean_box_uint32((uint32_t)data.indices[i*3+1]),
                    lean_box_uint32((uint32_t)data.indices[i*3+2])));
        lean_array_set_core(arr, i, t);
    }
    free(data.indices);
    return lean_io_result_mk_ok(arr);
}
