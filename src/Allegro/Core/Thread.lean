/-!
# Allegro Mutex & Condition Variable Bindings

Allegro's mutex and condition variable primitives, useful for synchronizing
multiple Lean `Task`s that access shared Allegro resources.

> **Note:** Thread *creation* functions (`al_create_thread`,
> `al_run_detached_thread`) are intentionally omitted — they require C
> function-pointer callbacks that would need to enter the Lean runtime on a
> foreign OS thread, which is unsafe.  Use Lean's own `Task.spawn` / `IO.asTask`
> for concurrency.

## Basic usage

```
let mtx ← Allegro.createMutex
Allegro.lockMutex mtx
-- … access shared state …
Allegro.unlockMutex mtx
Allegro.destroyMutex mtx
```

## Condition variables

```
let cond ← Allegro.createCond
let mtx  ← Allegro.createMutex
-- producer:
Allegro.lockMutex mtx
-- … update shared data …
Allegro.signalCond cond
Allegro.unlockMutex mtx
-- consumer:
Allegro.lockMutex mtx
Allegro.waitCond cond mtx    -- atomically unlocks mtx, waits, re-locks
-- … consume data …
Allegro.unlockMutex mtx
```
-/
namespace Allegro

-- ── Handle types ──

/-- Opaque handle to an Allegro mutex (ALLEGRO_MUTEX). -/
def Mutex := UInt64

instance : BEq Mutex := inferInstanceAs (BEq UInt64)
instance : Inhabited Mutex := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Mutex := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Mutex 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Mutex := ⟨fun (h : UInt64) => s!"Mutex#{h}"⟩
instance : Repr Mutex := ⟨fun (h : UInt64) _ => .text s!"Mutex#{repr h}"⟩

/-- The null mutex handle. -/
def Mutex.null : Mutex := (0 : UInt64)

/-- Opaque handle to an Allegro condition variable (ALLEGRO_COND). -/
def Cond := UInt64

instance : BEq Cond := inferInstanceAs (BEq UInt64)
instance : Inhabited Cond := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Cond := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Cond 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Cond := ⟨fun (h : UInt64) => s!"Cond#{h}"⟩
instance : Repr Cond := ⟨fun (h : UInt64) _ => .text s!"Cond#{repr h}"⟩

/-- The null cond handle. -/
def Cond.null : Cond := (0 : UInt64)

-- ── Mutex operations ──

/-- Create a new mutex. Returns a handle that must be destroyed with `destroyMutex`. -/
@[extern "allegro_al_create_mutex"]
opaque createMutex : IO Mutex

/-- Create a new recursive mutex (can be locked multiple times by the same thread). -/
@[extern "allegro_al_create_mutex_recursive"]
opaque createMutexRecursive : IO Mutex

/-- Lock the mutex. Blocks until the lock is acquired.
    **Caution:** This blocks the calling OS thread, which will stall one of
    Lean's worker threads. Keep critical sections short. -/
@[extern "allegro_al_lock_mutex"]
opaque lockMutex : Mutex → IO Unit

/-- Unlock the mutex. -/
@[extern "allegro_al_unlock_mutex"]
opaque unlockMutex : Mutex → IO Unit

/-- Destroy the mutex. Must not be locked when destroyed. -/
@[extern "allegro_al_destroy_mutex"]
opaque destroyMutex : Mutex → IO Unit

-- ── Condition variable operations ──

/-- Create a new condition variable. Returns a handle that must be destroyed with `destroyCond`. -/
@[extern "allegro_al_create_cond"]
opaque createCond : IO Cond

/-- Destroy the condition variable. -/
@[extern "allegro_al_destroy_cond"]
opaque destroyCond : Cond → IO Unit

/-- Wait on a condition variable. Atomically unlocks `mutex`, waits on `cond`,
    then re-locks `mutex` before returning.
    **Caution:** This blocks the calling OS thread indefinitely. -/
@[extern "allegro_al_wait_cond"]
opaque waitCond : Cond → Mutex → IO Unit

/-- Wait on a condition variable with a timeout (in seconds from now).
    Returns 1 if the condition was signalled, 0 on timeout. -/
@[extern "allegro_al_wait_cond_until"]
opaque waitCondUntil : Cond → Mutex → Float → IO UInt32

/-- Wake all threads waiting on the condition variable. -/
@[extern "allegro_al_broadcast_cond"]
opaque broadcastCond : Cond → IO Unit

/-- Wake one thread waiting on the condition variable. -/
@[extern "allegro_al_signal_cond"]
opaque signalCond : Cond → IO Unit

-- ── RAII-style helper ──

/-- Acquire a mutex, run an action, and release the mutex even if the action throws.
    ```
    let result ← Allegro.withMutex mtx do
      -- … critical section …
      pure someValue
    ```
-/
def withMutex (mtx : Mutex) (action : IO α) : IO α := do
  lockMutex mtx
  try
    action
  finally
    unlockMutex mtx

end Allegro
