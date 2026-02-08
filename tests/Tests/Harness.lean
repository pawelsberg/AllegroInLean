/-!
# Test harness

Shared helpers for all test executables. Provides `check` (with pass/fail
counting) and `printSection`.  Call `Harness.summary` at the end to print
totals and return an appropriate exit code.
-/

namespace Harness

/-- Mutable pass/fail counters, initialised once per process. -/
initialize passCount : IO.Ref Nat ← IO.mkRef 0
initialize failCount : IO.Ref Nat ← IO.mkRef 0

/-- Record a single assertion. Prints PASS or FAIL and updates counters. -/
def check (label : String) (ok : Bool) : IO Unit := do
  if ok then
    IO.println s!"  PASS: {label}"
    passCount.modify (· + 1)
  else
    IO.eprintln s!"  FAIL: {label}"
    failCount.modify (· + 1)

/-- Print a section heading. -/
def printSection (name : String) : IO Unit :=
  IO.println s!"── {name} ──"

/-- Print totals and return 0 on all-pass, 1 on any failure. -/
def summary : IO UInt32 := do
  let p ← passCount.get
  let f ← failCount.get
  IO.println ""
  IO.println s!"Results: {p} passed, {f} failed, {p + f} total"
  return if f == 0 then 0 else 1

end Harness
