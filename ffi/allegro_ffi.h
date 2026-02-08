#pragma once
#define ALLEGRO_UNSTABLE
#include <lean/lean.h>
#include <stdint.h>
#include <stdlib.h>

static inline lean_object* io_ok_uint32(uint32_t value) {
    return lean_io_result_mk_ok(lean_box_uint32(value));
}

static inline lean_object* io_ok_uint64(uint64_t value) {
    return lean_io_result_mk_ok(lean_box_uint64(value));
}

static inline lean_object* io_ok_unit(void) {
    return lean_io_result_mk_ok(lean_box(0));
}

static inline lean_object* io_ok_string(const char *value) {
    return lean_io_result_mk_ok(lean_mk_string(value ? value : ""));
}


static inline uint64_t ptr_to_u64(void *ptr) {
    return (uint64_t)(uintptr_t)ptr;
}

static inline void *u64_to_ptr(uint64_t value) {
    return (void *)(uintptr_t)value;
}

/* ── Tuple helpers ── */

/* Build a Lean Prod (a, b) = ctor 0 with two object fields */
static inline lean_object* mk_pair(lean_object* a, lean_object* b) {
    lean_object* p = lean_alloc_ctor(0, 2, 0);
    lean_ctor_set(p, 0, a);
    lean_ctor_set(p, 1, b);
    return p;
}

/* IO-ok a UInt32 pair: (UInt32 × UInt32) */
static inline lean_object* io_ok_u32_pair(uint32_t a, uint32_t b) {
    return lean_io_result_mk_ok(mk_pair(lean_box_uint32(a), lean_box_uint32(b)));
}

/* IO-ok a UInt32 triple: (UInt32 × UInt32 × UInt32) */
static inline lean_object* io_ok_u32_triple(uint32_t a, uint32_t b, uint32_t c) {
    lean_object* inner = mk_pair(lean_box_uint32(b), lean_box_uint32(c));
    return lean_io_result_mk_ok(mk_pair(lean_box_uint32(a), inner));
}

/* IO-ok a UInt32 quad: (UInt32 × UInt32 × UInt32 × UInt32) */
static inline lean_object* io_ok_u32_quad(uint32_t a, uint32_t b, uint32_t c, uint32_t d) {
    lean_object* d3 = mk_pair(lean_box_uint32(c), lean_box_uint32(d));
    lean_object* d2 = mk_pair(lean_box_uint32(b), d3);
    return lean_io_result_mk_ok(mk_pair(lean_box_uint32(a), d2));
}

/* IO-ok a Float pair: (Float × Float) */
static inline lean_object* io_ok_f64_pair(double a, double b) {
    return lean_io_result_mk_ok(mk_pair(lean_box_float(a), lean_box_float(b)));
}

/* IO-ok a Float triple: (Float × Float × Float) */
static inline lean_object* io_ok_f64_triple(double a, double b, double c) {
    lean_object* inner = mk_pair(lean_box_float(b), lean_box_float(c));
    return lean_io_result_mk_ok(mk_pair(lean_box_float(a), inner));
}

/* IO-ok a Float quad: (Float × Float × Float × Float) */
static inline lean_object* io_ok_f64_quad(double a, double b, double c, double d) {
    lean_object* d3 = mk_pair(lean_box_float(c), lean_box_float(d));
    lean_object* d2 = mk_pair(lean_box_float(b), d3);
    return lean_io_result_mk_ok(mk_pair(lean_box_float(a), d2));
}

/* ── EventData constructor ──
   Builds a Lean EventData structure (ctor 0, 15 boxed object fields).
   Fields: type timestamp source
           a b c d   (generic int32 slots — keyboard/mouse/display/joystick/touch)
           e f g h   (mouse dx/dy/dz/dw or zeros)
           i         (button / orientation / primary)
           fv1 fv2   (pressure / joystick.pos / touch coords / timer error+ts)
           u64v      (timer.count / joystick.id / user data)
*/
static inline lean_object* mk_event_data(
    uint32_t type, double timestamp, uint64_t source,
    int32_t a, int32_t b, int32_t c, int32_t d,
    int32_t e, int32_t f, int32_t g, int32_t h,
    int32_t i, double fv1, double fv2, uint64_t u64v)
{
    /* Lean compiles EventData with 0 object fields and an 80-byte scalar area.
       Layout (from compiler output):
         offset  0: timestamp  (Float,  8 bytes)
         offset  8: source     (UInt64, 8 bytes)
         offset 16: fv1        (Float,  8 bytes)
         offset 24: fv2        (Float,  8 bytes)
         offset 32: u64v       (UInt64, 8 bytes)
         offset 40: type       (UInt32, 4 bytes)
         offset 44: a          (UInt32, 4 bytes)
         offset 48: b          (UInt32, 4 bytes)
         offset 52: c          (UInt32, 4 bytes)
         offset 56: d          (UInt32, 4 bytes)
         offset 60: e          (UInt32, 4 bytes)
         offset 64: f          (UInt32, 4 bytes)
         offset 68: g          (UInt32, 4 bytes)
         offset 72: h          (UInt32, 4 bytes)
         offset 76: i          (UInt32, 4 bytes)
       Total = 80 bytes. */
    lean_object* obj = lean_alloc_ctor(0, 0, 80);
    lean_ctor_set_float(obj,   0, timestamp);
    lean_ctor_set_uint64(obj,  8, source);
    lean_ctor_set_float(obj,  16, fv1);
    lean_ctor_set_float(obj,  24, fv2);
    lean_ctor_set_uint64(obj, 32, u64v);
    lean_ctor_set_uint32(obj, 40, type);
    lean_ctor_set_uint32(obj, 44, (uint32_t)a);
    lean_ctor_set_uint32(obj, 48, (uint32_t)b);
    lean_ctor_set_uint32(obj, 52, (uint32_t)c);
    lean_ctor_set_uint32(obj, 56, (uint32_t)d);
    lean_ctor_set_uint32(obj, 60, (uint32_t)e);
    lean_ctor_set_uint32(obj, 64, (uint32_t)f);
    lean_ctor_set_uint32(obj, 68, (uint32_t)g);
    lean_ctor_set_uint32(obj, 72, (uint32_t)h);
    lean_ctor_set_uint32(obj, 76, (uint32_t)i);
    return obj;
}
