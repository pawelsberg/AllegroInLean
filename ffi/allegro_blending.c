#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/* ── set / get blender ── */

lean_object* allegro_al_set_blender(uint32_t op, uint32_t src, uint32_t dest) {
    al_set_blender((int)op, (int)src, (int)dest);
    return io_ok_unit();
}

lean_object* allegro_al_set_separate_blender(
    uint32_t op, uint32_t src, uint32_t dst,
    uint32_t alpha_op, uint32_t alpha_src, uint32_t alpha_dst) {
    al_set_separate_blender((int)op, (int)src, (int)dst,
                            (int)alpha_op, (int)alpha_src, (int)alpha_dst);
    return io_ok_unit();
}

/* ── clear with alpha ── */

lean_object* allegro_al_clear_to_color_rgba(uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
    al_clear_to_color(al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a));
    return io_ok_unit();
}

/* ── draw_tinted_bitmap ── */

lean_object* allegro_al_draw_tinted_bitmap_rgba(
    uint64_t bitmap,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a,
    double dx, double dy,
    uint32_t flags) {
    if (bitmap != 0) {
        ALLEGRO_COLOR tint = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
        al_draw_tinted_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), tint, (float)dx, (float)dy, (int)flags);
    }
    return io_ok_unit();
}

/* ── Tuple-returning queries ── */

lean_object* allegro_al_get_blender(void) {
    int op, src, dest;
    al_get_blender(&op, &src, &dest);
    return io_ok_u32_triple((uint32_t)op, (uint32_t)src, (uint32_t)dest);
}

lean_object* allegro_al_get_separate_blender(void) {
    int op, src, dst, aop, asrc, adst;
    al_get_separate_blender(&op, &src, &dst, &aop, &asrc, &adst);
    /* Return (op, src, dst, alphaOp, alphaSrc, alphaDst) as nested pairs */
    lean_object* p5 = mk_pair(lean_box_uint32((uint32_t)asrc), lean_box_uint32((uint32_t)adst));
    lean_object* p4 = mk_pair(lean_box_uint32((uint32_t)aop), p5);
    lean_object* p3 = mk_pair(lean_box_uint32((uint32_t)dst), p4);
    lean_object* p2 = mk_pair(lean_box_uint32((uint32_t)src), p3);
    lean_object* p1 = mk_pair(lean_box_uint32((uint32_t)op), p2);
    return lean_io_result_mk_ok(p1);
}

/* ── Blend colour ── */

lean_object* allegro_al_get_blend_color(void) {
    ALLEGRO_COLOR c = al_get_blend_color();
    float r, g, b, a;
    al_unmap_rgba_f(c, &r, &g, &b, &a);
    return io_ok_f64_quad((double)r, (double)g, (double)b, (double)a);
}

lean_object* allegro_al_set_blend_color(double r, double g, double b, double a) {
    al_set_blend_color(al_map_rgba_f((float)r, (float)g, (float)b, (float)a));
    return io_ok_unit();
}
