#include "allegro_ffi.h"
#include <allegro5/allegro.h>
#include <allegro5/haptic.h>

/* ── Haptic (force-feedback) ── */

/* install / uninstall */

lean_object* allegro_al_install_haptic(void) {
    return io_ok_uint32(al_install_haptic() ? 1u : 0u);
}

lean_object* allegro_al_uninstall_haptic(void) {
    al_uninstall_haptic();
    return io_ok_unit();
}

lean_object* allegro_al_is_haptic_installed(void) {
    return io_ok_uint32(al_is_haptic_installed() ? 1u : 0u);
}

/* device detection — mouse/keyboard/touch use internal pointers not exposed via public API.
   For safety, these pass NULL which returns false. Joystick and display use the handle. */

lean_object* allegro_al_is_mouse_haptic(void) {
    /* ALLEGRO_MOUSE is not a public handle; there is no al_get_mouse().
       Pass NULL — returns false on all known platforms. */
    return io_ok_uint32(0);
}

lean_object* allegro_al_is_joystick_haptic(uint64_t joy) {
    if (joy == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_joystick_haptic((ALLEGRO_JOYSTICK *)u64_to_ptr(joy)) ? 1u : 0u);
}

lean_object* allegro_al_is_keyboard_haptic(void) {
    /* ALLEGRO_KEYBOARD is not a public handle. */
    return io_ok_uint32(0);
}

lean_object* allegro_al_is_display_haptic(uint64_t display) {
    if (display == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_display_haptic((ALLEGRO_DISPLAY *)u64_to_ptr(display)) ? 1u : 0u);
}

lean_object* allegro_al_is_touch_input_haptic(void) {
    /* ALLEGRO_TOUCH_INPUT is not a public handle. */
    return io_ok_uint32(0);
}

/* get haptic from device — only joystick and display have public handles */

lean_object* allegro_al_get_haptic_from_mouse(void) {
    return io_ok_uint64(0); /* not accessible */
}

lean_object* allegro_al_get_haptic_from_joystick(uint64_t joy) {
    if (joy == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(
        al_get_haptic_from_joystick((ALLEGRO_JOYSTICK *)u64_to_ptr(joy))));
}

lean_object* allegro_al_get_haptic_from_keyboard(void) {
    return io_ok_uint64(0); /* not accessible */
}

lean_object* allegro_al_get_haptic_from_display(uint64_t display) {
    if (display == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(
        al_get_haptic_from_display((ALLEGRO_DISPLAY *)u64_to_ptr(display))));
}

lean_object* allegro_al_get_haptic_from_touch_input(void) {
    return io_ok_uint64(0); /* not accessible */
}

/* release / query */

lean_object* allegro_al_release_haptic(uint64_t haptic) {
    if (haptic == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_release_haptic((ALLEGRO_HAPTIC *)u64_to_ptr(haptic)) ? 1u : 0u);
}

lean_object* allegro_al_is_haptic_active(uint64_t haptic) {
    if (haptic == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_haptic_active((ALLEGRO_HAPTIC *)u64_to_ptr(haptic)) ? 1u : 0u);
}

lean_object* allegro_al_get_haptic_capabilities(uint64_t haptic) {
    if (haptic == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_haptic_capabilities((ALLEGRO_HAPTIC *)u64_to_ptr(haptic)));
}

lean_object* allegro_al_is_haptic_capable(uint64_t haptic, uint32_t cap) {
    if (haptic == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_is_haptic_capable((ALLEGRO_HAPTIC *)u64_to_ptr(haptic), (int)cap) ? 1u : 0u);
}

/* gain / autocenter */

lean_object* allegro_al_set_haptic_gain(uint64_t haptic, double gain) {
    if (haptic == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_set_haptic_gain((ALLEGRO_HAPTIC *)u64_to_ptr(haptic), gain) ? 1u : 0u);
}

lean_object* allegro_al_get_haptic_gain(uint64_t haptic) {
    if (haptic == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(
        al_get_haptic_gain((ALLEGRO_HAPTIC *)u64_to_ptr(haptic))));
}

lean_object* allegro_al_set_haptic_autocenter(uint64_t haptic, double intensity) {
    if (haptic == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_set_haptic_autocenter((ALLEGRO_HAPTIC *)u64_to_ptr(haptic), intensity) ? 1u : 0u);
}

lean_object* allegro_al_get_haptic_autocenter(uint64_t haptic) {
    if (haptic == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(
        al_get_haptic_autocenter((ALLEGRO_HAPTIC *)u64_to_ptr(haptic))));
}

/* max effects */

lean_object* allegro_al_get_max_haptic_effects(uint64_t haptic) {
    if (haptic == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_max_haptic_effects((ALLEGRO_HAPTIC *)u64_to_ptr(haptic)));
}

/* rumble — simple vibration without building a full ALLEGRO_HAPTIC_EFFECT */

lean_object* allegro_al_rumble_haptic(uint64_t haptic, double intensity, double duration) {
    if (haptic == 0) return io_ok_uint64(0);
    ALLEGRO_HAPTIC_EFFECT_ID *id = (ALLEGRO_HAPTIC_EFFECT_ID *)malloc(sizeof(ALLEGRO_HAPTIC_EFFECT_ID));
    memset(id, 0, sizeof(*id));
    bool ok = al_rumble_haptic((ALLEGRO_HAPTIC *)u64_to_ptr(haptic), intensity, duration, id);
    if (!ok) { free(id); return io_ok_uint64(0); }
    return io_ok_uint64(ptr_to_u64(id));
}

/* effect lifecycle (via effect ID handle) */

lean_object* allegro_al_stop_haptic_effect(uint64_t effectId) {
    if (effectId == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_stop_haptic_effect((ALLEGRO_HAPTIC_EFFECT_ID *)u64_to_ptr(effectId)) ? 1u : 0u);
}

lean_object* allegro_al_is_haptic_effect_playing(uint64_t effectId) {
    if (effectId == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_is_haptic_effect_playing((ALLEGRO_HAPTIC_EFFECT_ID *)u64_to_ptr(effectId)) ? 1u : 0u);
}

lean_object* allegro_al_release_haptic_effect(uint64_t effectId) {
    if (effectId == 0) return io_ok_uint32(0);
    bool ok = al_release_haptic_effect((ALLEGRO_HAPTIC_EFFECT_ID *)u64_to_ptr(effectId));
    free(u64_to_ptr(effectId));
    return io_ok_uint32(ok ? 1u : 0u);
}
