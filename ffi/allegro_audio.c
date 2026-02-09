#include "allegro_ffi.h"
#include <allegro5/allegro_audio.h>
#include <allegro5/allegro_acodec.h>

/* ── Installation & codec ── */

lean_object* allegro_al_install_audio(void) {
    return io_ok_uint32(al_install_audio() ? 1u : 0u);
}

lean_object* allegro_al_uninstall_audio(void) {
    al_uninstall_audio();
    return io_ok_unit();
}

lean_object* allegro_al_is_audio_installed(void) {
    return io_ok_uint32(al_is_audio_installed() ? 1u : 0u);
}

lean_object* allegro_al_init_acodec_addon(void) {
    return io_ok_uint32(al_init_acodec_addon() ? 1u : 0u);
}

lean_object* allegro_al_reserve_samples(uint32_t count) {
    return io_ok_uint32(al_reserve_samples((int)count) ? 1u : 0u);
}

/* ── Sample ── */

lean_object* allegro_al_load_sample(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_SAMPLE *sample = al_load_sample(path);
    return io_ok_uint64(ptr_to_u64(sample));
}

lean_object* allegro_al_destroy_sample(uint64_t sample) {
    if (sample != 0)
        al_destroy_sample((ALLEGRO_SAMPLE *)u64_to_ptr(sample));
    return io_ok_unit();
}

lean_object* allegro_al_play_sample(uint64_t sample, double gain, double pan, double speed, uint32_t loop) {
    if (sample == 0)
        return io_ok_uint32(0);
    ALLEGRO_SAMPLE_ID id;
    bool ok = al_play_sample((ALLEGRO_SAMPLE *)u64_to_ptr(sample), (float)gain, (float)pan, (float)speed,
                             loop ? ALLEGRO_PLAYMODE_LOOP : ALLEGRO_PLAYMODE_ONCE, &id);
    return io_ok_uint32(ok ? 1u : 0u);
}

/* ── Play sample returning SAMPLE_ID packed as UInt64 ── */

static inline uint64_t pack_sample_id(const ALLEGRO_SAMPLE_ID *id) {
    uint64_t lo = (uint32_t)id->_index;
    uint64_t hi = (uint32_t)id->_id;
    return lo | (hi << 32);
}

static inline void unpack_sample_id(uint64_t packed, ALLEGRO_SAMPLE_ID *id) {
    id->_index = (int)(uint32_t)(packed & 0xFFFFFFFF);
    id->_id    = (int)(uint32_t)(packed >> 32);
}

lean_object* allegro_al_play_sample_with_id(uint64_t sample, double gain, double pan,
                                             double speed, uint32_t playmode) {
    if (sample == 0) return io_ok_uint64(0);
    ALLEGRO_SAMPLE_ID id;
    memset(&id, 0, sizeof(id));
    bool ok = al_play_sample((ALLEGRO_SAMPLE *)u64_to_ptr(sample),
                             (float)gain, (float)pan, (float)speed,
                             (ALLEGRO_PLAYMODE)playmode, &id);
    if (!ok) return io_ok_uint64(0);
    return io_ok_uint64(pack_sample_id(&id));
}

lean_object* allegro_al_stop_sample(uint64_t packed) {
    ALLEGRO_SAMPLE_ID id;
    unpack_sample_id(packed, &id);
    al_stop_sample(&id);
    return io_ok_unit();
}

lean_object* allegro_al_lock_sample_id(uint64_t packed) {
    ALLEGRO_SAMPLE_ID id;
    unpack_sample_id(packed, &id);
    ALLEGRO_SAMPLE_INSTANCE *inst = al_lock_sample_id(&id);
    return io_ok_uint64(ptr_to_u64(inst));
}

lean_object* allegro_al_unlock_sample_id(uint64_t packed) {
    ALLEGRO_SAMPLE_ID id;
    unpack_sample_id(packed, &id);
    al_unlock_sample_id(&id);
    return io_ok_unit();
}

lean_object* allegro_al_stop_samples(void) {
    al_stop_samples();
    return io_ok_unit();
}

lean_object* allegro_al_get_sample_frequency(uint64_t spl) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_sample_frequency((ALLEGRO_SAMPLE *)u64_to_ptr(spl)));
}

lean_object* allegro_al_get_sample_length(uint64_t spl) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_sample_length((ALLEGRO_SAMPLE *)u64_to_ptr(spl)));
}

lean_object* allegro_al_get_sample_depth(uint64_t spl) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_sample_depth((ALLEGRO_SAMPLE *)u64_to_ptr(spl)));
}

lean_object* allegro_al_get_sample_channels(uint64_t spl) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_sample_channels((ALLEGRO_SAMPLE *)u64_to_ptr(spl)));
}

/* ── Sample instance ── */

lean_object* allegro_al_create_sample_instance(uint64_t sample) {
    if (sample == 0) return io_ok_uint64(0);
    ALLEGRO_SAMPLE_INSTANCE *inst = al_create_sample_instance((ALLEGRO_SAMPLE *)u64_to_ptr(sample));
    return io_ok_uint64(ptr_to_u64(inst));
}

lean_object* allegro_al_destroy_sample_instance(uint64_t inst) {
    if (inst != 0)
        al_destroy_sample_instance((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst));
    return io_ok_unit();
}

lean_object* allegro_al_play_sample_instance(uint64_t inst) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_play_sample_instance((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst)) ? 1u : 0u);
}

lean_object* allegro_al_stop_sample_instance(uint64_t inst) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_stop_sample_instance((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst)) ? 1u : 0u);
}

lean_object* allegro_al_get_sample_instance_playing(uint64_t inst) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_sample_instance_playing((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst)) ? 1u : 0u);
}

lean_object* allegro_al_set_sample_instance_playing(uint64_t inst, uint32_t val) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_sample_instance_playing((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst), val != 0) ? 1u : 0u);
}

lean_object* allegro_al_get_sample_instance_gain(uint64_t inst) {
    if (inst == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double g = al_get_sample_instance_gain((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst));
    return lean_io_result_mk_ok(lean_box_float(g));
}

lean_object* allegro_al_set_sample_instance_gain(uint64_t inst, double val) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_sample_instance_gain((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst), (float)val) ? 1u : 0u);
}

lean_object* allegro_al_get_sample_instance_pan(uint64_t inst) {
    if (inst == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double p = al_get_sample_instance_pan((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst));
    return lean_io_result_mk_ok(lean_box_float(p));
}

lean_object* allegro_al_set_sample_instance_pan(uint64_t inst, double val) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_sample_instance_pan((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst), (float)val) ? 1u : 0u);
}

lean_object* allegro_al_get_sample_instance_speed(uint64_t inst) {
    if (inst == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double s = al_get_sample_instance_speed((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst));
    return lean_io_result_mk_ok(lean_box_float(s));
}

lean_object* allegro_al_set_sample_instance_speed(uint64_t inst, double val) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_sample_instance_speed((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst), (float)val) ? 1u : 0u);
}

lean_object* allegro_al_get_sample_instance_position(uint64_t inst) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_sample_instance_position((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst)));
}

lean_object* allegro_al_set_sample_instance_position(uint64_t inst, uint32_t val) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_sample_instance_position((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst), val) ? 1u : 0u);
}

lean_object* allegro_al_get_sample_instance_length(uint64_t inst) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_sample_instance_length((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst)));
}

lean_object* allegro_al_get_sample_instance_playmode(uint64_t inst) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_sample_instance_playmode((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst)));
}

lean_object* allegro_al_set_sample_instance_playmode(uint64_t inst, uint32_t val) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_sample_instance_playmode((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst), (ALLEGRO_PLAYMODE)val) ? 1u : 0u);
}

lean_object* allegro_al_detach_sample_instance(uint64_t inst) {
    if (inst == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_detach_sample_instance((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst)) ? 1u : 0u);
}

lean_object* allegro_al_attach_sample_instance_to_mixer(uint64_t inst, uint64_t mixer) {
    if (inst == 0 || mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_attach_sample_instance_to_mixer(
        (ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(inst),
        (ALLEGRO_MIXER *)u64_to_ptr(mixer)) ? 1u : 0u);
}

/* ── Audio stream ── */

lean_object* allegro_al_load_audio_stream(lean_object* pathObj, uint32_t bufCount, uint32_t samples) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_AUDIO_STREAM *stream = al_load_audio_stream(path, (size_t)bufCount, (unsigned int)samples);
    return io_ok_uint64(ptr_to_u64(stream));
}

lean_object* allegro_al_play_audio_stream(lean_object* pathObj) {
    const char *path = lean_string_cstr(pathObj);
    ALLEGRO_AUDIO_STREAM *stream = al_play_audio_stream(path);
    return io_ok_uint64(ptr_to_u64(stream));
}

lean_object* allegro_al_destroy_audio_stream(uint64_t stream) {
    if (stream != 0)
        al_destroy_audio_stream((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return io_ok_unit();
}

lean_object* allegro_al_drain_audio_stream(uint64_t stream) {
    if (stream != 0)
        al_drain_audio_stream((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return io_ok_unit();
}

lean_object* allegro_al_rewind_audio_stream(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_rewind_audio_stream((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_stream_playing(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_audio_stream_playing((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)) ? 1u : 0u);
}

lean_object* allegro_al_set_audio_stream_playing(uint64_t stream, uint32_t val) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_audio_stream_playing((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream), val != 0) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_stream_gain(uint64_t stream) {
    if (stream == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double g = al_get_audio_stream_gain((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return lean_io_result_mk_ok(lean_box_float(g));
}

lean_object* allegro_al_set_audio_stream_gain(uint64_t stream, double val) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_audio_stream_gain((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream), (float)val) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_stream_pan(uint64_t stream) {
    if (stream == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double p = al_get_audio_stream_pan((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return lean_io_result_mk_ok(lean_box_float(p));
}

lean_object* allegro_al_set_audio_stream_pan(uint64_t stream, double val) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_audio_stream_pan((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream), (float)val) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_stream_speed(uint64_t stream) {
    if (stream == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double s = al_get_audio_stream_speed((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return lean_io_result_mk_ok(lean_box_float(s));
}

lean_object* allegro_al_set_audio_stream_speed(uint64_t stream, double val) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_audio_stream_speed((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream), (float)val) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_stream_playmode(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_audio_stream_playmode((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)));
}

lean_object* allegro_al_set_audio_stream_playmode(uint64_t stream, uint32_t val) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_audio_stream_playmode((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream), (ALLEGRO_PLAYMODE)val) ? 1u : 0u);
}

lean_object* allegro_al_seek_audio_stream_secs(uint64_t stream, double time) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_seek_audio_stream_secs((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream), time) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_stream_position_secs(uint64_t stream) {
    if (stream == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double t = al_get_audio_stream_position_secs((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return lean_io_result_mk_ok(lean_box_float(t));
}

lean_object* allegro_al_get_audio_stream_length_secs(uint64_t stream) {
    if (stream == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double t = al_get_audio_stream_length_secs((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return lean_io_result_mk_ok(lean_box_float(t));
}

lean_object* allegro_al_set_audio_stream_loop_secs(uint64_t stream, double start, double end_) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_audio_stream_loop_secs((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream), start, end_) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_stream_event_source(uint64_t stream) {
    if (stream == 0) return io_ok_uint64(0);
    ALLEGRO_EVENT_SOURCE *src = al_get_audio_stream_event_source((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return io_ok_uint64(ptr_to_u64(src));
}

lean_object* allegro_al_attach_audio_stream_to_mixer(uint64_t stream, uint64_t mixer) {
    if (stream == 0 || mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_attach_audio_stream_to_mixer(
        (ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream),
        (ALLEGRO_MIXER *)u64_to_ptr(mixer)) ? 1u : 0u);
}

lean_object* allegro_al_detach_audio_stream(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_detach_audio_stream((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)) ? 1u : 0u);
}

/* ── Mixer ── */

lean_object* allegro_al_create_mixer(uint32_t freq, uint32_t depth, uint32_t chan_conf) {
    ALLEGRO_MIXER *m = al_create_mixer(freq, (ALLEGRO_AUDIO_DEPTH)depth, (ALLEGRO_CHANNEL_CONF)chan_conf);
    return io_ok_uint64(ptr_to_u64(m));
}

lean_object* allegro_al_destroy_mixer(uint64_t mixer) {
    if (mixer != 0)
        al_destroy_mixer((ALLEGRO_MIXER *)u64_to_ptr(mixer));
    return io_ok_unit();
}

lean_object* allegro_al_get_default_mixer(void) {
    return io_ok_uint64(ptr_to_u64(al_get_default_mixer()));
}

lean_object* allegro_al_set_default_mixer(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_default_mixer((ALLEGRO_MIXER *)u64_to_ptr(mixer)) ? 1u : 0u);
}

lean_object* allegro_al_restore_default_mixer(void) {
    return io_ok_uint32(al_restore_default_mixer() ? 1u : 0u);
}

lean_object* allegro_al_attach_mixer_to_mixer(uint64_t sub, uint64_t master) {
    if (sub == 0 || master == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_attach_mixer_to_mixer(
        (ALLEGRO_MIXER *)u64_to_ptr(sub),
        (ALLEGRO_MIXER *)u64_to_ptr(master)) ? 1u : 0u);
}

lean_object* allegro_al_detach_mixer(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_detach_mixer((ALLEGRO_MIXER *)u64_to_ptr(mixer)) ? 1u : 0u);
}

lean_object* allegro_al_get_mixer_frequency(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_mixer_frequency((ALLEGRO_MIXER *)u64_to_ptr(mixer)));
}

lean_object* allegro_al_set_mixer_frequency(uint64_t mixer, uint32_t val) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_mixer_frequency((ALLEGRO_MIXER *)u64_to_ptr(mixer), val) ? 1u : 0u);
}

lean_object* allegro_al_get_mixer_gain(uint64_t mixer) {
    if (mixer == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    double g = al_get_mixer_gain((ALLEGRO_MIXER *)u64_to_ptr(mixer));
    return lean_io_result_mk_ok(lean_box_float(g));
}

lean_object* allegro_al_set_mixer_gain(uint64_t mixer, double val) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_mixer_gain((ALLEGRO_MIXER *)u64_to_ptr(mixer), (float)val) ? 1u : 0u);
}

lean_object* allegro_al_get_mixer_quality(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_mixer_quality((ALLEGRO_MIXER *)u64_to_ptr(mixer)));
}

lean_object* allegro_al_set_mixer_quality(uint64_t mixer, uint32_t val) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_mixer_quality((ALLEGRO_MIXER *)u64_to_ptr(mixer), (ALLEGRO_MIXER_QUALITY)val) ? 1u : 0u);
}

lean_object* allegro_al_get_mixer_playing(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_mixer_playing((ALLEGRO_MIXER *)u64_to_ptr(mixer)) ? 1u : 0u);
}

lean_object* allegro_al_set_mixer_playing(uint64_t mixer, uint32_t val) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_mixer_playing((ALLEGRO_MIXER *)u64_to_ptr(mixer), val != 0) ? 1u : 0u);
}

/* ── Voice ── */

lean_object* allegro_al_create_voice(uint32_t freq, uint32_t depth, uint32_t chan_conf) {
    ALLEGRO_VOICE *v = al_create_voice(freq, (ALLEGRO_AUDIO_DEPTH)depth, (ALLEGRO_CHANNEL_CONF)chan_conf);
    return io_ok_uint64(ptr_to_u64(v));
}

lean_object* allegro_al_destroy_voice(uint64_t voice) {
    if (voice != 0)
        al_destroy_voice((ALLEGRO_VOICE *)u64_to_ptr(voice));
    return io_ok_unit();
}

lean_object* allegro_al_attach_mixer_to_voice(uint64_t mixer, uint64_t voice) {
    if (mixer == 0 || voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_attach_mixer_to_voice(
        (ALLEGRO_MIXER *)u64_to_ptr(mixer),
        (ALLEGRO_VOICE *)u64_to_ptr(voice)) ? 1u : 0u);
}

lean_object* allegro_al_detach_voice(uint64_t voice) {
    if (voice != 0)
        al_detach_voice((ALLEGRO_VOICE *)u64_to_ptr(voice));
    return io_ok_unit();
}

lean_object* allegro_al_get_voice_frequency(uint64_t voice) {
    if (voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_voice_frequency((ALLEGRO_VOICE *)u64_to_ptr(voice)));
}

lean_object* allegro_al_get_voice_playing(uint64_t voice) {
    if (voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_voice_playing((ALLEGRO_VOICE *)u64_to_ptr(voice)) ? 1u : 0u);
}

lean_object* allegro_al_set_voice_playing(uint64_t voice, uint32_t val) {
    if (voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_voice_playing((ALLEGRO_VOICE *)u64_to_ptr(voice), val != 0) ? 1u : 0u);
}

lean_object* allegro_al_get_default_voice(void) {
    return io_ok_uint64(ptr_to_u64((void*)al_get_default_voice()));
}

/* ── Device enumeration ── */

lean_object* allegro_al_get_num_audio_output_devices(void) {
    return io_ok_uint32((uint32_t)al_get_num_audio_output_devices());
}

lean_object* allegro_al_get_audio_device_name(uint32_t index) {
    const ALLEGRO_AUDIO_DEVICE *dev = al_get_audio_output_device((int)index);
    if (!dev) return io_ok_string("(unknown)");
    const char *name = al_get_audio_device_name(dev);
    return io_ok_string(name);
}

/* ── Version & utility ── */

lean_object* allegro_al_get_allegro_audio_version(void) {
    return io_ok_uint32(al_get_allegro_audio_version());
}

lean_object* allegro_al_get_channel_count(uint32_t conf) {
    return io_ok_uint32((uint32_t)al_get_channel_count((ALLEGRO_CHANNEL_CONF)conf));
}

lean_object* allegro_al_get_audio_depth_size(uint32_t depth) {
    return io_ok_uint32((uint32_t)al_get_audio_depth_size((ALLEGRO_AUDIO_DEPTH)depth));
}

lean_object* allegro_al_get_allegro_acodec_version(void) {
    return io_ok_uint32(al_get_allegro_acodec_version());
}

lean_object* allegro_al_is_acodec_addon_initialized(void) {
    return io_ok_uint32(al_is_acodec_addon_initialized() ? 1u : 0u);
}

/* ── Sample instance getters ── */

lean_object* allegro_al_get_sample_instance_frequency(uint64_t spl) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_sample_instance_frequency((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl)));
}

lean_object* allegro_al_get_sample_instance_channels(uint64_t spl) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_sample_instance_channels((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl)));
}

lean_object* allegro_al_get_sample_instance_depth(uint64_t spl) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_sample_instance_depth((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl)));
}

lean_object* allegro_al_get_sample_instance_attached(uint64_t spl) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_sample_instance_attached((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl)) ? 1u : 0u);
}

lean_object* allegro_al_get_sample_instance_time(uint64_t spl) {
    if (spl == 0) return lean_io_result_mk_ok(lean_box_float(0.0));
    return lean_io_result_mk_ok(lean_box_float(
        (double)al_get_sample_instance_time((ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl))));
}

lean_object* allegro_al_set_sample_instance_length(uint64_t spl, uint32_t val) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_sample_instance_length(
        (ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl), val) ? 1u : 0u);
}

/* ── Audio stream getters ── */

lean_object* allegro_al_get_audio_stream_frequency(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_audio_stream_frequency((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)));
}

lean_object* allegro_al_get_audio_stream_length(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_audio_stream_length((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)));
}

lean_object* allegro_al_get_audio_stream_fragments(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_audio_stream_fragments((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)));
}

lean_object* allegro_al_get_available_audio_stream_fragments(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_available_audio_stream_fragments((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)));
}

lean_object* allegro_al_get_audio_stream_channels(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_audio_stream_channels((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)));
}

lean_object* allegro_al_get_audio_stream_depth(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_audio_stream_depth((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)));
}

lean_object* allegro_al_get_audio_stream_attached(uint64_t stream) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_audio_stream_attached((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_stream_played_samples(uint64_t stream) {
    if (stream == 0) return io_ok_uint64(0);
    return io_ok_uint64(al_get_audio_stream_played_samples((ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream)));
}

/* ── Mixer getters ── */

lean_object* allegro_al_get_mixer_channels(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_mixer_channels((ALLEGRO_MIXER *)u64_to_ptr(mixer)));
}

lean_object* allegro_al_get_mixer_depth(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_mixer_depth((ALLEGRO_MIXER *)u64_to_ptr(mixer)));
}

lean_object* allegro_al_get_mixer_attached(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_mixer_attached((ALLEGRO_MIXER *)u64_to_ptr(mixer)) ? 1u : 0u);
}

lean_object* allegro_al_mixer_has_attachments(uint64_t mixer) {
    if (mixer == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_mixer_has_attachments((ALLEGRO_MIXER *)u64_to_ptr(mixer)) ? 1u : 0u);
}

/* ── Voice getters/setters ── */

lean_object* allegro_al_get_voice_position(uint64_t voice) {
    if (voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_get_voice_position((ALLEGRO_VOICE *)u64_to_ptr(voice)));
}

lean_object* allegro_al_set_voice_position(uint64_t voice, uint32_t val) {
    if (voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_voice_position((ALLEGRO_VOICE *)u64_to_ptr(voice), val) ? 1u : 0u);
}

lean_object* allegro_al_get_voice_channels(uint64_t voice) {
    if (voice == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_voice_channels((ALLEGRO_VOICE *)u64_to_ptr(voice)));
}

lean_object* allegro_al_get_voice_depth(uint64_t voice) {
    if (voice == 0) return io_ok_uint32(0);
    return io_ok_uint32((uint32_t)al_get_voice_depth((ALLEGRO_VOICE *)u64_to_ptr(voice)));
}

lean_object* allegro_al_voice_has_attachments(uint64_t voice) {
    if (voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_voice_has_attachments((ALLEGRO_VOICE *)u64_to_ptr(voice)) ? 1u : 0u);
}

/* ── Default voice setter ── */

lean_object* allegro_al_set_default_voice(uint64_t voice) {
    al_set_default_voice(voice != 0 ? (ALLEGRO_VOICE *)u64_to_ptr(voice) : NULL);
    return io_ok_unit();
}

/* ── Sample save / identify ── */

lean_object* allegro_al_save_sample(b_lean_obj_arg pathObj, uint64_t sample) {
    if (sample == 0) return io_ok_uint32(0);
    const char *path = lean_string_cstr(pathObj);
    bool ok = al_save_sample(path, (ALLEGRO_SAMPLE *)u64_to_ptr(sample));
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_identify_sample(b_lean_obj_arg pathObj) {
    const char *path = lean_string_cstr(pathObj);
    const char *type = al_identify_sample(path);
    return io_ok_string(type);
}

/* ── Attach to voice ── */

lean_object* allegro_al_attach_sample_instance_to_voice(uint64_t spl, uint64_t voice) {
    if (spl == 0 || voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_attach_sample_instance_to_voice(
        (ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl),
        (ALLEGRO_VOICE *)u64_to_ptr(voice)) ? 1u : 0u);
}

lean_object* allegro_al_attach_audio_stream_to_voice(uint64_t stream, uint64_t voice) {
    if (stream == 0 || voice == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_attach_audio_stream_to_voice(
        (ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream),
        (ALLEGRO_VOICE *)u64_to_ptr(voice)) ? 1u : 0u);
}

/* ── Sample data access ── */

lean_object* allegro_al_get_sample(uint64_t spl) {
    if (spl == 0) return io_ok_uint64(0);
    ALLEGRO_SAMPLE *s = al_get_sample(
        (ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl));
    return io_ok_uint64(ptr_to_u64(s));
}

lean_object* allegro_al_set_sample(uint64_t spl, uint64_t data) {
    if (spl == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_sample(
        (ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl),
        (ALLEGRO_SAMPLE *)u64_to_ptr(data)) ? 1u : 0u);
}

/* ── Audio recorder (UNSTABLE) ── */

lean_object* allegro_al_create_audio_recorder(uint32_t fragmentCount,
                                               uint32_t samples,
                                               uint32_t freq,
                                               uint32_t depth,
                                               uint32_t chanConf) {
    ALLEGRO_AUDIO_RECORDER *rec = al_create_audio_recorder(
        (size_t)fragmentCount, (unsigned int)samples, (unsigned int)freq,
        (ALLEGRO_AUDIO_DEPTH)depth, (ALLEGRO_CHANNEL_CONF)chanConf);
    return io_ok_uint64(ptr_to_u64(rec));
}

lean_object* allegro_al_start_audio_recorder(uint64_t rec) {
    if (rec == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_start_audio_recorder(
        (ALLEGRO_AUDIO_RECORDER *)u64_to_ptr(rec)) ? 1u : 0u);
}

lean_object* allegro_al_stop_audio_recorder(uint64_t rec) {
    if (rec != 0) {
        al_stop_audio_recorder((ALLEGRO_AUDIO_RECORDER *)u64_to_ptr(rec));
    }
    return io_ok_unit();
}

lean_object* allegro_al_is_audio_recorder_recording(uint64_t rec) {
    if (rec == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_is_audio_recorder_recording(
        (ALLEGRO_AUDIO_RECORDER *)u64_to_ptr(rec)) ? 1u : 0u);
}

lean_object* allegro_al_get_audio_recorder_event_source(uint64_t rec) {
    if (rec == 0) return io_ok_uint64(0);
    return io_ok_uint64(ptr_to_u64(al_get_audio_recorder_event_source(
        (ALLEGRO_AUDIO_RECORDER *)u64_to_ptr(rec))));
}

lean_object* allegro_al_destroy_audio_recorder(uint64_t rec) {
    if (rec != 0) {
        al_destroy_audio_recorder((ALLEGRO_AUDIO_RECORDER *)u64_to_ptr(rec));
    }
    return io_ok_unit();
}

/* ── Create audio stream from parameters (not from file) ── */

lean_object* allegro_al_create_audio_stream(uint32_t bufferCount,
                                             uint32_t samples,
                                             uint32_t freq,
                                             uint32_t depth,
                                             uint32_t chanConf) {
    ALLEGRO_AUDIO_STREAM *s = al_create_audio_stream(
        (size_t)bufferCount, (unsigned int)samples, (unsigned int)freq,
        (ALLEGRO_AUDIO_DEPTH)depth, (ALLEGRO_CHANNEL_CONF)chanConf);
    return io_ok_uint64(ptr_to_u64(s));
}

/* ── Create sample from raw buffer ── */

lean_object* allegro_al_create_sample(uint64_t buf, uint32_t samples,
                                       uint32_t freq, uint32_t depth,
                                       uint32_t chanConf, uint32_t freeBuf) {
    ALLEGRO_SAMPLE *s = al_create_sample(
        u64_to_ptr(buf), (unsigned int)samples, (unsigned int)freq,
        (ALLEGRO_AUDIO_DEPTH)depth, (ALLEGRO_CHANNEL_CONF)chanConf,
        freeBuf ? true : false);
    return io_ok_uint64(ptr_to_u64(s));
}

/* ── Raw sample data access ── */

lean_object* allegro_al_get_sample_data(uint64_t sample) {
    if (sample == 0) return io_ok_uint64(0);
    void *data = al_get_sample_data((ALLEGRO_SAMPLE *)u64_to_ptr(sample));
    return io_ok_uint64(ptr_to_u64(data));
}

/* ── Fill silence ── */

lean_object* allegro_al_fill_silence(uint64_t buf, uint32_t samples,
                                      uint32_t depth, uint32_t chanConf) {
    if (buf != 0) {
        al_fill_silence(u64_to_ptr(buf), (unsigned int)samples,
                        (ALLEGRO_AUDIO_DEPTH)depth,
                        (ALLEGRO_CHANNEL_CONF)chanConf);
    }
    return io_ok_unit();
}

/* ── Audio stream fragment access ── */

lean_object* allegro_al_get_audio_stream_fragment(uint64_t stream) {
    if (stream == 0) return io_ok_uint64(0);
    void *frag = al_get_audio_stream_fragment(
        (const ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream));
    return io_ok_uint64(ptr_to_u64(frag));
}

lean_object* allegro_al_set_audio_stream_fragment(uint64_t stream, uint64_t val) {
    if (stream == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_set_audio_stream_fragment(
        (ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream),
        u64_to_ptr(val)) ? 1u : 0u);
}

/* ── Channel matrix (UNSTABLE) ── */

lean_object* allegro_al_set_sample_instance_channel_matrix(uint64_t spl, b_lean_obj_arg ba) {
    if (spl == 0) return io_ok_uint32(0);
    const float *matrix = (const float *)lean_sarray_cptr(ba);
    return io_ok_uint32(al_set_sample_instance_channel_matrix(
        (ALLEGRO_SAMPLE_INSTANCE *)u64_to_ptr(spl), matrix) ? 1u : 0u);
}

lean_object* allegro_al_set_audio_stream_channel_matrix(uint64_t stream, b_lean_obj_arg ba) {
    if (stream == 0) return io_ok_uint32(0);
    const float *matrix = (const float *)lean_sarray_cptr(ba);
    return io_ok_uint32(al_set_audio_stream_channel_matrix(
        (ALLEGRO_AUDIO_STREAM *)u64_to_ptr(stream), matrix) ? 1u : 0u);
}

/* ── File-based audio I/O ── */

lean_object* allegro_al_load_sample_f(uint64_t fp, lean_object* identObj) {
    if (fp == 0) { lean_dec_ref(identObj); return io_ok_uint64(0); }
    const char *ident = lean_string_cstr(identObj);
    ALLEGRO_SAMPLE *spl = al_load_sample_f(
        (ALLEGRO_FILE *)u64_to_ptr(fp), ident);
    lean_dec_ref(identObj);
    return io_ok_uint64(ptr_to_u64(spl));
}

lean_object* allegro_al_save_sample_f(uint64_t fp, lean_object* identObj, uint64_t spl) {
    if (fp == 0 || spl == 0) { lean_dec_ref(identObj); return io_ok_uint32(0); }
    const char *ident = lean_string_cstr(identObj);
    bool ok = al_save_sample_f((ALLEGRO_FILE *)u64_to_ptr(fp), ident,
                                (ALLEGRO_SAMPLE *)u64_to_ptr(spl));
    lean_dec_ref(identObj);
    return io_ok_uint32(ok ? 1u : 0u);
}

lean_object* allegro_al_identify_sample_f(uint64_t fp) {
    if (fp == 0) return io_ok_string("");
    const char *ident = al_identify_sample_f((ALLEGRO_FILE *)u64_to_ptr(fp));
    return io_ok_string(ident ? ident : "");
}

lean_object* allegro_al_load_audio_stream_f(uint64_t fp, lean_object* identObj,
                                             uint32_t bufferCount, uint32_t samples) {
    if (fp == 0) { lean_dec_ref(identObj); return io_ok_uint64(0); }
    const char *ident = lean_string_cstr(identObj);
    ALLEGRO_AUDIO_STREAM *stream = al_load_audio_stream_f(
        (ALLEGRO_FILE *)u64_to_ptr(fp), ident,
        (size_t)bufferCount, (unsigned int)samples);
    lean_dec_ref(identObj);
    return io_ok_uint64(ptr_to_u64(stream));
}

lean_object* allegro_al_play_audio_stream_f(uint64_t fp, lean_object* identObj) {
    if (fp == 0) { lean_dec_ref(identObj); return io_ok_uint64(0); }
    const char *ident = lean_string_cstr(identObj);
    ALLEGRO_AUDIO_STREAM *stream = al_play_audio_stream_f(
        (ALLEGRO_FILE *)u64_to_ptr(fp), ident);
    lean_dec_ref(identObj);
    return io_ok_uint64(ptr_to_u64(stream));
}
