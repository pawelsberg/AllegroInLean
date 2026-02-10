-- MenuExtrasDemo — demonstrates gap-fill Native Dialog menu APIs.
-- Console-only — no display needed.
--
-- Showcases: buildMenu, findMenuItem, toggleMenuItemFlags
import Allegro

open Allegro

def main : IO Unit := do
  let ok ← Allegro.init
  if ok == 0 then IO.eprintln "al_init failed"; return
  let _ ← Allegro.initNativeDialogAddon

  IO.println "── Menu Extras Demo ──"

  -- buildMenu — construct a simple menu from parallel arrays
  -- captions, ids, flags, icons
  -- Menu structure: "File" (id 1), "->" submenu start, "Open" (id 2), "" end submenu
  let captions := #["File->", "Open", "Save", "", "Quit"]
  let ids      := #[(1 : UInt32), 2, 3, 0, 4]
  let flags    := #[MenuItemFlags.enabled, MenuItemFlags.enabled, MenuItemFlags.enabled, MenuItemFlags.enabled, MenuItemFlags.enabled]
  let icons    := #[(0 : UInt64), 0, 0, 0, 0]
  let menu ← Allegro.buildMenu captions ids flags icons
  IO.println s!"  buildMenu = {menu}"

  if menu != 0 then
    -- findMenuItem — search for "Open" (id 2)
    let found ← Allegro.findMenuItem menu (2 : UInt32)
    match found with
    | some (subMenu, idx) =>
      IO.println s!"  findMenuItem(2) = found in menu {subMenu} at index {idx}"
    | none =>
      IO.println "  findMenuItem(2) = not found"

    -- toggleMenuItemFlags — toggle "disabled" flag on item id 3 (Save)
    -- ALLEGRO_MENU_ITEM_DISABLED = 0x08
    let oldFlags ← menu.toggleItemFlags (3 : Int32) MenuItemFlags.disabled
    IO.println s!"  toggleMenuItemFlags(3, DISABLED) → old flags = {oldFlags.val}"

    -- toggle again to restore
    let restored ← menu.toggleItemFlags (3 : Int32) MenuItemFlags.disabled
    IO.println s!"  toggleMenuItemFlags(3, DISABLED) again → flags = {restored.val}"

    menu.destroy
    IO.println "  destroyMenu — OK"

  Allegro.shutdownNativeDialogAddon
  Allegro.uninstallSystem
  IO.println "── done ──"
