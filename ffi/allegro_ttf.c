#include "allegro_ffi.h"
#include <allegro5/allegro_ttf.h>

/* ── Lifecycle ── */

lean_object* allegro_al_init_ttf_addon(void) {
    return io_ok_uint32(al_init_ttf_addon() ? 1u : 0u);
}

lean_object* allegro_al_shutdown_ttf_addon(void) {
    al_shutdown_ttf_addon();
    return io_ok_unit();
}

lean_object* allegro_al_is_ttf_addon_initialized(void) {
    return io_ok_uint32(al_is_ttf_addon_initialized() ? 1u : 0u);
}

/* ── Font loading ── */

lean_object* allegro_al_load_ttf_font(lean_object* pathObj, int32_t size, uint32_t flags) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_FONT *font = al_load_ttf_font(path, size, (int)flags);
    return io_ok_uint64(ptr_to_u64(font));
}

lean_object* allegro_al_load_ttf_font_stretch(lean_object* pathObj, int32_t w, int32_t h, uint32_t flags) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_FONT *font = al_load_ttf_font_stretch(path, w, h, (int)flags);
    return io_ok_uint64(ptr_to_u64(font));
}

/* ── Version ── */

lean_object* allegro_al_get_allegro_ttf_version(void) {
    return io_ok_uint32(al_get_allegro_ttf_version());
}

/* ── File-based TTF loading ── */

lean_object* allegro_al_load_ttf_font_f(uint64_t file, lean_object* nameObj,
                                         int32_t size, uint32_t flags) {
    if (file == 0) { lean_dec_ref(nameObj); return io_ok_uint64(0); }
    const char *name = lean_string_cstr(nameObj);
    ALLEGRO_FONT *font = al_load_ttf_font_f(
        (ALLEGRO_FILE *)u64_to_ptr(file), name, (int)size, (int)flags);
    lean_dec_ref(nameObj);
    return io_ok_uint64(ptr_to_u64(font));
}

lean_object* allegro_al_load_ttf_font_stretch_f(uint64_t file, lean_object* nameObj,
                                                  int32_t w, int32_t h, uint32_t flags) {
    if (file == 0) { lean_dec_ref(nameObj); return io_ok_uint64(0); }
    const char *name = lean_string_cstr(nameObj);
    ALLEGRO_FONT *font = al_load_ttf_font_stretch_f(
        (ALLEGRO_FILE *)u64_to_ptr(file), name, (int)w, (int)h, (int)flags);
    lean_dec_ref(nameObj);
    return io_ok_uint64(ptr_to_u64(font));
}
