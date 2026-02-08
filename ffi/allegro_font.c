#include "allegro_ffi.h"
#include <allegro5/allegro_font.h>

/* ── Lifecycle ── */

lean_object* allegro_al_init_font_addon(void) {
    al_init_font_addon();
    return io_ok_unit();
}

lean_object* allegro_al_shutdown_font_addon(void) {
    al_shutdown_font_addon();
    return io_ok_unit();
}

lean_object* allegro_al_is_font_addon_initialized(void) {
    return io_ok_uint32(al_is_font_addon_initialized() ? 1u : 0u);
}

/* ── Font creation / loading / destruction ── */

lean_object* allegro_al_create_builtin_font(void) {
    ALLEGRO_FONT *font = al_create_builtin_font();
    return io_ok_uint64(ptr_to_u64(font));
}

lean_object* allegro_al_load_font(lean_object* pathObj, int32_t size, uint32_t flags) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_FONT *font = al_load_font(path, size, (int)flags);
    return io_ok_uint64(ptr_to_u64(font));
}

lean_object* allegro_al_load_bitmap_font(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_FONT *font = al_load_bitmap_font(path);
    return io_ok_uint64(ptr_to_u64(font));
}

lean_object* allegro_al_load_bitmap_font_flags(lean_object* pathObj, uint32_t flags) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_FONT *font = al_load_bitmap_font_flags(path, (int)flags);
    return io_ok_uint64(ptr_to_u64(font));
}

lean_object* allegro_al_destroy_font(uint64_t font) {
    if (font != 0) {
        al_destroy_font((ALLEGRO_FONT *)u64_to_ptr(font));
    }
    return io_ok_unit();
}

/* ── Text drawing ── */

lean_object* allegro_al_draw_text_rgb(
    uint64_t font,
    uint32_t r, uint32_t g, uint32_t b,
    double x, double y,
    uint32_t flags,
    lean_object* textObj) {
    if (font != 0) {
        const char *text = lean_string_cstr(textObj);
        ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_text((ALLEGRO_FONT *)u64_to_ptr(font), color, (float)x, (float)y, (int)flags, text);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_text_rgba(
    uint64_t font,
    uint32_t r, uint32_t g, uint32_t b, uint32_t a,
    double x, double y,
    uint32_t flags,
    lean_object* textObj) {
    if (font != 0) {
        const char *text = lean_string_cstr(textObj);
        ALLEGRO_COLOR color = al_map_rgba((unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a);
        al_draw_text((ALLEGRO_FONT *)u64_to_ptr(font), color, (float)x, (float)y, (int)flags, text);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_ustr_rgb(
    uint64_t font,
    uint32_t r, uint32_t g, uint32_t b,
    double x, double y,
    uint32_t flags,
    uint64_t ustr) {
    if (font != 0 && ustr != 0) {
        ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_ustr((ALLEGRO_FONT *)u64_to_ptr(font), color, (float)x, (float)y, (int)flags, (ALLEGRO_USTR *)u64_to_ptr(ustr));
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_justified_text_rgb(
    uint64_t font,
    uint32_t r, uint32_t g, uint32_t b,
    double x1, double x2, double y, double diff,
    uint32_t flags,
    lean_object* textObj) {
    if (font != 0) {
        const char *text = lean_string_cstr(textObj);
        ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_justified_text((ALLEGRO_FONT *)u64_to_ptr(font), color,
            (float)x1, (float)x2, (float)y, (float)diff, (int)flags, text);
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_multiline_text_rgb(
    uint64_t font,
    uint32_t r, uint32_t g, uint32_t b,
    double x, double y, double max_width, double line_height,
    uint32_t flags,
    lean_object* textObj) {
    if (font != 0) {
        const char *text = lean_string_cstr(textObj);
        ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_multiline_text((ALLEGRO_FONT *)u64_to_ptr(font), color,
            (float)x, (float)y, (float)max_width, (float)line_height, (int)flags, text);
    }
    return io_ok_unit();
}

/* ── Glyph drawing ── */

lean_object* allegro_al_draw_glyph_rgb(
    uint64_t font,
    uint32_t r, uint32_t g, uint32_t b,
    double x, double y,
    int32_t codepoint) {
    if (font != 0) {
        ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_glyph((ALLEGRO_FONT *)u64_to_ptr(font), color, (float)x, (float)y, codepoint);
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_glyph_width(uint64_t font, int32_t codepoint) {
    if (font == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_glyph_width((ALLEGRO_FONT *)u64_to_ptr(font), codepoint));
}

lean_object* allegro_al_get_glyph_advance(uint64_t font, int32_t codepoint1, int32_t codepoint2) {
    if (font == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_glyph_advance((ALLEGRO_FONT *)u64_to_ptr(font), codepoint1, codepoint2));
}

/* ── Text / font metrics ── */

lean_object* allegro_al_get_text_width(uint64_t font, lean_object* textObj) {
    if (font == 0) {
        return io_ok_uint32(0);
    }
    const char *text = lean_string_cstr(textObj);
    int w = al_get_text_width((ALLEGRO_FONT *)u64_to_ptr(font), text);
    return io_ok_uint32((uint32_t)w);
}

lean_object* allegro_al_get_font_line_height(uint64_t font) {
    if (font == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_font_line_height((ALLEGRO_FONT *)u64_to_ptr(font)));
}

lean_object* allegro_al_get_font_ascent(uint64_t font) {
    if (font == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_font_ascent((ALLEGRO_FONT *)u64_to_ptr(font)));
}

lean_object* allegro_al_get_font_descent(uint64_t font) {
    if (font == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_font_descent((ALLEGRO_FONT *)u64_to_ptr(font)));
}

lean_object* allegro_al_get_font_ranges(uint64_t font, int32_t rangesCount) {
    if (font == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_font_ranges((ALLEGRO_FONT *)u64_to_ptr(font), rangesCount, NULL));
}

lean_object* allegro_al_get_ustr_width(uint64_t font, uint64_t ustr) {
    if (font == 0 || ustr == 0) return io_ok_uint32(0);
    int w = al_get_ustr_width((ALLEGRO_FONT *)u64_to_ptr(font), (ALLEGRO_USTR *)u64_to_ptr(ustr));
    return io_ok_uint32((uint32_t)w);
}

/* ── Fallback font ── */

lean_object* allegro_al_set_fallback_font(uint64_t font, uint64_t fallback) {
    if (font != 0) {
        al_set_fallback_font((ALLEGRO_FONT *)u64_to_ptr(font),
            fallback != 0 ? (ALLEGRO_FONT *)u64_to_ptr(fallback) : NULL);
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_fallback_font(uint64_t font) {
    if (font == 0) return io_ok_uint64(0);
    ALLEGRO_FONT *fb = al_get_fallback_font((ALLEGRO_FONT *)u64_to_ptr(font));
    return io_ok_uint64(ptr_to_u64(fb));
}

/* ── Tuple-returning queries ── */

lean_object* allegro_al_get_text_dimensions(uint64_t font, lean_object* textObj) {
    if (font == 0) return io_ok_u32_quad(0, 0, 0, 0);
    int x, y, w, h;
    al_get_text_dimensions((ALLEGRO_FONT *)u64_to_ptr(font), lean_string_cstr(textObj), &x, &y, &w, &h);
    return io_ok_u32_quad((uint32_t)x, (uint32_t)y, (uint32_t)w, (uint32_t)h);
}

/* ── Additional font functions ── */

lean_object* allegro_al_get_ustr_dimensions(uint64_t font, uint64_t ustr) {
    if (font == 0 || ustr == 0) return io_ok_u32_quad(0, 0, 0, 0);
    int x, y, w, h;
    al_get_ustr_dimensions((ALLEGRO_FONT *)u64_to_ptr(font),
                           (ALLEGRO_USTR *)u64_to_ptr(ustr), &x, &y, &w, &h);
    return io_ok_u32_quad((uint32_t)x, (uint32_t)y, (uint32_t)w, (uint32_t)h);
}

lean_object* allegro_al_get_glyph_dimensions(uint64_t font, int32_t codepoint) {
    if (font == 0) return io_ok_u32_quad(0, 0, 0, 0);
    int x, y, w, h;
    bool ok = al_get_glyph_dimensions((ALLEGRO_FONT *)u64_to_ptr(font), codepoint, &x, &y, &w, &h);
    if (!ok) return io_ok_u32_quad(0, 0, 0, 0);
    return io_ok_u32_quad((uint32_t)x, (uint32_t)y, (uint32_t)w, (uint32_t)h);
}

lean_object* allegro_al_draw_justified_ustr_rgb(
    uint64_t font,
    uint32_t r, uint32_t g, uint32_t b,
    double x1, double x2, double y, double diff,
    uint32_t flags,
    uint64_t ustr) {
    if (font != 0 && ustr != 0) {
        ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_justified_ustr((ALLEGRO_FONT *)u64_to_ptr(font), color,
            (float)x1, (float)x2, (float)y, (float)diff, (int)flags,
            (ALLEGRO_USTR *)u64_to_ptr(ustr));
    }
    return io_ok_unit();
}

lean_object* allegro_al_draw_multiline_ustr_rgb(
    uint64_t font,
    uint32_t r, uint32_t g, uint32_t b,
    double x, double y, double max_width, double line_height,
    uint32_t flags,
    uint64_t ustr) {
    if (font != 0 && ustr != 0) {
        ALLEGRO_COLOR color = al_map_rgb((unsigned char)r, (unsigned char)g, (unsigned char)b);
        al_draw_multiline_ustr((ALLEGRO_FONT *)u64_to_ptr(font), color,
            (float)x, (float)y, (float)max_width, (float)line_height, (int)flags,
            (ALLEGRO_USTR *)u64_to_ptr(ustr));
    }
    return io_ok_unit();
}

lean_object* allegro_al_grab_font_from_bitmap(uint64_t bmp, lean_object* rangesObj) {
    if (bmp == 0) return io_ok_uint64(0);
    /* rangesObj is a Lean Array of Int32.  Each pair (start, end) defines a range. */
    size_t count = lean_array_size(rangesObj);
    int *ranges = NULL;
    if (count > 0) {
        ranges = (int *)malloc(count * sizeof(int));
        if (!ranges) return io_ok_uint64(0);
        for (size_t i = 0; i < count; i++) {
            lean_object* elem = lean_array_get_core(rangesObj, i);
            ranges[i] = (int)lean_unbox_uint32(elem);
        }
    }
    /* n = number of ranges, each range is 2 ints */
    int n = (int)(count / 2);
    ALLEGRO_FONT *f = al_grab_font_from_bitmap((ALLEGRO_BITMAP *)u64_to_ptr(bmp), n, ranges);
    if (ranges) free(ranges);
    return io_ok_uint64(ptr_to_u64(f));
}

lean_object* allegro_al_get_allegro_font_version(void) {
    return io_ok_uint32(al_get_allegro_font_version());
}

/* ── Glyph info (UNSTABLE) ── */

lean_object* allegro_al_get_glyph(uint64_t font, uint32_t codepoint) {
    if (font == 0) {
        /* Return (bitmap=0, x=0, y=0, w=0, h=0, kerning=0, offset_x=0, offset_y=0, advance=0) */
        lean_object* t8 = mk_pair(lean_box_uint32(0), lean_box_uint32(0));
        lean_object* t7 = mk_pair(lean_box_uint32(0), t8);
        lean_object* t6 = mk_pair(lean_box_uint32(0), t7);
        lean_object* t5 = mk_pair(lean_box_uint32(0), t6);
        lean_object* t4 = mk_pair(lean_box_uint32(0), t5);
        lean_object* t3 = mk_pair(lean_box_uint32(0), t4);
        lean_object* t2 = mk_pair(lean_box_uint32(0), t3);
        return lean_io_result_mk_ok(mk_pair(lean_box_uint64(0), t2));
    }
    ALLEGRO_GLYPH glyph;
    memset(&glyph, 0, sizeof(glyph));
    bool ok = al_get_glyph((ALLEGRO_FONT *)u64_to_ptr(font), 0, (int)codepoint, &glyph);
    if (!ok) memset(&glyph, 0, sizeof(glyph));
    lean_object* t8 = mk_pair(lean_box_uint32((uint32_t)glyph.offset_y),
                               lean_box_uint32((uint32_t)glyph.advance));
    lean_object* t7 = mk_pair(lean_box_uint32((uint32_t)glyph.offset_x), t8);
    lean_object* t6 = mk_pair(lean_box_uint32((uint32_t)glyph.kerning), t7);
    lean_object* t5 = mk_pair(lean_box_uint32((uint32_t)glyph.h), t6);
    lean_object* t4 = mk_pair(lean_box_uint32((uint32_t)glyph.w), t5);
    lean_object* t3 = mk_pair(lean_box_uint32((uint32_t)glyph.y), t4);
    lean_object* t2 = mk_pair(lean_box_uint32((uint32_t)glyph.x), t3);
    return lean_io_result_mk_ok(
        mk_pair(lean_box_uint64(ptr_to_u64(glyph.bitmap)), t2));
}

/* ── Callback-collecting multiline text ── */

typedef struct {
    lean_object **lines;
    size_t count;
    size_t capacity;
} multiline_collect_t;

static bool multiline_text_cb(int line_num, const char *line, int size, void *extra) {
    multiline_collect_t *d = (multiline_collect_t *)extra;
    if (d->count >= d->capacity) {
        d->capacity = d->capacity ? d->capacity * 2 : 16;
        d->lines = (lean_object **)realloc(d->lines, d->capacity * sizeof(lean_object *));
    }
    char *buf = (char *)malloc((size_t)size + 1);
    memcpy(buf, line, (size_t)size);
    buf[size] = '\0';
    d->lines[d->count++] = lean_mk_string(buf);
    free(buf);
    return true;
}

lean_object* allegro_al_do_multiline_text(uint64_t font, double maxWidth, lean_object* textObj) {
    const char *text = lean_string_cstr(textObj);
    multiline_collect_t data = {NULL, 0, 0};
    if (font != 0) {
        al_do_multiline_text((const ALLEGRO_FONT *)u64_to_ptr(font),
                              (float)maxWidth, text, multiline_text_cb, &data);
    }
    lean_dec_ref(textObj);
    lean_object *arr = lean_alloc_array(data.count, data.count);
    for (size_t i = 0; i < data.count; i++) {
        lean_array_set_core(arr, i, data.lines[i]);
    }
    free(data.lines);
    return lean_io_result_mk_ok(arr);
}

static bool multiline_ustr_cb(int line_num, const ALLEGRO_USTR *line, void *extra) {
    multiline_collect_t *d = (multiline_collect_t *)extra;
    if (d->count >= d->capacity) {
        d->capacity = d->capacity ? d->capacity * 2 : 16;
        d->lines = (lean_object **)realloc(d->lines, d->capacity * sizeof(lean_object *));
    }
    char *dup = al_cstr_dup(line);
    d->lines[d->count++] = lean_mk_string(dup);
    al_free(dup);
    return true;
}

lean_object* allegro_al_do_multiline_ustr(uint64_t font, double maxWidth, uint64_t ustr) {
    multiline_collect_t data = {NULL, 0, 0};
    if (font != 0 && ustr != 0) {
        al_do_multiline_ustr((const ALLEGRO_FONT *)u64_to_ptr(font),
                              (float)maxWidth,
                              (const ALLEGRO_USTR *)u64_to_ptr(ustr),
                              multiline_ustr_cb, &data);
    }
    lean_object *arr = lean_alloc_array(data.count, data.count);
    for (size_t i = 0; i < data.count; i++) {
        lean_array_set_core(arr, i, data.lines[i]);
    }
    free(data.lines);
    return lean_io_result_mk_ok(arr);
}
