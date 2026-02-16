#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/* ── Event queue lifecycle ── */

lean_object* allegro_al_create_event_queue(void) {
    return io_ok_uint64(ptr_to_u64(al_create_event_queue()));
}

lean_object* allegro_al_destroy_event_queue(uint64_t queue) {
    if (queue != 0) {
        al_destroy_event_queue((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue));
    }
    return io_ok_unit();
}

lean_object* allegro_al_register_event_source(uint64_t queue, uint64_t source) {
    if (queue != 0 && source != 0) {
        al_register_event_source((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), (ALLEGRO_EVENT_SOURCE *)u64_to_ptr(source));
    }
    return io_ok_unit();
}

lean_object* allegro_al_unregister_event_source(uint64_t queue, uint64_t source) {
    if (queue != 0 && source != 0) {
        al_unregister_event_source((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), (ALLEGRO_EVENT_SOURCE *)u64_to_ptr(source));
    }
    return io_ok_unit();
}

lean_object* allegro_al_flush_event_queue(uint64_t queue) {
    if (queue != 0) {
        al_flush_event_queue((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue));
    }
    return io_ok_unit();
}

/* ── Event source helpers ── */

lean_object* allegro_al_get_display_event_source(uint64_t display) {
    if (display == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(al_get_display_event_source((ALLEGRO_DISPLAY *)u64_to_ptr(display))));
}

lean_object* allegro_al_get_timer_event_source(uint64_t timer) {
    if (timer == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(al_get_timer_event_source((ALLEGRO_TIMER *)u64_to_ptr(timer))));
}

/* ── Event allocation ── */

lean_object* allegro_al_create_event(void) {
    ALLEGRO_EVENT *ev = (ALLEGRO_EVENT *)malloc(sizeof(ALLEGRO_EVENT));
    return io_ok_uint64(ptr_to_u64(ev));
}

lean_object* allegro_al_destroy_event(uint64_t eventPtr) {
    if (eventPtr != 0) {
        free(u64_to_ptr(eventPtr));
    }
    return io_ok_unit();
}

/* ── Waiting and polling ── */

lean_object* allegro_al_wait_for_event(uint64_t queue, uint64_t eventPtr) {
    if (queue != 0 && eventPtr != 0) {
        al_wait_for_event((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), (ALLEGRO_EVENT *)u64_to_ptr(eventPtr));
    }
    return io_ok_unit();
}

lean_object* allegro_al_wait_for_event_timed(uint64_t queue, uint64_t eventPtr, double secs) {
    if (queue == 0 || eventPtr == 0) return io_ok_uint32(0);
    bool got = al_wait_for_event_timed(
        (ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue),
        (ALLEGRO_EVENT *)u64_to_ptr(eventPtr),
        (float)secs);
    return io_ok_uint32(got ? 1u : 0u);
}

lean_object* allegro_al_get_next_event(uint64_t queue, uint64_t eventPtr) {
    if (queue == 0 || eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_next_event((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), (ALLEGRO_EVENT *)u64_to_ptr(eventPtr)) ? 1u : 0u);
}

lean_object* allegro_al_peek_next_event(uint64_t queue, uint64_t eventPtr) {
    if (queue == 0 || eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_peek_next_event((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), (ALLEGRO_EVENT *)u64_to_ptr(eventPtr)) ? 1u : 0u);
}

lean_object* allegro_al_drop_next_event(uint64_t queue) {
    if (queue == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_drop_next_event((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue)) ? 1u : 0u);
}

lean_object* allegro_al_is_event_queue_empty(uint64_t queue) {
    if (queue == 0) return io_ok_uint32(1);
    return io_ok_uint32(al_is_event_queue_empty((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue)) ? 1u : 0u);
}

lean_object* allegro_al_is_event_queue_paused(uint64_t queue) {
    if (queue == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_event_queue_paused((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue)) ? 1u : 0u);
}

lean_object* allegro_al_pause_event_queue(uint64_t queue, uint32_t pause) {
    if (queue != 0) {
        al_pause_event_queue((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), pause != 0);
    }
    return io_ok_unit();
}

/* ── General event fields ── */

lean_object* allegro_al_event_get_type(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->type);
}

lean_object* allegro_al_event_get_timestamp(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->any.timestamp));
}

lean_object* allegro_al_event_get_source(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->any.source));
}

/* ── Keyboard event fields ── */

lean_object* allegro_al_event_get_keyboard_keycode(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->keyboard.keycode);
}

lean_object* allegro_al_event_get_keyboard_unichar(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->keyboard.unichar);
}

lean_object* allegro_al_event_get_keyboard_modifiers(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->keyboard.modifiers);
}

lean_object* allegro_al_event_get_keyboard_repeat(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->keyboard.repeat);
}

/* ── Mouse event fields ── */

lean_object* allegro_al_event_get_mouse_x(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.x);
}

lean_object* allegro_al_event_get_mouse_y(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.y);
}

lean_object* allegro_al_event_get_mouse_z(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.z);
}

lean_object* allegro_al_event_get_mouse_w(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.w);
}

lean_object* allegro_al_event_get_mouse_dx(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.dx);
}

lean_object* allegro_al_event_get_mouse_dy(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.dy);
}

lean_object* allegro_al_event_get_mouse_dz(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.dz);
}

lean_object* allegro_al_event_get_mouse_dw(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.dw);
}

lean_object* allegro_al_event_get_mouse_pressure(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.pressure));
}

/* ── Float-returning mouse accessors (for games that compute in Float) ── */

lean_object* allegro_al_event_get_mouse_x_f(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float((double)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.x));
}

lean_object* allegro_al_event_get_mouse_y_f(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float((double)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.y));
}

lean_object* allegro_al_event_get_mouse_z_f(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float((double)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.z));
}

lean_object* allegro_al_event_get_mouse_w_f(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float((double)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.w));
}

lean_object* allegro_al_event_get_mouse_dx_f(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float((double)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.dx));
}

lean_object* allegro_al_event_get_mouse_dy_f(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float((double)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.dy));
}

lean_object* allegro_al_event_get_mouse_button(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->mouse.button);
}

/* ── Display event fields ── */

lean_object* allegro_al_event_get_display_x(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->display.x);
}

lean_object* allegro_al_event_get_display_y(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->display.y);
}

lean_object* allegro_al_event_get_display_width(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->display.width);
}

lean_object* allegro_al_event_get_display_height(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->display.height);
}

lean_object* allegro_al_event_get_display_orientation(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->display.orientation);
}

lean_object* allegro_al_event_get_display_source(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->display.source));
}

/* ── Timer event fields ── */

lean_object* allegro_al_event_get_timer_count(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->timer.count);
}

lean_object* allegro_al_event_get_timer_error(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->timer.error));
}

lean_object* allegro_al_event_get_timer_timestamp(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->timer.timestamp));
}

/* ── Joystick event fields ── */

lean_object* allegro_al_event_get_joystick_id(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->joystick.id));
}

lean_object* allegro_al_event_get_joystick_stick(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->joystick.stick);
}

lean_object* allegro_al_event_get_joystick_axis(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->joystick.axis);
}

lean_object* allegro_al_event_get_joystick_pos(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->joystick.pos));
}

lean_object* allegro_al_event_get_joystick_button(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->joystick.button);
}

/* ── Touch event fields ── */

lean_object* allegro_al_event_get_touch_id(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->touch.id);
}

lean_object* allegro_al_event_get_touch_x(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->touch.x));
}

lean_object* allegro_al_event_get_touch_y(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->touch.y));
}

lean_object* allegro_al_event_get_touch_dx(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->touch.dx));
}

lean_object* allegro_al_event_get_touch_dy(uint64_t eventPtr) {
    if (eventPtr == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->touch.dy));
}

lean_object* allegro_al_event_get_touch_primary(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->touch.primary);
}

/* ── User event fields ── */

lean_object* allegro_al_event_get_user_data1(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->user.data1);
}

lean_object* allegro_al_event_get_user_data2(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->user.data2);
}

lean_object* allegro_al_event_get_user_data3(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->user.data3);
}

lean_object* allegro_al_event_get_user_data4(uint64_t eventPtr) {
    if (eventPtr == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)((ALLEGRO_EVENT *)u64_to_ptr(eventPtr))->user.data4);
}

/* ── User event source ── */

lean_object* allegro_al_init_user_event_source(void) {
    ALLEGRO_EVENT_SOURCE *src = (ALLEGRO_EVENT_SOURCE *)malloc(sizeof(ALLEGRO_EVENT_SOURCE));
    al_init_user_event_source(src);
    return io_ok_uint64(ptr_to_u64(src));
}

lean_object* allegro_al_destroy_user_event_source(uint64_t src) {
    if (src != 0) {
        al_destroy_user_event_source((ALLEGRO_EVENT_SOURCE *)u64_to_ptr(src));
        free(u64_to_ptr(src));
    }
    return io_ok_unit();
}

lean_object* allegro_al_emit_user_event(uint64_t src, uint64_t data1, uint64_t data2, uint64_t data3, uint64_t data4) {
    if (src == 0) return io_ok_uint32(0);
    ALLEGRO_EVENT ev;
    ev.user.type = ALLEGRO_GET_EVENT_TYPE('U','S','E','R');
    ev.user.data1 = (intptr_t)data1;
    ev.user.data2 = (intptr_t)data2;
    ev.user.data3 = (intptr_t)data3;
    ev.user.data4 = (intptr_t)data4;
    bool ok = al_emit_user_event((ALLEGRO_EVENT_SOURCE *)u64_to_ptr(src), &ev, NULL);
    return io_ok_uint32(ok ? 1u : 0u);
}

/* ── Stack-allocated event → EventData structure ──
   Packs an ALLEGRO_EVENT's fields into a Lean EventData constructor.
   Field mapping (by event type):
     Keyboard: a=keycode  b=unichar  c=modifiers  d=repeat
     Mouse:    a=x  b=y  c=z  d=w  e=dx  f=dy  g=dz  h=dw  i=button  fv1=pressure
     Display:  a=x  b=y  c=width  d=height  i=orientation
     Timer:    fv1=error  fv2=timestamp  u64v=count
     Joystick: a=stick  b=axis  i=button  fv1=pos  u64v=id
     Touch:    a=(int)x  b=(int)y  i=primary  fv1=x  fv2=y  (dx/dy via e/f)
     User:     u64v=data1 (data2–4 accessible via old API if needed)
*/
static lean_object* pack_event_data(const ALLEGRO_EVENT *ev) {
    uint32_t type = ev->type;
    double   ts   = ev->any.timestamp;
    uint64_t src  = ptr_to_u64(ev->any.source);

    int32_t a = 0, b = 0, c = 0, d = 0;
    int32_t e = 0, f = 0, g = 0, h = 0, i = 0;
    double fv1 = 0.0, fv2 = 0.0;
    uint64_t u64v = 0;

    if (type >= 10 && type <= 12) {
        /* Keyboard event */
        a = ev->keyboard.keycode;
        b = ev->keyboard.unichar;
        c = (int32_t)ev->keyboard.modifiers;
        d = (int32_t)ev->keyboard.repeat;
    } else if (type >= 20 && type <= 25) {
        /* Mouse event */
        a = ev->mouse.x;
        b = ev->mouse.y;
        c = ev->mouse.z;
        d = ev->mouse.w;
        e = ev->mouse.dx;
        f = ev->mouse.dy;
        g = ev->mouse.dz;
        h = ev->mouse.dw;
        i = (int32_t)ev->mouse.button;
        fv1 = ev->mouse.pressure;
    } else if (type == 30) {
        /* Timer event */
        fv1 = ev->timer.error;
        fv2 = ev->timer.timestamp;
        u64v = (uint64_t)ev->timer.count;
    } else if ((type >= 40 && type <= 49) || (type >= 60 && type <= 61)) {
        /* Display event (40-49: expose..resume_drawing, 60-61: connected/disconnected) */
        a = ev->display.x;
        b = ev->display.y;
        c = ev->display.width;
        d = ev->display.height;
        i = ev->display.orientation;
        u64v = ptr_to_u64(ev->display.source);
    } else if (type >= 1 && type <= 4) {
        /* Joystick event */
        a = ev->joystick.stick;
        b = ev->joystick.axis;
        i = ev->joystick.button;
        fv1 = ev->joystick.pos;
        u64v = ptr_to_u64(ev->joystick.id);
    } else if (type >= 50 && type <= 53) {
        /* Touch event (50-53: begin, end, move, cancel) */
        a = (int32_t)ev->touch.x;
        b = (int32_t)ev->touch.y;
        e = (int32_t)ev->touch.dx;
        f = (int32_t)ev->touch.dy;
        i = (int32_t)ev->touch.primary;
        fv1 = ev->touch.x;
        fv2 = ev->touch.y;
        u64v = (uint64_t)ev->touch.id;
    } else if (type >= 512) {
        /* User event */
        u64v = (uint64_t)ev->user.data1;
    }

    return mk_event_data(type, ts, src, a, b, c, d, e, f, g, h, i, fv1, fv2, u64v);
}

lean_object* allegro_al_wait_for_event_data(uint64_t queue) {
    ALLEGRO_EVENT ev;
    if (queue != 0) {
        al_wait_for_event((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), &ev);
    } else {
        memset(&ev, 0, sizeof(ev));
    }
    return lean_io_result_mk_ok(pack_event_data(&ev));
}

lean_object* allegro_al_wait_for_event_timed_data(uint64_t queue, double secs) {
    ALLEGRO_EVENT ev;
    memset(&ev, 0, sizeof(ev));
    uint32_t got = 0;
    if (queue != 0) {
        got = al_wait_for_event_timed(
            (ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), &ev, (float)secs) ? 1u : 0u;
    }
    /* Return (got : UInt32, data : EventData) as a pair */
    lean_object* data = pack_event_data(&ev);
    lean_object* pair = mk_pair(lean_box_uint32(got), data);
    return lean_io_result_mk_ok(pair);
}

lean_object* allegro_al_get_next_event_data(uint64_t queue) {
    ALLEGRO_EVENT ev;
    memset(&ev, 0, sizeof(ev));
    uint32_t got = 0;
    if (queue != 0) {
        got = al_get_next_event((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), &ev) ? 1u : 0u;
    }
    lean_object* data = pack_event_data(&ev);
    lean_object* pair = mk_pair(lean_box_uint32(got), data);
    return lean_io_result_mk_ok(pair);
}

lean_object* allegro_al_peek_next_event_data(uint64_t queue) {
    ALLEGRO_EVENT ev;
    memset(&ev, 0, sizeof(ev));
    uint32_t got = 0;
    if (queue != 0) {
        got = al_peek_next_event((ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue), &ev) ? 1u : 0u;
    }
    lean_object* data = pack_event_data(&ev);
    lean_object* pair = mk_pair(lean_box_uint32(got), data);
    return lean_io_result_mk_ok(pair);
}

/* ── Event source queries ── */

lean_object* allegro_al_is_event_source_registered(uint64_t queue, uint64_t source) {
    if (queue == 0 || source == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_is_event_source_registered(
            (ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue),
            (ALLEGRO_EVENT_SOURCE *)u64_to_ptr(source)) ? 1u : 0u);
}

lean_object* allegro_al_get_event_source_data(uint64_t source) {
    if (source == 0) return io_ok_uint64(0);
    return io_ok_uint64((uint64_t)al_get_event_source_data(
        (const ALLEGRO_EVENT_SOURCE *)u64_to_ptr(source)));
}

lean_object* allegro_al_set_event_source_data(uint64_t source, uint64_t data) {
    if (source != 0) {
        al_set_event_source_data((ALLEGRO_EVENT_SOURCE *)u64_to_ptr(source), (intptr_t)data);
    }
    return io_ok_unit();
}

/* ── Timeout ── */

lean_object* allegro_al_create_timeout(void) {
    ALLEGRO_TIMEOUT *t = (ALLEGRO_TIMEOUT *)calloc(1, sizeof(ALLEGRO_TIMEOUT));
    return io_ok_uint64(ptr_to_u64(t));
}

lean_object* allegro_al_destroy_timeout(uint64_t t) {
    if (t != 0) free(u64_to_ptr(t));
    return io_ok_unit();
}

lean_object* allegro_al_init_timeout(uint64_t t, double seconds) {
    if (t != 0) {
        al_init_timeout((ALLEGRO_TIMEOUT *)u64_to_ptr(t), seconds);
    }
    return io_ok_unit();
}

/* ── Wait for event with timeout ── */

lean_object* allegro_al_wait_for_event_until_data(uint64_t queue, uint64_t timeout) {
    ALLEGRO_EVENT ev;
    memset(&ev, 0, sizeof(ev));
    uint32_t got = 0;
    if (queue != 0 && timeout != 0) {
        got = al_wait_for_event_until(
            (ALLEGRO_EVENT_QUEUE *)u64_to_ptr(queue),
            &ev,
            (ALLEGRO_TIMEOUT *)u64_to_ptr(timeout)) ? 1u : 0u;
    }
    lean_object* data = pack_event_data(&ev);
    lean_object* pair = mk_pair(lean_box_uint32(got), data);
    return lean_io_result_mk_ok(pair);
}

/* ── User event unref ── */

lean_object* allegro_al_unref_user_event(uint64_t eventPtr) {
    if (eventPtr != 0) {
        ALLEGRO_EVENT *ev = (ALLEGRO_EVENT *)u64_to_ptr(eventPtr);
        al_unref_user_event(&ev->user);
    }
    return io_ok_unit();
}
