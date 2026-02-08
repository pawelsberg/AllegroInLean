#include "allegro_ffi.h"
#include <allegro5/allegro.h>

lean_object* allegro_al_init(void) {
    return io_ok_uint32(al_init() ? 1u : 0u);
}

lean_object* allegro_al_uninstall_system(void) {
    al_uninstall_system();
    return io_ok_unit();
}

lean_object* allegro_al_rest(double seconds) {
    al_rest(seconds);
    return io_ok_unit();
}

lean_object* allegro_al_get_time(void) {
    return lean_io_result_mk_ok(lean_box_float(al_get_time()));
}

/* ── System info ── */

lean_object* allegro_al_get_allegro_version(void) {
    return io_ok_uint32((uint32_t)al_get_allegro_version());
}

lean_object* allegro_al_get_app_name(void) {
    return io_ok_string(al_get_app_name());
}

lean_object* allegro_al_set_app_name(lean_object* name) {
    al_set_app_name(lean_string_cstr(name));
    lean_dec_ref(name);
    return io_ok_unit();
}

lean_object* allegro_al_get_org_name(void) {
    return io_ok_string(al_get_org_name());
}

lean_object* allegro_al_set_org_name(lean_object* name) {
    al_set_org_name(lean_string_cstr(name));
    lean_dec_ref(name);
    return io_ok_unit();
}

lean_object* allegro_al_get_cpu_count(void) {
    return io_ok_uint32((uint32_t)al_get_cpu_count());
}

lean_object* allegro_al_get_ram_size(void) {
    return io_ok_uint32((uint32_t)al_get_ram_size());
}

/* ── State save/restore ── */

lean_object* allegro_al_create_state(void) {
    ALLEGRO_STATE *state = (ALLEGRO_STATE *)calloc(1, sizeof(ALLEGRO_STATE));
    return io_ok_uint64(ptr_to_u64(state));
}

lean_object* allegro_al_destroy_state(uint64_t state) {
    if (state != 0) {
        free(u64_to_ptr(state));
    }
    return io_ok_unit();
}

lean_object* allegro_al_store_state(uint64_t state, uint32_t flags) {
    if (state != 0) {
        al_store_state((ALLEGRO_STATE *)u64_to_ptr(state), (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_restore_state(uint64_t state) {
    if (state != 0) {
        al_restore_state((ALLEGRO_STATE *)u64_to_ptr(state));
    }
    return io_ok_unit();
}

/* ── Errno ── */

lean_object* allegro_al_get_errno(void) {
    return lean_io_result_mk_ok(lean_box_uint32((uint32_t)al_get_errno()));
}

lean_object* allegro_al_set_errno(uint32_t val) {
    al_set_errno((int)val);
    return io_ok_unit();
}

/* ── System queries ── */

lean_object* allegro_al_is_system_installed(void) {
    return io_ok_uint32(al_is_system_installed() ? 1u : 0u);
}

lean_object* allegro_al_get_system_id(void) {
    return io_ok_uint32((uint32_t)al_get_system_id());
}

lean_object* allegro_al_set_exe_name(lean_object* path) {
    al_set_exe_name(lean_string_cstr(path));
    lean_dec_ref(path);
    return io_ok_unit();
}

/* ── System driver ── */

lean_object* allegro_al_get_system_driver(void) {
    return io_ok_uint64(ptr_to_u64(al_get_system_driver()));
}
