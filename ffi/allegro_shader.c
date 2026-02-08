#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/* ── Shader ── */

lean_object* allegro_al_create_shader(uint32_t platform) {
    ALLEGRO_SHADER *s = al_create_shader((ALLEGRO_SHADER_PLATFORM)platform);
    return io_ok_uint64(ptr_to_u64(s));
}

lean_object* allegro_al_destroy_shader(uint64_t shader) {
    if (shader != 0) al_destroy_shader((ALLEGRO_SHADER *)u64_to_ptr(shader));
    return io_ok_unit();
}

lean_object* allegro_al_attach_shader_source(uint64_t shader, uint32_t type, lean_object* srcObj) {
    if (shader == 0) { lean_dec_ref(srcObj); return io_ok_uint32(0); }
    const char *src = lean_string_cstr(srcObj);
    bool ok = al_attach_shader_source((ALLEGRO_SHADER *)u64_to_ptr(shader),
                                      (ALLEGRO_SHADER_TYPE)type, src);
    lean_dec_ref(srcObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_attach_shader_source_file(uint64_t shader, uint32_t type, lean_object* fnObj) {
    if (shader == 0) { lean_dec_ref(fnObj); return io_ok_uint32(0); }
    const char *fn = lean_string_cstr(fnObj);
    bool ok = al_attach_shader_source_file((ALLEGRO_SHADER *)u64_to_ptr(shader),
                                           (ALLEGRO_SHADER_TYPE)type, fn);
    lean_dec_ref(fnObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_build_shader(uint64_t shader) {
    if (shader == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_build_shader((ALLEGRO_SHADER *)u64_to_ptr(shader)) ? 1u : 0u);
}

lean_object* allegro_al_get_shader_log(uint64_t shader) {
    if (shader == 0) return io_ok_string("");
    return io_ok_string(al_get_shader_log((ALLEGRO_SHADER *)u64_to_ptr(shader)));
}

lean_object* allegro_al_get_shader_platform(uint64_t shader) {
    if (shader == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_shader_platform((ALLEGRO_SHADER *)u64_to_ptr(shader)));
}

lean_object* allegro_al_use_shader(uint64_t shader) {
    /* shader == 0 is valid — means "use default shader" */
    return io_ok_uint32(
        al_use_shader(shader == 0 ? NULL : (ALLEGRO_SHADER *)u64_to_ptr(shader)) ? 1u : 0u);
}

lean_object* allegro_al_get_current_shader(void) {
    return io_ok_uint64(ptr_to_u64(al_get_current_shader()));
}

/* uniform setters */

lean_object* allegro_al_set_shader_sampler(lean_object* nameObj, uint64_t bitmap, uint32_t unit) {
    const char *name = lean_string_cstr(nameObj);
    bool ok = al_set_shader_sampler(name,
        bitmap == 0 ? NULL : (ALLEGRO_BITMAP *)u64_to_ptr(bitmap), (int)unit);
    lean_dec_ref(nameObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_set_shader_matrix(lean_object* nameObj, uint64_t matrix) {
    const char *name = lean_string_cstr(nameObj);
    bool ok = al_set_shader_matrix(name,
        matrix == 0 ? NULL : (const ALLEGRO_TRANSFORM *)u64_to_ptr(matrix));
    lean_dec_ref(nameObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_set_shader_int(lean_object* nameObj, uint32_t i) {
    const char *name = lean_string_cstr(nameObj);
    bool ok = al_set_shader_int(name, (int)i);
    lean_dec_ref(nameObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_set_shader_float(lean_object* nameObj, double f) {
    const char *name = lean_string_cstr(nameObj);
    bool ok = al_set_shader_float(name, (float)f);
    lean_dec_ref(nameObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_set_shader_bool(lean_object* nameObj, uint32_t b) {
    const char *name = lean_string_cstr(nameObj);
    bool ok = al_set_shader_bool(name, b != 0);
    lean_dec_ref(nameObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_get_default_shader_source(uint32_t platform, uint32_t type) {
    const char *src = al_get_default_shader_source(
        (ALLEGRO_SHADER_PLATFORM)platform, (ALLEGRO_SHADER_TYPE)type);
    return io_ok_string(src);
}

/* vector uniform setters — accept Lean FloatArray / Int arrays */

lean_object* allegro_al_set_shader_int_vector(lean_object* nameObj, uint32_t num_components,
                                               lean_object* arrObj, uint32_t num_elems) {
    const char *name = lean_string_cstr(nameObj);
    /* arrObj is a Lean Array UInt32 — we need to extract int values */
    size_t len = lean_array_size(arrObj);
    int *buf = (int *)malloc(len * sizeof(int));
    for (size_t i = 0; i < len; i++) {
        buf[i] = (int)lean_unbox_uint32(lean_array_get_core(arrObj, i));
    }
    bool ok = al_set_shader_int_vector(name, (int)num_components, buf, (int)num_elems);
    free(buf);
    lean_dec_ref(nameObj);
    lean_dec_ref(arrObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_set_shader_float_vector(lean_object* nameObj, uint32_t num_components,
                                                 lean_object* arrObj, uint32_t num_elems) {
    const char *name = lean_string_cstr(nameObj);
    /* arrObj is a Lean FloatArray */
    size_t len = lean_sarray_size(arrObj);
    float *buf = (float *)malloc(len * sizeof(float));
    const double *src = (const double *)lean_float_array_cptr(arrObj);
    for (size_t i = 0; i < len; i++) {
        buf[i] = (float)src[i];
    }
    bool ok = al_set_shader_float_vector(name, (int)num_components, buf, (int)num_elems);
    free(buf);
    lean_dec_ref(nameObj);
    lean_dec_ref(arrObj);
    return io_ok_uint32(ok ? 1u : 0u);
}
