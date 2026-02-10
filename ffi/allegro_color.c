#include "allegro_ffi.h"
#include <allegro5/allegro_color.h>

/* ── Named → name (not per-component) ── */

lean_object* allegro_al_color_rgb_to_name(uint32_t r, uint32_t g, uint32_t b) {
    const char *name = al_color_rgb_to_name(r / 255.0f, g / 255.0f, b / 255.0f);
    return io_ok_string(name);
}

/* ── HTML ── */

lean_object* allegro_al_color_rgb_to_html(uint32_t r, uint32_t g, uint32_t b) {
    char buf[8]; /* "#rrggbb\0" */
    al_color_rgb_to_html(r / 255.0f, g / 255.0f, b / 255.0f, buf);
    return io_ok_string(buf);
}

/* ═══════════════════════════════════════════════════════════════════
   Tuple-returning conversions  (one FFI call → full result)
   Each function returns IO (UInt32 × UInt32 × UInt32) for integer RGB
   or IO (Float × Float × Float) for float-valued colour components.
   CMYK returns IO (Float × Float × Float × Float).
   ═══════════════════════════════════════════════════════════════════ */

/* ── HSV ↔ RGB tuples ── */

lean_object* allegro_al_color_hsv_rgb(double h, double s, double v) {
    float r, g, b;
    al_color_hsv_to_rgb((float)h, (float)s, (float)v, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_hsv(uint32_t r, uint32_t g, uint32_t b) {
    float h, s, v;
    al_color_rgb_to_hsv(r / 255.0f, g / 255.0f, b / 255.0f, &h, &s, &v);
    return io_ok_f64_triple((double)h, (double)s, (double)v);
}

/* ── HSL ↔ RGB tuples ── */

lean_object* allegro_al_color_hsl_rgb(double h, double s, double l) {
    float r, g, b;
    al_color_hsl_to_rgb((float)h, (float)s, (float)l, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_hsl(uint32_t r, uint32_t g, uint32_t b) {
    float h, s, l;
    al_color_rgb_to_hsl(r / 255.0f, g / 255.0f, b / 255.0f, &h, &s, &l);
    return io_ok_f64_triple((double)h, (double)s, (double)l);
}

/* ── CMYK ↔ RGB tuples ── */

lean_object* allegro_al_color_cmyk_rgb(double c, double m, double y, double k) {
    float r, g, b;
    al_color_cmyk_to_rgb((float)c, (float)m, (float)y, (float)k, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_cmyk(uint32_t r, uint32_t g, uint32_t b) {
    float c, m, y, k;
    al_color_rgb_to_cmyk(r / 255.0f, g / 255.0f, b / 255.0f, &c, &m, &y, &k);
    return io_ok_f64_quad((double)c, (double)m, (double)y, (double)k);
}

/* ── YUV ↔ RGB tuples ── */

lean_object* allegro_al_color_yuv_rgb(double y, double u, double v) {
    float r, g, b;
    al_color_yuv_to_rgb((float)y, (float)u, (float)v, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_yuv(uint32_t r, uint32_t g, uint32_t b) {
    float yy, u, v;
    al_color_rgb_to_yuv(r / 255.0f, g / 255.0f, b / 255.0f, &yy, &u, &v);
    return io_ok_f64_triple((double)yy, (double)u, (double)v);
}

/* ── Named CSS colour → RGB tuple ── */

lean_object* allegro_al_color_name_rgb(b_lean_obj_arg nameObj) {
    const char *name = lean_string_cstr(nameObj);
    ALLEGRO_COLOR c = al_color_name(name);
    unsigned char r, g, b;
    al_unmap_rgb(c, &r, &g, &b);
    return io_ok_u32_triple((uint32_t)r, (uint32_t)g, (uint32_t)b);
}

/* ── HTML → RGB tuple ── */

lean_object* allegro_al_color_html_rgb(b_lean_obj_arg htmlObj) {
    const char *html = lean_string_cstr(htmlObj);
    ALLEGRO_COLOR c = al_color_html(html);
    unsigned char r, g, b;
    al_unmap_rgb(c, &r, &g, &b);
    return io_ok_u32_triple((uint32_t)r, (uint32_t)g, (uint32_t)b);
}

/* ── OkLab ↔ RGB tuples ── */

lean_object* allegro_al_color_oklab_rgb(double l, double a, double b_) {
    float r, g, b;
    al_color_oklab_to_rgb((float)l, (float)a, (float)b_, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_oklab(uint32_t r, uint32_t g, uint32_t b) {
    float l, a, b_;
    al_color_rgb_to_oklab(r / 255.0f, g / 255.0f, b / 255.0f, &l, &a, &b_);
    return io_ok_f64_triple((double)l, (double)a, (double)b_);
}

/* ── Linear sRGB ↔ RGB tuples ── */

lean_object* allegro_al_color_linear_rgb(double lr, double lg, double lb) {
    float r, g, b;
    al_color_linear_to_rgb((float)lr, (float)lg, (float)lb, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_linear(uint32_t r, uint32_t g, uint32_t b) {
    float lr, lg, lb;
    al_color_rgb_to_linear(r / 255.0f, g / 255.0f, b / 255.0f, &lr, &lg, &lb);
    return io_ok_f64_triple((double)lr, (double)lg, (double)lb);
}

/* ── Version ── */

lean_object* allegro_al_get_allegro_color_version(void) {
    return io_ok_uint32(al_get_allegro_color_version());
}

/* ── XYZ ↔ RGB tuples ── */

lean_object* allegro_al_color_xyz_rgb(double x, double y, double z) {
    float r, g, b;
    al_color_xyz_to_rgb((float)x, (float)y, (float)z, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_xyz(uint32_t r, uint32_t g, uint32_t b) {
    float x, y, z;
    al_color_rgb_to_xyz(r / 255.0f, g / 255.0f, b / 255.0f, &x, &y, &z);
    return io_ok_f64_triple((double)x, (double)y, (double)z);
}

/* ── L*a*b* ↔ RGB tuples ── */

lean_object* allegro_al_color_lab_rgb(double l, double a, double b_) {
    float r, g, b;
    al_color_lab_to_rgb((float)l, (float)a, (float)b_, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_lab(uint32_t r, uint32_t g, uint32_t b) {
    float l, a, b_;
    al_color_rgb_to_lab(r / 255.0f, g / 255.0f, b / 255.0f, &l, &a, &b_);
    return io_ok_f64_triple((double)l, (double)a, (double)b_);
}

/* ── xyY ↔ RGB tuples ── */

lean_object* allegro_al_color_xyy_rgb(double x, double y, double y2) {
    float r, g, b;
    al_color_xyy_to_rgb((float)x, (float)y, (float)y2, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_xyy(uint32_t r, uint32_t g, uint32_t b) {
    float x, y, y2;
    al_color_rgb_to_xyy(r / 255.0f, g / 255.0f, b / 255.0f, &x, &y, &y2);
    return io_ok_f64_triple((double)x, (double)y, (double)y2);
}

/* ── LCH ↔ RGB tuples ── */

lean_object* allegro_al_color_lch_rgb(double l, double c, double h) {
    float r, g, b;
    al_color_lch_to_rgb((float)l, (float)c, (float)h, &r, &g, &b);
    return io_ok_u32_triple(
        (uint32_t)(r * 255.0f + 0.5f),
        (uint32_t)(g * 255.0f + 0.5f),
        (uint32_t)(b * 255.0f + 0.5f));
}

lean_object* allegro_al_color_rgb_to_lch(uint32_t r, uint32_t g, uint32_t b) {
    float l, c, h;
    al_color_rgb_to_lch(r / 255.0f, g / 255.0f, b / 255.0f, &l, &c, &h);
    return io_ok_f64_triple((double)l, (double)c, (double)h);
}

/* ── Colour distance ── */

lean_object* allegro_al_color_distance_ciede2000(
        uint32_t r1, uint32_t g1, uint32_t b1,
        uint32_t r2, uint32_t g2, uint32_t b2) {
    ALLEGRO_COLOR c1 = al_map_rgb((unsigned char)r1, (unsigned char)g1, (unsigned char)b1);
    ALLEGRO_COLOR c2 = al_map_rgb((unsigned char)r2, (unsigned char)g2, (unsigned char)b2);
    double d = (double)al_color_distance_ciede2000(c1, c2);
    return lean_io_result_mk_ok(lean_box_float(d));
}

/* ── Colour validity ── */

lean_object* allegro_al_is_color_valid(double r, double g, double b, double a) {
    ALLEGRO_COLOR c = al_map_rgba_f((float)r, (float)g, (float)b, (float)a);
    return io_ok_uint32(al_is_color_valid(c) ? 1u : 0u);
}

/* ═══════════════════════════════════════════════════════════════════
   Convenience constructors  (colour-space → RGBA 0–255)
   Each calls the Allegro constructor, then decomposes the resulting
   ALLEGRO_COLOR via al_unmap_rgba into IO (UInt32 × UInt32 × UInt32 × UInt32).
   ═══════════════════════════════════════════════════════════════════ */

lean_object* allegro_al_color_hsv(double h, double s, double v) {
    ALLEGRO_COLOR c = al_color_hsv((float)h, (float)s, (float)v);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_hsl(double h, double s, double l) {
    ALLEGRO_COLOR c = al_color_hsl((float)h, (float)s, (float)l);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_cmyk(double c_, double m, double y, double k) {
    ALLEGRO_COLOR c = al_color_cmyk((float)c_, (float)m, (float)y, (float)k);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_yuv(double y_, double u, double v) {
    ALLEGRO_COLOR c = al_color_yuv((float)y_, (float)u, (float)v);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_name_rgba(b_lean_obj_arg nameObj) {
    const char *name = lean_string_cstr(nameObj);
    ALLEGRO_COLOR c = al_color_name(name);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_html_rgba(b_lean_obj_arg htmlObj) {
    const char *html = lean_string_cstr(htmlObj);
    ALLEGRO_COLOR c = al_color_html(html);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_xyz(double x, double y, double z) {
    ALLEGRO_COLOR c = al_color_xyz((float)x, (float)y, (float)z);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_lab(double l, double a_, double b_) {
    ALLEGRO_COLOR c = al_color_lab((float)l, (float)a_, (float)b_);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_xyy(double x, double y, double y2) {
    ALLEGRO_COLOR c = al_color_xyy((float)x, (float)y, (float)y2);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_lch(double l, double c_, double h) {
    ALLEGRO_COLOR c = al_color_lch((float)l, (float)c_, (float)h);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_oklab(double l, double a_, double b_) {
    ALLEGRO_COLOR c = al_color_oklab((float)l, (float)a_, (float)b_);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

lean_object* allegro_al_color_linear(double lr, double lg, double lb) {
    ALLEGRO_COLOR c = al_color_linear((float)lr, (float)lg, (float)lb);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}
