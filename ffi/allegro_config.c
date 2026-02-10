#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/* ── Lifecycle ── */

lean_object* allegro_al_create_config(void) {
    ALLEGRO_CONFIG *cfg = al_create_config();
    return io_ok_uint64(ptr_to_u64(cfg));
}

lean_object* allegro_al_destroy_config(uint64_t cfg) {
    if (cfg != 0) {
        al_destroy_config((ALLEGRO_CONFIG *)u64_to_ptr(cfg));
    }
    return io_ok_unit();
}

/* ── Load / Save ── */

lean_object* allegro_al_load_config_file(b_lean_obj_arg pathObj) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_CONFIG *cfg = al_load_config_file(path);
    return io_ok_uint64(ptr_to_u64(cfg));
}

lean_object* allegro_al_save_config_file(b_lean_obj_arg pathObj, uint64_t cfg) {
    if (cfg == 0) return io_ok_uint32(0);
    const char *path = lean_string_cstr(pathObj);
    bool ok = al_save_config_file(path, (const ALLEGRO_CONFIG *)u64_to_ptr(cfg));
    return io_ok_uint32(ok ? 1u : 0u);
}

/* ── Sections ── */

lean_object* allegro_al_add_config_section(uint64_t cfg, b_lean_obj_arg nameObj) {
    if (cfg != 0) {
        al_add_config_section((ALLEGRO_CONFIG *)u64_to_ptr(cfg), lean_string_cstr(nameObj));
    }
    return io_ok_unit();
}

lean_object* allegro_al_remove_config_section(uint64_t cfg, b_lean_obj_arg nameObj) {
    if (cfg == 0) return io_ok_uint32(0);
    bool ok = al_remove_config_section((ALLEGRO_CONFIG *)u64_to_ptr(cfg), lean_string_cstr(nameObj));
    return io_ok_uint32(ok ? 1u : 0u);
}

/* ── Key/value ── */

lean_object* allegro_al_set_config_value(uint64_t cfg, b_lean_obj_arg sectionObj, b_lean_obj_arg keyObj, b_lean_obj_arg valueObj) {
    if (cfg != 0) {
        const char *section = lean_string_cstr(sectionObj);
        /* Allegro treats "" section as the global (unnamed) section. */
        al_set_config_value((ALLEGRO_CONFIG *)u64_to_ptr(cfg),
            section[0] ? section : NULL,
            lean_string_cstr(keyObj),
            lean_string_cstr(valueObj));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_config_value(uint64_t cfg, b_lean_obj_arg sectionObj, b_lean_obj_arg keyObj) {
    if (cfg == 0) return io_ok_string("");
    const char *section = lean_string_cstr(sectionObj);
    const char *val = al_get_config_value(
        (const ALLEGRO_CONFIG *)u64_to_ptr(cfg),
        section[0] ? section : NULL,
        lean_string_cstr(keyObj));
    return io_ok_string(val ? val : "");
}

lean_object* allegro_al_remove_config_key(uint64_t cfg, b_lean_obj_arg sectionObj, b_lean_obj_arg keyObj) {
    if (cfg == 0) return io_ok_uint32(0);
    const char *section = lean_string_cstr(sectionObj);
    bool ok = al_remove_config_key((ALLEGRO_CONFIG *)u64_to_ptr(cfg),
        section[0] ? section : NULL,
        lean_string_cstr(keyObj));
    return io_ok_uint32(ok ? 1u : 0u);
}

/* ── Comments ── */

lean_object* allegro_al_add_config_comment(uint64_t cfg, b_lean_obj_arg sectionObj, b_lean_obj_arg commentObj) {
    if (cfg != 0) {
        const char *section = lean_string_cstr(sectionObj);
        al_add_config_comment((ALLEGRO_CONFIG *)u64_to_ptr(cfg),
            section[0] ? section : NULL,
            lean_string_cstr(commentObj));
    }
    return io_ok_unit();
}

/* ── Merge ── */

lean_object* allegro_al_merge_config(uint64_t cfg1, uint64_t cfg2) {
    if (cfg1 == 0 || cfg2 == 0) return io_ok_uint64(0);
    ALLEGRO_CONFIG *merged = al_merge_config(
        (const ALLEGRO_CONFIG *)u64_to_ptr(cfg1),
        (const ALLEGRO_CONFIG *)u64_to_ptr(cfg2));
    return io_ok_uint64(ptr_to_u64(merged));
}

lean_object* allegro_al_merge_config_into(uint64_t master, uint64_t add) {
    if (master != 0 && add != 0) {
        al_merge_config_into(
            (ALLEGRO_CONFIG *)u64_to_ptr(master),
            (const ALLEGRO_CONFIG *)u64_to_ptr(add));
    }
    return io_ok_unit();
}

/* ── System config ── */

lean_object* allegro_al_get_system_config(void) {
    ALLEGRO_CONFIG *cfg = al_get_system_config();
    return io_ok_uint64(ptr_to_u64(cfg));
}

/* ── Iteration ── */

lean_object* allegro_al_get_config_sections(uint64_t cfg) {
    lean_object *arr = lean_mk_empty_array();
    if (cfg == 0) return lean_io_result_mk_ok(arr);
    ALLEGRO_CONFIG_SECTION *iter;
    const char *name = al_get_first_config_section(
        (const ALLEGRO_CONFIG *)u64_to_ptr(cfg), &iter);
    while (name) {
        arr = lean_array_push(arr, lean_mk_string(name));
        name = al_get_next_config_section(&iter);
    }
    return lean_io_result_mk_ok(arr);
}

lean_object* allegro_al_get_config_entries(uint64_t cfg, b_lean_obj_arg sectionObj) {
    lean_object *arr = lean_mk_empty_array();
    if (cfg == 0) return lean_io_result_mk_ok(arr);
    const char *section = lean_string_cstr(sectionObj);
    ALLEGRO_CONFIG_ENTRY *iter;
    const char *name = al_get_first_config_entry(
        (const ALLEGRO_CONFIG *)u64_to_ptr(cfg),
        section[0] ? section : NULL, &iter);
    while (name) {
        arr = lean_array_push(arr, lean_mk_string(name));
        name = al_get_next_config_entry(&iter);
    }
    return lean_io_result_mk_ok(arr);
}

/* ── File-based config I/O ── */

lean_object* allegro_al_load_config_file_f(uint64_t file) {
    if (file == 0) return io_ok_uint64(0);
    ALLEGRO_CONFIG *cfg = al_load_config_file_f((ALLEGRO_FILE *)u64_to_ptr(file));
    return io_ok_uint64(ptr_to_u64(cfg));
}

lean_object* allegro_al_save_config_file_f(uint64_t file, uint64_t config) {
    if (file == 0 || config == 0) return io_ok_uint32(0);
    bool ok = al_save_config_file_f((ALLEGRO_FILE *)u64_to_ptr(file),
                                     (const ALLEGRO_CONFIG *)u64_to_ptr(config));
    return io_ok_uint32(ok ? 1u : 0u);
}
