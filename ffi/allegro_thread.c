#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/*
 * Allegro threading bindings — mutex and condition variable primitives only.
 *
 * Thread creation (al_create_thread, al_run_detached_thread) is intentionally
 * omitted: those require C function-pointer callbacks that would need to enter
 * the Lean runtime on a foreign OS thread, which is unsafe.  Use Lean's own
 * Task system for concurrency, and these mutexes/conds for synchronization
 * when multiple Lean Tasks access shared Allegro resources.
 */

/* ── Mutex ── */

lean_object* allegro_al_create_mutex(void) {
    ALLEGRO_MUTEX *m = al_create_mutex();
    return io_ok_uint64(ptr_to_u64(m));
}

lean_object* allegro_al_create_mutex_recursive(void) {
    ALLEGRO_MUTEX *m = al_create_mutex_recursive();
    return io_ok_uint64(ptr_to_u64(m));
}

lean_object* allegro_al_lock_mutex(uint64_t mutex) {
    if (mutex != 0) {
        al_lock_mutex((ALLEGRO_MUTEX *)u64_to_ptr(mutex));
    }
    return io_ok_unit();
}

lean_object* allegro_al_unlock_mutex(uint64_t mutex) {
    if (mutex != 0) {
        al_unlock_mutex((ALLEGRO_MUTEX *)u64_to_ptr(mutex));
    }
    return io_ok_unit();
}

lean_object* allegro_al_destroy_mutex(uint64_t mutex) {
    if (mutex != 0) {
        al_destroy_mutex((ALLEGRO_MUTEX *)u64_to_ptr(mutex));
    }
    return io_ok_unit();
}

/* ── Condition variables ── */

lean_object* allegro_al_create_cond(void) {
    ALLEGRO_COND *c = al_create_cond();
    return io_ok_uint64(ptr_to_u64(c));
}

lean_object* allegro_al_destroy_cond(uint64_t cond) {
    if (cond != 0) {
        al_destroy_cond((ALLEGRO_COND *)u64_to_ptr(cond));
    }
    return io_ok_unit();
}

lean_object* allegro_al_wait_cond(uint64_t cond, uint64_t mutex) {
    if (cond != 0 && mutex != 0) {
        al_wait_cond((ALLEGRO_COND *)u64_to_ptr(cond),
                     (ALLEGRO_MUTEX *)u64_to_ptr(mutex));
    }
    return io_ok_unit();
}

lean_object* allegro_al_wait_cond_until(uint64_t cond, uint64_t mutex, double secs) {
    if (cond == 0 || mutex == 0) return io_ok_uint32(0);
    ALLEGRO_TIMEOUT timeout;
    al_init_timeout(&timeout, secs);
    int r = al_wait_cond_until((ALLEGRO_COND *)u64_to_ptr(cond),
                               (ALLEGRO_MUTEX *)u64_to_ptr(mutex),
                               &timeout);
    /* Returns 0 on success, non-zero on timeout. We return 1 on success, 0 on timeout. */
    return io_ok_uint32(r == 0 ? 1u : 0u);
}

lean_object* allegro_al_broadcast_cond(uint64_t cond) {
    if (cond != 0) {
        al_broadcast_cond((ALLEGRO_COND *)u64_to_ptr(cond));
    }
    return io_ok_unit();
}

lean_object* allegro_al_signal_cond(uint64_t cond) {
    if (cond != 0) {
        al_signal_cond((ALLEGRO_COND *)u64_to_ptr(cond));
    }
    return io_ok_unit();
}
