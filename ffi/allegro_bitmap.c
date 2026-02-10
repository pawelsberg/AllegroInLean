#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/* ── Bitmap creation & properties ── */

lean_object* allegro_al_set_new_bitmap_flags(uint32_t flags) {
    al_set_new_bitmap_flags((int)flags);
    return io_ok_unit();
}

lean_object* allegro_al_create_bitmap(uint32_t w, uint32_t h) {
    ALLEGRO_BITMAP *bmp = al_create_bitmap((int)w, (int)h);
    return io_ok_uint64(ptr_to_u64(bmp));
}

lean_object* allegro_al_clone_bitmap(uint64_t bitmap) {
    if (bitmap == 0) {
        return io_ok_uint64(0);
    }
    ALLEGRO_BITMAP *bmp = al_clone_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap));
    return io_ok_uint64(ptr_to_u64(bmp));
}

lean_object* allegro_al_create_sub_bitmap(uint64_t bitmap, int32_t x, int32_t y, int32_t w, int32_t h) {
    if (bitmap == 0) {
        return io_ok_uint64(0);
    }
    ALLEGRO_BITMAP *bmp = al_create_sub_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), x, y, w, h);
    return io_ok_uint64(ptr_to_u64(bmp));
}

lean_object* allegro_al_get_bitmap_width(uint64_t bitmap) {
    if (bitmap == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_get_bitmap_width((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)));
}

lean_object* allegro_al_get_bitmap_height(uint64_t bitmap) {
    if (bitmap == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_get_bitmap_height((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)));
}

lean_object* allegro_al_get_backbuffer(uint64_t display) {
    if (display == 0) {
        return io_ok_uint64(0);
    }
    return io_ok_uint64(ptr_to_u64(al_get_backbuffer((ALLEGRO_DISPLAY *)u64_to_ptr(display))));
}

lean_object* allegro_al_set_target_backbuffer(uint64_t display) {
    if (display != 0) {
        al_set_target_backbuffer((ALLEGRO_DISPLAY *)u64_to_ptr(display));
    }
    return io_ok_unit();
}

lean_object* allegro_al_set_target_bitmap(uint64_t bitmap) {
    if (bitmap != 0) {
        al_set_target_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_target_bitmap(void) {
    return io_ok_uint64(ptr_to_u64(al_get_target_bitmap()));
}

lean_object* allegro_al_draw_pixel_rgb(double x, double y, uint32_t r, uint32_t g, uint32_t b) {
    ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
    al_draw_pixel((float)x, (float)y, color);
    return io_ok_unit();
}

/* ── Clipping rectangle ── */

lean_object* allegro_al_set_clipping_rectangle(uint32_t x, uint32_t y, uint32_t w, uint32_t h) {
    al_set_clipping_rectangle((int)x, (int)y, (int)w, (int)h);
    return io_ok_unit();
}

lean_object* allegro_al_reset_clipping_rectangle(void) {
    al_reset_clipping_rectangle();
    return io_ok_unit();
}

/* ── Pixel format queries ── */

lean_object* allegro_al_get_pixel_size(uint32_t format) {
    return io_ok_uint32((uint32_t)al_get_pixel_size((int)format));
}

lean_object* allegro_al_get_pixel_format_bits(uint32_t format) {
    return io_ok_uint32((uint32_t)al_get_pixel_format_bits((int)format));
}

lean_object* allegro_al_get_pixel_block_size(uint32_t format) {
    return io_ok_uint32((uint32_t)al_get_pixel_block_size((int)format));
}

lean_object* allegro_al_get_pixel_block_width(uint32_t format) {
    return io_ok_uint32((uint32_t)al_get_pixel_block_width((int)format));
}

lean_object* allegro_al_get_pixel_block_height(uint32_t format) {
    return io_ok_uint32((uint32_t)al_get_pixel_block_height((int)format));
}

/* ── Bitmap flags & format ── */

lean_object* allegro_al_get_new_bitmap_flags(void) {
    return io_ok_uint32((uint32_t)al_get_new_bitmap_flags());
}

lean_object* allegro_al_add_new_bitmap_flag(uint32_t flag) {
    al_add_new_bitmap_flag((int)flag);
    return io_ok_unit();
}

lean_object* allegro_al_get_bitmap_flags(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_bitmap_flags((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)));
}

lean_object* allegro_al_get_bitmap_format(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_bitmap_format((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)));
}

lean_object* allegro_al_set_new_bitmap_format(uint32_t format) {
    al_set_new_bitmap_format((int)format);
    return io_ok_unit();
}

lean_object* allegro_al_get_new_bitmap_format(void) {
    return io_ok_uint32((uint32_t)al_get_new_bitmap_format());
}

/* ── Sub-bitmap ── */

lean_object* allegro_al_is_sub_bitmap(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_sub_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)) ? 1u : 0u);
}

lean_object* allegro_al_get_parent_bitmap(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(al_get_parent_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap))));
}

lean_object* allegro_al_reparent_bitmap(uint64_t bitmap, uint64_t parent,
        int32_t x, int32_t y, int32_t w, int32_t h) {
    if (bitmap != 0 && parent != 0) {
        al_reparent_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap),
            (ALLEGRO_BITMAP *)u64_to_ptr(parent), x, y, w, h);
    }
    return io_ok_unit();
}

/* ── Bitmap conversion ── */

lean_object* allegro_al_convert_bitmap(uint64_t bitmap) {
    if (bitmap != 0) {
        al_convert_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap));
    }
    return io_ok_unit();
}

lean_object* allegro_al_convert_memory_bitmaps(void) {
    al_convert_memory_bitmaps();
    return io_ok_unit();
}

/* ── Bitmap locking ── */

lean_object* allegro_al_is_bitmap_locked(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_bitmap_locked((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)) ? 1u : 0u);
}

lean_object* allegro_al_lock_bitmap(uint64_t bitmap, uint32_t format, uint32_t flags) {
    if (bitmap == 0) return io_ok_uint64(0);
    ALLEGRO_LOCKED_REGION *lr = al_lock_bitmap(
        (ALLEGRO_BITMAP *)u64_to_ptr(bitmap), (int)format, (int)flags);
    return io_ok_uint64(ptr_to_u64(lr));
}

lean_object* allegro_al_lock_bitmap_region(uint64_t bitmap,
        int32_t x, int32_t y, int32_t w, int32_t h,
        uint32_t format, uint32_t flags) {
    if (bitmap == 0) return io_ok_uint64(0);
    ALLEGRO_LOCKED_REGION *lr = al_lock_bitmap_region(
        (ALLEGRO_BITMAP *)u64_to_ptr(bitmap), x, y, w, h, (int)format, (int)flags);
    return io_ok_uint64(ptr_to_u64(lr));
}

lean_object* allegro_al_unlock_bitmap(uint64_t bitmap) {
    if (bitmap != 0) {
        al_unlock_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap));
    }
    return io_ok_unit();
}

lean_object* allegro_al_locked_region_get_format(uint64_t lr) {
    if (lr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_LOCKED_REGION *)u64_to_ptr(lr))->format);
}

lean_object* allegro_al_locked_region_get_pitch(uint64_t lr) {
    if (lr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_LOCKED_REGION *)u64_to_ptr(lr))->pitch);
}

lean_object* allegro_al_locked_region_get_pixel_size(uint64_t lr) {
    if (lr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_LOCKED_REGION *)u64_to_ptr(lr))->pixel_size);
}

lean_object* allegro_al_locked_region_get_data(uint64_t lr) {
    if (lr == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(((ALLEGRO_LOCKED_REGION *)u64_to_ptr(lr))->data));
}

/* ── Pixel get/put ── */

lean_object* allegro_al_put_pixel(int32_t x, int32_t y, uint32_t r, uint32_t g, uint32_t b) {
    al_put_pixel(x, y, al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b));
    return io_ok_unit();
}

lean_object* allegro_al_put_pixel_rgba(int32_t x, int32_t y, uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
    al_put_pixel(x, y, al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a));
    return io_ok_unit();
}

lean_object* allegro_al_put_blended_pixel(int32_t x, int32_t y, uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
    al_put_blended_pixel(x, y, al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a));
    return io_ok_unit();
}

/* ── Rotated / tinted drawing ── */

lean_object* allegro_al_draw_rotated_bitmap(uint64_t bitmap,
        double cx, double cy, double dx, double dy, double angle, uint32_t flags) {
    if (bitmap != 0) {
        al_draw_rotated_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap),
            (float)cx, (float)cy, (float)dx, (float)dy, (float)angle, (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_scaled_rotated_bitmap(uint64_t bitmap,
        double cx, double cy, double dx, double dy,
        double xscale, double yscale, double angle, uint32_t flags) {
    if (bitmap != 0) {
        al_draw_scaled_rotated_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap),
            (float)cx, (float)cy, (float)dx, (float)dy,
            (float)xscale, (float)yscale, (float)angle, (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_tinted_bitmap_rgb(uint64_t bitmap,
        uint32_t r, uint32_t g, uint32_t b,
        double dx, double dy, uint32_t flags) {
    if (bitmap != 0) {
        ALLEGRO_COLOR tint = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_tinted_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), tint,
            (float)dx, (float)dy, (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_tinted_scaled_bitmap_rgb(uint64_t bitmap,
        uint32_t r, uint32_t g, uint32_t b,
        double sx, double sy, double sw, double sh,
        double dx, double dy, double dw, double dh, uint32_t flags) {
    if (bitmap != 0) {
        ALLEGRO_COLOR tint = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_tinted_scaled_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), tint,
            (float)sx, (float)sy, (float)sw, (float)sh,
            (float)dx, (float)dy, (float)dw, (float)dh, (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_tinted_rotated_bitmap_rgb(uint64_t bitmap,
        uint32_t r, uint32_t g, uint32_t b,
        double cx, double cy, double dx, double dy, double angle, uint32_t flags) {
    if (bitmap != 0) {
        ALLEGRO_COLOR tint = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_tinted_rotated_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), tint,
            (float)cx, (float)cy, (float)dx, (float)dy, (float)angle, (int)flags);
    }
    return io_ok_unit();
}

/* ── Render state ── */

lean_object* allegro_al_hold_bitmap_drawing(uint32_t hold) {
    al_hold_bitmap_drawing(hold != 0);
    return io_ok_unit();
}

lean_object* allegro_al_is_bitmap_drawing_held(void) {
    return io_ok_uint32(al_is_bitmap_drawing_held() ? 1u : 0u);
}

/* ── Tuple-returning queries ── */

lean_object* allegro_al_get_clipping_rectangle(void) {
    int x = 0, y = 0, w = 0, h = 0;
    al_get_clipping_rectangle(&x, &y, &w, &h);
    return io_ok_u32_quad((uint32_t)x, (uint32_t)y, (uint32_t)w, (uint32_t)h);
}

lean_object* allegro_al_get_pixel_rgba(uint64_t bitmap, int32_t x, int32_t y) {
    if (bitmap == 0) return io_ok_u32_quad(0, 0, 0, 0);
    ALLEGRO_COLOR c = al_get_pixel((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), x, y);
    unsigned char r, g, b, a;
    al_unmap_rgba(c, &r, &g, &b, &a);
    return io_ok_u32_quad((uint32_t)r, (uint32_t)g, (uint32_t)b, (uint32_t)a);
}

/* ── Depth / samples / wrap (UNSTABLE) ── */

lean_object* allegro_al_get_new_bitmap_depth(void) {
    return io_ok_uint32((uint32_t)al_get_new_bitmap_depth());
}

lean_object* allegro_al_set_new_bitmap_depth(uint32_t depth) {
    al_set_new_bitmap_depth((int)depth);
    return io_ok_unit();
}

lean_object* allegro_al_get_new_bitmap_samples(void) {
    return io_ok_uint32((uint32_t)al_get_new_bitmap_samples());
}

lean_object* allegro_al_set_new_bitmap_samples(uint32_t samples) {
    al_set_new_bitmap_samples((int)samples);
    return io_ok_unit();
}

lean_object* allegro_al_get_new_bitmap_wrap(void) {
    ALLEGRO_BITMAP_WRAP u, v;
    al_get_new_bitmap_wrap(&u, &v);
    return io_ok_u32_pair((uint32_t)u, (uint32_t)v);
}

lean_object* allegro_al_set_new_bitmap_wrap(uint32_t u, uint32_t v) {
    al_set_new_bitmap_wrap((ALLEGRO_BITMAP_WRAP)u, (ALLEGRO_BITMAP_WRAP)v);
    return io_ok_unit();
}

lean_object* allegro_al_get_bitmap_depth(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_bitmap_depth((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)));
}

lean_object* allegro_al_get_bitmap_samples(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_bitmap_samples((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)));
}

/* ── Sub-bitmap position ── */

lean_object* allegro_al_get_bitmap_x(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_bitmap_x((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)));
}

lean_object* allegro_al_get_bitmap_y(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_bitmap_y((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)));
}

/* ── Mask to alpha ── */

lean_object* allegro_al_convert_mask_to_alpha(uint64_t bitmap,
        uint32_t r, uint32_t g, uint32_t b) {
    if (bitmap != 0) {
        ALLEGRO_COLOR mask = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_convert_mask_to_alpha((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), mask);
    }
    return io_ok_unit();
}

/* ── Per-bitmap blender (UNSTABLE) ── */

lean_object* allegro_al_get_bitmap_blender(void) {
    int op, src, dst;
    al_get_bitmap_blender(&op, &src, &dst);
    return io_ok_u32_triple((uint32_t)op, (uint32_t)src, (uint32_t)dst);
}

lean_object* allegro_al_set_bitmap_blender(uint32_t op, uint32_t src, uint32_t dst) {
    al_set_bitmap_blender((int)op, (int)src, (int)dst);
    return io_ok_unit();
}

lean_object* allegro_al_get_separate_bitmap_blender(void) {
    int op, src, dst, aop, asrc, adst;
    al_get_separate_bitmap_blender(&op, &src, &dst, &aop, &asrc, &adst);
    lean_object* p5 = mk_pair(lean_box_uint32((uint32_t)asrc), lean_box_uint32((uint32_t)adst));
    lean_object* p4 = mk_pair(lean_box_uint32((uint32_t)aop), p5);
    lean_object* p3 = mk_pair(lean_box_uint32((uint32_t)dst), p4);
    lean_object* p2 = mk_pair(lean_box_uint32((uint32_t)src), p3);
    lean_object* p1 = mk_pair(lean_box_uint32((uint32_t)op), p2);
    return lean_io_result_mk_ok(p1);
}

lean_object* allegro_al_set_separate_bitmap_blender(
        uint32_t op, uint32_t src, uint32_t dst,
        uint32_t alpha_op, uint32_t alpha_src, uint32_t alpha_dst) {
    al_set_separate_bitmap_blender((int)op, (int)src, (int)dst,
                                   (int)alpha_op, (int)alpha_src, (int)alpha_dst);
    return io_ok_unit();
}

lean_object* allegro_al_get_bitmap_blend_color(void) {
    ALLEGRO_COLOR c = al_get_bitmap_blend_color();
    float r, g, b, a;
    al_unmap_rgba_f(c, &r, &g, &b, &a);
    return io_ok_f64_quad((double)r, (double)g, (double)b, (double)a);
}

lean_object* allegro_al_set_bitmap_blend_color(double r, double g, double b, double a) {
    al_set_bitmap_blend_color(al_map_rgba_f((float)r, (float)g, (float)b, (float)a));
    return io_ok_unit();
}

lean_object* allegro_al_reset_bitmap_blender(void) {
    al_reset_bitmap_blender();
    return io_ok_unit();
}

/* ── Tinted drawing (remaining) ── */

lean_object* allegro_al_draw_tinted_bitmap_region_rgb(uint64_t bitmap,
        uint32_t r, uint32_t g, uint32_t b,
        double sx, double sy, double sw, double sh,
        double dx, double dy, uint32_t flags) {
    if (bitmap != 0) {
        ALLEGRO_COLOR tint = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_tinted_bitmap_region((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), tint,
            (float)sx, (float)sy, (float)sw, (float)sh,
            (float)dx, (float)dy, (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_tinted_scaled_rotated_bitmap_rgb(uint64_t bitmap,
        uint32_t r, uint32_t g, uint32_t b,
        double cx, double cy, double dx, double dy,
        double xscale, double yscale, double angle, uint32_t flags) {
    if (bitmap != 0) {
        ALLEGRO_COLOR tint = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_tinted_scaled_rotated_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), tint,
            (float)cx, (float)cy, (float)dx, (float)dy,
            (float)xscale, (float)yscale, (float)angle, (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_tinted_scaled_rotated_bitmap_region_rgb(uint64_t bitmap,
        double sx, double sy, double sw, double sh,
        uint32_t r, uint32_t g, uint32_t b,
        double cx, double cy, double dx, double dy,
        double xscale, double yscale, double angle, uint32_t flags) {
    if (bitmap != 0) {
        ALLEGRO_COLOR tint = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_tinted_scaled_rotated_bitmap_region((ALLEGRO_BITMAP *)u64_to_ptr(bitmap),
            (float)sx, (float)sy, (float)sw, (float)sh, tint,
            (float)cx, (float)cy, (float)dx, (float)dy,
            (float)xscale, (float)yscale, (float)angle, (int)flags);
    }
    return io_ok_unit();
}

/* ── Block-aligned locking ── */

lean_object* allegro_al_lock_bitmap_blocked(uint64_t bitmap, uint32_t flags) {
    if (bitmap == 0) return io_ok_uint64(0);
    ALLEGRO_LOCKED_REGION *lr = al_lock_bitmap_blocked(
        (ALLEGRO_BITMAP *)u64_to_ptr(bitmap), (int)flags);
    return io_ok_uint64(ptr_to_u64(lr));
}

lean_object* allegro_al_lock_bitmap_region_blocked(uint64_t bitmap,
        int32_t x_block, int32_t y_block, int32_t w_block, int32_t h_block,
        uint32_t flags) {
    if (bitmap == 0) return io_ok_uint64(0);
    ALLEGRO_LOCKED_REGION *lr = al_lock_bitmap_region_blocked(
        (ALLEGRO_BITMAP *)u64_to_ptr(bitmap),
        x_block, y_block, w_block, h_block, (int)flags);
    return io_ok_uint64(ptr_to_u64(lr));
}

lean_object* allegro_al_backup_dirty_bitmap(uint64_t bitmap) {
    if (bitmap != 0) {
        al_backup_dirty_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap));
    }
    return io_ok_unit();
}
