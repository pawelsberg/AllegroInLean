import Allegro.Core.Display
import Allegro.Core.Bitmap
import Allegro.Core.Events

/-!
# Native dialog addon bindings

Provides platform-native file chooser dialogs, message boxes, text log windows,
and application menus.

Requires the Allegro native dialog addon library (`liballegro_dialog`), which in
turn needs GTK 3 on Linux. Initialise with `initNativeDialogAddon` before use.

**Wayland note:** Allegro 5.2's GTK dialog backend forces the X11 GDK backend
(`gdk_set_allowed_backends("x11")`). On Wayland sessions the addon will fail to
initialise unless XWayland is available. Set the environment variable
`GDK_BACKEND=x11` before launching the application, e.g.
`GDK_BACKEND=x11 ./myapp`.

## File chooser
```
let _ ← Allegro.initNativeDialogAddon
let fc ← Allegro.createNativeFileDialog "" "Choose a file" "*.*" 0
let _ ← Allegro.showNativeFileDialog display fc
let count ← Allegro.getNativeFileDialogCount fc
for i in List.range count.toNat do
  let path ← Allegro.getNativeFileDialogPath fc i.toUInt32
  IO.println s!"Selected: {path}"
Allegro.destroyNativeFileDialog fc
```

## Message box
```
let _ ← Allegro.showNativeMessageBox display "Title" "Heading" "Body text" "" 0
```

## Text log
```
let tl ← Allegro.openNativeTextLog "Debug" 0
Allegro.appendNativeTextLog tl "Hello, world!\n"
-- register tl's event source for close events …
Allegro.closeNativeTextLog tl
```

## Menus
```
let menu ← Allegro.createMenu
let _ ← Allegro.appendMenuItem menu "File" 1 0 0 0
let _ ← Allegro.setDisplayMenu display menu
```
-/
namespace Allegro

-- ════════════════════════════════════════════════════════════════════════════
-- Handle types
-- ════════════════════════════════════════════════════════════════════════════

/-- Opaque handle to a native file chooser dialog (ALLEGRO_FILECHOOSER). -/
def FileChooser := UInt64

instance : BEq FileChooser := inferInstanceAs (BEq UInt64)
instance : Inhabited FileChooser := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq FileChooser := inferInstanceAs (DecidableEq UInt64)
instance : OfNat FileChooser 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString FileChooser := ⟨fun (h : UInt64) => s!"FileChooser#{h}"⟩
instance : Repr FileChooser := ⟨fun (h : UInt64) _ => .text s!"FileChooser#{repr h}"⟩

/-- The null file chooser handle. -/
def FileChooser.null : FileChooser := (0 : UInt64)

/-- Opaque handle to a native text log window (ALLEGRO_TEXTLOG). -/
def TextLog := UInt64

instance : BEq TextLog := inferInstanceAs (BEq UInt64)
instance : Inhabited TextLog := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq TextLog := inferInstanceAs (DecidableEq UInt64)
instance : OfNat TextLog 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString TextLog := ⟨fun (h : UInt64) => s!"TextLog#{h}"⟩
instance : Repr TextLog := ⟨fun (h : UInt64) _ => .text s!"TextLog#{repr h}"⟩

/-- The null text log handle. -/
def TextLog.null : TextLog := (0 : UInt64)

/-- Opaque handle to an application menu (ALLEGRO_MENU). -/
def Menu := UInt64

instance : BEq Menu := inferInstanceAs (BEq UInt64)
instance : Inhabited Menu := inferInstanceAs (Inhabited UInt64)
instance : DecidableEq Menu := inferInstanceAs (DecidableEq UInt64)
instance : OfNat Menu 0 := inferInstanceAs (OfNat UInt64 0)
instance : ToString Menu := ⟨fun (h : UInt64) => s!"Menu#{h}"⟩
instance : Repr Menu := ⟨fun (h : UInt64) _ => .text s!"Menu#{repr h}"⟩

/-- The null menu handle. -/
def Menu.null : Menu := (0 : UInt64)

-- ════════════════════════════════════════════════════════════════════════════
-- Constants — file chooser mode flags
-- ════════════════════════════════════════════════════════════════════════════

/-- The file must already exist (for open dialogs). -/
def filechooserFileMustExist : UInt32 := 1
/-- Show a "Save" dialog instead of "Open". -/
def filechooserSave           : UInt32 := 2
/-- Select folders instead of files. -/
def filechooserFolder         : UInt32 := 4
/-- Show a pictures-only filter. -/
def filechooserPictures       : UInt32 := 8
/-- Show hidden files. -/
def filechooserShowHidden     : UInt32 := 16
/-- Allow selecting multiple files. -/
def filechooserMultiple       : UInt32 := 32

-- ════════════════════════════════════════════════════════════════════════════
-- Constants — message box flags
-- ════════════════════════════════════════════════════════════════════════════

/-- Show a warning icon. -/
def messageboxWarn       : UInt32 := 1
/-- Show an error icon. -/
def messageboxError      : UInt32 := 2
/-- Show OK and Cancel buttons (returns 1 for OK, 2 for Cancel). -/
def messageboxOkCancel   : UInt32 := 4
/-- Show Yes and No buttons (returns 1 for Yes, 2 for No). -/
def messageboxYesNo      : UInt32 := 8
/-- Show a question icon. -/
def messageboxQuestion   : UInt32 := 16

-- ════════════════════════════════════════════════════════════════════════════
-- Constants — text log flags
-- ════════════════════════════════════════════════════════════════════════════

/-- Do not show a close button on the text log window. -/
def textlogNoClose   : UInt32 := 1
/-- Use a monospace font in the text log. -/
def textlogMonospace : UInt32 := 2

-- ════════════════════════════════════════════════════════════════════════════
-- Constants — menu item flags
-- ════════════════════════════════════════════════════════════════════════════

/-- Menu item is enabled (default). -/
def menuItemEnabled   : UInt32 := 0
/-- Menu item has a checkbox. -/
def menuItemCheckbox  : UInt32 := 1
/-- Menu item checkbox is checked. -/
def menuItemChecked   : UInt32 := 2
/-- Menu item is disabled (greyed out). -/
def menuItemDisabled  : UInt32 := 4

-- ════════════════════════════════════════════════════════════════════════════
-- Constants — event types
-- ════════════════════════════════════════════════════════════════════════════

/-- Fired when the user closes a native text log window. -/
def eventNativeDialogClose : UInt32 := 600
/-- Fired when the user clicks a menu item. -/
def eventMenuClick         : UInt32 := 601

-- ════════════════════════════════════════════════════════════════════════════
-- Addon lifecycle
-- ════════════════════════════════════════════════════════════════════════════

/-- Initialise the native dialog addon. Returns 1 on success. -/
@[extern "allegro_al_init_native_dialog_addon"]
opaque initNativeDialogAddon : IO UInt32

/-- Shut down the native dialog addon. -/
@[extern "allegro_al_shutdown_native_dialog_addon"]
opaque shutdownNativeDialogAddon : IO Unit

/-- Returns 1 if the native dialog addon is initialised. -/
@[extern "allegro_al_is_native_dialog_addon_initialized"]
opaque isNativeDialogAddonInitialized : IO UInt32

/-- Get the version of the native dialog addon (encoded as for `al_get_allegro_version`). -/
@[extern "allegro_al_get_allegro_native_dialog_version"]
opaque getNativeDialogVersion : IO UInt32

-- ════════════════════════════════════════════════════════════════════════════
-- File chooser
-- ════════════════════════════════════════════════════════════════════════════

/-- Create a native file chooser dialog.
    - `initialPath`: starting directory or file (use `""` for default)
    - `title`: dialog title
    - `patterns`: semicolon-separated file patterns, e.g. `"*.png;*.jpg"`
    - `mode`: combination of `filechooser*` flags -/
@[extern "allegro_al_create_native_file_dialog"]
opaque createNativeFileDialog : String → String → String → UInt32 → IO FileChooser

/-- Create a native file chooser, returning `none` on failure. -/
def createNativeFileDialog? (initialPath title patterns : String) (mode : UInt32) :
    IO (Option FileChooser) :=
  liftOption (createNativeFileDialog initialPath title patterns mode)

/-- Show the file chooser dialog (blocks until the user closes it).
    Returns 1 on success (user selected file(s)). -/
@[extern "allegro_al_show_native_file_dialog"]
opaque showNativeFileDialog : Display → FileChooser → IO UInt32

/-- Get the number of files selected in the dialog. -/
@[extern "allegro_al_get_native_file_dialog_count"]
opaque getNativeFileDialogCount : FileChooser → IO UInt32

/-- Get the path of the `index`-th selected file (0-based). -/
@[extern "allegro_al_get_native_file_dialog_path"]
opaque getNativeFileDialogPath : FileChooser → UInt32 → IO String

/-- Destroy a file chooser dialog. -/
@[extern "allegro_al_destroy_native_file_dialog"]
opaque destroyNativeFileDialog : FileChooser → IO Unit

-- ════════════════════════════════════════════════════════════════════════════
-- Message box
-- ════════════════════════════════════════════════════════════════════════════

/-- Show a native message box. Blocks until the user dismisses it.
    - `display`: parent display (use 0 for no parent)
    - `title`, `heading`, `text`: the message content
    - `buttons`: custom button labels separated by `|`, or `""` for default OK
    - `flags`: combination of `messagebox*` flags
    Returns the 1-based index of the button pressed (0 if dialog was closed). -/
@[extern "allegro_al_show_native_message_box"]
opaque showNativeMessageBox : Display → String → String → String → String → UInt32 → IO UInt32

-- ════════════════════════════════════════════════════════════════════════════
-- Text log
-- ════════════════════════════════════════════════════════════════════════════

/-- Open a native text log window.
    - `title`: window title
    - `flags`: combination of `textlog*` flags -/
@[extern "allegro_al_open_native_text_log"]
opaque openNativeTextLog : String → UInt32 → IO TextLog

/-- Open a native text log, returning `none` on failure. -/
def openNativeTextLog? (title : String) (flags : UInt32) : IO (Option TextLog) :=
  liftOption (openNativeTextLog title flags)

/-- Close and destroy a text log window. -/
@[extern "allegro_al_close_native_text_log"]
opaque closeNativeTextLog : TextLog → IO Unit

/-- Append a string to the text log. Formatting should be done on the Lean side. -/
@[extern "allegro_al_append_native_text_log"]
opaque appendNativeTextLog : TextLog → String → IO Unit

/-- Get the event source for a text log (fires `eventNativeDialogClose`). -/
@[extern "allegro_al_get_native_text_log_event_source"]
opaque getNativeTextLogEventSource : TextLog → IO EventSource

-- ════════════════════════════════════════════════════════════════════════════
-- Menu — creation / destruction
-- ════════════════════════════════════════════════════════════════════════════

/-- Create a new empty menu bar. -/
@[extern "allegro_al_create_menu"]
opaque createMenu : IO Menu

/-- Create a new empty popup (context) menu. -/
@[extern "allegro_al_create_popup_menu"]
opaque createPopupMenu : IO Menu

/-- Destroy a menu and all its children. -/
@[extern "allegro_al_destroy_menu"]
opaque destroyMenu : Menu → IO Unit

/-- Clone a menu (deep copy). -/
@[extern "allegro_al_clone_menu"]
opaque cloneMenu : Menu → IO Menu

/-- Clone a menu as a popup menu. -/
@[extern "allegro_al_clone_menu_for_popup"]
opaque cloneMenuForPopup : Menu → IO Menu

-- ════════════════════════════════════════════════════════════════════════════
-- Menu — items
-- ════════════════════════════════════════════════════════════════════════════

/-- Append an item to a menu. Pass `""` as title for a separator.
    - `parent`: the menu to append to
    - `title`: item label (use `""` for separator)
    - `id`: unique item ID
    - `flags`: combination of `menuItem*` flags
    - `icon`: bitmap icon (use 0 for none)
    - `submenu`: child menu (use 0 for none)
    Returns the index of the new item, or -1 on failure. -/
@[extern "allegro_al_append_menu_item"]
opaque appendMenuItem : Menu → String → UInt32 → UInt32 → Bitmap → Menu → IO UInt32

/-- Insert an item into a menu at position `pos` (0-based).
    Same parameters as `appendMenuItem`. -/
@[extern "allegro_al_insert_menu_item"]
opaque insertMenuItem : Menu → UInt32 → String → UInt32 → UInt32 → Bitmap → Menu → IO UInt32

/-- Remove the item at position `pos`. Returns 1 on success. -/
@[extern "allegro_al_remove_menu_item"]
opaque removeMenuItem : Menu → UInt32 → IO UInt32

-- ════════════════════════════════════════════════════════════════════════════
-- Menu — item properties
-- ════════════════════════════════════════════════════════════════════════════

/-- Get the caption of the item at position `pos`. -/
@[extern "allegro_al_get_menu_item_caption"]
opaque getMenuItemCaption : Menu → UInt32 → IO String

/-- Set the caption of the item at position `pos`. -/
@[extern "allegro_al_set_menu_item_caption"]
opaque setMenuItemCaption : Menu → UInt32 → String → IO Unit

/-- Get the flags of the item at position `pos`. -/
@[extern "allegro_al_get_menu_item_flags"]
opaque getMenuItemFlags : Menu → UInt32 → IO UInt32

/-- Set the flags of the item at position `pos`. -/
@[extern "allegro_al_set_menu_item_flags"]
opaque setMenuItemFlags : Menu → UInt32 → UInt32 → IO Unit

/-- Get the icon bitmap of the item at position `pos`. Returns 0 if none. -/
@[extern "allegro_al_get_menu_item_icon"]
opaque getMenuItemIcon : Menu → UInt32 → IO Bitmap

/-- Set the icon bitmap of the item at position `pos`. Pass 0 to clear. -/
@[extern "allegro_al_set_menu_item_icon"]
opaque setMenuItemIcon : Menu → UInt32 → Bitmap → IO Unit

-- ════════════════════════════════════════════════════════════════════════════
-- Menu — querying
-- ════════════════════════════════════════════════════════════════════════════

/-- Find a submenu by its item ID. Returns 0 if not found. -/
@[extern "allegro_al_find_menu"]
opaque findMenu : Menu → UInt32 → IO Menu

/-- Find a submenu by ID, returning `none` if not found. -/
def findMenu? (haystack : Menu) (id : UInt32) : IO (Option Menu) :=
  liftOption (findMenu haystack id)

-- ════════════════════════════════════════════════════════════════════════════
-- Menu — events
-- ════════════════════════════════════════════════════════════════════════════

/-- Get the default event source that receives events from all menus. -/
@[extern "allegro_al_get_default_menu_event_source"]
opaque getDefaultMenuEventSource : IO EventSource

/-- Enable a per-menu event source (overrides the default). Returns the event source. -/
@[extern "allegro_al_enable_menu_event_source"]
opaque enableMenuEventSource : Menu → IO EventSource

/-- Disable the per-menu event source (revert to the default). -/
@[extern "allegro_al_disable_menu_event_source"]
opaque disableMenuEventSource : Menu → IO Unit

-- ════════════════════════════════════════════════════════════════════════════
-- Menu — display integration
-- ════════════════════════════════════════════════════════════════════════════

/-- Get the menu currently attached to a display. Returns 0 if none. -/
@[extern "allegro_al_get_display_menu"]
opaque getDisplayMenu : Display → IO Menu

/-- Attach a menu bar to a display. Returns 1 on success.
    Pass menu 0 to remove the current menu (prefer `removeDisplayMenu`). -/
@[extern "allegro_al_set_display_menu"]
opaque setDisplayMenu : Display → Menu → IO UInt32

/-- Show a popup menu at the current mouse position. Returns 1 on success. -/
@[extern "allegro_al_popup_menu"]
opaque popupMenu : Menu → Display → IO UInt32

/-- Remove the menu from a display, returning the removed Menu handle. -/
@[extern "allegro_al_remove_display_menu"]
opaque removeDisplayMenu : Display → IO Menu

-- ── Menu item flag toggling ──

/-- Toggle flags on a menu item at position `pos`.
    Returns the *old* flags that were changed, or negative on error. -/
@[extern "allegro_al_toggle_menu_item_flags"]
opaque toggleMenuItemFlags : Menu → Int32 → UInt32 → IO UInt32

-- ── Find menu item ──

/-- Search for a menu item by its unique ID.
    Returns `(found, containingMenu, index)` where `found` is 1 if the item
    was located, `containingMenu` is the sub-menu that owns it, and `index`
    is the item's position within that sub-menu. -/
@[extern "allegro_al_find_menu_item"]
opaque findMenuItem' : Menu → UInt32 → IO (UInt32 × Menu × UInt32)

/-- Search for a menu item by ID, returning `some (containingMenu, index)` or `none`. -/
def findMenuItem (menu : Menu) (id : UInt32) : IO (Option (Menu × UInt32)) := do
  let (found, m, idx) ← findMenuItem' menu id
  if found != 0 then return some (m, idx) else return none

-- ── Build menu from info array ──

/-- Build a complete menu tree from a flat array of `ALLEGRO_MENU_INFO` entries.
    The four parallel arrays encode each entry:
    - `captions`: item text (`""` for end-of-submenu marker, append `"->"` suffix for submenu start)
    - `ids`: item IDs (use `65535` with empty caption for separator)
    - `flags`: item flags (e.g. `0` for enabled)
    - `icons`: bitmap handles (`0` for no icon)
    The array is automatically null-terminated. -/
@[extern "allegro_al_build_menu"]
opaque buildMenu : @&Array String → @&Array UInt32 → @&Array UInt32 → @&Array UInt64 → IO Menu

/-- Build a menu, returning `none` on failure. -/
def buildMenu? (captions : @&Array String) (ids flags : @&Array UInt32) (icons : @&Array UInt64) : IO (Option Menu) :=
  liftOption (buildMenu captions ids flags icons)

end Allegro
