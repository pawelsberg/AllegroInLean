#include "allegro_ffi.h"
#include <allegro5/allegro.h>
#include <string.h>

/* ── File I/O ── */

/* open / close */

lean_object* allegro_al_fopen(lean_object* pathObj, lean_object* modeObj) {
    const char *path = lean_string_cstr(pathObj);
    const char *mode = lean_string_cstr(modeObj);
    ALLEGRO_FILE *f = al_fopen(path, mode);
    lean_dec_ref(pathObj);
    lean_dec_ref(modeObj);
    return io_ok_uint64(ptr_to_u64(f));
}

lean_object* allegro_al_fclose(uint64_t file) {
    if (file == 0) return io_ok_uint32(0);
    bool ok = al_fclose((ALLEGRO_FILE *)u64_to_ptr(file));
    return io_ok_uint32(ok ? 1u : 0u);
}

/* read / write (raw bytes) */

lean_object* allegro_al_fread(uint64_t file, uint32_t size) {
    if (file == 0 || size == 0) {
        /* Return empty ByteArray + 0 bytes read */
        lean_object *ba = lean_mk_empty_byte_array(lean_box(0));
        return lean_io_result_mk_ok(mk_pair(ba, lean_box_uint32(0)));
    }
    lean_object *ba = lean_mk_empty_byte_array(lean_box(size));
    /* Grow the ByteArray to the requested capacity */
    ba = lean_byte_array_push(ba, 0); /* ensure at least 1 byte to get a sarray */
    /* Actually, build a buffer, read, then create the ByteArray */
    lean_dec_ref(ba);
    uint8_t *buf = (uint8_t *)malloc(size);
    size_t n = al_fread((ALLEGRO_FILE *)u64_to_ptr(file), buf, size);
    lean_object *result = lean_alloc_sarray(1, n, n);
    if (n > 0) memcpy(lean_sarray_cptr(result), buf, n);
    free(buf);
    return lean_io_result_mk_ok(mk_pair(result, lean_box_uint32((uint32_t)n)));
}

lean_object* allegro_al_fwrite(uint64_t file, lean_object* ba) {
    if (file == 0) {
        lean_dec_ref(ba);
        return io_ok_uint32(0);
    }
    size_t sz = lean_sarray_size(ba);
    const uint8_t *ptr = lean_sarray_cptr(ba);
    size_t n = al_fwrite((ALLEGRO_FILE *)u64_to_ptr(file), ptr, sz);
    lean_dec_ref(ba);
    return io_ok_uint32((uint32_t)n);
}

/* flush / seek / tell / size */

lean_object* allegro_al_fflush(uint64_t file) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_fflush((ALLEGRO_FILE *)u64_to_ptr(file)) ? 1u : 0u);
}

lean_object* allegro_al_ftell(uint64_t file) {
    if (file == 0) return io_ok_uint64(0);
    int64_t pos = al_ftell((ALLEGRO_FILE *)u64_to_ptr(file));
    return io_ok_uint64((uint64_t)pos);
}

lean_object* allegro_al_fseek(uint64_t file, uint64_t offset, uint32_t whence) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_fseek((ALLEGRO_FILE *)u64_to_ptr(file), (int64_t)offset, (int)whence) ? 1u : 0u);
}

lean_object* allegro_al_feof(uint64_t file) {
    if (file == 0) return io_ok_uint32(1);
    return io_ok_uint32(al_feof((ALLEGRO_FILE *)u64_to_ptr(file)) ? 1u : 0u);
}

lean_object* allegro_al_ferror(uint64_t file) {
    if (file == 0) return io_ok_uint32(1);
    return io_ok_uint32((uint32_t)al_ferror((ALLEGRO_FILE *)u64_to_ptr(file)));
}

lean_object* allegro_al_ferrmsg(uint64_t file) {
    if (file == 0) return io_ok_string("null file");
    return io_ok_string(al_ferrmsg((ALLEGRO_FILE *)u64_to_ptr(file)));
}

lean_object* allegro_al_fclearerr(uint64_t file) {
    if (file != 0) al_fclearerr((ALLEGRO_FILE *)u64_to_ptr(file));
    return io_ok_unit();
}

lean_object* allegro_al_fsize(uint64_t file) {
    if (file == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)al_fsize((ALLEGRO_FILE *)u64_to_ptr(file)));
}

/* character-level I/O */

lean_object* allegro_al_fgetc(uint64_t file) {
    if (file == 0) return io_ok_uint32(0xFFFFFFFF); /* EOF */
    return io_ok_uint32((uint32_t)al_fgetc((ALLEGRO_FILE *)u64_to_ptr(file)));
}

lean_object* allegro_al_fputc(uint64_t file, uint32_t c) {
    if (file == 0) return io_ok_uint32(0xFFFFFFFF);
    return io_ok_uint32((uint32_t)al_fputc((ALLEGRO_FILE *)u64_to_ptr(file), (int)c));
}

lean_object* allegro_al_fungetc(uint64_t file, uint32_t c) {
    if (file == 0) return io_ok_uint32(0xFFFFFFFF);
    return io_ok_uint32((uint32_t)al_fungetc((ALLEGRO_FILE *)u64_to_ptr(file), (int)c));
}

/* endian-aware reads */

lean_object* allegro_al_fread16le(uint64_t file) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)(uint16_t)al_fread16le((ALLEGRO_FILE *)u64_to_ptr(file)));
}

lean_object* allegro_al_fread16be(uint64_t file) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)(uint16_t)al_fread16be((ALLEGRO_FILE *)u64_to_ptr(file)));
}

lean_object* allegro_al_fread32le(uint64_t file) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_fread32le((ALLEGRO_FILE *)u64_to_ptr(file)));
}

lean_object* allegro_al_fread32be(uint64_t file) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_fread32be((ALLEGRO_FILE *)u64_to_ptr(file)));
}

/* endian-aware writes */

lean_object* allegro_al_fwrite16le(uint64_t file, uint32_t w) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_fwrite16le((ALLEGRO_FILE *)u64_to_ptr(file), (int16_t)w));
}

lean_object* allegro_al_fwrite16be(uint64_t file, uint32_t w) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_fwrite16be((ALLEGRO_FILE *)u64_to_ptr(file), (int16_t)w));
}

lean_object* allegro_al_fwrite32le(uint64_t file, uint32_t l) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_fwrite32le((ALLEGRO_FILE *)u64_to_ptr(file), (int32_t)l));
}

lean_object* allegro_al_fwrite32be(uint64_t file, uint32_t l) {
    if (file == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_fwrite32be((ALLEGRO_FILE *)u64_to_ptr(file), (int32_t)l));
}

/* string I/O */

lean_object* allegro_al_fgets(uint64_t file, uint32_t max) {
    if (file == 0 || max == 0) return io_ok_string("");
    char *buf = (char *)malloc(max);
    char *r = al_fgets((ALLEGRO_FILE *)u64_to_ptr(file), buf, (size_t)max);
    lean_object *result = io_ok_string(r ? r : "");
    free(buf);
    return result;
}

lean_object* allegro_al_fget_ustr(uint64_t file) {
    if (file == 0) return io_ok_uint64(0);
    ALLEGRO_USTR *u = al_fget_ustr((ALLEGRO_FILE *)u64_to_ptr(file));
    return io_ok_uint64(ptr_to_u64(u));
}

lean_object* allegro_al_fputs(uint64_t file, lean_object* str) {
    if (file == 0) { lean_dec_ref(str); return io_ok_uint32(0); }
    int r = al_fputs((ALLEGRO_FILE *)u64_to_ptr(file), lean_string_cstr(str));
    lean_dec_ref(str);
    return io_ok_uint32((uint32_t)r);
}

/* slices */

lean_object* allegro_al_fopen_slice(uint64_t fp, uint32_t initial_size, lean_object* modeObj) {
    if (fp == 0) { lean_dec_ref(modeObj); return io_ok_uint64(0); }
    const char *mode = lean_string_cstr(modeObj);
    ALLEGRO_FILE *slice = al_fopen_slice(
        (ALLEGRO_FILE *)u64_to_ptr(fp), (size_t)initial_size, mode);
    lean_dec_ref(modeObj);
    return io_ok_uint64(ptr_to_u64(slice));
}

/* temp file */

lean_object* allegro_al_make_temp_file(lean_object* tmplObj) {
    const char *tmpl = lean_string_cstr(tmplObj);
    ALLEGRO_PATH *ret_path = NULL;
    ALLEGRO_FILE *f = al_make_temp_file(tmpl, &ret_path);
    lean_dec_ref(tmplObj);
    /* Return (AllegroFile × Path) */
    return lean_io_result_mk_ok(
        mk_pair(lean_box_uint64(ptr_to_u64(f)),
                lean_box_uint64(ptr_to_u64(ret_path))));
}

/* fd-based open */

lean_object* allegro_al_fopen_fd(uint32_t fd, lean_object* modeObj) {
    const char *mode = lean_string_cstr(modeObj);
    ALLEGRO_FILE *f = al_fopen_fd((int)fd, mode);
    lean_dec_ref(modeObj);
    return io_ok_uint64(ptr_to_u64(f));
}

/* interface management */

lean_object* allegro_al_set_standard_file_interface(void) {
    al_set_standard_file_interface();
    return io_ok_unit();
}

lean_object* allegro_al_get_file_userdata(uint64_t file) {
    if (file == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(al_get_file_userdata((ALLEGRO_FILE *)u64_to_ptr(file))));
}
