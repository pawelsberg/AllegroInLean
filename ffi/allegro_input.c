#include "allegro_ffi.h"
#include <allegro5/allegro.h>

#ifdef __APPLE__
#include <pthread.h>
#endif

lean_object* allegro_al_install_keyboard(void) {
    return io_ok_uint32(al_install_keyboard() ? 1u : 0u);
}

lean_object* allegro_al_install_mouse(void) {
#ifdef __APPLE__
    /* On macOS the mouse driver init calls _al_osx_mouse_was_installed()
     * which uses dispatch_sync(dispatch_get_main_queue()) to notify
     * existing display windows.  When the caller IS the main thread and
     * no Cocoa run loop is active (the case for Lean), this deadlocks
     * and triggers SIGTRAP.  Return 0 (false) to signal failure;
     * all callers handle mouse-not-installed gracefully. */
    if (pthread_main_np()) {
        return io_ok_uint32(0);
    }
#endif
    return io_ok_uint32(al_install_mouse() ? 1u : 0u);
}

lean_object* allegro_al_get_keyboard_event_source(void) {
    return io_ok_uint64(ptr_to_u64(al_get_keyboard_event_source()));
}

lean_object* allegro_al_get_mouse_event_source(void) {
    return io_ok_uint64(ptr_to_u64(al_get_mouse_event_source()));
}

lean_object* allegro_al_keycode_to_name(uint32_t keycode) {
    const char *name = al_keycode_to_name((int)keycode);
    return io_ok_string(name);
}

lean_object* allegro_al_get_mouse_num_buttons(void) {
    return io_ok_uint32((uint32_t)al_get_mouse_num_buttons());
}

lean_object* allegro_al_set_mouse_wheel_precision(double precision) {
    al_set_mouse_wheel_precision((float)precision);
    return io_ok_unit();
}

lean_object* allegro_al_hide_mouse_cursor(uint64_t display) {
    if (display == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32(al_hide_mouse_cursor((ALLEGRO_DISPLAY *)u64_to_ptr(display)) ? 1u : 0u);
}

lean_object* allegro_al_show_mouse_cursor(uint64_t display) {
    if (display == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32(al_show_mouse_cursor((ALLEGRO_DISPLAY *)u64_to_ptr(display)) ? 1u : 0u);
}

/* ── Keyboard state ── */

lean_object* allegro_al_create_keyboard_state(void) {
    ALLEGRO_KEYBOARD_STATE *state = (ALLEGRO_KEYBOARD_STATE *)malloc(sizeof(ALLEGRO_KEYBOARD_STATE));
    return io_ok_uint64(ptr_to_u64(state));
}

lean_object* allegro_al_destroy_keyboard_state(uint64_t state) {
    if (state != 0) {
        free(u64_to_ptr(state));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_keyboard_state(uint64_t state) {
    if (state != 0) {
        al_get_keyboard_state((ALLEGRO_KEYBOARD_STATE *)u64_to_ptr(state));
    }
    return io_ok_unit();
}

lean_object* allegro_al_key_down(uint64_t state, uint32_t keycode) {
    if (state == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32(
        al_key_down((const ALLEGRO_KEYBOARD_STATE *)u64_to_ptr(state), (int)keycode) ? 1u : 0u);
}

/* ── Mouse state ── */

lean_object* allegro_al_create_mouse_state(void) {
    ALLEGRO_MOUSE_STATE *state = (ALLEGRO_MOUSE_STATE *)malloc(sizeof(ALLEGRO_MOUSE_STATE));
    return io_ok_uint64(ptr_to_u64(state));
}

lean_object* allegro_al_destroy_mouse_state(uint64_t state) {
    if (state != 0) {
        free(u64_to_ptr(state));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_mouse_state(uint64_t state) {
    if (state != 0) {
        al_get_mouse_state((ALLEGRO_MOUSE_STATE *)u64_to_ptr(state));
    }
    return io_ok_unit();
}

lean_object* allegro_al_mouse_button_down(uint64_t state, uint32_t button) {
    if (state == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32(
        al_mouse_button_down((const ALLEGRO_MOUSE_STATE *)u64_to_ptr(state), (int)button) ? 1u : 0u);
}

lean_object* allegro_al_get_mouse_state_axis(uint64_t state, uint32_t axis) {
    if (state == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_get_mouse_state_axis(
        (const ALLEGRO_MOUSE_STATE *)u64_to_ptr(state), (int)axis));
}

/* ── Mouse cursor ── */

lean_object* allegro_al_create_mouse_cursor(uint64_t bitmap, int32_t xfocus, int32_t yfocus) {
    if (bitmap == 0) return io_ok_uint64(0);
    ALLEGRO_MOUSE_CURSOR *cur = al_create_mouse_cursor(
        (ALLEGRO_BITMAP *)u64_to_ptr(bitmap), xfocus, yfocus);
    return io_ok_uint64(ptr_to_u64(cur));
}

lean_object* allegro_al_destroy_mouse_cursor(uint64_t cursor) {
    if (cursor != 0) {
        al_destroy_mouse_cursor((ALLEGRO_MOUSE_CURSOR *)u64_to_ptr(cursor));
    }
    return io_ok_unit();
}

lean_object* allegro_al_set_mouse_cursor(uint64_t display, uint64_t cursor) {
    if (display == 0 || cursor == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_set_mouse_cursor((ALLEGRO_DISPLAY *)u64_to_ptr(display),
                            (ALLEGRO_MOUSE_CURSOR *)u64_to_ptr(cursor)) ? 1u : 0u);
}

lean_object* allegro_al_set_system_mouse_cursor(uint64_t display, uint32_t cursor_id) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_set_system_mouse_cursor((ALLEGRO_DISPLAY *)u64_to_ptr(display),
                                   (ALLEGRO_SYSTEM_MOUSE_CURSOR)cursor_id) ? 1u : 0u);
}

lean_object* allegro_al_set_mouse_xy(uint64_t display, int32_t x, int32_t y) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_set_mouse_xy((ALLEGRO_DISPLAY *)u64_to_ptr(display), x, y) ? 1u : 0u);
}

lean_object* allegro_al_grab_mouse(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_grab_mouse((ALLEGRO_DISPLAY *)u64_to_ptr(display)) ? 1u : 0u);
}

lean_object* allegro_al_ungrab_mouse(void) {
    return io_ok_uint32(al_ungrab_mouse() ? 1u : 0u);
}

/* ── Tuple-returning queries ── */

lean_object* allegro_al_get_mouse_cursor_position(void) {
    int x = 0, y = 0;
    al_get_mouse_cursor_position(&x, &y);
    return io_ok_u32_pair((uint32_t)x, (uint32_t)y);
}

/* ── Keyboard: install check / uninstall / LEDs / clear ── */

lean_object* allegro_al_is_keyboard_installed(void) {
    return io_ok_uint32(al_is_keyboard_installed() ? 1u : 0u);
}

lean_object* allegro_al_uninstall_keyboard(void) {
    al_uninstall_keyboard();
    return io_ok_unit();
}

lean_object* allegro_al_can_set_keyboard_leds(void) {
    /* On X11 the LED query touches the display connection — guard. */
    if (!al_get_current_display()) return io_ok_uint32(0);
    return io_ok_uint32(al_can_set_keyboard_leds() ? 1u : 0u);
}

lean_object* allegro_al_set_keyboard_leds(uint32_t leds) {
    /* On X11 this calls XChangeKeyboardControl which segfaults headless. */
    if (!al_get_current_display()) return io_ok_uint32(0);
    return io_ok_uint32(al_set_keyboard_leds((int)leds) ? 1u : 0u);
}

lean_object* allegro_al_clear_keyboard_state(uint64_t display) {
    al_clear_keyboard_state(display != 0 ? (ALLEGRO_DISPLAY *)u64_to_ptr(display) : NULL);
    return io_ok_unit();
}

/* ── Mouse: install check / uninstall / axes ── */

lean_object* allegro_al_is_mouse_installed(void) {
    return io_ok_uint32(al_is_mouse_installed() ? 1u : 0u);
}

lean_object* allegro_al_uninstall_mouse(void) {
    al_uninstall_mouse();
    return io_ok_unit();
}

lean_object* allegro_al_get_mouse_num_axes(void) {
    if (!al_is_mouse_installed()) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_mouse_num_axes());
}

lean_object* allegro_al_set_mouse_z(uint32_t z) {
    if (!al_is_mouse_installed()) return io_ok_uint32(0);
    return io_ok_uint32(al_set_mouse_z((int)z) ? 1u : 0u);
}

lean_object* allegro_al_set_mouse_w(uint32_t w) {
    if (!al_is_mouse_installed()) return io_ok_uint32(0);
    return io_ok_uint32(al_set_mouse_w((int)w) ? 1u : 0u);
}

lean_object* allegro_al_set_mouse_axis(uint32_t axis, uint32_t value) {
    if (!al_is_mouse_installed()) return io_ok_uint32(0);
    return io_ok_uint32(al_set_mouse_axis((int)axis, (int)value) ? 1u : 0u);
}

lean_object* allegro_al_can_get_mouse_cursor_position(void) {
    if (!al_is_mouse_installed()) return io_ok_uint32(0);
    return io_ok_uint32(al_can_get_mouse_cursor_position() ? 1u : 0u);
}

lean_object* allegro_al_get_mouse_wheel_precision(void) {
    if (!al_is_mouse_installed()) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_mouse_wheel_precision());
}
