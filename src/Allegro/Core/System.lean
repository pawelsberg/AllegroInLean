/-!
System lifecycle, timing, and system info helpers for Allegro 5.

Provides initialization, shutdown, timing utilities, and runtime
information such as the library version, app/org name, and hardware.

## Version decoding
The packed version from `getAllegroVersion` encodes major/minor/revision/release:
```
let v ← Allegro.getAllegroVersion
let major := v >>> 24
let minor := (v >>> 16) &&& 0xFF
let rev   := (v >>> 8) &&& 0xFF
let rel   := v &&& 0xFF
```
-/
namespace Allegro

/-- Initialise all Allegro subsystems. Returns 0 on failure. -/
@[extern "allegro_al_init"]
opaque init : IO UInt32

/-- Shut down Allegro and release all resources. -/
@[extern "allegro_al_uninstall_system"]
opaque uninstallSystem : IO Unit

/-- Sleep for the given number of seconds (may yield the CPU). -/
@[extern "allegro_al_rest"]
opaque rest : Float -> IO Unit

/-- Return the number of seconds elapsed since Allegro was initialised. -/
@[extern "allegro_al_get_time"]
opaque getTime : IO Float

-- ── System info ──

/-- Get the packed Allegro version number (major<<24 | minor<<16 | rev<<8 | release). -/
@[extern "allegro_al_get_allegro_version"]
opaque getAllegroVersion : IO UInt32

/-- Get the current application name. -/
@[extern "allegro_al_get_app_name"]
opaque getAppName : IO String

/-- Set the application name (used by `getStandardPath` etc.). -/
@[extern "allegro_al_set_app_name"]
opaque setAppName : String → IO Unit

/-- Get the current organisation name. -/
@[extern "allegro_al_get_org_name"]
opaque getOrgName : IO String

/-- Set the organisation name (used by `getStandardPath` etc.). -/
@[extern "allegro_al_set_org_name"]
opaque setOrgName : String → IO Unit

/-- Get the number of CPU cores (including hyperthreads). Returns 1 if detection fails. -/
@[extern "allegro_al_get_cpu_count"]
opaque getCpuCount : IO UInt32

/-- Get the size of system RAM in MiB. Returns 0 if detection fails. -/
@[extern "allegro_al_get_ram_size"]
opaque getRamSize : IO UInt32

/-- Check whether Allegro is initialised. Returns 1 if `init` has been called successfully. -/
@[extern "allegro_al_is_system_installed"]
opaque isSystemInstalled : IO UInt32

/-- Get the platform identifier (e.g. `systemIdXGLX` on Linux/X11). Added in Allegro 5.2.6. -/
@[extern "allegro_al_get_system_id"]
opaque getSystemId : IO UInt32

/-- Override the executable name used by `getStandardPath` and friends. -/
@[extern "allegro_al_set_exe_name"]
opaque setExeName : String → IO Unit

-- ── System ID constants ──

/-- Unknown / uninitialised system. -/
def systemIdUnknown : UInt32 := 0
/-- Linux X11/GLX backend. -/
def systemIdXGLX : UInt32 := 0x58474C58
/-- Windows backend. -/
def systemIdWindows : UInt32 := 0x57494E44
/-- macOS backend. -/
def systemIdMacOSX : UInt32 := 0x4F535820
/-- Android backend. -/
def systemIdAndroid : UInt32 := 0x414E4452
/-- iOS (iPhone) backend. -/
def systemIdIPhone : UInt32 := 0x4950484F
/-- GP2X Wiz backend. -/
def systemIdGP2XWiz : UInt32 := 0x57495A20
/-- Raspberry Pi backend. -/
def systemIdRaspberryPi : UInt32 := 0x52415350
/-- SDL2 backend. -/
def systemIdSDL : UInt32 := 0x53444C32

-- ── State save/restore ──

/-- Opaque handle to a saved Allegro state buffer. -/
def State := UInt64

instance : BEq State := inferInstanceAs (BEq UInt64)
instance : Inhabited State := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq State := inferInstanceAs (DecidableEq UInt64)
instance : OfNat State 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString State := ⟨fun (h : UInt64) => s!"State#{h}"⟩
instance : Repr State := ⟨fun (h : UInt64) _ => .text s!"State#{repr h}"⟩

/-- The null state handle. -/
def State.null : State := (0 : UInt64)

/-- Allocate an opaque state buffer (must be freed with `destroyState`). -/
@[extern "allegro_al_create_state"]
opaque createState : IO State

/-- Free a state buffer previously allocated with `createState`. -/
@[extern "allegro_al_destroy_state"]
opaque destroyState : State → IO Unit

-- ── State flag constants ──

/-- Bitmask of Allegro state flags for `storeState`/`restoreState`.
    Combine with `|||` (e.g. `.blender ||| .targetBitmap`). -/
structure StateFlags where
  /-- Raw Allegro constant value. -/
  val : UInt32
  deriving BEq, Repr

instance : OrOp StateFlags where or a b := ⟨a.val ||| b.val⟩
instance : AndOp StateFlags where and a b := ⟨a.val &&& b.val⟩

namespace StateFlags
def newDisplayParameters : StateFlags := ⟨0x0001⟩
def newBitmapParameters : StateFlags := ⟨0x0002⟩
def display : StateFlags := ⟨0x0004⟩
def targetBitmap : StateFlags := ⟨0x0008⟩
def blender : StateFlags := ⟨0x0010⟩
def newFileInterface : StateFlags := ⟨0x0020⟩
def transform : StateFlags := ⟨0x0040⟩
def projectionTransform : StateFlags := ⟨0x0100⟩
def bitmap : StateFlags := ⟨0x000A⟩
def all : StateFlags := ⟨0xFFFF⟩
end StateFlags

/-- Capture the indicated state into the state buffer.
    `flags` is a bitmask of `StateFlags` values (combine with `|||`). -/
@[extern "allegro_al_store_state"]
private opaque storeStateRaw : State → UInt32 → IO Unit

@[inline] def storeState (state : State) (flags : StateFlags) : IO Unit :=
  storeStateRaw state flags.val

/-- Restore the state previously captured with `storeState`. -/
@[extern "allegro_al_restore_state"]
opaque restoreState : State → IO Unit

-- ── Errno ──

/-- Get the last Allegro error code for the calling thread. -/
@[extern "allegro_al_get_errno"]
opaque getErrno : IO UInt32

/-- Set the Allegro error code for the calling thread. -/
@[extern "allegro_al_set_errno"]
opaque setErrno : UInt32 → IO Unit

/-- Get a pointer to the active system driver (low-level). Returns 0 if not installed. -/
@[extern "allegro_al_get_system_driver"]
opaque getSystemDriver : IO UInt64

-- ── Option lifting ──

/-- Convert a nullable handle (where 0 means failure/null) to `Option`.
    Used by the `?`-suffixed API variants throughout the library. -/
@[inline] def liftOption {α : Type} [BEq α] [OfNat α 0] (act : IO α) : IO (Option α) := do
  let v ← act
  pure (if v == (0 : α) then none else some v)

-- ════════════════════════════════════════
-- Error-checked initialization helpers
-- ════════════════════════════════════════

/-- Initialise Allegro, throwing a descriptive error on failure.
    Prefer this over `init` for games — it provides a clear message
    instead of silently returning 0. -/
def initOrFail : IO Unit := do
  let ok ← init
  if ok == 0 then
    throw (IO.userError "Allegro.init failed — is there a display server available? Check that X11/Wayland/Windows desktop is running.")


-- ════════════════════════════════════════
-- Color
-- ════════════════════════════════════════

/-- An RGBA colour with components in the 0–255 range.
    Use Color.rgb / Color.rgba to construct, then pass to any
    colour-accepting function (e.g. drawFilledRectangle, drawText). -/
structure Color where
  /-- Red component (0–255). -/
  r : UInt32 := 0
  /-- Green component (0–255). -/
  g : UInt32 := 0
  /-- Blue component (0–255). -/
  b : UInt32 := 0
  /-- Alpha component (0–255, 255 = fully opaque). -/
  a : UInt32 := 255
  deriving BEq, Repr, Inhabited

namespace Color

/-- Construct an opaque RGB colour. `Color.rgb 255 100 50` -/
@[inline] def rgb (r g b : UInt32) : Color := { r, g, b, a := 255 }

/-- Construct an RGBA colour. `Color.rgba 255 100 50 128` -/
@[inline] def rgba (r g b a : UInt32) : Color := { r, g, b, a }

/-- White (255, 255, 255). -/
def white : Color := rgb 255 255 255
/-- Black (0, 0, 0). -/
def black : Color := rgb 0 0 0
/-- Red (255, 0, 0). -/
def red : Color := rgb 255 0 0
/-- Green (0, 255, 0). -/
def green : Color := rgb 0 255 0
/-- Blue (0, 0, 255). -/
def blue : Color := rgb 0 0 255
/-- Yellow (255, 255, 0). -/
def yellow : Color := rgb 255 255 0
/-- Cyan (0, 255, 255). -/
def cyan : Color := rgb 0 255 255
/-- Magenta (255, 0, 255). -/
def magenta : Color := rgb 255 0 255
/-- Transparent (0, 0, 0, 0). -/
def transparent : Color := rgba 0 0 0 0

end Color
end Allegro
