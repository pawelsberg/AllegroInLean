#include "allegro_ffi.h"
#include <allegro5/allegro.h>
#include <allegro5/allegro_native_dialog.h>

/*
 * Allegro 5 native dialog addon bindings.
 *
 * Covers: file chooser, message box, text log, and menu.
 * The `al_append_native_text_log` variadic is bound as a simple string-append
 * (the format string is "%s") — formatting should be done on the Lean side.
 */

/* ── Addon lifecycle ── */

lean_object* allegro_al_init_native_dialog_addon(void) {
    return io_ok_uint32(al_init_native_dialog_addon() ? 1u : 0u);
}

lean_object* allegro_al_shutdown_native_dialog_addon(void) {
    al_shutdown_native_dialog_addon();
    return io_ok_unit();
}

lean_object* allegro_al_is_native_dialog_addon_initialized(void) {
    return io_ok_uint32(al_is_native_dialog_addon_initialized() ? 1u : 0u);
}

lean_object* allegro_al_get_allegro_native_dialog_version(void) {
    return io_ok_uint32(al_get_allegro_native_dialog_version());
}

/* ── File chooser ── */

lean_object* allegro_al_create_native_file_dialog(b_lean_obj_arg initialPathObj,
                                                   b_lean_obj_arg titleObj,
                                                   b_lean_obj_arg patternsObj,
                                                   uint32_t mode) {
    const char *initial_path = lean_string_cstr(initialPathObj);
    const char *title        = lean_string_cstr(titleObj);
    const char *patterns     = lean_string_cstr(patternsObj);
    ALLEGRO_FILECHOOSER *fc = al_create_native_file_dialog(
        initial_path, title, patterns, (int)mode);
    return io_ok_uint64(ptr_to_u64(fc));
}

lean_object* allegro_al_show_native_file_dialog(uint64_t display, uint64_t dialog) {
    if (dialog == 0) return io_ok_uint32(0);
    bool ok = al_show_native_file_dialog(
        (ALLEGRO_DISPLAY *)u64_to_ptr(display),
        (ALLEGRO_FILECHOOSER *)u64_to_ptr(dialog));
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_get_native_file_dialog_count(uint64_t dialog) {
    if (dialog == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_native_file_dialog_count(
        (const ALLEGRO_FILECHOOSER *)u64_to_ptr(dialog)));
}

lean_object* allegro_al_get_native_file_dialog_path(uint64_t dialog, uint32_t index) {
    if (dialog == 0) return io_ok_string("");
    const char *path = al_get_native_file_dialog_path(
        (const ALLEGRO_FILECHOOSER *)u64_to_ptr(dialog), (size_t)index);
    return io_ok_string(path);
}

lean_object* allegro_al_destroy_native_file_dialog(uint64_t dialog) {
    if (dialog != 0) {
        al_destroy_native_file_dialog((ALLEGRO_FILECHOOSER *)u64_to_ptr(dialog));
    }
    return io_ok_unit();
}

/* ── Message box ── */

lean_object* allegro_al_show_native_message_box(uint64_t display,
                                                 b_lean_obj_arg titleObj,
                                                 b_lean_obj_arg headingObj,
                                                 b_lean_obj_arg textObj,
                                                 b_lean_obj_arg buttonsObj,
                                                 uint32_t flags) {
    const char *title   = lean_string_cstr(titleObj);
    const char *heading = lean_string_cstr(headingObj);
    const char *text    = lean_string_cstr(textObj);
    const char *buttons = lean_string_cstr(buttonsObj);
    /* Pass NULL for buttons if the string is empty (Allegro uses NULL for
       default OK button). */
    const char *btn_ptr = (buttons[0] == '\0') ? NULL : buttons;
    int r = al_show_native_message_box(
        (ALLEGRO_DISPLAY *)u64_to_ptr(display),
        title, heading, text, btn_ptr, (int)flags);
    return io_ok_uint32((uint32_t)r);
}

/* ── Text log ── */

lean_object* allegro_al_open_native_text_log(b_lean_obj_arg titleObj, uint32_t flags) {
    const char *title = lean_string_cstr(titleObj);
    ALLEGRO_TEXTLOG *tl = al_open_native_text_log(title, (int)flags);
    return io_ok_uint64(ptr_to_u64(tl));
}

lean_object* allegro_al_close_native_text_log(uint64_t textlog) {
    if (textlog != 0) {
        al_close_native_text_log((ALLEGRO_TEXTLOG *)u64_to_ptr(textlog));
    }
    return io_ok_unit();
}

lean_object* allegro_al_append_native_text_log(uint64_t textlog, b_lean_obj_arg textObj) {
    if (textlog != 0) {
        const char *text = lean_string_cstr(textObj);
        al_append_native_text_log((ALLEGRO_TEXTLOG *)u64_to_ptr(textlog), "%s", text);
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_native_text_log_event_source(uint64_t textlog) {
    if (textlog == 0) return io_ok_uint64(0);
    ALLEGRO_EVENT_SOURCE *es = al_get_native_text_log_event_source(
        (ALLEGRO_TEXTLOG *)u64_to_ptr(textlog));
    return io_ok_uint64(ptr_to_u64(es));
}

/* ── Menu ── */

lean_object* allegro_al_create_menu(void) {
    ALLEGRO_MENU *m = al_create_menu();
    return io_ok_uint64(ptr_to_u64(m));
}

lean_object* allegro_al_create_popup_menu(void) {
    ALLEGRO_MENU *m = al_create_popup_menu();
    return io_ok_uint64(ptr_to_u64(m));
}

lean_object* allegro_al_destroy_menu(uint64_t menu) {
    if (menu != 0) {
        al_destroy_menu((ALLEGRO_MENU *)u64_to_ptr(menu));
    }
    return io_ok_unit();
}

lean_object* allegro_al_clone_menu(uint64_t menu) {
    if (menu == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(al_clone_menu((ALLEGRO_MENU *)u64_to_ptr(menu))));
}

lean_object* allegro_al_clone_menu_for_popup(uint64_t menu) {
    if (menu == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(al_clone_menu_for_popup((ALLEGRO_MENU *)u64_to_ptr(menu))));
}

lean_object* allegro_al_append_menu_item(uint64_t parent, b_lean_obj_arg titleObj,
                                          uint32_t id, uint32_t flags,
                                          uint64_t icon, uint64_t submenu) {
    if (parent == 0) return io_ok_uint32((uint32_t)-1);
    const char *title = lean_string_cstr(titleObj);
    /* Empty title string treated as a separator (pass NULL). */
    const char *t = (title[0] == '\0') ? NULL : title;
    int r = al_append_menu_item((ALLEGRO_MENU *)u64_to_ptr(parent),
                                t, (uint16_t)id, (int)flags,
                                (ALLEGRO_BITMAP *)u64_to_ptr(icon),
                                (ALLEGRO_MENU *)u64_to_ptr(submenu));
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_insert_menu_item(uint64_t parent, uint32_t pos,
                                          b_lean_obj_arg titleObj,
                                          uint32_t id, uint32_t flags,
                                          uint64_t icon, uint64_t submenu) {
    if (parent == 0) return io_ok_uint32((uint32_t)-1);
    const char *title = lean_string_cstr(titleObj);
    const char *t = (title[0] == '\0') ? NULL : title;
    int r = al_insert_menu_item((ALLEGRO_MENU *)u64_to_ptr(parent),
                                (int)pos, t, (uint16_t)id, (int)flags,
                                (ALLEGRO_BITMAP *)u64_to_ptr(icon),
                                (ALLEGRO_MENU *)u64_to_ptr(submenu));
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_remove_menu_item(uint64_t menu, uint32_t pos) {
    if (menu == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_remove_menu_item((ALLEGRO_MENU *)u64_to_ptr(menu), (int)pos) ? 1u : 0u);
}

lean_object* allegro_al_get_menu_item_caption(uint64_t menu, uint32_t pos) {
    if (menu == 0) return io_ok_string("");
    const char *c = al_get_menu_item_caption((ALLEGRO_MENU *)u64_to_ptr(menu), (int)pos);
    return io_ok_string(c);
}

lean_object* allegro_al_set_menu_item_caption(uint64_t menu, uint32_t pos, b_lean_obj_arg captionObj) {
    if (menu != 0) {
        const char *caption = lean_string_cstr(captionObj);
        al_set_menu_item_caption((ALLEGRO_MENU *)u64_to_ptr(menu), (int)pos, caption);
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_menu_item_flags(uint64_t menu, uint32_t pos) {
    if (menu == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_menu_item_flags((ALLEGRO_MENU *)u64_to_ptr(menu), (int)pos));
}

lean_object* allegro_al_set_menu_item_flags(uint64_t menu, uint32_t pos, uint32_t flags) {
    if (menu != 0) {
        al_set_menu_item_flags((ALLEGRO_MENU *)u64_to_ptr(menu), (int)pos, (int)flags);
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_menu_item_icon(uint64_t menu, uint32_t pos) {
    if (menu == 0) return io_ok_uint64(0);
    ALLEGRO_BITMAP *bmp = al_get_menu_item_icon((ALLEGRO_MENU *)u64_to_ptr(menu), (int)pos);
    return io_ok_uint64(ptr_to_u64(bmp));
}

lean_object* allegro_al_set_menu_item_icon(uint64_t menu, uint32_t pos, uint64_t icon) {
    if (menu != 0) {
        al_set_menu_item_icon((ALLEGRO_MENU *)u64_to_ptr(menu), (int)pos,
                              (ALLEGRO_BITMAP *)u64_to_ptr(icon));
    }
    return io_ok_unit();
}

lean_object* allegro_al_find_menu(uint64_t menu, uint32_t id) {
    if (menu == 0) return io_ok_uint64(0);
    ALLEGRO_MENU *found = al_find_menu((ALLEGRO_MENU *)u64_to_ptr(menu), (uint16_t)id);
    return io_ok_uint64(ptr_to_u64(found));
}

lean_object* allegro_al_get_default_menu_event_source(void) {
    ALLEGRO_EVENT_SOURCE *es = al_get_default_menu_event_source();
    return io_ok_uint64(ptr_to_u64(es));
}

lean_object* allegro_al_enable_menu_event_source(uint64_t menu) {
    if (menu == 0) return io_ok_uint64(0);
    ALLEGRO_EVENT_SOURCE *es = al_enable_menu_event_source(
        (ALLEGRO_MENU *)u64_to_ptr(menu));
    return io_ok_uint64(ptr_to_u64(es));
}

lean_object* allegro_al_disable_menu_event_source(uint64_t menu) {
    if (menu != 0) {
        al_disable_menu_event_source((ALLEGRO_MENU *)u64_to_ptr(menu));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_display_menu(uint64_t display) {
    if (display == 0) return io_ok_uint64(0);
    ALLEGRO_MENU *m = al_get_display_menu((ALLEGRO_DISPLAY *)u64_to_ptr(display));
    return io_ok_uint64(ptr_to_u64(m));
}

lean_object* allegro_al_set_display_menu(uint64_t display, uint64_t menu) {
    if (display == 0) return io_ok_uint32(0);
    bool ok = al_set_display_menu((ALLEGRO_DISPLAY *)u64_to_ptr(display),
                                  (ALLEGRO_MENU *)u64_to_ptr(menu));
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_popup_menu(uint64_t menu, uint64_t display) {
    if (menu == 0 || display == 0) return io_ok_uint32(0);
    bool ok = al_popup_menu((ALLEGRO_MENU *)u64_to_ptr(menu),
                            (ALLEGRO_DISPLAY *)u64_to_ptr(display));
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_remove_display_menu(uint64_t display) {
    if (display == 0) return io_ok_uint64(0);
    ALLEGRO_MENU *m = al_remove_display_menu((ALLEGRO_DISPLAY *)u64_to_ptr(display));
    return io_ok_uint64(ptr_to_u64(m));
}

/* ── Menu item flag toggling ── */

lean_object* allegro_al_toggle_menu_item_flags(uint64_t menu, int32_t pos, uint32_t flags) {
    if (menu == 0) return io_ok_uint32(0);
    int result = al_toggle_menu_item_flags(
        (ALLEGRO_MENU *)u64_to_ptr(menu), pos, (int)flags);
    return io_ok_uint32((uint32_t)result);
}

/* ── Find menu item by ID ── */

lean_object* allegro_al_find_menu_item(uint64_t menu, uint32_t id) {
    if (menu == 0) {
        lean_object* inner = mk_pair(lean_box_uint64(0), lean_box_uint32(0));
        return lean_io_result_mk_ok(mk_pair(lean_box_uint32(0), inner));
    }
    ALLEGRO_MENU *found = NULL;
    int index = -1;
    bool ok = al_find_menu_item(
        (ALLEGRO_MENU *)u64_to_ptr(menu), (uint16_t)id, &found, &index);
    lean_object* inner = mk_pair(
        lean_box_uint64(ptr_to_u64(found)),
        lean_box_uint32((uint32_t)(ok ? index : 0)));
    return lean_io_result_mk_ok(
        mk_pair(lean_box_uint32(ok ? 1u : 0u), inner));
}

/* ── Build menu from flat info array ── */

lean_object* allegro_al_build_menu(b_lean_obj_arg captions, b_lean_obj_arg ids,
                                    b_lean_obj_arg flags_arr, b_lean_obj_arg icons) {
    size_t n = lean_array_size(captions);
    ALLEGRO_MENU_INFO *info = (ALLEGRO_MENU_INFO *)calloc(n + 1, sizeof(ALLEGRO_MENU_INFO));
    if (!info) return io_ok_uint64(0);
    for (size_t i = 0; i < n; i++) {
        lean_object *cap = lean_array_get_core(captions, i);
        const char *s = lean_string_cstr(cap);
        info[i].caption = (s[0] == '\0') ? NULL : s;
        info[i].id = (uint16_t)lean_unbox_uint32(lean_array_get_core(ids, i));
        info[i].flags = (int)lean_unbox_uint32(lean_array_get_core(flags_arr, i));
        uint64_t icon_val = lean_unbox_uint64(lean_array_get_core(icons, i));
        info[i].icon = (icon_val != 0) ? (ALLEGRO_BITMAP *)u64_to_ptr(icon_val) : NULL;
    }
    /* info[n] already zeroed by calloc — serves as terminator */
    ALLEGRO_MENU *menu = al_build_menu(info);
    free(info);
    return io_ok_uint64(ptr_to_u64(menu));
}
