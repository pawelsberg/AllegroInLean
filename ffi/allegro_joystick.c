#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/* ── Joystick installation ── */

lean_object* allegro_al_install_joystick(void) {
    return io_ok_uint32(al_install_joystick() ? 1u : 0u);
}

lean_object* allegro_al_uninstall_joystick(void) {
    al_uninstall_joystick();
    return io_ok_unit();
}

lean_object* allegro_al_is_joystick_installed(void) {
    return io_ok_uint32(al_is_joystick_installed() ? 1u : 0u);
}

lean_object* allegro_al_reconfigure_joysticks(void) {
    return io_ok_uint32(al_reconfigure_joysticks() ? 1u : 0u);
}

/* ── Joystick enumeration ── */

lean_object* allegro_al_get_num_joysticks(void) {
    return io_ok_uint32((uint32_t)al_get_num_joysticks());
}

lean_object* allegro_al_get_joystick(uint32_t num) {
    ALLEGRO_JOYSTICK *joy = al_get_joystick((int)num);
    return io_ok_uint64(ptr_to_u64(joy));
}

lean_object* allegro_al_release_joystick(uint64_t joy) {
    if (joy != 0) {
        al_release_joystick((ALLEGRO_JOYSTICK *)u64_to_ptr(joy));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_joystick_active(uint64_t joy) {
    if (joy == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_joystick_active((ALLEGRO_JOYSTICK *)u64_to_ptr(joy)) ? 1u : 0u);
}

/* ── Joystick properties ── */

lean_object* allegro_al_get_joystick_name(uint64_t joy) {
    if (joy == 0) return io_ok_string("");
    return io_ok_string(al_get_joystick_name((ALLEGRO_JOYSTICK *)u64_to_ptr(joy)));
}

lean_object* allegro_al_get_joystick_num_sticks(uint64_t joy) {
    if (joy == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_joystick_num_sticks((ALLEGRO_JOYSTICK *)u64_to_ptr(joy)));
}

lean_object* allegro_al_get_joystick_stick_name(uint64_t joy, uint32_t stick) {
    if (joy == 0) return io_ok_string("");
    return io_ok_string(al_get_joystick_stick_name((ALLEGRO_JOYSTICK *)u64_to_ptr(joy), (int)stick));
}

lean_object* allegro_al_get_joystick_num_axes(uint64_t joy, uint32_t stick) {
    if (joy == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_joystick_num_axes((ALLEGRO_JOYSTICK *)u64_to_ptr(joy), (int)stick));
}

lean_object* allegro_al_get_joystick_axis_name(uint64_t joy, uint32_t stick, uint32_t axis) {
    if (joy == 0) return io_ok_string("");
    return io_ok_string(al_get_joystick_axis_name((ALLEGRO_JOYSTICK *)u64_to_ptr(joy), (int)stick, (int)axis));
}

lean_object* allegro_al_get_joystick_num_buttons(uint64_t joy) {
    if (joy == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_joystick_num_buttons((ALLEGRO_JOYSTICK *)u64_to_ptr(joy)));
}

lean_object* allegro_al_get_joystick_button_name(uint64_t joy, uint32_t button) {
    if (joy == 0) return io_ok_string("");
    return io_ok_string(al_get_joystick_button_name((ALLEGRO_JOYSTICK *)u64_to_ptr(joy), (int)button));
}

/* ── Joystick state ── */

lean_object* allegro_al_create_joystick_state(void) {
    ALLEGRO_JOYSTICK_STATE *state = (ALLEGRO_JOYSTICK_STATE *)malloc(sizeof(ALLEGRO_JOYSTICK_STATE));
    return io_ok_uint64(ptr_to_u64(state));
}

lean_object* allegro_al_destroy_joystick_state(uint64_t state) {
    if (state != 0) free(u64_to_ptr(state));
    return io_ok_unit();
}

lean_object* allegro_al_get_joystick_state(uint64_t joy, uint64_t state) {
    if (joy != 0 && state != 0) {
        al_get_joystick_state(
            (ALLEGRO_JOYSTICK *)u64_to_ptr(joy),
            (ALLEGRO_JOYSTICK_STATE *)u64_to_ptr(state));
    }
    return io_ok_unit();
}

lean_object* allegro_al_joystick_state_get_axis(uint64_t state, uint32_t stick, uint32_t axis) {
    if (state == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    ALLEGRO_JOYSTICK_STATE *s = (ALLEGRO_JOYSTICK_STATE *)u64_to_ptr(state);
    return lean_io_result_mk_ok(lean_box_float(s->stick[stick].axis[axis]));
}

lean_object* allegro_al_joystick_state_get_button(uint64_t state, uint32_t button) {
    if (state == 0) return io_ok_uint32(0);
    ALLEGRO_JOYSTICK_STATE *s = (ALLEGRO_JOYSTICK_STATE *)u64_to_ptr(state);
    return io_ok_uint32((uint32_t)s->button[button]);
}

/* ── Joystick event source ── */

lean_object* allegro_al_get_joystick_event_source(void) {
    return io_ok_uint64(ptr_to_u64(al_get_joystick_event_source()));
}

/* ── Joystick stick flags ── */

lean_object* allegro_al_get_joystick_stick_flags(uint64_t joy, uint32_t stick) {
    if (joy == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_joystick_stick_flags(
        (ALLEGRO_JOYSTICK *)u64_to_ptr(joy), (int)stick));
}

/* ── Joystick 5.2.11 — GUID / type / mappings (UNSTABLE) ── */

lean_object* allegro_al_get_joystick_guid(uint64_t joy) {
    if (joy == 0) return io_ok_string("");
    ALLEGRO_JOYSTICK_GUID guid = al_get_joystick_guid(
        (ALLEGRO_JOYSTICK *)u64_to_ptr(joy));
    static const char hex[] = "0123456789abcdef";
    char buf[33];
    for (int i = 0; i < 16; i++) {
        buf[i * 2]     = hex[guid.val[i] >> 4];
        buf[i * 2 + 1] = hex[guid.val[i] & 0x0f];
    }
    buf[32] = '\0';
    return io_ok_string(buf);
}

lean_object* allegro_al_get_joystick_type(uint64_t joy) {
    if (joy == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_joystick_type(
        (ALLEGRO_JOYSTICK *)u64_to_ptr(joy)));
}

lean_object* allegro_al_set_joystick_mappings(b_lean_obj_arg pathObj) {
    const char *path = lean_string_cstr(pathObj);
    bool ok = al_set_joystick_mappings(path);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_set_joystick_mappings_f(uint64_t file) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_joystick_mappings_f(
        (ALLEGRO_FILE *)u64_to_ptr(file)) ? 1u : 0u);
}
