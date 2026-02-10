import Allegro.Core.System

/-!
# Config module bindings

Key/value configuration file support for Allegro 5.

Configs organise settings into named sections with string key/value pairs.
An empty section name `""` maps to the global (unnamed) section.

## Create and populate
```
let cfg ← Allegro.createConfig
Allegro.setConfigValue cfg "" "title" "My Game"
Allegro.setConfigValue cfg "video" "fullscreen" "true"
let _ ← Allegro.saveConfigFile "settings.cfg" cfg
Allegro.destroyConfig cfg
```

## Load and query
```
let cfg ← Allegro.loadConfigFile "settings.cfg"
let title ← Allegro.getConfigValue cfg "" "title"
IO.println s!"Title = {title}"
Allegro.destroyConfig cfg
```

## System config
```
let sysCfg ← Allegro.getSystemConfig
let val ← Allegro.getConfigValue sysCfg "graphics" "renderer"
-- Do NOT destroy the system config — it is owned by Allegro.
```
-/
namespace Allegro

/-- Opaque handle to an Allegro config. -/
def Config := UInt64

instance : BEq Config := inferInstanceAs (BEq UInt64)
instance : Inhabited Config := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Config := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Config 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Config := ⟨fun (h : UInt64) => s!"Config#{h}"⟩
instance : Repr Config := ⟨fun (h : UInt64) _ => .text s!"Config#{repr h}"⟩

/-- The null config handle. -/
def Config.null : Config := (0 : UInt64)

-- ── Lifecycle ──

/-- Create a new empty configuration. -/
@[extern "allegro_al_create_config"]
opaque createConfig : IO Config

/-- Destroy a configuration. Do not call on the system config. -/
@[extern "allegro_al_destroy_config"]
opaque destroyConfig : Config → IO Unit

-- ── Load / Save ──

/-- Load a config from a file. Returns 0 on failure. -/
@[extern "allegro_al_load_config_file"]
opaque loadConfigFile : @& String → IO Config

/-- Save a config to a file. Returns 1 on success. -/
@[extern "allegro_al_save_config_file"]
opaque saveConfigFile : @& String → Config → IO UInt32

-- ── Sections ──

/-- Add a named section (does nothing if it already exists). -/
@[extern "allegro_al_add_config_section"]
opaque addConfigSection : Config → @& String → IO Unit

/-- Remove a section and all its keys. Returns 1 on success. -/
@[extern "allegro_al_remove_config_section"]
opaque removeConfigSection : Config → @& String → IO UInt32

-- ── Key / Value ──

/-- Set a key's value. Section `""` = global section. Creates key if absent. -/
@[extern "allegro_al_set_config_value"]
opaque setConfigValue : Config → @& String → @& String → @& String → IO Unit

/-- Get a key's value. Returns `""` if not found. Section `""` = global. -/
@[extern "allegro_al_get_config_value"]
opaque getConfigValue : Config → @& String → @& String → IO String

/-- Remove a key. Returns 1 on success. -/
@[extern "allegro_al_remove_config_key"]
opaque removeConfigKey : Config → @& String → @& String → IO UInt32

-- ── Comments ──

/-- Add a comment line in the given section. -/
@[extern "allegro_al_add_config_comment"]
opaque addConfigComment : Config → @& String → @& String → IO Unit

-- ── Merge ──

/-- Create a new config by merging two configs. Values in cfg2 override cfg1. -/
@[extern "allegro_al_merge_config"]
opaque mergeConfig : Config → Config → IO Config

/-- Merge `add` into `master` in-place. Values in `add` override. -/
@[extern "allegro_al_merge_config_into"]
opaque mergeConfigInto : Config → Config → IO Unit

-- ── System config ──

/-- Get the system-wide config. **Do not destroy** — owned by Allegro. -/
@[extern "allegro_al_get_system_config"]
opaque getSystemConfig : IO Config

-- ── Iteration ──

/-- Get all section names in the config as an array.
    The global (unnamed) section appears as `""`. -/
@[extern "allegro_al_get_config_sections"]
opaque getConfigSections : Config → IO (Array String)

/-- Get all entry (key) names in a section as an array.
    Pass `""` for the global (unnamed) section. -/
@[extern "allegro_al_get_config_entries"]
opaque getConfigEntries : Config → @& String → IO (Array String)

-- ── Option-returning variants ──

/-- Load a config file, returning `none` on failure (file not found, parse error). -/
def loadConfigFile? (filename : String) : IO (Option Config) := liftOption (loadConfigFile filename)

-- ── File-based config I/O ──

/-- Load a config from an open `AllegroFile`. -/
@[extern "allegro_al_load_config_file_f"]
opaque loadConfigFileF : UInt64 → IO Config

/-- Save a config to an open `AllegroFile`. Returns 1 on success. -/
@[extern "allegro_al_save_config_file_f"]
opaque saveConfigFileF : UInt64 → Config → IO UInt32

/-- Load a config from an open file, returning `none` on failure. -/
def loadConfigFileF? (fp : UInt64) : IO (Option Config) := liftOption (loadConfigFileF fp)

end Allegro
