#include "allegro_ffi.h"
#include <allegro5/allegro.h>

lean_object* allegro_al_standard_path_resources(void) {
    return io_ok_uint32((uint32_t)ALLEGRO_RESOURCES_PATH);
}

lean_object* allegro_al_create_path(b_lean_obj_arg pathObj) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_PATH *p = al_create_path(path);
    return io_ok_uint64(ptr_to_u64(p));
}

lean_object* allegro_al_clone_path(uint64_t pathPtr) {
    if (pathPtr == 0) {
        return io_ok_uint64(0);
    }
    ALLEGRO_PATH *p = al_clone_path((ALLEGRO_PATH *)u64_to_ptr(pathPtr));
    return io_ok_uint64(ptr_to_u64(p));
}

lean_object* allegro_al_make_path_canonical(uint64_t pathPtr) {
    if (pathPtr == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32(al_make_path_canonical((ALLEGRO_PATH *)u64_to_ptr(pathPtr)) ? 1u : 0u);
}

lean_object* allegro_al_get_standard_path(uint32_t which) {
    ALLEGRO_PATH *path = al_get_standard_path((int)which);
    return io_ok_uint64(ptr_to_u64(path));
}

lean_object* allegro_al_append_path_component(uint64_t pathPtr, b_lean_obj_arg componentObj) {
    if (pathPtr != 0) {
        const char *component = lean_string_cstr(componentObj);
        al_append_path_component((ALLEGRO_PATH *)u64_to_ptr(pathPtr), component);
    }
    return io_ok_unit();
}

lean_object* allegro_al_path_cstr(uint64_t pathPtr, uint32_t delim) {
    if (pathPtr == 0) {
        return io_ok_string("");
    }
    const char *value = al_path_cstr((ALLEGRO_PATH *)u64_to_ptr(pathPtr), (char)delim);
    return io_ok_string(value);
}

lean_object* allegro_al_get_path_drive(uint64_t pathPtr) {
    if (pathPtr == 0) {
        return io_ok_string("");
    }
    return io_ok_string(al_get_path_drive((ALLEGRO_PATH *)u64_to_ptr(pathPtr)));
}

lean_object* allegro_al_get_path_filename(uint64_t pathPtr) {
    if (pathPtr == 0) {
        return io_ok_string("");
    }
    return io_ok_string(al_get_path_filename((ALLEGRO_PATH *)u64_to_ptr(pathPtr)));
}

lean_object* allegro_al_get_path_num_components(uint64_t pathPtr) {
    if (pathPtr == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_get_path_num_components((ALLEGRO_PATH *)u64_to_ptr(pathPtr)));
}

lean_object* allegro_al_get_path_component(uint64_t pathPtr, uint32_t index) {
    if (pathPtr == 0) {
        return io_ok_string("");
    }
    return io_ok_string(al_get_path_component((ALLEGRO_PATH *)u64_to_ptr(pathPtr), (int)index));
}

lean_object* allegro_al_change_directory(b_lean_obj_arg pathObj) {
    const char *path = lean_string_cstr(pathObj);
    return io_ok_uint32(al_change_directory(path) ? 1u : 0u);
}

lean_object* allegro_al_destroy_path(uint64_t pathPtr) {
    if (pathPtr != 0) {
        al_destroy_path((ALLEGRO_PATH *)u64_to_ptr(pathPtr));
    }
    return io_ok_unit();
}

/* ── Path: additional operations ── */

lean_object* allegro_al_create_path_for_directory(lean_object* pathObj) {
    const char *str = lean_string_cstr(pathObj);
    ALLEGRO_PATH *p = al_create_path_for_directory(str);
    lean_dec_ref(pathObj);
    return io_ok_uint64(ptr_to_u64(p));
}

lean_object* allegro_al_insert_path_component(uint64_t pathPtr, uint32_t index, lean_object* sObj) {
    if (pathPtr != 0) {
        al_insert_path_component((ALLEGRO_PATH *)u64_to_ptr(pathPtr),
            (int)index, lean_string_cstr(sObj));
    }
    lean_dec_ref(sObj);
    return io_ok_unit();
}

lean_object* allegro_al_remove_path_component(uint64_t pathPtr, uint32_t index) {
    if (pathPtr != 0) {
        al_remove_path_component((ALLEGRO_PATH *)u64_to_ptr(pathPtr), (int)index);
    }
    return io_ok_unit();
}

lean_object* allegro_al_replace_path_component(uint64_t pathPtr, uint32_t index, lean_object* sObj) {
    if (pathPtr != 0) {
        al_replace_path_component((ALLEGRO_PATH *)u64_to_ptr(pathPtr),
            (int)index, lean_string_cstr(sObj));
    }
    lean_dec_ref(sObj);
    return io_ok_unit();
}

lean_object* allegro_al_get_path_tail(uint64_t pathPtr) {
    if (pathPtr == 0) return io_ok_string("");
    return io_ok_string(al_get_path_tail((const ALLEGRO_PATH *)u64_to_ptr(pathPtr)));
}

lean_object* allegro_al_drop_path_tail(uint64_t pathPtr) {
    if (pathPtr != 0) {
        al_drop_path_tail((ALLEGRO_PATH *)u64_to_ptr(pathPtr));
    }
    return io_ok_unit();
}

lean_object* allegro_al_join_paths(uint64_t pathPtr, uint64_t tailPtr) {
    if (pathPtr == 0 || tailPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_join_paths((ALLEGRO_PATH *)u64_to_ptr(pathPtr),
                      (const ALLEGRO_PATH *)u64_to_ptr(tailPtr)) ? 1u : 0u);
}

lean_object* allegro_al_rebase_path(uint64_t headPtr, uint64_t tailPtr) {
    if (headPtr == 0 || tailPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_rebase_path((const ALLEGRO_PATH *)u64_to_ptr(headPtr),
                       (ALLEGRO_PATH *)u64_to_ptr(tailPtr)) ? 1u : 0u);
}

lean_object* allegro_al_set_path_drive(uint64_t pathPtr, lean_object* driveObj) {
    if (pathPtr != 0) {
        al_set_path_drive((ALLEGRO_PATH *)u64_to_ptr(pathPtr), lean_string_cstr(driveObj));
    }
    lean_dec_ref(driveObj);
    return io_ok_unit();
}

lean_object* allegro_al_set_path_filename(uint64_t pathPtr, lean_object* fnObj) {
    if (pathPtr != 0) {
        al_set_path_filename((ALLEGRO_PATH *)u64_to_ptr(pathPtr), lean_string_cstr(fnObj));
    }
    lean_dec_ref(fnObj);
    return io_ok_unit();
}

lean_object* allegro_al_get_path_extension(uint64_t pathPtr) {
    if (pathPtr == 0) return io_ok_string("");
    return io_ok_string(al_get_path_extension((const ALLEGRO_PATH *)u64_to_ptr(pathPtr)));
}

lean_object* allegro_al_set_path_extension(uint64_t pathPtr, lean_object* extObj) {
    if (pathPtr == 0) {
        lean_dec_ref(extObj);
        return io_ok_uint32(0);
    }
    uint32_t ok = al_set_path_extension((ALLEGRO_PATH *)u64_to_ptr(pathPtr),
        lean_string_cstr(extObj)) ? 1u : 0u;
    lean_dec_ref(extObj);
    return io_ok_uint32(ok);
}

lean_object* allegro_al_get_path_basename(uint64_t pathPtr) {
    if (pathPtr == 0) return io_ok_string("");
    return io_ok_string(al_get_path_basename((const ALLEGRO_PATH *)u64_to_ptr(pathPtr)));
}

/* ── Path as USTR handle ── */

lean_object* allegro_al_path_ustr(uint64_t pathPtr, uint32_t delim) {
    if (pathPtr == 0) return io_ok_uint64(0);
    const ALLEGRO_USTR *u = al_path_ustr(
        (const ALLEGRO_PATH *)u64_to_ptr(pathPtr), (char)delim);
    /* The returned USTR is owned by the path — we return a pointer to it.
       Caller must not destroy it (it lives as long as the Path). */
    return io_ok_uint64(ptr_to_u64((void *)u));
}
