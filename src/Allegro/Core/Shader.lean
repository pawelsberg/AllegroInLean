import Allegro.Core.System

/-!
# Allegro 5 Shader bindings (`shader.h`)

GLSL / HLSL shader support. Requires an active display with
appropriate driver support (OpenGL for GLSL, Direct3D for HLSL).

## Shader types
- `shaderTypeVertex` (1)  — vertex shader
- `shaderTypePixel`  (2)  — fragment / pixel shader

## Shader platforms
- `shaderPlatformAuto`         (0) — auto-detect
- `shaderPlatformGlsl`         (1) — OpenGL GLSL
- `shaderPlatformHlsl`         (2) — Direct3D HLSL
- `shaderPlatformAutoMinimal`  (3) — auto with minimal features
- `shaderPlatformGlslMinimal`  (4) — GLSL minimal
- `shaderPlatformHlslMinimal`  (5) — HLSL minimal
-/
namespace Allegro

/-- Opaque handle to an Allegro shader (`ALLEGRO_SHADER *`). -/
def Shader := UInt64

instance : BEq Shader := inferInstanceAs (BEq UInt64)
instance : Inhabited Shader := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Shader := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Shader 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Shader := ⟨fun (h : UInt64) => s!"Shader#{h}"⟩
instance : Repr Shader := ⟨fun (h : UInt64) _ => .text s!"Shader#{repr h}"⟩

/-- The null shader handle. -/
def Shader.null : Shader := (0 : UInt64)

-- ── Shader type constants ──

/-- Vertex shader type. -/
def shaderTypeVertex : UInt32 := 1
/-- Fragment / pixel shader type. -/
def shaderTypePixel  : UInt32 := 2

/-- Auto-detect shader platform. -/
def shaderPlatformAuto         : UInt32 := 0
/-- OpenGL GLSL. -/
def shaderPlatformGlsl         : UInt32 := 1
/-- Direct3D HLSL. -/
def shaderPlatformHlsl         : UInt32 := 2
/-- Auto-detect, minimal feature set. -/
def shaderPlatformAutoMinimal  : UInt32 := 3
/-- GLSL, minimal feature set. -/
def shaderPlatformGlslMinimal  : UInt32 := 4
/-- HLSL, minimal feature set. -/
def shaderPlatformHlslMinimal  : UInt32 := 5

-- ── Lifecycle ──

/-- Create a shader for the given platform. Returns `Shader.null` (0) on failure. -/
@[extern "allegro_al_create_shader"]
opaque createShader : UInt32 → IO Shader

/-- Destroy a shader. -/
@[extern "allegro_al_destroy_shader"]
opaque destroyShader : Shader → IO Unit

-- ── Shader source ──

/-- Attach shader source code. `type` is `AllegroShaderType.vertex` or `.pixel`.
    Returns 1 on success, 0 on failure (check `getShaderLog`). -/
@[extern "allegro_al_attach_shader_source"]
opaque attachShaderSource : Shader → UInt32 → String → IO UInt32

/-- Attach shader source from a file. Returns 1 on success. -/
@[extern "allegro_al_attach_shader_source_file"]
opaque attachShaderSourceFile : Shader → UInt32 → String → IO UInt32

/-- Compile / link the shader. Returns 1 on success. -/
@[extern "allegro_al_build_shader"]
opaque buildShader : Shader → IO UInt32

/-- Get the shader compilation log (errors and warnings). -/
@[extern "allegro_al_get_shader_log"]
opaque getShaderLog : Shader → IO String

/-- Get the platform of a shader. -/
@[extern "allegro_al_get_shader_platform"]
opaque getShaderPlatform : Shader → IO UInt32

-- ── Shader usage ──

/-- Use a shader for subsequent drawing. Pass `Shader.null` (0) to use the default shader. -/
@[extern "allegro_al_use_shader"]
opaque useShader : Shader → IO UInt32

/-- Get the currently active shader, or `Shader.null` (0). -/
@[extern "allegro_al_get_current_shader"]
opaque getCurrentShader : IO Shader

-- ── Uniform setters ──

/-- Set a sampler (texture) uniform. -/
@[extern "allegro_al_set_shader_sampler"]
opaque setShaderSampler : String → UInt64 → UInt32 → IO UInt32

/-- Set a matrix uniform from a `Transform` handle. -/
@[extern "allegro_al_set_shader_matrix"]
opaque setShaderMatrix : String → UInt64 → IO UInt32

/-- Set an integer uniform. -/
@[extern "allegro_al_set_shader_int"]
opaque setShaderInt : String → UInt32 → IO UInt32

/-- Set a float uniform. -/
@[extern "allegro_al_set_shader_float"]
opaque setShaderFloat : String → Float → IO UInt32

/-- Set a boolean uniform. -/
@[extern "allegro_al_set_shader_bool"]
opaque setShaderBool : String → UInt32 → IO UInt32

/-- Set an integer vector uniform. `numComponents` is 1–4, `numElems` is array length. -/
@[extern "allegro_al_set_shader_int_vector"]
opaque setShaderIntVector : String → UInt32 → Array UInt32 → UInt32 → IO UInt32

/-- Set a float vector uniform. `numComponents` is 1–4, `numElems` is array length. -/
@[extern "allegro_al_set_shader_float_vector"]
opaque setShaderFloatVector : String → UInt32 → FloatArray → UInt32 → IO UInt32

-- ── Default shader source ──

/-- Get the built-in default shader source for the given platform and type. -/
@[extern "allegro_al_get_default_shader_source"]
opaque getDefaultShaderSource : UInt32 → UInt32 → IO String

-- ── Option-returning variant ──

/-- Create a shader, returning `none` on failure. -/
def createShader? (platform : UInt32) : IO (Option Shader) := liftOption (createShader platform)

-- ── RAII wrapper ──

/-- Create a shader, run `f`, then destroy it. -/
def withShader (platform : UInt32) (f : Shader → IO α) : IO α := do
  let s ← createShader platform
  try f s finally destroyShader s

end Allegro
