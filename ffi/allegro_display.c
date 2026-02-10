#include "allegro_ffi.h"
#include <allegro5/allegro.h>
#include <stdlib.h>
#include <string.h>

#ifdef __APPLE__
#include <pthread.h>
#endif

lean_object* allegro_al_set_new_display_flags(uint32_t flags) {
    al_set_new_display_flags(flags);
    return io_ok_unit();
}

lean_object* allegro_al_set_window_title(uint64_t display, b_lean_obj_arg titleObj) {
    if (display != 0) {
        const char *title = lean_string_cstr(titleObj);
        al_set_window_title((ALLEGRO_DISPLAY *)u64_to_ptr(display), title);
    }
    return io_ok_unit();
}

lean_object* allegro_al_create_display(uint32_t width, uint32_t height) {
#ifdef __APPLE__
    /* On macOS the Cocoa backend creates the NSWindow via
     *   dispatch_sync(dispatch_get_main_queue(), ^{ ... })
     * which deadlocks / traps (SIGTRAP) when the caller IS the main thread
     * and no Cocoa run loop is active.  Lean runs user code on the main
     * thread, so we cannot safely call al_create_display().
     * Return NULL (0) to signal failure; all callers handle this gracefully. */
    if (pthread_main_np()) {
        return io_ok_uint64(0);
    }
#endif
#ifdef _WIN32
    /* On Windows CI runners the WGL / D3D display driver can segfault
     * when no real GPU / desktop session is available.
     * When the CI environment variable is set, skip display creation. */
    {
        const char *ci = getenv("CI");
        if (ci && (strcmp(ci, "true") == 0 || strcmp(ci, "1") == 0)) {
            return io_ok_uint64(0);
        }
    }
#endif
    ALLEGRO_DISPLAY *display = al_create_display((int)width, (int)height);
    return io_ok_uint64(ptr_to_u64(display));
}

lean_object* allegro_al_resize_display(uint64_t display, uint32_t width, uint32_t height) {
    if (display == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32(al_resize_display((ALLEGRO_DISPLAY *)u64_to_ptr(display), (int)width, (int)height) ? 1u : 0u);
}

lean_object* allegro_al_get_current_display(void) {
    return io_ok_uint64(ptr_to_u64(al_get_current_display()));
}

lean_object* allegro_al_get_display_width(uint64_t display) {
    if (display == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_get_display_width((ALLEGRO_DISPLAY *)u64_to_ptr(display)));
}

lean_object* allegro_al_get_display_height(uint64_t display) {
    if (display == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_get_display_height((ALLEGRO_DISPLAY *)u64_to_ptr(display)));
}

lean_object* allegro_al_update_display_region(int32_t x, int32_t y, int32_t w, int32_t h) {
    al_update_display_region(x, y, w, h);
    return io_ok_unit();
}

lean_object* allegro_al_acknowledge_resize(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_acknowledge_resize((ALLEGRO_DISPLAY *)u64_to_ptr(display)) ? 1u : 0u);
}

lean_object* allegro_al_acknowledge_drawing_halt(uint64_t display) {
    if (display != 0) {
        al_acknowledge_drawing_halt((ALLEGRO_DISPLAY *)u64_to_ptr(display));
    }
    return io_ok_unit();
}

lean_object* allegro_al_acknowledge_drawing_resume(uint64_t display) {
    if (display != 0) {
        al_acknowledge_drawing_resume((ALLEGRO_DISPLAY *)u64_to_ptr(display));
    }
    return io_ok_unit();
}

lean_object* allegro_al_clear_to_color_rgb(uint32_t r, uint32_t g, uint32_t b) {
    al_clear_to_color(al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b));
    return io_ok_unit();
}

lean_object* allegro_al_flip_display(void) {
    al_flip_display();
    return io_ok_unit();
}

lean_object* allegro_al_destroy_display(uint64_t display) {
    if (display != 0) {
        al_destroy_display((ALLEGRO_DISPLAY *)u64_to_ptr(display));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_display_flags(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_display_flags((ALLEGRO_DISPLAY *)u64_to_ptr(display)));
}

lean_object* allegro_al_set_display_flag(uint64_t display, uint32_t flag, uint32_t onoff) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_set_display_flag((ALLEGRO_DISPLAY *)u64_to_ptr(display), (int)flag, onoff != 0) ? 1u : 0u);
}

lean_object* allegro_al_get_new_display_flags(void) {
    return io_ok_uint32((uint32_t)al_get_new_display_flags());
}

lean_object* allegro_al_set_new_display_option(uint32_t option, uint32_t value, uint32_t importance) {
    al_set_new_display_option((int)option, (int)value, (int)importance);
    return io_ok_unit();
}

lean_object* allegro_al_get_new_display_option(uint32_t option) {
    int importance = 0;
    int value = al_get_new_display_option((int)option, &importance);
    /* Return value; importance is rarely needed from Lean */
    return io_ok_uint32((uint32_t)value);
}

lean_object* allegro_al_reset_new_display_options(void) {
    al_reset_new_display_options();
    return io_ok_unit();
}

lean_object* allegro_al_get_display_option(uint64_t display, uint32_t option) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_display_option(
        (ALLEGRO_DISPLAY *)u64_to_ptr(display), (int)option));
}

/* ── Window position ── */

lean_object* allegro_al_set_window_position(uint64_t display, uint32_t x, uint32_t y) {
    if (display != 0) {
        al_set_window_position((ALLEGRO_DISPLAY *)u64_to_ptr(display), (int)x, (int)y);
    }
    return io_ok_unit();
}

lean_object* allegro_al_set_window_constraints(uint64_t display, uint32_t minW, uint32_t minH, uint32_t maxW, uint32_t maxH) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_set_window_constraints((ALLEGRO_DISPLAY *)u64_to_ptr(display),
            (int)minW, (int)minH, (int)maxW, (int)maxH) ? 1u : 0u);
}

/* ── Clipboard ── */

lean_object* allegro_al_get_clipboard_text(uint64_t display) {
    if (display == 0) return io_ok_string("");
    char *text = al_get_clipboard_text((ALLEGRO_DISPLAY *)u64_to_ptr(display));
    lean_object *result = io_ok_string(text ? text : "");
    if (text) al_free(text);
    return result;
}

lean_object* allegro_al_set_clipboard_text(uint64_t display, lean_object *textObj) {
    const char *text = lean_string_cstr(textObj);
    uint32_t ok = 0;
    if (display != 0) {
        ok = al_set_clipboard_text((ALLEGRO_DISPLAY *)u64_to_ptr(display), text) ? 1u : 0u;
    }
    lean_dec_ref(textObj);
    return io_ok_uint32(ok);
}

lean_object* allegro_al_clipboard_has_text(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_clipboard_has_text((ALLEGRO_DISPLAY *)u64_to_ptr(display)) ? 1u : 0u);
}

/* ── Monitor info ── */

lean_object* allegro_al_get_num_video_adapters(void) {
    return io_ok_uint32((uint32_t)al_get_num_video_adapters());
}

lean_object* allegro_al_get_monitor_dpi(uint32_t adapter) {
    return io_ok_uint32((uint32_t)al_get_monitor_dpi((int)adapter));
}

/* ── Fullscreen display modes ── */

lean_object* allegro_al_get_num_display_modes(void) {
    return io_ok_uint32((uint32_t)al_get_num_display_modes());
}

/* ── Display extras ── */

lean_object* allegro_al_set_display_icon(uint64_t display, uint64_t bitmap) {
    if (display != 0 && bitmap != 0) {
        al_set_display_icon((ALLEGRO_DISPLAY *)u64_to_ptr(display),
                            (ALLEGRO_BITMAP *)u64_to_ptr(bitmap));
    }
    return io_ok_unit();
}

lean_object* allegro_al_inhibit_screensaver(uint32_t inhibit) {
    return io_ok_uint32(al_inhibit_screensaver(inhibit != 0) ? 1u : 0u);
}

/* ── Tuple-returning queries ── */

lean_object* allegro_al_get_window_position(uint64_t display) {
    if (display == 0) return io_ok_u32_pair(0, 0);
    int x = 0, y = 0;
    al_get_window_position((ALLEGRO_DISPLAY *)u64_to_ptr(display), &x, &y);
    return io_ok_u32_pair((uint32_t)x, (uint32_t)y);
}

lean_object* allegro_al_get_monitor_info(uint32_t adapter) {
    ALLEGRO_MONITOR_INFO info;
    if (!al_get_monitor_info((int)adapter, &info)) return io_ok_u32_quad(0, 0, 0, 0);
    return io_ok_u32_quad((uint32_t)info.x1, (uint32_t)info.y1,
                          (uint32_t)info.x2, (uint32_t)info.y2);
}

lean_object* allegro_al_get_display_mode(uint32_t index) {
    ALLEGRO_DISPLAY_MODE mode;
    if (!al_get_display_mode((int)index, &mode)) return io_ok_u32_quad(0, 0, 0, 0);
    return io_ok_u32_quad((uint32_t)mode.width, (uint32_t)mode.height,
                          (uint32_t)mode.format, (uint32_t)mode.refresh_rate);
}

/* ── New-display creation parameters ── */

lean_object* allegro_al_set_new_display_refresh_rate(uint32_t rate) {
    al_set_new_display_refresh_rate((int)rate);
    return io_ok_unit();
}

lean_object* allegro_al_get_new_display_refresh_rate(void) {
    return io_ok_uint32((uint32_t)al_get_new_display_refresh_rate());
}

lean_object* allegro_al_set_new_window_title(lean_object* titleObj) {
    al_set_new_window_title(lean_string_cstr(titleObj));
    lean_dec_ref(titleObj);
    return io_ok_unit();
}

lean_object* allegro_al_get_new_window_title(void) {
    return io_ok_string(al_get_new_window_title());
}

lean_object* allegro_al_set_new_display_adapter(uint32_t adapter) {
    al_set_new_display_adapter((int)adapter);
    return io_ok_unit();
}

lean_object* allegro_al_get_new_display_adapter(void) {
    return io_ok_uint32((uint32_t)al_get_new_display_adapter());
}

lean_object* allegro_al_set_new_window_position(uint32_t x, uint32_t y) {
    al_set_new_window_position((int)x, (int)y);
    return io_ok_unit();
}

lean_object* allegro_al_get_new_window_position(void) {
    int x = 0, y = 0;
    al_get_new_window_position(&x, &y);
    return io_ok_u32_pair((uint32_t)x, (uint32_t)y);
}

/* ── Existing display queries ── */

lean_object* allegro_al_get_display_format(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_display_format((ALLEGRO_DISPLAY *)u64_to_ptr(display)));
}

lean_object* allegro_al_get_display_refresh_rate(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_display_refresh_rate((ALLEGRO_DISPLAY *)u64_to_ptr(display)));
}

lean_object* allegro_al_get_display_orientation(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_display_orientation((ALLEGRO_DISPLAY *)u64_to_ptr(display)));
}

lean_object* allegro_al_get_display_adapter(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_display_adapter((ALLEGRO_DISPLAY *)u64_to_ptr(display)));
}

/* ── Window management ── */

lean_object* allegro_al_get_window_borders(uint64_t display) {
    if (display == 0) return io_ok_u32_quad(0, 0, 0, 0);
    int left = 0, top = 0, right = 0, bottom = 0;
    al_get_window_borders((ALLEGRO_DISPLAY *)u64_to_ptr(display), &left, &top, &right, &bottom);
    return io_ok_u32_quad((uint32_t)left, (uint32_t)top, (uint32_t)right, (uint32_t)bottom);
}

lean_object* allegro_al_get_window_constraints(uint64_t display) {
    if (display == 0) return io_ok_u32_quad(0, 0, 0, 0);
    int minW = 0, minH = 0, maxW = 0, maxH = 0;
    al_get_window_constraints((ALLEGRO_DISPLAY *)u64_to_ptr(display), &minW, &minH, &maxW, &maxH);
    return io_ok_u32_quad((uint32_t)minW, (uint32_t)minH, (uint32_t)maxW, (uint32_t)maxH);
}

lean_object* allegro_al_apply_window_constraints(uint64_t display, uint32_t onoff) {
    if (display != 0) {
        al_apply_window_constraints((ALLEGRO_DISPLAY *)u64_to_ptr(display), onoff != 0);
    }
    return io_ok_unit();
}

lean_object* allegro_al_set_display_option_live(uint64_t display, uint32_t option, uint32_t value) {
    if (display != 0) {
        al_set_display_option((ALLEGRO_DISPLAY *)u64_to_ptr(display), (int)option, (int)value);
    }
    return io_ok_unit();
}

/* ── Display extras ── */

lean_object* allegro_al_is_compatible_bitmap(uint64_t bitmap) {
    if (bitmap == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_compatible_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bitmap)) ? 1u : 0u);
}

lean_object* allegro_al_wait_for_vsync(void) {
    ALLEGRO_DISPLAY *d = al_get_current_display();
    if (!d) return io_ok_uint32(0);
    return io_ok_uint32(al_wait_for_vsync() ? 1u : 0u);
}

lean_object* allegro_al_backup_dirty_bitmaps(uint64_t display) {
    if (display != 0) {
        al_backup_dirty_bitmaps((ALLEGRO_DISPLAY *)u64_to_ptr(display));
    }
    return io_ok_unit();
}

/* ── Render state ── */

lean_object* allegro_al_clear_depth_buffer(double value) {
    al_clear_depth_buffer((float)value);
    return io_ok_unit();
}

lean_object* allegro_al_get_render_state(uint32_t state) {
    return io_ok_uint32((uint32_t)al_get_render_state((ALLEGRO_RENDER_STATE)state));
}

lean_object* allegro_al_set_render_state(uint32_t state, uint32_t value) {
    al_set_render_state((ALLEGRO_RENDER_STATE)state, (int)value);
    return io_ok_unit();
}

/* ── Monitor extras ── */

lean_object* allegro_al_get_monitor_refresh_rate(uint32_t adapter) {
    return io_ok_uint32((uint32_t)al_get_monitor_refresh_rate((int)adapter));
}

/* ── Display icons ── */

lean_object* allegro_al_set_display_icons(uint64_t display, b_lean_obj_arg arr) {
    if (display == 0) return io_ok_unit();
    size_t n = lean_array_size(arr);
    if (n == 0) return io_ok_unit();
    ALLEGRO_BITMAP **icons = (ALLEGRO_BITMAP **)alloca(n * sizeof(ALLEGRO_BITMAP *));
    for (size_t i = 0; i < n; i++) {
        lean_object* elem = lean_array_get_core(arr, i);
        uint64_t h = lean_unbox_uint64(elem);
        icons[i] = (ALLEGRO_BITMAP *)u64_to_ptr(h);
    }
    al_set_display_icons((ALLEGRO_DISPLAY *)u64_to_ptr(display), (int)n, icons);
    return io_ok_unit();
}
