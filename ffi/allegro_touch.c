#include "allegro_ffi.h"
#include <allegro5/allegro.h>
#include <allegro5/touch_input.h>

/* ── Touch input installation ── */

lean_object* allegro_al_install_touch_input(void) {
    return io_ok_uint32(al_install_touch_input() ? 1u : 0u);
}

lean_object* allegro_al_uninstall_touch_input(void) {
    al_uninstall_touch_input();
    return io_ok_unit();
}

lean_object* allegro_al_is_touch_input_installed(void) {
    return io_ok_uint32(al_is_touch_input_installed() ? 1u : 0u);
}

/* ── Touch event sources ── */

lean_object* allegro_al_get_touch_input_event_source(void) {
    ALLEGRO_EVENT_SOURCE *src = al_get_touch_input_event_source();
    return io_ok_uint64(ptr_to_u64(src));
}

lean_object* allegro_al_get_touch_input_mouse_emulation_event_source(void) {
    ALLEGRO_EVENT_SOURCE *src = al_get_touch_input_mouse_emulation_event_source();
    return io_ok_uint64(ptr_to_u64(src));
}

lean_object* allegro_al_set_mouse_emulation_mode(uint32_t mode) {
    al_set_mouse_emulation_mode((int)mode);
    return io_ok_unit();
}

lean_object* allegro_al_get_mouse_emulation_mode(void) {
    return io_ok_uint32((uint32_t)al_get_mouse_emulation_mode());
}

/* ── Touch input state ── */

lean_object* allegro_al_create_touch_input_state(void) {
    ALLEGRO_TOUCH_INPUT_STATE *s =
        (ALLEGRO_TOUCH_INPUT_STATE *)calloc(1, sizeof(ALLEGRO_TOUCH_INPUT_STATE));
    return io_ok_uint64(ptr_to_u64(s));
}

lean_object* allegro_al_destroy_touch_input_state(uint64_t state) {
    if (state != 0) free(u64_to_ptr(state));
    return io_ok_unit();
}

lean_object* allegro_al_get_touch_input_state(uint64_t state) {
    if (state != 0) {
        al_get_touch_input_state(
            (ALLEGRO_TOUCH_INPUT_STATE *)u64_to_ptr(state));
    }
    return io_ok_unit();
}

/* Returns (id, x, y, dx, dy, primary) for a single touch slot. */
lean_object* allegro_al_touch_input_state_get_touch(uint64_t state, uint32_t index) {
    if (state == 0 || index >= ALLEGRO_TOUCH_INPUT_MAX_TOUCH_COUNT) {
        /* Return (0, 0.0, 0.0, 0.0, 0.0, 0) */
        lean_object* t5 = mk_pair(lean_box_float(0.0), lean_box_uint32(0));
        lean_object* t4 = mk_pair(lean_box_float(0.0), t5);
        lean_object* t3 = mk_pair(lean_box_float(0.0), t4);
        lean_object* t2 = mk_pair(lean_box_float(0.0), t3);
        return lean_io_result_mk_ok(mk_pair(lean_box_uint32(0), t2));
    }
    ALLEGRO_TOUCH_INPUT_STATE *s =
        (ALLEGRO_TOUCH_INPUT_STATE *)u64_to_ptr(state);
    ALLEGRO_TOUCH_STATE *t = &s->touches[index];
    lean_object* t5 = mk_pair(lean_box_float((double)t->dy), lean_box_uint32(t->primary ? 1u : 0u));
    lean_object* t4 = mk_pair(lean_box_float((double)t->dx), t5);
    lean_object* t3 = mk_pair(lean_box_float((double)t->y), t4);
    lean_object* t2 = mk_pair(lean_box_float((double)t->x), t3);
    return lean_io_result_mk_ok(mk_pair(lean_box_uint32((uint32_t)t->id), t2));
}
