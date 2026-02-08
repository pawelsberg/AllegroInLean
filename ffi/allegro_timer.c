#include "allegro_ffi.h"
#include <allegro5/allegro.h>

lean_object* allegro_al_create_timer(double seconds) {
    return io_ok_uint64(ptr_to_u64(al_create_timer(seconds)));
}

lean_object* allegro_al_start_timer(uint64_t timer) {
    if (timer != 0) {
        al_start_timer((ALLEGRO_TIMER *)u64_to_ptr(timer));
    }
    return io_ok_unit();
}

lean_object* allegro_al_stop_timer(uint64_t timer) {
    if (timer != 0) {
        al_stop_timer((ALLEGRO_TIMER *)u64_to_ptr(timer));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_timer_count(uint64_t timer) {
    if (timer == 0) {
        return io_ok_uint64(0);
    }
    return io_ok_uint64((uint64_t)al_get_timer_count((ALLEGRO_TIMER *)u64_to_ptr(timer)));
}

lean_object* allegro_al_get_timer_speed(uint64_t timer) {
    if (timer == 0) {
        return lean_io_result_mk_ok(lean_box_float(0.0));
    }
    return lean_io_result_mk_ok(lean_box_float(al_get_timer_speed((ALLEGRO_TIMER *)u64_to_ptr(timer))));
}

lean_object* allegro_al_set_timer_speed(uint64_t timer, double speed) {
    if (timer != 0) {
        al_set_timer_speed((ALLEGRO_TIMER *)u64_to_ptr(timer), speed);
    }
    return io_ok_unit();
}

lean_object* allegro_al_destroy_timer(uint64_t timer) {
    if (timer != 0) {
        al_destroy_timer((ALLEGRO_TIMER *)u64_to_ptr(timer));
    }
    return io_ok_unit();
}

lean_object* allegro_al_resume_timer(uint64_t timer) {
    if (timer != 0) {
        al_resume_timer((ALLEGRO_TIMER *)u64_to_ptr(timer));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_timer_started(uint64_t timer) {
    if (timer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_timer_started((const ALLEGRO_TIMER *)u64_to_ptr(timer)) ? 1u : 0u);
}

lean_object* allegro_al_set_timer_count(uint64_t timer, uint64_t count) {
    if (timer != 0) {
        al_set_timer_count((ALLEGRO_TIMER *)u64_to_ptr(timer), (int64_t)count);
    }
    return io_ok_unit();
}

lean_object* allegro_al_add_timer_count(uint64_t timer, uint64_t diff) {
    if (timer != 0) {
        al_add_timer_count((ALLEGRO_TIMER *)u64_to_ptr(timer), (int64_t)diff);
    }
    return io_ok_unit();
}
