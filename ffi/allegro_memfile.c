#include "allegro_ffi.h"
#include <allegro5/allegro.h>
#include <allegro5/allegro_memfile.h>

/* ── Memfile ── */

lean_object* allegro_al_open_memfile(uint64_t mem, int64_t size, lean_object* modeObj) {
    if (mem == 0) return io_ok_uint64(0);
    const char *mode = lean_string_cstr(modeObj);
    ALLEGRO_FILE *f = al_open_memfile((void *)u64_to_ptr(mem), size, mode);
    return io_ok_uint64(ptr_to_u64(f));
}

lean_object* allegro_al_get_allegro_memfile_version(void) {
    return io_ok_uint32(al_get_allegro_memfile_version());
}
