#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/* ── Filesystem (fshook.h) ── */

/* entry lifecycle */

lean_object* allegro_al_create_fs_entry(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_FS_ENTRY *e = al_create_fs_entry(path);
    lean_dec_ref(pathObj);
    return io_ok_uint64(ptr_to_u64(e));
}

lean_object* allegro_al_destroy_fs_entry(uint64_t entry) {
    if (entry != 0) al_destroy_fs_entry((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry));
    return io_ok_unit();
}

/* entry queries */

lean_object* allegro_al_get_fs_entry_name(uint64_t entry) {
    if (entry == 0) return io_ok_string("");
    return io_ok_string(al_get_fs_entry_name((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)));
}

lean_object* allegro_al_update_fs_entry(uint64_t entry) {
    if (entry == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_update_fs_entry((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)) ? 1u : 0u);
}

lean_object* allegro_al_get_fs_entry_mode(uint64_t entry) {
    if (entry == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_fs_entry_mode((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)));
}

lean_object* allegro_al_get_fs_entry_atime(uint64_t entry) {
    if (entry == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)al_get_fs_entry_atime((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)));
}

lean_object* allegro_al_get_fs_entry_mtime(uint64_t entry) {
    if (entry == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)al_get_fs_entry_mtime((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)));
}

lean_object* allegro_al_get_fs_entry_ctime(uint64_t entry) {
    if (entry == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)al_get_fs_entry_ctime((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)));
}

lean_object* allegro_al_get_fs_entry_size(uint64_t entry) {
    if (entry == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)al_get_fs_entry_size((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)));
}

lean_object* allegro_al_fs_entry_exists(uint64_t entry) {
    if (entry == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_fs_entry_exists((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)) ? 1u : 0u);
}

lean_object* allegro_al_remove_fs_entry(uint64_t entry) {
    if (entry == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_remove_fs_entry((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)) ? 1u : 0u);
}

/* directory traversal */

lean_object* allegro_al_open_directory(uint64_t entry) {
    if (entry == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_open_directory((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)) ? 1u : 0u);
}

lean_object* allegro_al_read_directory(uint64_t entry) {
    if (entry == 0) return io_ok_uint64(0);
    ALLEGRO_FS_ENTRY *child = al_read_directory((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry));
    return io_ok_uint64(ptr_to_u64(child));
}

lean_object* allegro_al_close_directory(uint64_t entry) {
    if (entry == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_close_directory((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry)) ? 1u : 0u);
}

/* filename / path utilities */

lean_object* allegro_al_filename_exists(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    bool exists = al_filename_exists(path);
    lean_dec_ref(pathObj);
    return io_ok_uint32(exists ? 1u : 0u);
}

lean_object* allegro_al_remove_filename(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    bool ok = al_remove_filename(path);
    lean_dec_ref(pathObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_get_current_directory(void) {
    char *dir = al_get_current_directory();
    lean_object *result = io_ok_string(dir ? dir : "");
    if (dir) al_free(dir);
    return result;
}

/* allegro_al_change_directory is already in allegro_path.c */

lean_object* allegro_al_make_directory(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    bool ok = al_make_directory(path);
    lean_dec_ref(pathObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

/* open fs entry as file */

lean_object* allegro_al_open_fs_entry(uint64_t entry, lean_object* modeObj) {
    if (entry == 0) { lean_dec_ref(modeObj); return io_ok_uint64(0); }
    const char *mode = lean_string_cstr(modeObj);
    ALLEGRO_FILE *f = al_open_fs_entry((ALLEGRO_FS_ENTRY *)u64_to_ptr(entry), mode);
    lean_dec_ref(modeObj);
    return io_ok_uint64(ptr_to_u64(f));
}

/* interface management */

lean_object* allegro_al_set_standard_fs_interface(void) {
    al_set_standard_fs_interface();
    return io_ok_unit();
}
