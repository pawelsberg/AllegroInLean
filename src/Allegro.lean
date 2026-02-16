import Allegro.Core
import Allegro.Addons
import Allegro.Resource
import Allegro.Compat
import Allegro.Math
import Allegro.Vec2
import Allegro.GameLoop

/-!
# Allegro — Lean 4 bindings for the Allegro 5 game-programming library

This is the root import module. Importing `Allegro` brings in every
sub-module: core APIs (display, input, events, bitmaps …), addon APIs
(audio, fonts, image I/O, primitives, native dialogs, video, memfile),
the RAII `Resource` helper, the dot-notation `Compat` layer, and utility
modules (`Math`, `Vec2`, `GameLoop`).
-/
