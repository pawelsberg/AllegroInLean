#include "allegro_ffi.h"
#include <allegro5/allegro.h>
#include <allegro5/allegro_audio.h>
#include <allegro5/allegro_video.h>

/* ── Addon lifecycle ── */

lean_object* allegro_al_init_video_addon(void) {
    return io_ok_uint32(al_init_video_addon() ? 1u : 0u);
}

lean_object* allegro_al_is_video_addon_initialized(void) {
    return io_ok_uint32(al_is_video_addon_initialized() ? 1u : 0u);
}

lean_object* allegro_al_shutdown_video_addon(void) {
    al_shutdown_video_addon();
    return io_ok_unit();
}

lean_object* allegro_al_get_allegro_video_version(void) {
    return io_ok_uint32(al_get_allegro_video_version());
}

/* ── Video open / close ── */

lean_object* allegro_al_open_video(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_VIDEO *v = al_open_video(path);
    return io_ok_uint64(ptr_to_u64(v));
}

lean_object* allegro_al_close_video(uint64_t video) {
    if (video != 0) {
        al_close_video((ALLEGRO_VIDEO *)u64_to_ptr(video));
    }
    return io_ok_unit();
}

/* ── Video playback control ── */

lean_object* allegro_al_start_video(uint64_t video, uint64_t mixer) {
    if (video != 0 && mixer != 0) {
        al_start_video((ALLEGRO_VIDEO *)u64_to_ptr(video),
                       (ALLEGRO_MIXER *)u64_to_ptr(mixer));
    }
    return io_ok_unit();
}

lean_object* allegro_al_start_video_with_voice(uint64_t video, uint64_t voice) {
    if (video != 0 && voice != 0) {
        al_start_video_with_voice((ALLEGRO_VIDEO *)u64_to_ptr(video),
                                  (ALLEGRO_VOICE *)u64_to_ptr(voice));
    }
    return io_ok_unit();
}

lean_object* allegro_al_set_video_playing(uint64_t video, uint32_t playing) {
    if (video != 0) {
        al_set_video_playing((ALLEGRO_VIDEO *)u64_to_ptr(video), playing != 0);
    }
    return io_ok_unit();
}

lean_object* allegro_al_is_video_playing(uint64_t video) {
    if (video == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_video_playing((ALLEGRO_VIDEO *)u64_to_ptr(video)) ? 1u : 0u);
}

lean_object* allegro_al_seek_video(uint64_t video, double pos) {
    if (video == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_seek_video((ALLEGRO_VIDEO *)u64_to_ptr(video), pos) ? 1u : 0u);
}

/* ── Video queries ── */

lean_object* allegro_al_get_video_event_source(uint64_t video) {
    if (video == 0) return io_ok_uint64(0);
    ALLEGRO_EVENT_SOURCE *es = al_get_video_event_source((ALLEGRO_VIDEO *)u64_to_ptr(video));
    return io_ok_uint64(ptr_to_u64(es));
}

lean_object* allegro_al_get_video_audio_rate(uint64_t video) {
    if (video == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double r = al_get_video_audio_rate((ALLEGRO_VIDEO *)u64_to_ptr(video));
    return lean_io_result_mk_ok(lean_box_float(r));
}

lean_object* allegro_al_get_video_fps(uint64_t video) {
    if (video == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double fps = al_get_video_fps((ALLEGRO_VIDEO *)u64_to_ptr(video));
    return lean_io_result_mk_ok(lean_box_float(fps));
}

lean_object* allegro_al_get_video_scaled_width(uint64_t video) {
    if (video == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    float w = al_get_video_scaled_width((ALLEGRO_VIDEO *)u64_to_ptr(video));
    return lean_io_result_mk_ok(lean_box_float((double)w));
}

lean_object* allegro_al_get_video_scaled_height(uint64_t video) {
    if (video == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    float h = al_get_video_scaled_height((ALLEGRO_VIDEO *)u64_to_ptr(video));
    return lean_io_result_mk_ok(lean_box_float((double)h));
}

lean_object* allegro_al_get_video_frame(uint64_t video) {
    if (video == 0) return io_ok_uint64(0);
    ALLEGRO_BITMAP *bmp = al_get_video_frame((ALLEGRO_VIDEO *)u64_to_ptr(video));
    return io_ok_uint64(ptr_to_u64(bmp));
}

lean_object* allegro_al_get_video_position(uint64_t video, uint32_t which) {
    if (video == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double pos = al_get_video_position((ALLEGRO_VIDEO *)u64_to_ptr(video), (ALLEGRO_VIDEO_POSITION_TYPE)which);
    return lean_io_result_mk_ok(lean_box_float(pos));
}

/* ── Video identification ── */

lean_object* allegro_al_identify_video(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    const char *ident = al_identify_video(path);
    return io_ok_string(ident);
}

/* ── File-based video I/O ── */

lean_object* allegro_al_open_video_f(uint64_t fp, lean_object* identObj) {
    if (fp == 0) { lean_dec_ref(identObj); return io_ok_uint64(0); }
    const char *ident = lean_string_cstr(identObj);
    ALLEGRO_VIDEO *v = al_open_video_f(
        (ALLEGRO_FILE *)u64_to_ptr(fp), ident);
    lean_dec_ref(identObj);
    return io_ok_uint64(ptr_to_u64(v));
}

lean_object* allegro_al_identify_video_f(uint64_t fp) {
    if (fp == 0) return io_ok_string("");
    const char *ident = al_identify_video_f((ALLEGRO_FILE *)u64_to_ptr(fp));
    return io_ok_string(ident ? ident : "");
}
