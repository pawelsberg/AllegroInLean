#include "allegro_ffi.h"
#include <allegro5/allegro.h>

/* ── Lifecycle ── */

lean_object* allegro_al_ustr_new(b_lean_obj_arg textObj) {
    const char *text = lean_string_cstr(textObj);
    ALLEGRO_USTR *ustr = al_ustr_new(text);
    return io_ok_uint64(ptr_to_u64(ustr));
}

lean_object* allegro_al_ustr_new_from_buffer(b_lean_obj_arg textObj, uint32_t size) {
    const char *text = lean_string_cstr(textObj);
    /* Clamp size to actual string length to prevent over-read */
    size_t actual = strlen(text);
    size_t clamped = (size_t)size > actual ? actual : (size_t)size;
    ALLEGRO_USTR *ustr = al_ustr_new_from_buffer(text, clamped);
    return io_ok_uint64(ptr_to_u64(ustr));
}

lean_object* allegro_al_ustr_free(uint64_t ustr) {
    if (ustr != 0) {
        al_ustr_free((ALLEGRO_USTR *)u64_to_ptr(ustr));
    }
    return io_ok_unit();
}

lean_object* allegro_al_cstr(uint64_t ustr) {
    if (ustr == 0) {
        return io_ok_string("");
    }
    return io_ok_string(al_cstr((ALLEGRO_USTR *)u64_to_ptr(ustr)));
}

lean_object* allegro_al_ustr_size(uint64_t ustr) {
    if (ustr == 0) {
        return io_ok_uint64(0);
    }
    return io_ok_uint64((uint64_t)al_ustr_size((ALLEGRO_USTR *)u64_to_ptr(ustr)));
}

lean_object* allegro_al_ustr_length(uint64_t ustr) {
    if (ustr == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_ustr_length((ALLEGRO_USTR *)u64_to_ptr(ustr)));
}

lean_object* allegro_al_ustr_dup(uint64_t ustr) {
    if (ustr == 0) {
        return io_ok_uint64(0);
    }
    return io_ok_uint64(ptr_to_u64(al_ustr_dup((ALLEGRO_USTR *)u64_to_ptr(ustr))));
}

lean_object* allegro_al_ustr_append(uint64_t ustr, uint64_t other) {
    if (ustr != 0 && other != 0) {
        al_ustr_append((ALLEGRO_USTR *)u64_to_ptr(ustr), (ALLEGRO_USTR *)u64_to_ptr(other));
    }
    return io_ok_unit();
}

lean_object* allegro_al_ustr_append_cstr(uint64_t ustr, b_lean_obj_arg textObj) {
    if (ustr != 0) {
        const char *text = lean_string_cstr(textObj);
        al_ustr_append_cstr((ALLEGRO_USTR *)u64_to_ptr(ustr), text);
    }
    return io_ok_unit();
}

lean_object* allegro_al_ustr_insert_cstr(uint64_t ustr, uint32_t offset, b_lean_obj_arg textObj) {
    if (ustr != 0) {
        const char *text = lean_string_cstr(textObj);
        al_ustr_insert_cstr((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)offset, text);
    }
    return io_ok_unit();
}

lean_object* allegro_al_ustr_remove_range(uint64_t ustr, uint32_t start, uint32_t end) {
    if (ustr != 0) {
        al_ustr_remove_range((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)start, (int)end);
    }
    return io_ok_unit();
}

lean_object* allegro_al_ustr_get(uint64_t ustr, uint32_t index) {
    if (ustr == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_ustr_get((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)index));
}

lean_object* allegro_al_ustr_offset(uint64_t ustr, uint32_t index) {
    if (ustr == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32((uint32_t)al_ustr_offset((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)index));
}

/* ── Comparison ── */

lean_object* allegro_al_ustr_equal(uint64_t us1, uint64_t us2) {
    if (us1 == 0 || us2 == 0) return io_ok_uint32(us1 == us2 ? 1u : 0u);
    return io_ok_uint32(
        al_ustr_equal((const ALLEGRO_USTR *)u64_to_ptr(us1),
                      (const ALLEGRO_USTR *)u64_to_ptr(us2)) ? 1u : 0u);
}

lean_object* allegro_al_ustr_compare(uint64_t us1, uint64_t us2) {
    if (us1 == 0 && us2 == 0) return io_ok_uint32(0);
    if (us1 == 0) return io_ok_uint32((uint32_t)-1);
    if (us2 == 0) return io_ok_uint32(1);
    int r = al_ustr_compare((const ALLEGRO_USTR *)u64_to_ptr(us1),
                            (const ALLEGRO_USTR *)u64_to_ptr(us2));
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_ncompare(uint64_t us1, uint64_t us2, uint32_t n) {
    if (us1 == 0 && us2 == 0) return io_ok_uint32(0);
    if (us1 == 0) return io_ok_uint32((uint32_t)-1);
    if (us2 == 0) return io_ok_uint32(1);
    int r = al_ustr_ncompare((const ALLEGRO_USTR *)u64_to_ptr(us1),
                             (const ALLEGRO_USTR *)u64_to_ptr(us2), (int)n);
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_has_prefix_cstr(uint64_t ustr, b_lean_obj_arg prefixObj) {
    if (ustr == 0) return io_ok_uint32(0);
    const char *prefix = lean_string_cstr(prefixObj);
    return io_ok_uint32(
        al_ustr_has_prefix_cstr((const ALLEGRO_USTR *)u64_to_ptr(ustr), prefix) ? 1u : 0u);
}

lean_object* allegro_al_ustr_has_suffix_cstr(uint64_t ustr, b_lean_obj_arg suffixObj) {
    if (ustr == 0) return io_ok_uint32(0);
    const char *suffix = lean_string_cstr(suffixObj);
    return io_ok_uint32(
        al_ustr_has_suffix_cstr((const ALLEGRO_USTR *)u64_to_ptr(ustr), suffix) ? 1u : 0u);
}

/* ── Search ── */

lean_object* allegro_al_ustr_find_chr(uint64_t ustr, uint32_t startPos, uint32_t ch) {
    if (ustr == 0) return io_ok_uint32((uint32_t)-1);
    int r = al_ustr_find_chr((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos, (int32_t)ch);
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_rfind_chr(uint64_t ustr, uint32_t endPos, uint32_t ch) {
    if (ustr == 0) return io_ok_uint32((uint32_t)-1);
    int r = al_ustr_rfind_chr((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)endPos, (int32_t)ch);
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_find_cstr(uint64_t ustr, uint32_t startPos, b_lean_obj_arg needleObj) {
    if (ustr == 0) return io_ok_uint32((uint32_t)-1);
    const char *needle = lean_string_cstr(needleObj);
    int r = al_ustr_find_cstr((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos, needle);
    return io_ok_uint32((uint32_t)r);
}

/* ── Mutation ── */

lean_object* allegro_al_ustr_assign_cstr(uint64_t ustr, b_lean_obj_arg textObj) {
    if (ustr == 0) return io_ok_uint32(0);
    const char *text = lean_string_cstr(textObj);
    return io_ok_uint32(
        al_ustr_assign_cstr((ALLEGRO_USTR *)u64_to_ptr(ustr), text) ? 1u : 0u);
}

lean_object* allegro_al_ustr_set_chr(uint64_t ustr, uint32_t pos, uint32_t ch) {
    if (ustr == 0) return io_ok_uint32(0);
    size_t r = al_ustr_set_chr((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)pos, (int32_t)ch);
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_replace_range(uint64_t us1, uint32_t startPos, uint32_t endPos, uint64_t us2) {
    if (us1 == 0 || us2 == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_replace_range((ALLEGRO_USTR *)u64_to_ptr(us1), (int)startPos, (int)endPos,
                              (const ALLEGRO_USTR *)u64_to_ptr(us2)) ? 1u : 0u);
}

lean_object* allegro_al_ustr_truncate(uint64_t ustr, uint32_t startPos) {
    if (ustr == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_truncate((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos) ? 1u : 0u);
}

/* ── Trimming ── */

lean_object* allegro_al_ustr_ltrim_ws(uint64_t ustr) {
    if (ustr == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_ustr_ltrim_ws((ALLEGRO_USTR *)u64_to_ptr(ustr)) ? 1u : 0u);
}

lean_object* allegro_al_ustr_rtrim_ws(uint64_t ustr) {
    if (ustr == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_ustr_rtrim_ws((ALLEGRO_USTR *)u64_to_ptr(ustr)) ? 1u : 0u);
}

lean_object* allegro_al_ustr_trim_ws(uint64_t ustr) {
    if (ustr == 0) return io_ok_uint32(0);
    return io_ok_uint32(al_ustr_trim_ws((ALLEGRO_USTR *)u64_to_ptr(ustr)) ? 1u : 0u);
}

/* ── Substring / copy ── */

lean_object* allegro_al_ustr_dup_substr(uint64_t ustr, uint32_t startPos, uint32_t endPos) {
    if (ustr == 0) return io_ok_uint64(0);
    ALLEGRO_USTR *sub = al_ustr_dup_substr((const ALLEGRO_USTR *)u64_to_ptr(ustr),
                                            (int)startPos, (int)endPos);
    return io_ok_uint64(ptr_to_u64(sub));
}

lean_object* allegro_al_ustr_empty_string(void) {
    const ALLEGRO_USTR *e = al_ustr_empty_string();
    /* This is a static singleton — return it as a pointer but caller must NOT free it */
    return io_ok_uint64(ptr_to_u64((void *)e));
}

/* ── Iterator ── */

lean_object* allegro_al_ustr_next(uint64_t ustr, uint32_t pos) {
    if (ustr == 0) return io_ok_uint32(pos);
    int p = (int)pos;
    bool ok = al_ustr_next((const ALLEGRO_USTR *)u64_to_ptr(ustr), &p);
    /* Return the new position; if at end, p is unchanged and ok is false.
       We return the position regardless — caller checks if it advanced. */
    (void)ok;
    return io_ok_uint32((uint32_t)p);
}

lean_object* allegro_al_ustr_prev(uint64_t ustr, uint32_t pos) {
    if (ustr == 0) return io_ok_uint32(pos);
    int p = (int)pos;
    bool ok = al_ustr_prev((const ALLEGRO_USTR *)u64_to_ptr(ustr), &p);
    (void)ok;
    return io_ok_uint32((uint32_t)p);
}

lean_object* allegro_al_ustr_get_next(uint64_t ustr, uint32_t pos) {
    /* Returns (codepoint, newPos) encoded as two packed UInt32s in a UInt64:
       low 32 bits  = codepoint (or -1 as 0xFFFFFFFF at end)
       high 32 bits = new position */
    if (ustr == 0) return io_ok_uint64(((uint64_t)pos << 32) | 0xFFFFFFFFu);
    int p = (int)pos;
    int32_t ch = al_ustr_get_next((const ALLEGRO_USTR *)u64_to_ptr(ustr), &p);
    uint64_t packed = ((uint64_t)(uint32_t)p << 32) | (uint32_t)ch;
    return io_ok_uint64(packed);
}

lean_object* allegro_al_ustr_prev_get(uint64_t ustr, uint32_t pos) {
    /* Same encoding as get_next: low 32 = codepoint, high 32 = new position */
    if (ustr == 0) return io_ok_uint64(((uint64_t)pos << 32) | 0xFFFFFFFFu);
    int p = (int)pos;
    int32_t ch = al_ustr_prev_get((const ALLEGRO_USTR *)u64_to_ptr(ustr), &p);
    uint64_t packed = ((uint64_t)(uint32_t)p << 32) | (uint32_t)ch;
    return io_ok_uint64(packed);
}

/* ── Insert / append single codepoint ── */

lean_object* allegro_al_ustr_insert_chr(uint64_t ustr, uint32_t pos, uint32_t ch) {
    if (ustr == 0) return io_ok_uint32(0);
    size_t r = al_ustr_insert_chr((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)pos, (int32_t)ch);
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_append_chr(uint64_t ustr, uint32_t ch) {
    if (ustr == 0) return io_ok_uint32(0);
    size_t r = al_ustr_append_chr((ALLEGRO_USTR *)u64_to_ptr(ustr), (int32_t)ch);
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_remove_chr(uint64_t ustr, uint32_t pos) {
    if (ustr == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_remove_chr((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)pos) ? 1u : 0u);
}

/* ── Assign ustr to ustr ── */

lean_object* allegro_al_ustr_assign(uint64_t us1, uint64_t us2) {
    if (us1 == 0 || us2 == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_assign((ALLEGRO_USTR *)u64_to_ptr(us1),
                       (const ALLEGRO_USTR *)u64_to_ptr(us2)) ? 1u : 0u);
}

/* ── Search extended ── */

lean_object* allegro_al_ustr_rfind_cstr(uint64_t ustr, uint32_t endPos, b_lean_obj_arg needleObj) {
    if (ustr == 0) return io_ok_uint32((uint32_t)-1);
    const char *needle = lean_string_cstr(needleObj);
    int r = al_ustr_rfind_cstr((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)endPos, needle);
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_find_set_cstr(uint64_t ustr, uint32_t startPos, b_lean_obj_arg acceptObj) {
    if (ustr == 0) return io_ok_uint32((uint32_t)-1);
    const char *accept = lean_string_cstr(acceptObj);
    int r = al_ustr_find_set_cstr((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos, accept);
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_find_cset_cstr(uint64_t ustr, uint32_t startPos, b_lean_obj_arg rejectObj) {
    if (ustr == 0) return io_ok_uint32((uint32_t)-1);
    const char *reject = lean_string_cstr(rejectObj);
    int r = al_ustr_find_cset_cstr((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos, reject);
    return io_ok_uint32((uint32_t)r);
}

/* ── Find & replace ── */

lean_object* allegro_al_ustr_find_replace_cstr(uint64_t ustr,
                                                uint32_t startPos,
                                                b_lean_obj_arg findObj,
                                                b_lean_obj_arg replaceObj) {
    if (ustr == 0) return io_ok_uint32(0);
    const char *find_str = lean_string_cstr(findObj);
    const char *replace_str = lean_string_cstr(replaceObj);
    return io_ok_uint32(
        al_ustr_find_replace_cstr((ALLEGRO_USTR *)u64_to_ptr(ustr),
                                  (int)startPos,
                                  find_str, replace_str) ? 1u : 0u);
}

/* ── Insert ustr into ustr ── */

lean_object* allegro_al_ustr_insert(uint64_t us1, uint32_t pos, uint64_t us2) {
    if (us1 == 0 || us2 == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_insert((ALLEGRO_USTR *)u64_to_ptr(us1), (int)pos,
                       (const ALLEGRO_USTR *)u64_to_ptr(us2)) ? 1u : 0u);
}

/* ── Assign substr ── */

lean_object* allegro_al_ustr_assign_substr(uint64_t us1, uint64_t us2, uint32_t startPos, uint32_t endPos) {
    if (us1 == 0 || us2 == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_assign_substr((ALLEGRO_USTR *)u64_to_ptr(us1),
                              (const ALLEGRO_USTR *)u64_to_ptr(us2),
                              (int)startPos, (int)endPos) ? 1u : 0u);
}

/* ── Ustr-based search variants ── */

lean_object* allegro_al_ustr_find_set(uint64_t ustr, uint32_t startPos, uint64_t accept) {
    if (ustr == 0 || accept == 0) return io_ok_uint32((uint32_t)-1);
    int r = al_ustr_find_set((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos,
                             (const ALLEGRO_USTR *)u64_to_ptr(accept));
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_find_cset(uint64_t ustr, uint32_t startPos, uint64_t reject) {
    if (ustr == 0 || reject == 0) return io_ok_uint32((uint32_t)-1);
    int r = al_ustr_find_cset((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos,
                              (const ALLEGRO_USTR *)u64_to_ptr(reject));
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_find_str(uint64_t ustr, uint32_t startPos, uint64_t needle) {
    if (ustr == 0 || needle == 0) return io_ok_uint32((uint32_t)-1);
    int r = al_ustr_find_str((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos,
                             (const ALLEGRO_USTR *)u64_to_ptr(needle));
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_rfind_str(uint64_t ustr, uint32_t endPos, uint64_t needle) {
    if (ustr == 0 || needle == 0) return io_ok_uint32((uint32_t)-1);
    int r = al_ustr_rfind_str((const ALLEGRO_USTR *)u64_to_ptr(ustr), (int)endPos,
                              (const ALLEGRO_USTR *)u64_to_ptr(needle));
    return io_ok_uint32((uint32_t)r);
}

lean_object* allegro_al_ustr_find_replace(uint64_t ustr, uint32_t startPos,
                                           uint64_t find_us, uint64_t replace_us) {
    if (ustr == 0 || find_us == 0 || replace_us == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_find_replace((ALLEGRO_USTR *)u64_to_ptr(ustr), (int)startPos,
                             (const ALLEGRO_USTR *)u64_to_ptr(find_us),
                             (const ALLEGRO_USTR *)u64_to_ptr(replace_us)) ? 1u : 0u);
}

/* ── Ustr-based comparison variants ── */

lean_object* allegro_al_ustr_has_prefix(uint64_t us1, uint64_t us2) {
    if (us1 == 0 || us2 == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_has_prefix((const ALLEGRO_USTR *)u64_to_ptr(us1),
                           (const ALLEGRO_USTR *)u64_to_ptr(us2)) ? 1u : 0u);
}

lean_object* allegro_al_ustr_has_suffix(uint64_t us1, uint64_t us2) {
    if (us1 == 0 || us2 == 0) return io_ok_uint32(0);
    return io_ok_uint32(
        al_ustr_has_suffix((const ALLEGRO_USTR *)u64_to_ptr(us1),
                           (const ALLEGRO_USTR *)u64_to_ptr(us2)) ? 1u : 0u);
}

/* ── Low-level UTF-8 helpers ── */

lean_object* allegro_al_utf8_width(uint32_t codepoint) {
    size_t w = al_utf8_width((int32_t)codepoint);
    return io_ok_uint32((uint32_t)w);
}

lean_object* allegro_al_utf8_encode(uint32_t codepoint) {
    char buf[5];  /* up to 4 UTF-8 bytes + NUL terminator */
    size_t n = al_utf8_encode(buf, (int32_t)codepoint);
    /* Return as a Lean String (up to 4 UTF-8 bytes). */
    buf[n] = '\0';
    return io_ok_string(buf);
}

/* ── UTF-16 functions ── */

lean_object* allegro_al_ustr_size_utf16(uint64_t ustr) {
    if (ustr == 0) return io_ok_uint64(0);
    size_t sz = al_ustr_size_utf16((const ALLEGRO_USTR *)u64_to_ptr(ustr));
    return io_ok_uint64((uint64_t)sz);
}

lean_object* allegro_al_utf16_width(uint32_t codepoint) {
    size_t w = al_utf16_width((int)codepoint);
    return io_ok_uint32((uint32_t)w);
}

/* ── Duplicate USTR to Lean String ── */

lean_object* allegro_al_cstr_dup(uint64_t ustr) {
    if (ustr == 0) return io_ok_string("");
    char *dup = al_cstr_dup((const ALLEGRO_USTR *)u64_to_ptr(ustr));
    lean_object *result = io_ok_string(dup);
    al_free(dup);
    return result;
}

/* ── Copy USTR content to Lean String (via buffer) ── */

lean_object* allegro_al_ustr_to_buffer(uint64_t ustr) {
    if (ustr == 0) return io_ok_string("");
    size_t sz = al_ustr_size((const ALLEGRO_USTR *)u64_to_ptr(ustr));
    char *buf = (char *)malloc(sz + 1);
    if (!buf) return io_ok_string("");
    al_ustr_to_buffer((const ALLEGRO_USTR *)u64_to_ptr(ustr), buf, (int)(sz + 1));
    buf[sz] = '\0';
    lean_object *result = io_ok_string(buf);
    free(buf);
    return result;
}

/* ── UTF-16 encode single codepoint ── */

lean_object* allegro_al_utf16_encode(uint32_t codepoint) {
    uint16_t buf[2] = {0, 0};
    size_t n = al_utf16_encode(buf, (int32_t)codepoint);
    /* Return as (uint32_t hi, uint32_t lo, uint32_t count) */
    return io_ok_u32_triple((uint32_t)buf[0], (uint32_t)buf[1], (uint32_t)n);
}

/* ── Read-only USTR references (heap-allocated info structs) ── */

lean_object* allegro_al_ref_cstr(lean_object* strObj) {
    /* NOTE: al_ref_cstr creates a non-owning reference into the source string.
     * Since lean_dec_ref may free strObj, we must copy the string instead
     * to avoid a use-after-free.  We use al_ustr_new which makes an owned copy.
     * The ALLEGRO_USTR_INFO is not needed for al_ustr_new. */
    const char *s = lean_string_cstr(strObj);
    const ALLEGRO_USTR *u = al_ustr_new(s);
    lean_dec_ref(strObj);
    return io_ok_uint64(ptr_to_u64((void *)u));
}

lean_object* allegro_al_ref_buffer(uint64_t buf, uint32_t size) {
    if (buf == 0) return io_ok_uint64(0);
    ALLEGRO_USTR_INFO *info = (ALLEGRO_USTR_INFO *)malloc(sizeof(ALLEGRO_USTR_INFO));
    if (!info) return io_ok_uint64(0);
    const ALLEGRO_USTR *u = al_ref_buffer(info, (const char *)u64_to_ptr(buf), (size_t)size);
    return io_ok_uint64(ptr_to_u64((void *)u));
}

lean_object* allegro_al_ref_ustr(uint64_t ustr, uint32_t startPos, uint32_t endPos) {
    if (ustr == 0) return io_ok_uint64(0);
    ALLEGRO_USTR_INFO *info = (ALLEGRO_USTR_INFO *)malloc(sizeof(ALLEGRO_USTR_INFO));
    if (!info) return io_ok_uint64(0);
    const ALLEGRO_USTR *u = al_ref_ustr(info, (const ALLEGRO_USTR *)u64_to_ptr(ustr),
                                          (int)startPos, (int)endPos);
    return io_ok_uint64(ptr_to_u64((void *)u));
}

/* ── UTF-16 conversion ── */

lean_object* allegro_al_ustr_new_from_utf16(b_lean_obj_arg ba) {
    /* ba is a Lean ByteArray containing uint16_t values */
    size_t byteLen = lean_sarray_size(ba);
    const uint16_t *data = (const uint16_t *)lean_sarray_cptr(ba);
    ALLEGRO_USTR *u = al_ustr_new_from_utf16(data);
    return io_ok_uint64(ptr_to_u64(u));
}

lean_object* allegro_al_ustr_encode_utf16(uint64_t ustr) {
    if (ustr == 0) {
        lean_object* ba = lean_alloc_sarray(1, 0, 0);
        return lean_io_result_mk_ok(ba);
    }
    size_t sz = al_ustr_size_utf16((const ALLEGRO_USTR *)u64_to_ptr(ustr));
    lean_object* ba = lean_alloc_sarray(1, 0, sz);
    uint16_t *dst = (uint16_t *)lean_sarray_cptr(ba);
    size_t written = al_ustr_encode_utf16((const ALLEGRO_USTR *)u64_to_ptr(ustr), dst, sz);
    lean_sarray_set_size(ba, written);
    return lean_io_result_mk_ok(ba);
}
