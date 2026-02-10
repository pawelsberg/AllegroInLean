import Lake
open Lake DSL

open System

-- ── pkg-config helper (build-time only) ──

/-- Run a shell command and return its stdout, or `none` on failure. -/
private unsafe def runCmdUnsafe (cmd : String) (args : Array String) : Option String :=
  let result := unsafeBaseIO (IO.Process.output {
    cmd := cmd, args := args
  } |>.toBaseIO)
  match result with
  | Except.ok out => if out.exitCode == 0 then
      let s := out.stdout.trimAsciiEnd.toString
      if s.isEmpty then none else some s
    else none
  | Except.error _ => none

@[implemented_by runCmdUnsafe]
private opaque runCmd : String → Array String → Option String

/-- Query pkg-config. -/
private def pkgConfig (args : Array String) : Option String :=
  runCmd "pkg-config" args

/-- Query pkg-config with extra PKG_CONFIG_PATH entries via `sh -c`. -/
private def pkgConfigWithPath (extraPath : String) (args : Array String) : Option String :=
  let pkgArgs := " ".intercalate args.toList
  runCmd "sh" #["-c", s!"PKG_CONFIG_PATH={extraPath} pkg-config {pkgArgs}"]

/-- Check whether a file path exists (build-time only).
    Used as a fallback on Windows where `pkg-config` / `sh` may be
    unavailable to native (non-MSYS2) processes like Lake. -/
private unsafe def fileExistsUnsafe (path : System.FilePath) : Bool :=
  let action : IO Bool := System.FilePath.pathExists path
  let result := unsafeBaseIO action.toBaseIO
  match result with
  | Except.ok b => b
  | Except.error _ => false

@[implemented_by fileExistsUnsafe]
private opaque fileExistsBuildTime : System.FilePath → Bool

-- ── Allegro prefix detection ──

/-- Candidate pkg-config directories from a local Allegro build (produced by `scripts/build-allegro.sh`). -/
private def localPkgConfigPath : String :=
  "allegro-local/lib64/pkgconfig:allegro-local/lib/pkgconfig"

/-- Common system prefixes where Allegro may be installed but not on the
    default `PKG_CONFIG_PATH` (e.g. `/usr/local` on RHEL/Rocky/Fedora). -/
private def commonPkgConfigPath : String :=
  "/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:/opt/homebrew/lib/pkgconfig"

/-- Resolve the Allegro installation prefix.
    Priority: 1) `-K allegroPrefix=…`  2) local build tree
    3) system pkg-config  4) common system prefixes  5) empty. -/
def allegroPrefixCandidates : Array System.FilePath :=
  match get_config? allegroPrefix with
  | some p => #[System.FilePath.mk p]
  | none =>
    -- Try local build (allegro-local/, or legacy vendored tree)
    match pkgConfigWithPath localPkgConfigPath #["--variable=prefix", "allegro-5"] with
    | some p => #[System.FilePath.mk p]
    | none =>
      -- Try system pkg-config
      match pkgConfig #["--variable=prefix", "allegro-5"] with
      | some p => #[System.FilePath.mk p]
      | none =>
        -- Try common system prefixes (/usr/local, Homebrew, etc.)
        match pkgConfigWithPath commonPkgConfigPath #["--variable=prefix", "allegro-5"] with
        | some p => #[System.FilePath.mk p]
        | none =>
          -- Direct fallback: check for allegro-local/ build tree directly.
          -- On Windows, pkg-config / sh are MSYS2 tools that are not visible
          -- to native processes (Lake, Lean).  Bypass pkg-config entirely.
          let localPrefix : System.FilePath := "allegro-local"
          if fileExistsBuildTime (localPrefix / "include" / "allegro5" / "allegro.h") then
            #[localPrefix]
          else
            #[]

def allegroLibDirs : Array System.FilePath := Id.run do
  let mut dirs := #[]
  for pfx in allegroPrefixCandidates do
    -- lib64 exists on Linux but not macOS / Windows
    if !System.Platform.isOSX && !System.Platform.isWindows then
      dirs := dirs.push (pfx / "lib64")
    dirs := dirs.push (pfx / "lib")
  return dirs

def allegroIncludeDirs : Array System.FilePath := Id.run do
  let mut dirs := #[]
  for pfx in allegroPrefixCandidates do
    dirs := dirs.push (pfx / "include")
  return dirs

def allegroLinkArgs : Array String := Id.run do
  let mut args := #[]
  for dir in allegroLibDirs do
    args := args.push s!"-L{dir.toString}"
    -- rpath is a Unix concept; PE/COFF (Windows) does not support it
    if !System.Platform.isWindows then
      args := args.push s!"-Wl,-rpath,{dir.toString}"
  args := args ++ #[
    "-lallegro",
    "-lallegro_image",
    "-lallegro_font",
    "-lallegro_ttf",
    "-lallegro_primitives",
    "-lallegro_audio",
    "-lallegro_acodec",
    "-lallegro_color",
    "-lallegro_dialog",
    "-lallegro_video",
    "-lallegro_memfile"
  ]
  -- macOS bundles math in libSystem (no separate libm).
  -- Linux needs explicit -lm.
  if !System.Platform.isWindows && !System.Platform.isOSX then
    args := args.push "-lm"
  -- Lean's bundled ld.lld defaults to --no-allow-shlib-undefined which rejects
  -- versioned GLIBC math symbols (fmodf@GLIBC_2.38, etc.) referenced by the
  -- Allegro shared libraries.  Override on Linux so the dynamic linker resolves
  -- them at runtime.
  if !System.Platform.isWindows && !System.Platform.isOSX then
    args := args.push "-Wl,--allow-shlib-undefined"
  return args

-- ── Version from git branch ──

/-- Get the current git branch name (`main`, `0.1.0`, etc.). -/
private def gitBranch : String :=
  (runCmd "git" #["rev-parse", "--abbrev-ref", "HEAD"]).getD "unknown"

/-- Try to parse a string as `major.minor.patch`.  Returns `none` on failure. -/
private def parseSemVer (s : String) : Option StdVer := do
  let parts := s.splitOn "."
  guard (parts.length == 3)
  let major ← parts[0]!.toNat?
  let minor ← parts[1]!.toNat?
  let patch ← parts[2]!.toNat?
  pure { major, minor, patch, specialDescr := "" }

/-- Derive the package version from the git branch name.
    - Branch `0.1.0` → version `0.1.0` (clean release)
    - Branch `main`  → version `0.0.0-main` (prerelease) -/
def packageVersion : StdVer :=
  let branch := gitBranch
  (parseSemVer branch).getD { major := 0, minor := 0, patch := 0, specialDescr := branch }

-- ── Package & library ──

package AllegroInLean where
  version := packageVersion
  description := "Lean 4 FFI bindings to Allegro 5"

@[default_target]
lean_lib Allegro where
  srcDir := "src"

-- ── Shared test harness library ──

lean_lib «Tests.Harness» where
  srcDir := "tests"
  roots := #[`Tests.Harness]

-- ── Allegro exe helper ──
-- Eliminates duplication of moreLinkArgs / extraDepTargets across all
-- example and test executables by injecting those fields automatically.

open Lean Elab Command in
syntax (name := allegroExeDecl)
  "allegro_exe " Lake.DSL.identOrStr Lake.DSL.optConfig : command

open Lean Elab Command Syntax in
@[command_elab allegroExeDecl]
def elabAllegroExeDecl : CommandElab := fun stx => do
  let nameStx := stx[1]   -- identOrStr
  let cfgStx  := stx[2]   -- optConfig
  -- Build the extra fields we always inject.
  -- Must construct idents manually to avoid macro hygiene mangling field names.
  let mkField (fieldName : String) (val : Syntax) : Syntax :=
    mkNode ``Lake.DSL.declField #[
      mkIdent (Name.mkSimple fieldName),
      atom SourceInfo.none ":=",
      val
    ]
  let linkVal := Unhygienic.run `(allegroLinkArgs)
  let depVal := Unhygienic.run `(#[`allegroshim])
  let linkField := mkField "moreLinkArgs" linkVal
  let depField := mkField "extraDepTargets" depVal
  -- Extract existing fields from optConfig (where fs;*)
  let (existingFields, wds?, whereInfo) ← match cfgStx with
    | `(Lake.DSL.optConfig| where%$tk $fs;* $[$wds?:whereDecls]?) =>
      pure (fs.getElems, wds?, tk.getHeadInfo)
    | `(Lake.DSL.optConfig| ) =>
      pure (#[], none, SourceInfo.none)
    | _ => throwErrorAt cfgStx "ill-formed allegro_exe configuration"
  -- Combine fields
  let allFields := existingFields ++ #[linkField, depField]
  -- Build the augmented optConfig
  -- optConfig is `(declValWhere <|> declValStruct)?` so it wraps in a null node
  let whereTk := atom whereInfo "where"
  let fieldsStx := mkSep allFields mkNullNode
  let instFields := mkNode ``Lean.Parser.Term.structInstFields #[fieldsStx]
  let optWds := mkOptionalNode wds?
  let newValWhere := mkNode ``Lake.DSL.declValWhere #[whereTk, instFields, optWds]
  let newCfg := mkNode ``Lake.DSL.optConfig #[mkNullNode #[newValWhere]]
  -- Build the full lean_exe command:
  --   (docComment)? (attributes)? "lean_exe " (identOrStr)? optConfig
  let leanExeKw := atom SourceInfo.none "lean_exe "
  let newCmd := mkNode ``Lake.DSL.leanExeCommand
    #[mkNullNode, mkNullNode, leanExeKw, mkOptionalNode (some nameStx), newCfg]
  withMacroExpansion stx newCmd (elabCommand newCmd)

-- ── Example executables ──

allegro_exe allegroLoopDemo where
  root := `Examples.LoopDemo; srcDir := "examples"
allegro_exe allegroFullDemo where
  root := `Examples.FullDemo; srcDir := "examples"
allegro_exe allegroImageDemo where
  root := `Examples.ImageDemo; srcDir := "examples"
allegro_exe allegroFontDemo where
  root := `Examples.FontDemo; srcDir := "examples"
allegro_exe allegroTtfDemo where
  root := `Examples.TtfDemo; srcDir := "examples"
allegro_exe allegroPrimitivesDemo where
  root := `Examples.PrimitivesDemo; srcDir := "examples"
allegro_exe allegroAudioDemo where
  root := `Examples.AudioDemo; srcDir := "examples"
allegro_exe allegroInputDemo where
  root := `Examples.InputDemo; srcDir := "examples"
allegro_exe allegroTransformDemo where
  root := `Examples.TransformDemo; srcDir := "examples"
allegro_exe allegroJoystickDemo where
  root := `Examples.JoystickDemo; srcDir := "examples"
allegro_exe allegroEventDemo where
  root := `Examples.EventDemo; srcDir := "examples"
allegro_exe allegroGameLoopDemo where
  root := `Examples.GameLoopDemo; srcDir := "examples"
allegro_exe allegroConfigDemo where
  root := `Examples.ConfigDemo; srcDir := "examples"
allegro_exe allegroColorDemo where
  root := `Examples.ColorDemo; srcDir := "examples"
allegro_exe allegroUstrDemo where
  root := `Examples.UstrDemo; srcDir := "examples"
allegro_exe allegroPathDemo where
  root := `Examples.PathDemo; srcDir := "examples"
allegro_exe allegroBlendingDemo where
  root := `Examples.BlendingDemo; srcDir := "examples"
allegro_exe allegroNativeDialogDemo where
  root := `Examples.NativeDialogDemo; srcDir := "examples"
allegro_exe allegroVideoDemo where
  root := `Examples.VideoDemo; srcDir := "examples"
allegro_exe allegroSystemExtrasDemo where
  root := `Examples.SystemExtrasDemo; srcDir := "examples"
allegro_exe allegroDisplayExtrasDemo where
  root := `Examples.DisplayExtrasDemo; srcDir := "examples"
allegro_exe allegroBitmapExtrasDemo where
  root := `Examples.BitmapExtrasDemo; srcDir := "examples"
allegro_exe allegroEventExtrasDemo where
  root := `Examples.EventExtrasDemo; srcDir := "examples"
allegro_exe allegroTransformExtrasDemo where
  root := `Examples.TransformExtrasDemo; srcDir := "examples"
allegro_exe allegroPathExtrasDemo where
  root := `Examples.PathExtrasDemo; srcDir := "examples"
allegro_exe allegroUstrExtrasDemo where
  root := `Examples.UstrExtrasDemo; srcDir := "examples"
allegro_exe allegroColorExtrasDemo where
  root := `Examples.ColorExtrasDemo; srcDir := "examples"
allegro_exe allegroAudioExtrasDemo where
  root := `Examples.AudioExtrasDemo; srcDir := "examples"
allegro_exe allegroPrimitivesExtrasDemo where
  root := `Examples.PrimitivesExtrasDemo; srcDir := "examples"
allegro_exe allegroConfigExtrasDemo where
  root := `Examples.ConfigExtrasDemo; srcDir := "examples"
allegro_exe allegroFontExtrasDemo where
  root := `Examples.FontExtrasDemo; srcDir := "examples"
allegro_exe allegroFileIODemo where
  root := `Examples.FileIODemo; srcDir := "examples"
allegro_exe allegroShaderDemo where
  root := `Examples.ShaderDemo; srcDir := "examples"
allegro_exe allegroHapticDemo where
  root := `Examples.HapticDemo; srcDir := "examples"
allegro_exe allegroJoystickExtrasDemo where
  root := `Examples.JoystickExtrasDemo; srcDir := "examples"
allegro_exe allegroMenuExtrasDemo where
  root := `Examples.MenuExtrasDemo; srcDir := "examples"
allegro_exe allegroVideoFileDemo where
  root := `Examples.VideoFileDemo; srcDir := "examples"

-- ── Test executables ──

allegro_exe allegroSmoke where
  root := `Tests.Smoke; srcDir := "tests"
allegro_exe allegroFuncTest where
  root := `Tests.Functional; srcDir := "tests"
  needs := #[Allegro, «Tests.Harness»]
allegro_exe allegroErrorTest where
  root := `Tests.ErrorPath; srcDir := "tests"
  needs := #[Allegro, «Tests.Harness»]

-- ── C shim static library ──

extern_lib allegroshim (pkg : NPackage __name__) := do
  let libFile := pkg.buildDir / (Lake.nameToStaticLib "allegroshim")
  let srcFiles := #[
    "allegro_system.c",
    "allegro_display.c",
    "allegro_bitmap.c",
    "allegro_image.c",
    "allegro_font.c",
    "allegro_ttf.c",
    "allegro_primitives.c",
    "allegro_input.c",
    "allegro_event.c",
    "allegro_timer.c",
    "allegro_path.c",
    "allegro_ustr.c",
    "allegro_audio.c",
    "allegro_transforms.c",
    "allegro_blending.c",
    "allegro_joystick.c",
    "allegro_touch.c",
    "allegro_color.c",
    "allegro_config.c",
    "allegro_thread.c",
    "allegro_native_dialog.c",
    "allegro_video.c",
    "allegro_memfile.c",
    "allegro_file.c",
    "allegro_filesystem.c",
    "allegro_shader.c",
    "allegro_haptic.c"
  ]
  let lean ← getLeanInstall
  let mut oJobs : Array (Job System.FilePath) := #[]
  for file in srcFiles do
    let srcFile := pkg.dir / "ffi" / file
    let oFile := pkg.buildDir / "ffi" / (file.replace ".c" ".o")
    let srcJob ← inputFile srcFile false
    let mut cArgs := #["-fPIC", "-I", lean.includeDir.toString]
    -- Add ffi/ directory to include path so #include "allegro_ffi.h" works
    cArgs := cArgs.push "-I"
    cArgs := cArgs.push (pkg.dir / "ffi").toString
    for dir in allegroIncludeDirs do
      cArgs := cArgs.push "-I"
      cArgs := cArgs.push dir.toString
    let oJob ← buildO oFile srcJob cArgs
    oJobs := oJobs.push oJob
  buildStaticLib libFile oJobs
