#include "allegro_ffi.h"
#include <allegro5/allegro.h>
#include <allegro5/allegro_image.h>

lean_object* allegro_al_init_image_addon(void) {
    return io_ok_uint32(al_init_image_addon() ? 1u : 0u);
}

lean_object* allegro_al_shutdown_image_addon(void) {
    al_shutdown_image_addon();
    return io_ok_unit();
}

lean_object* allegro_al_is_image_addon_initialized(void) {
    return io_ok_uint32(al_is_image_addon_initialized() ? 1u : 0u);
}

lean_object* allegro_al_load_bitmap(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_BITMAP *bitmap = al_load_bitmap(path);
    return io_ok_uint64(ptr_to_u64(bitmap));
}

lean_object* allegro_al_destroy_bitmap(uint64_t bitmap) {
    if (bitmap != 0) {
        al_destroy_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap));
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_bitmap(uint64_t bitmap, double x, double y, uint32_t flags) {
    if (bitmap != 0) {
        al_draw_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap), (float)x, (float)y, (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_scaled_bitmap(
    uint64_t bitmap,
    double sx, double sy, double sw, double sh,
    double dx, double dy, double dw, double dh,
    uint32_t flags) {
    if (bitmap != 0) {
        al_draw_scaled_bitmap(
            (ALLEGRO_BITMAP *)u64_to_ptr(bitmap),
            (float)sx, (float)sy, (float)sw, (float)sh,
            (float)dx, (float)dy, (float)dw, (float)dh,
            (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_bitmap_region(
    uint64_t bitmap,
    double sx, double sy, double sw, double sh,
    double dx, double dy,
    uint32_t flags) {
    if (bitmap != 0) {
        al_draw_bitmap_region(
            (ALLEGRO_BITMAP *)u64_to_ptr(bitmap),
            (float)sx, (float)sy, (float)sw, (float)sh,
            (float)dx, (float)dy,
            (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_save_bitmap(lean_object* pathObj, uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    const char *path = lean_string_cstr(pathObj);
    bool ok = al_save_bitmap(path, (ALLEGRO_BITMAP *)u64_to_ptr(bitmap));
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_load_bitmap_flags(lean_object* pathObj, uint32_t flags) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_BITMAP *bitmap = al_load_bitmap_flags(path, (int)flags);
    return io_ok_uint64(ptr_to_u64(bitmap));
}

/* ── Identify ── */

lean_object* allegro_al_identify_bitmap(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    const char *ident = al_identify_bitmap(path);
    return io_ok_string(ident);
}

/* ── Version ── */

lean_object* allegro_al_get_image_version(void) {
    return io_ok_uint32(al_get_allegro_image_version());
}
