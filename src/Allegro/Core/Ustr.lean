/-!
Unicode string helpers.

Create and manipulate Allegro ustr values.

## Basic usage
```
let u ← Allegro.ustrNew "Hello"
let len ← Allegro.ustrLength u   -- codepoint count
let s ← Allegro.ustrCstr u       -- convert back to Lean String
Allegro.ustrFree u
```

## Search
```
let u ← Allegro.ustrNew "Hello World"
let pos ← Allegro.ustrFindCstr u 0 "World"   -- byte offset, or UInt32.max on failure
Allegro.ustrFree u
```

## Comparison
```
let a ← Allegro.ustrNew "abc"
let b ← Allegro.ustrNew "abc"
let eq ← Allegro.ustrEqual a b   -- 1
Allegro.ustrFree a; Allegro.ustrFree b
```
-/
namespace Allegro

/-- Opaque handle to an Allegro Unicode string (ALLEGRO_USTR). -/
def Ustr := UInt64

instance : BEq Ustr := inferInstanceAs (BEq UInt64)
instance : Inhabited Ustr := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Ustr := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Ustr 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Ustr := ⟨fun (h : UInt64) => s!"Ustr#{h}"⟩
instance : Repr Ustr := ⟨fun (h : UInt64) _ => .text s!"Ustr#{repr h}"⟩

/-- The null ustr handle. -/
def Ustr.null : Ustr := (0 : UInt64)

-- ── Lifecycle ──

/-- Create a new Allegro ustr from a Lean string. Free with `ustrFree`. -/
@[extern "allegro_al_ustr_new"]
opaque ustrNew : @& String → IO Ustr

/-- Create a ustr from the first `size` bytes of the given string. -/
@[extern "allegro_al_ustr_new_from_buffer"]
opaque ustrNewFromBuffer : @& String → UInt32 → IO Ustr

/-- Free a ustr previously created with `ustrNew` or `ustrDup`. -/
@[extern "allegro_al_ustr_free"]
opaque ustrFree : Ustr → IO Unit

/-- Convert a ustr back to a Lean string (copies the data). -/
@[extern "allegro_al_cstr"]
opaque ustrCstr : Ustr → IO String

-- ── Size / length ──

/-- Byte size of the ustr (not codepoint count). -/
@[extern "allegro_al_ustr_size"]
opaque ustrSize : Ustr → IO UInt64

/-- Number of Unicode codepoints. -/
@[extern "allegro_al_ustr_length"]
opaque ustrLength : Ustr → IO UInt32

-- ── Copy ──

/-- Duplicate a ustr. The returned copy must be freed with `ustrFree`. -/
@[extern "allegro_al_ustr_dup"]
opaque ustrDup : Ustr → IO Ustr

-- ── Append / insert / remove ──

/-- Append the contents of one ustr to another. -/
@[extern "allegro_al_ustr_append"]
opaque ustrAppend : Ustr → Ustr → IO Unit

/-- Append a C string to a ustr. -/
@[extern "allegro_al_ustr_append_cstr"]
opaque ustrAppendCstr : Ustr → @& String → IO Unit

/-- Insert a C string at byte position `pos`. -/
@[extern "allegro_al_ustr_insert_cstr"]
opaque ustrInsertCstr : Ustr → UInt32 → @& String → IO Unit

/-- Insert ustr `us2` into `us1` at byte position `pos`. Returns 1 on success. -/
@[extern "allegro_al_ustr_insert"]
opaque ustrInsert : Ustr → UInt32 → Ustr → IO UInt32

/-- Remove bytes in the range [startPos, endPos) from the ustr. -/
@[extern "allegro_al_ustr_remove_range"]
opaque ustrRemoveRange : Ustr → UInt32 → UInt32 → IO Unit

-- ── Character access ──

/-- Get the Unicode codepoint at byte position `index`. -/
@[extern "allegro_al_ustr_get"]
opaque ustrGet : Ustr → UInt32 → IO UInt32

/-- Get the byte offset of the `index`-th codepoint. -/
@[extern "allegro_al_ustr_offset"]
opaque ustrOffset : Ustr → UInt32 → IO UInt32

/-- Set the codepoint at byte position `pos`. Returns new byte size at that position. -/
@[extern "allegro_al_ustr_set_chr"]
opaque ustrSetChr : Ustr → UInt32 → UInt32 → IO UInt32

-- ── Assignment ──

/-- Replace the entire contents of a ustr with a C string. Returns 1 on success. -/
@[extern "allegro_al_ustr_assign_cstr"]
opaque ustrAssignCstr : Ustr → @& String → IO UInt32

/-- Replace byte range [startPos, endPos) in `us1` with contents of `us2`. Returns 1 on success. -/
@[extern "allegro_al_ustr_replace_range"]
opaque ustrReplaceRange : Ustr → UInt32 → UInt32 → Ustr → IO UInt32

/-- Truncate to `startPos` bytes. Returns 1 on success. -/
@[extern "allegro_al_ustr_truncate"]
opaque ustrTruncate : Ustr → UInt32 → IO UInt32

-- ── Comparison ──

/-- Check equality. Returns 1 if equal. -/
@[extern "allegro_al_ustr_equal"]
opaque ustrEqual : Ustr → Ustr → IO UInt32

/-- Lexicographic comparison. Returns 0 if equal, negative if us1 < us2, positive if us1 > us2. -/
@[extern "allegro_al_ustr_compare"]
opaque ustrCompare : Ustr → Ustr → IO UInt32

/-- Compare at most `n` codepoints. -/
@[extern "allegro_al_ustr_ncompare"]
opaque ustrNcompare : Ustr → Ustr → UInt32 → IO UInt32

/-- Check if `ustr` starts with the given C string prefix. Returns 1 if yes. -/
@[extern "allegro_al_ustr_has_prefix_cstr"]
opaque ustrHasPrefixCstr : Ustr → @& String → IO UInt32

/-- Check if `ustr` ends with the given C string suffix. Returns 1 if yes. -/
@[extern "allegro_al_ustr_has_suffix_cstr"]
opaque ustrHasSuffixCstr : Ustr → @& String → IO UInt32

-- ── Search ──

/-- Find codepoint `ch` starting from byte position `startPos`.
    Returns byte offset, or `UInt32.max` (4294967295) on failure. -/
@[extern "allegro_al_ustr_find_chr"]
opaque ustrFindChr : Ustr → UInt32 → UInt32 → IO UInt32

/-- Reverse-find codepoint `ch` before byte position `endPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_rfind_chr"]
opaque ustrRfindChr : Ustr → UInt32 → UInt32 → IO UInt32

/-- Find C string `needle` starting from byte position `startPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_find_cstr"]
opaque ustrFindCstr : Ustr → UInt32 → @& String → IO UInt32

-- ── Trimming ──

/-- Remove leading whitespace. Returns 1 on success. -/
@[extern "allegro_al_ustr_ltrim_ws"]
opaque ustrLtrimWs : Ustr → IO UInt32

/-- Remove trailing whitespace. Returns 1 on success. -/
@[extern "allegro_al_ustr_rtrim_ws"]
opaque ustrRtrimWs : Ustr → IO UInt32

/-- Remove leading and trailing whitespace. Returns 1 on success. -/
@[extern "allegro_al_ustr_trim_ws"]
opaque ustrTrimWs : Ustr → IO UInt32

-- ── Substring / copy ──

/-- Duplicate a substring from byte position `startPos` to `endPos` (exclusive).
    Returns a new Ustr that must be freed with `ustrFree`. -/
@[extern "allegro_al_ustr_dup_substr"]
opaque ustrDupSubstr : Ustr → UInt32 → UInt32 → IO Ustr

/-- Return Allegro's singleton empty string. **Do not free** the returned handle. -/
@[extern "allegro_al_ustr_empty_string"]
opaque ustrEmptyString : IO Ustr

-- ── Iterator ──

/-- Advance byte position to the next codepoint. Returns the new position. -/
@[extern "allegro_al_ustr_next"]
opaque ustrNext : Ustr → UInt32 → IO UInt32

/-- Move byte position to the previous codepoint. Returns the new position. -/
@[extern "allegro_al_ustr_prev"]
opaque ustrPrev : Ustr → UInt32 → IO UInt32

/-- Get codepoint at `pos` and advance. Returns packed UInt64:
    low 32 bits = codepoint (0xFFFFFFFF at end), high 32 bits = new position.
    Use `ustrUnpackGetNext` to decode. -/
@[extern "allegro_al_ustr_get_next"]
opaque ustrGetNextRaw : Ustr → UInt32 → IO UInt64

/-- Move position back and get the codepoint there. Returns packed UInt64:
    low 32 bits = codepoint, high 32 bits = new position.
    Use `ustrUnpackPrevGet` to decode. -/
@[extern "allegro_al_ustr_prev_get"]
opaque ustrPrevGetRaw : Ustr → UInt32 → IO UInt64

/-- Decode the packed result of `ustrGetNextRaw`: (codepoint, newPosition). -/
def ustrUnpackGetNext (packed : UInt64) : UInt32 × UInt32 :=
  (packed.toUInt32, (packed >>> 32).toUInt32)

/-- Decode the packed result of `ustrPrevGetRaw`: (codepoint, newPosition). -/
def ustrUnpackPrevGet (packed : UInt64) : UInt32 × UInt32 :=
  (packed.toUInt32, (packed >>> 32).toUInt32)

-- ── Insert / append single codepoint ──

/-- Insert codepoint `ch` at byte position `pos`. Returns the number of bytes inserted. -/
@[extern "allegro_al_ustr_insert_chr"]
opaque ustrInsertChr : Ustr → UInt32 → UInt32 → IO UInt32

/-- Append codepoint `ch`. Returns the number of bytes written. -/
@[extern "allegro_al_ustr_append_chr"]
opaque ustrAppendChr : Ustr → UInt32 → IO UInt32

/-- Remove the codepoint starting at byte position `pos`. Returns 1 on success. -/
@[extern "allegro_al_ustr_remove_chr"]
opaque ustrRemoveChr : Ustr → UInt32 → IO UInt32

-- ── Assign ustr to ustr ──

/-- Replace the contents of `us1` with `us2`. Returns 1 on success. -/
@[extern "allegro_al_ustr_assign"]
opaque ustrAssign : Ustr → Ustr → IO UInt32

/-- Replace the contents of `us1` with the sub-range [startPos, endPos) of `us2`. Returns 1 on success. -/
@[extern "allegro_al_ustr_assign_substr"]
opaque ustrAssignSubstr : Ustr → Ustr → UInt32 → UInt32 → IO UInt32

-- ── Search extended ──

/-- Reverse-find C string `needle` before byte position `endPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_rfind_cstr"]
opaque ustrRfindCstr : Ustr → UInt32 → @& String → IO UInt32

/-- Find first occurrence of any character in `accept` set, starting from `startPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_find_set_cstr"]
opaque ustrFindSetCstr : Ustr → UInt32 → @& String → IO UInt32

/-- Find first character NOT in `reject` set, starting from `startPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_find_cset_cstr"]
opaque ustrFindCsetCstr : Ustr → UInt32 → @& String → IO UInt32

-- ── Find & replace ──

/-- Replace all occurrences of `find` with `replace` in the ustr, starting from `startPos`.
    Returns 1 on success. -/
@[extern "allegro_al_ustr_find_replace_cstr"]
opaque ustrFindReplaceCstr : Ustr → UInt32 → @& String → @& String → IO UInt32

-- ── Ustr-based search variants ──

/-- Find first occurrence of any character in `accept` ustr, starting from `startPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_find_set"]
opaque ustrFindSet : Ustr → UInt32 → Ustr → IO UInt32

/-- Find first character NOT in `reject` ustr, starting from `startPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_find_cset"]
opaque ustrFindCset : Ustr → UInt32 → Ustr → IO UInt32

/-- Find ustr `needle` starting from byte position `startPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_find_str"]
opaque ustrFindStr : Ustr → UInt32 → Ustr → IO UInt32

/-- Reverse-find ustr `needle` before byte position `endPos`.
    Returns byte offset, or `UInt32.max` on failure. -/
@[extern "allegro_al_ustr_rfind_str"]
opaque ustrRfindStr : Ustr → UInt32 → Ustr → IO UInt32

/-- Replace all occurrences of ustr `find` with ustr `replace`, starting from `startPos`.
    Returns 1 on success. -/
@[extern "allegro_al_ustr_find_replace"]
opaque ustrFindReplace : Ustr → UInt32 → Ustr → Ustr → IO UInt32

-- ── Ustr-based comparison variants ──

/-- Check if `ustr` starts with the given ustr prefix. Returns 1 if yes. -/
@[extern "allegro_al_ustr_has_prefix"]
opaque ustrHasPrefix : Ustr → Ustr → IO UInt32

/-- Check if `ustr` ends with the given ustr suffix. Returns 1 if yes. -/
@[extern "allegro_al_ustr_has_suffix"]
opaque ustrHasSuffix : Ustr → Ustr → IO UInt32

-- ── Low-level UTF-8 helpers ──

/-- Return the number of bytes that the given Unicode codepoint requires in UTF-8 encoding (1–4). -/
@[extern "allegro_al_utf8_width"]
opaque utf8Width : UInt32 → IO UInt32

/-- Encode a single Unicode codepoint to a UTF-8 string (1–4 bytes). -/
@[extern "allegro_al_utf8_encode"]
opaque utf8Encode : UInt32 → IO String

-- ── UTF-16 helpers ──

/-- Return the number of bytes needed to encode the ustr in UTF-16 (including terminating zero). -/
@[extern "allegro_al_ustr_size_utf16"]
opaque ustrSizeUtf16 : Ustr → IO UInt64

/-- Return the number of 16-bit units needed to encode a codepoint in UTF-16 (1 or 2). -/
@[extern "allegro_al_utf16_width"]
opaque utf16Width : UInt32 → IO UInt32

-- ── USTR to Lean String conversion ──

/-- Duplicate a USTR's content as a Lean `String`. Allocates a new C string, copies it
    to a Lean string, then frees the C string. -/
@[extern "allegro_al_cstr_dup"]
opaque cstrDup : Ustr → IO String

/-- Copy a USTR's content into a Lean `String` via `al_ustr_to_buffer`. -/
@[extern "allegro_al_ustr_to_buffer"]
opaque ustrToBuffer : Ustr → IO String

-- ── UTF-16 encode/decode ──

/-- Encode a single codepoint to UTF-16. Returns `(unit0, unit1, count)` where
    `count` is 1 or 2 (number of 16-bit units produced). -/
@[extern "allegro_al_utf16_encode"]
opaque utf16Encode : UInt32 → IO (UInt32 × UInt32 × UInt32)

/-- Create a USTR from a UTF-16 encoded ByteArray (zero-terminated `uint16_t` sequence). -/
@[extern "allegro_al_ustr_new_from_utf16"]
opaque ustrNewFromUtf16 : @&ByteArray → IO Ustr

/-- Encode a USTR to UTF-16. Returns a ByteArray containing `uint16_t` values. -/
@[extern "allegro_al_ustr_encode_utf16"]
opaque ustrEncodeUtf16 : Ustr → IO ByteArray

-- ── Read-only USTR references ──

/-- Create a read-only USTR reference from a Lean String. The underlying
    `ALLEGRO_USTR_INFO` is heap-allocated and should be freed via `ustrFree`. -/
@[extern "allegro_al_ref_cstr"]
opaque refCstr : String → IO Ustr

/-- Create a read-only USTR reference from a raw memory buffer.
    - `buf`: pointer to character data (as UInt64)
    - `size`: number of bytes -/
@[extern "allegro_al_ref_buffer"]
opaque refBuffer : UInt64 → UInt32 → IO Ustr

/-- Create a read-only USTR reference to a substring of an existing USTR.
    - `ustr`: source USTR
    - `startPos`, `endPos`: byte offsets into the source -/
@[extern "allegro_al_ref_ustr"]
opaque refUstr : Ustr → UInt32 → UInt32 → IO Ustr

end Allegro
