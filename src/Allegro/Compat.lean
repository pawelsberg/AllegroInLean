import Allegro.Core
import Allegro.Addons

/-!
# Lean-Idiomatic Naming Compatibility Layer

Dot-notation aliases for all Allegro handle-based functions.
Import `Allegro.Compat` (or just `Allegro`, which re-exports it) to use
handle-centric names like `display.width` instead of `Allegro.getDisplayWidth display`.

The original C-style names remain available — this module only adds aliases.
-/

namespace Allegro

-- ════════════════════════════════════════════════════════════════════════════
-- Setup diagnostics
-- ════════════════════════════════════════════════════════════════════════════

/-- Verify common setup preconditions and print diagnostic warnings to stderr.
    Call this after your initialisation sequence to catch easy-to-miss mistakes:
    - Allegro system not initialised
    - Keyboard not installed
    - Audio not installed or samples not reserved

    Returns `true` if all checks pass. -/
def checkSetup : IO Bool := do
  let mut ok := true
  let sysOk ← isSystemInstalled
  if sysOk == 0 then
    IO.eprintln "[AllegroInLean] WARNING: Allegro system not initialised — call Allegro.init first"
    ok := false
  let kbOk ← isKeyboardInstalled
  if kbOk == 0 then
    IO.eprintln "[AllegroInLean] WARNING: Keyboard not installed — call Allegro.installKeyboard"
  let audioOk ← isAudioInstalled
  if audioOk == 0 then
    IO.eprintln "[AllegroInLean] WARNING: Audio not installed — call Allegro.installAudio + Allegro.initAcodecAddon"
  else do
    let mixer ← getDefaultMixer
    if mixer == (0 : UInt64) then
      IO.eprintln "[AllegroInLean] WARNING: No default mixer — did you call Allegro.reserveSamples?"
  return ok

-- ════════════════════════════════════════════════════════════════════════════
-- Display
-- ════════════════════════════════════════════════════════════════════════════

namespace Display

@[inline] def destroy            (d : Display) := destroyDisplay d
@[inline] def width              (d : Display) := getDisplayWidth d
@[inline] def height             (d : Display) := getDisplayHeight d
@[inline] def widthF             (d : Display) := getDisplayWidthF d
@[inline] def heightF            (d : Display) := getDisplayHeightF d
@[inline] def resize             (d : Display) (w h : UInt32) := resizeDisplay d w h
@[inline] def ackResize          (d : Display) := acknowledgeResize d
@[inline] def ackDrawingHalt     (d : Display) := acknowledgeDrawingHalt d
@[inline] def ackDrawingResume   (d : Display) := acknowledgeDrawingResume d
@[inline] def flags              (d : Display) := getDisplayFlags d
@[inline] def setFlag            (d : Display) (flag : DisplayFlags) (onOff : UInt32) := setDisplayFlag d flag onOff
@[inline] def option             (d : Display) (opt : DisplayOption) := getDisplayOption d opt
@[inline] def setTitle           (d : Display) (title : String) := setWindowTitle d title
@[inline] def setPosition        (d : Display) (x y : Int32) := setWindowPosition d x y
@[inline] def setConstraints     (d : Display) (minW minH maxW maxH : UInt32) := setWindowConstraints d minW minH maxW maxH
@[inline] def backbuffer         (d : Display) := getBackbuffer d
@[inline] def setAsTarget        (d : Display) := setTargetBackbuffer d
@[inline] def clipboardText      (d : Display) := getClipboardText d
@[inline] def setClipboard       (d : Display) (text : String) := setClipboardText d text
@[inline] def hasClipboardText   (d : Display) := clipboardHasText d
@[inline] def setIcon            (d : Display) (bmp : Bitmap) := setDisplayIcon d bmp
@[inline] def windowPosition     (d : Display) := getWindowPosition d
@[inline] def eventSource        (d : Display) := getDisplayEventSource d
@[inline] def hideMouseCursor    (d : Display) := Allegro.hideMouseCursor d
@[inline] def showMouseCursor    (d : Display) := Allegro.showMouseCursor d
@[inline] def setMouseCursor     (d : Display) (c : MouseCursor) := Allegro.setMouseCursor d c
@[inline] def setSystemCursor    (d : Display) (id : SystemCursor) := setSystemMouseCursor d id
@[inline] def setMouseXy         (d : Display) (x y : Int32) := Allegro.setMouseXy d x y
@[inline] def grabMouse          (d : Display) := Allegro.grabMouse d
@[inline] def pixelFormat        (d : Display) := getDisplayFormat d
@[inline] def refreshRate        (d : Display) := getDisplayRefreshRate d
@[inline] def orientation        (d : Display) : IO DisplayOrientation := getDisplayOrientation d
@[inline] def adapter            (d : Display) := getDisplayAdapter d
@[inline] def windowBorders      (d : Display) := getWindowBorders d
@[inline] def getConstraints     (d : Display) := getWindowConstraints d
@[inline] def applyConstraints   (d : Display) (onOff : UInt32) := applyWindowConstraints d onOff
@[inline] def setOptionLive      (d : Display) (opt : DisplayOption) (val : UInt32) := setDisplayOptionLive d opt val
@[inline] def setIcons           (d : Display) (icons : @&Array Bitmap) := setDisplayIcons d icons
@[inline] def backupDirtyBitmaps (d : Display) := Allegro.backupDirtyBitmaps d

end Display

-- ════════════════════════════════════════════════════════════════════════════
-- Bitmap
-- ════════════════════════════════════════════════════════════════════════════

namespace Bitmap

@[inline] def destroy             (b : Bitmap) := destroyBitmap b
@[inline] def clone               (b : Bitmap) := cloneBitmap b
@[inline] def clone?              (b : Bitmap) := cloneBitmap? b
@[inline] def createSub           (b : Bitmap) (x y w h : Int32) := createSubBitmap b x y w h
@[inline] def createSub?          (b : Bitmap) (x y w h : Int32) := createSubBitmap? b x y w h
@[inline] def convert             (b : Bitmap) := convertBitmap b
@[inline] def width               (b : Bitmap) := getBitmapWidth b
@[inline] def height              (b : Bitmap) := getBitmapHeight b
@[inline] def flags               (b : Bitmap) := getBitmapFlags b
@[inline] def format              (b : Bitmap) := getBitmapFormat b
@[inline] def isSub               (b : Bitmap) := isSubBitmap b
@[inline] def parent              (b : Bitmap) := getParentBitmap b
@[inline] def reparent            (b : Bitmap) (p : UInt64) (x y w h : Int32) := reparentBitmap b p x y w h
@[inline] def isLocked            (b : Bitmap) := isBitmapLocked b
@[inline] def setAsTarget         (b : Bitmap) := setTargetBitmap b
@[inline] def lock                (b : Bitmap) (fmt : PixelFormat) (fl : LockMode) := lockBitmap b fmt fl
@[inline] def lock?               (b : Bitmap) (fmt : PixelFormat) (fl : LockMode) := lockBitmap? b fmt fl
@[inline] def lockRegion          (b : Bitmap) (x y w h : Int32) (fmt : PixelFormat) (fl : LockMode) := lockBitmapRegion b x y w h fmt fl
@[inline] def unlock              (b : Bitmap) := unlockBitmap b
@[inline] def getPixelRgba        (b : Bitmap) (x y : Int32) := Allegro.getPixelRgba b x y
@[inline] def draw                (b : Bitmap) (dx dy : Float) (fl : FlipFlags) := drawBitmap b dx dy fl
@[inline] def drawScaled          (b : Bitmap) (sx sy sw sh dx dy dw dh : Float) (fl : FlipFlags) := drawScaledBitmap b sx sy sw sh dx dy dw dh fl
@[inline] def drawRegion          (b : Bitmap) (sx sy sw sh dx dy : Float) (fl : FlipFlags) := drawBitmapRegion b sx sy sw sh dx dy fl
@[inline] def drawRotated         (b : Bitmap) (cx cy dx dy angle : Float) (fl : FlipFlags) := drawRotatedBitmap b cx cy dx dy angle fl
@[inline] def drawScaledRotated   (b : Bitmap) (cx cy dx dy xsc ysc angle : Float) (fl : FlipFlags) := drawScaledRotatedBitmap b cx cy dx dy xsc ysc angle fl
@[inline] def drawTintedRgb       (b : Bitmap) (r g bl : UInt32) (dx dy : Float) (fl : FlipFlags) := drawTintedBitmapRgb b r g bl dx dy fl
@[inline] def drawTintedScaledRgb (b : Bitmap) (r g bl : UInt32) (sx sy sw sh dx dy dw dh : Float) (fl : FlipFlags) := drawTintedScaledBitmapRgb b r g bl sx sy sw sh dx dy dw dh fl
@[inline] def drawTintedRotatedRgb (b : Bitmap) (r g bl : UInt32) (cx cy dx dy angle : Float) (fl : FlipFlags) := drawTintedRotatedBitmapRgb b r g bl cx cy dx dy angle fl
@[inline] def drawTintedRgba      (b : Bitmap) (r g bl a : UInt32) (dx dy : Float) (fl : FlipFlags) := drawTintedBitmapRgba b r g bl a dx dy fl
@[inline] def save                (b : Bitmap) (filename : String) := saveBitmap filename b
@[inline] def depth               (b : Bitmap) := getBitmapDepth b
@[inline] def samples             (b : Bitmap) := getBitmapSamples b
@[inline] def x                   (b : Bitmap) := getBitmapX b
@[inline] def y                   (b : Bitmap) := getBitmapY b
@[inline] def convertMaskToAlpha  (b : Bitmap) (r g bl : UInt32) := Allegro.convertMaskToAlpha b r g bl
@[inline] def drawTintedRegionRgb (b : Bitmap) (r g bl : UInt32) (sx sy sw sh dx dy : Float) (fl : FlipFlags) := drawTintedBitmapRegionRgb b r g bl sx sy sw sh dx dy fl
@[inline] def drawTintedScaledRotatedRgb (b : Bitmap) (r g bl : UInt32) (cx cy dx dy xsc ysc angle : Float) (fl : FlipFlags) := drawTintedScaledRotatedBitmapRgb b r g bl cx cy dx dy xsc ysc angle fl
@[inline] def drawTintedScaledRotatedRegionRgb (b : Bitmap) (sx sy sw sh : Float) (r g bl : UInt32) (cx cy dx dy xsc ysc angle : Float) (fl : FlipFlags) := drawTintedScaledRotatedBitmapRegionRgb b sx sy sw sh r g bl cx cy dx dy xsc ysc angle fl
@[inline] def lockBlocked         (b : Bitmap) (fl : LockMode) := lockBitmapBlocked b fl
@[inline] def lockRegionBlocked   (b : Bitmap) (x y w h : Int32) (fl : LockMode) := lockBitmapRegionBlocked b x y w h fl
@[inline] def isCompatible        (b : Bitmap) := isCompatibleBitmap b
@[inline] def backupDirty         (b : Bitmap) := backupDirtyBitmap b

-- Color-accepting overloads
@[inline] def drawTinted           (b : Bitmap) (c : Color) (dx dy : Float) (fl : FlipFlags) := drawTintedRgb b c.r c.g c.b dx dy fl
@[inline] def drawTintedScaled     (b : Bitmap) (c : Color) (sx sy sw sh dx dy dw dh : Float) (fl : FlipFlags) := drawTintedScaledRgb b c.r c.g c.b sx sy sw sh dx dy dw dh fl
@[inline] def drawTintedRotated    (b : Bitmap) (c : Color) (cx cy dx dy angle : Float) (fl : FlipFlags) := drawTintedRotatedRgb b c.r c.g c.b cx cy dx dy angle fl
end Bitmap

-- ════════════════════════════════════════════════════════════════════════════
-- LockedRegion
-- ════════════════════════════════════════════════════════════════════════════

namespace LockedRegion

@[inline] def format    (lr : LockedRegion) := lockedRegionGetFormat lr
@[inline] def pitch     (lr : LockedRegion) := lockedRegionGetPitch lr
@[inline] def pixelSize (lr : LockedRegion) := lockedRegionGetPixelSize lr
@[inline] def data      (lr : LockedRegion) := lockedRegionGetData lr

end LockedRegion

-- ════════════════════════════════════════════════════════════════════════════
-- EventQueue
-- ════════════════════════════════════════════════════════════════════════════

namespace EventQueue

@[inline] def destroy           (q : EventQueue) := destroyEventQueue q
@[inline] def registerSource    (q : EventQueue) (src : EventSource) := registerEventSource q src
@[inline] def unregisterSource  (q : EventQueue) (src : EventSource) := unregisterEventSource q src
@[inline] def flush             (q : EventQueue) := flushEventQueue q
@[inline] def isPaused          (q : EventQueue) := isEventQueuePaused q
@[inline] def pause             (q : EventQueue) (onOff : UInt32) := pauseEventQueue q onOff
@[inline] def waitFor           (q : EventQueue) (ev : Event) := waitForEvent q ev
@[inline] def waitForTimed      (q : EventQueue) (ev : Event) (secs : Float) := waitForEventTimed q ev secs
@[inline] def getNext           (q : EventQueue) (ev : Event) := getNextEvent q ev
@[inline] def peekNext          (q : EventQueue) (ev : Event) := peekNextEvent q ev
@[inline] def dropNext          (q : EventQueue) := dropNextEvent q
@[inline] def isEmpty           (q : EventQueue) := isEventQueueEmpty q
@[inline] def waitForData       (q : EventQueue) := waitForEventData q
@[inline] def waitForTimedData  (q : EventQueue) (secs : Float) := waitForEventTimedData q secs
@[inline] def getNextData       (q : EventQueue) := getNextEventData q
@[inline] def peekNextData      (q : EventQueue) := peekNextEventData q
@[inline] def isSourceRegistered (q : EventQueue) (src : EventSource) := isEventSourceRegistered q src
@[inline] def waitForUntilData   (q : EventQueue) (t : Timeout) := waitForEventUntilData q t

end EventQueue

-- ════════════════════════════════════════════════════════════════════════════
-- EventSource
-- ════════════════════════════════════════════════════════════════════════════

namespace EventSource

@[inline] def destroy (es : EventSource) := destroyUserEventSource es
@[inline] def emit    (es : EventSource) (d1 d2 d3 d4 : UInt64) := emitUserEvent es d1 d2 d3 d4
@[inline] def getData (es : EventSource) := getEventSourceData es
@[inline] def setData (es : EventSource) (d : UInt64) := setEventSourceData es d

end EventSource

-- ════════════════════════════════════════════════════════════════════════════
-- Event
-- ════════════════════════════════════════════════════════════════════════════

namespace Event

@[inline] def destroy              (e : Event) := destroyEvent e
@[inline] def type                 (e : Event) : IO EventType := eventGetType e
@[inline] def timestamp            (e : Event) := eventGetTimestamp e
@[inline] def source               (e : Event) := eventGetSource e
@[inline] def keyboardKeycode      (e : Event) := eventGetKeyboardKeycode e
@[inline] def keyboardUnichar      (e : Event) := eventGetKeyboardUnichar e
@[inline] def keyboardModifiers    (e : Event) := eventGetKeyboardModifiers e
@[inline] def keyboardRepeat       (e : Event) := eventGetKeyboardRepeat e
@[inline] def mouseX               (e : Event) := eventGetMouseX e
@[inline] def mouseY               (e : Event) := eventGetMouseY e
@[inline] def mouseZ               (e : Event) := eventGetMouseZ e
@[inline] def mouseW               (e : Event) := eventGetMouseW e
@[inline] def mouseDx              (e : Event) := eventGetMouseDx e
@[inline] def mouseDy              (e : Event) := eventGetMouseDy e
@[inline] def mouseDz              (e : Event) := eventGetMouseDz e
@[inline] def mouseDw              (e : Event) := eventGetMouseDw e
@[inline] def mousePressure        (e : Event) := eventGetMousePressure e
@[inline] def mouseButton          (e : Event) := eventGetMouseButton e
@[inline] def mouseXf              (e : Event) := eventGetMouseXf e
@[inline] def mouseYf              (e : Event) := eventGetMouseYf e
@[inline] def mouseZf              (e : Event) := eventGetMouseZf e
@[inline] def mouseWf              (e : Event) := eventGetMouseWf e
@[inline] def mouseDxf             (e : Event) := eventGetMouseDxf e
@[inline] def mouseDyf             (e : Event) := eventGetMouseDyf e
@[inline] def displayX             (e : Event) := eventGetDisplayX e
@[inline] def displayY             (e : Event) := eventGetDisplayY e
@[inline] def displayWidth         (e : Event) := eventGetDisplayWidth e
@[inline] def displayHeight        (e : Event) := eventGetDisplayHeight e
@[inline] def displayOrientation   (e : Event) := eventGetDisplayOrientation e
@[inline] def displaySource        (e : Event) := eventGetDisplaySource e
@[inline] def timerCount           (e : Event) := eventGetTimerCount e
@[inline] def timerError           (e : Event) := eventGetTimerError e
@[inline] def timerTimestamp       (e : Event) := eventGetTimerTimestamp e
@[inline] def joystickId           (e : Event) := eventGetJoystickId e
@[inline] def joystickStick        (e : Event) := eventGetJoystickStick e
@[inline] def joystickAxis         (e : Event) := eventGetJoystickAxis e
@[inline] def joystickPos          (e : Event) := eventGetJoystickPos e
@[inline] def joystickButton       (e : Event) := eventGetJoystickButton e
@[inline] def touchId              (e : Event) := eventGetTouchId e
@[inline] def touchX               (e : Event) := eventGetTouchX e
@[inline] def touchY               (e : Event) := eventGetTouchY e
@[inline] def touchDx              (e : Event) := eventGetTouchDx e
@[inline] def touchDy              (e : Event) := eventGetTouchDy e
@[inline] def touchPrimary         (e : Event) := eventGetTouchPrimary e
@[inline] def userData1            (e : Event) := eventGetUserData1 e
@[inline] def userData2            (e : Event) := eventGetUserData2 e
@[inline] def userData3            (e : Event) := eventGetUserData3 e
@[inline] def userData4            (e : Event) := eventGetUserData4 e

end Event

-- ════════════════════════════════════════════════════════════════════════════
-- Timer
-- ════════════════════════════════════════════════════════════════════════════

namespace Timer

@[inline] def destroy     (t : Timer) := destroyTimer t
@[inline] def start       (t : Timer) := startTimer t
@[inline] def stop        (t : Timer) := stopTimer t
@[inline] def count       (t : Timer) := getTimerCount t
@[inline] def speed       (t : Timer) := getTimerSpeed t
@[inline] def setSpeed    (t : Timer) (secs : Float) := setTimerSpeed t secs
@[inline] def eventSource (t : Timer) := getTimerEventSource t
@[inline] def resume      (t : Timer) := resumeTimer t
@[inline] def isStarted   (t : Timer) := getTimerStarted t
@[inline] def setCount    (t : Timer) (v : UInt64) := setTimerCount t v
@[inline] def addCount    (t : Timer) (v : UInt64) := addTimerCount t v

end Timer

-- ════════════════════════════════════════════════════════════════════════════
-- Config
-- ════════════════════════════════════════════════════════════════════════════

namespace Config

@[inline] def destroy       (c : Config) := destroyConfig c
@[inline] def save          (c : Config) (filename : String) := saveConfigFile filename c
@[inline] def addSection    (c : Config) (sect : String) := addConfigSection c sect
@[inline] def removeSection (c : Config) (sect : String) := removeConfigSection c sect
@[inline] def setValue      (c : Config) (sect key value : String) := setConfigValue c sect key value
@[inline] def getValue      (c : Config) (sect key : String) := getConfigValue c sect key
@[inline] def removeKey     (c : Config) (sect key : String) := removeConfigKey c sect key
@[inline] def addComment    (c : Config) (sect comment : String) := addConfigComment c sect comment
@[inline] def merge         (c : Config) (other : Config) := mergeConfig c other
@[inline] def mergeInto     (c : Config) (add : Config) := mergeConfigInto c add
@[inline] def sections      (c : Config) := getConfigSections c
@[inline] def entries       (c : Config) (sect : String) := getConfigEntries c sect

end Config

-- ════════════════════════════════════════════════════════════════════════════
-- Transform
-- ════════════════════════════════════════════════════════════════════════════

namespace Transform

@[inline] def destroy          (t : Transform) := destroyTransform t
@[inline] def identity         (t : Transform) := identityTransform t
@[inline] def copyFrom         (t : Transform) (src : Transform) := copyTransform t src
@[inline] def use              (t : Transform) := useTransform t
@[inline] def translate        (t : Transform) (x y : Float) := translateTransform t x y
@[inline] def rotate           (t : Transform) (angle : Float) := rotateTransform t angle
@[inline] def scale            (t : Transform) (sx sy : Float) := scaleTransform t sx sy
@[inline] def build            (t : Transform) (x y sx sy theta : Float) := buildTransform t x y sx sy theta
@[inline] def compose          (t : Transform) (other : Transform) := composeTransform t other
@[inline] def invert           (t : Transform) := invertTransform t
@[inline] def checkInverse     (t : Transform) (tol : Float) := Allegro.checkInverse t tol
@[inline] def transformCoords  (t : Transform) (x y : Float) := transformCoordinates t x y
@[inline] def useProjection    (t : Transform) := useProjectionTransform t
@[inline] def orthographic     (t : Transform) (l tp n r b f : Float) := orthographicTransform t l tp n r b f
@[inline] def perspective      (t : Transform) (l tp n r b f : Float) := perspectiveTransform t l tp n r b f
@[inline] def horizontalShear  (t : Transform) (theta : Float) := horizontalShearTransform t theta
@[inline] def verticalShear    (t : Transform) (theta : Float) := verticalShearTransform t theta
@[inline] def translate3d      (t : Transform) (x y z : Float) := translateTransform3d t x y z
@[inline] def rotate3d         (t : Transform) (x y z angle : Float) := rotateTransform3d t x y z angle
@[inline] def scale3d          (t : Transform) (sx sy sz : Float) := scaleTransform3d t sx sy sz
@[inline] def transformCoords3d (t : Transform) (x y z : Float) := transformCoordinates3d t x y z
@[inline] def transformCoords3dProjective (t : Transform) (x y z : Float) := transformCoordinates3dProjective t x y z
@[inline] def transformCoords4d (t : Transform) (x y z w : Float) := transformCoordinates4d t x y z w
@[inline] def buildCamera      (t : Transform) (px py pz lx ly lz ux uy uz : Float) := buildCameraTransform t px py pz lx ly lz ux uy uz
@[inline] def transpose        (t : Transform) := transposeTransform t

end Transform

-- ════════════════════════════════════════════════════════════════════════════
-- Path
-- ════════════════════════════════════════════════════════════════════════════

namespace Path

@[inline] def destroy        (p : Path) := destroyPath p
@[inline] def clone          (p : Path) := clonePath p
@[inline] def makeCanonical  (p : Path) := makePathCanonical p
@[inline] def append         (p : Path) (comp : String) := appendPathComponent p comp
@[inline] def cstr           (p : Path) (sep : UInt32) := pathCstr p sep
@[inline] def drive          (p : Path) := getPathDrive p
@[inline] def filename       (p : Path) := getPathFilename p
@[inline] def numComponents    (p : Path) := getPathNumComponents p
@[inline] def component        (p : Path) (i : UInt32) := getPathComponent p i
@[inline] def insertComponent  (p : Path) (i : UInt32) (s : String) := insertPathComponent p i s
@[inline] def removeComponent  (p : Path) (i : UInt32) := removePathComponent p i
@[inline] def replaceComponent (p : Path) (i : UInt32) (s : String) := replacePathComponent p i s
@[inline] def tail             (p : Path) := getPathTail p
@[inline] def dropTail         (p : Path) := dropPathTail p
@[inline] def join             (p : Path) (other : Path) := joinPaths p other
@[inline] def rebase           (p : Path) (base : Path) := rebasePath p base
@[inline] def ustr             (p : Path) (sep : UInt32) := pathUstr p sep
@[inline] def setDrive         (p : Path) (drv : String) := setPathDrive p drv
@[inline] def setFilename      (p : Path) (name : String) := setPathFilename p name
@[inline] def extension        (p : Path) := getPathExtension p
@[inline] def setExtension     (p : Path) (ext : String) := setPathExtension p ext
@[inline] def basename         (p : Path) := getPathBasename p

end Path

-- ════════════════════════════════════════════════════════════════════════════
-- Ustr
-- ════════════════════════════════════════════════════════════════════════════

namespace Ustr

@[inline] def free             (u : Ustr) := ustrFree u
@[inline] def cstr             (u : Ustr) := ustrCstr u
@[inline] def size             (u : Ustr) := ustrSize u
@[inline] def length           (u : Ustr) := ustrLength u
@[inline] def dup              (u : Ustr) := ustrDup u
@[inline] def append           (u : Ustr) (other : Ustr) := ustrAppend u other
@[inline] def appendCstr       (u : Ustr) (s : String) := ustrAppendCstr u s
@[inline] def insertCstr       (u : Ustr) (pos : UInt32) (s : String) := ustrInsertCstr u pos s
@[inline] def insert           (u : Ustr) (pos : UInt32) (other : Ustr) := ustrInsert u pos other
@[inline] def removeRange      (u : Ustr) (s e : UInt32) := ustrRemoveRange u s e
@[inline] def get              (u : Ustr) (pos : UInt32) := ustrGet u pos
@[inline] def offset           (u : Ustr) (index : UInt32) := ustrOffset u index
@[inline] def setChr           (u : Ustr) (pos ch : UInt32) := ustrSetChr u pos ch
@[inline] def assignCstr       (u : Ustr) (s : String) := ustrAssignCstr u s
@[inline] def replaceRange     (u : Ustr) (s e : UInt32) (other : Ustr) := ustrReplaceRange u s e other
@[inline] def truncate         (u : Ustr) (pos : UInt32) := ustrTruncate u pos
@[inline] def equal            (u : Ustr) (other : Ustr) := ustrEqual u other
@[inline] def compare          (u : Ustr) (other : Ustr) := ustrCompare u other
@[inline] def ncompare         (u : Ustr) (other : Ustr) (n : UInt32) := ustrNcompare u other n
@[inline] def hasPrefix        (u : Ustr) (pfx : String) := ustrHasPrefixCstr u pfx
@[inline] def hasSuffix        (u : Ustr) (sfx : String) := ustrHasSuffixCstr u sfx
@[inline] def findChr          (u : Ustr) (startPos ch : UInt32) := ustrFindChr u startPos ch
@[inline] def rfindChr         (u : Ustr) (endPos ch : UInt32) := ustrRfindChr u endPos ch
@[inline] def findCstr         (u : Ustr) (startPos : UInt32) (needle : String) := ustrFindCstr u startPos needle
@[inline] def ltrimWs          (u : Ustr) := ustrLtrimWs u
@[inline] def rtrimWs          (u : Ustr) := ustrRtrimWs u
@[inline] def trimWs           (u : Ustr) := ustrTrimWs u
@[inline] def dupSubstr        (u : Ustr) (s e : UInt32) := ustrDupSubstr u s e
@[inline] def next             (u : Ustr) (pos : UInt32) := ustrNext u pos
@[inline] def prev             (u : Ustr) (pos : UInt32) := ustrPrev u pos
@[inline] def getNextRaw       (u : Ustr) (pos : UInt32) := ustrGetNextRaw u pos
@[inline] def prevGetRaw       (u : Ustr) (pos : UInt32) := ustrPrevGetRaw u pos
@[inline] def insertChr        (u : Ustr) (pos ch : UInt32) := ustrInsertChr u pos ch
@[inline] def appendChr        (u : Ustr) (ch : UInt32) := ustrAppendChr u ch
@[inline] def removeChr        (u : Ustr) (pos : UInt32) := ustrRemoveChr u pos
@[inline] def assign           (u : Ustr) (other : Ustr) := ustrAssign u other
@[inline] def assignSubstr    (u : Ustr) (other : Ustr) (s e : UInt32) := ustrAssignSubstr u other s e
@[inline] def rfindCstr        (u : Ustr) (endPos : UInt32) (needle : String) := ustrRfindCstr u endPos needle
@[inline] def findSetCstr      (u : Ustr) (startPos : UInt32) (accept : String) := ustrFindSetCstr u startPos accept
@[inline] def findCsetCstr     (u : Ustr) (startPos : UInt32) (reject : String) := ustrFindCsetCstr u startPos reject
@[inline] def findReplaceCstr  (u : Ustr) (startPos : UInt32) (find replace : String) := ustrFindReplaceCstr u startPos find replace
@[inline] def findSet          (u : Ustr) (startPos : UInt32) (accept : Ustr) := ustrFindSet u startPos accept
@[inline] def findCset         (u : Ustr) (startPos : UInt32) (reject : Ustr) := ustrFindCset u startPos reject
@[inline] def findStr          (u : Ustr) (startPos : UInt32) (needle : Ustr) := ustrFindStr u startPos needle
@[inline] def rfindStr         (u : Ustr) (endPos : UInt32) (needle : Ustr) := ustrRfindStr u endPos needle
@[inline] def findReplace      (u : Ustr) (startPos : UInt32) (find replace : Ustr) := ustrFindReplace u startPos find replace
@[inline] def hasPrefixUstr    (u : Ustr) (pfx : Ustr) := Allegro.ustrHasPrefix u pfx
@[inline] def hasSuffixUstr    (u : Ustr) (sfx : Ustr) := Allegro.ustrHasSuffix u sfx
@[inline] def sizeUtf16        (u : Ustr) := ustrSizeUtf16 u
@[inline] def cstrDup          (u : Ustr) := Allegro.cstrDup u
@[inline] def toBuffer         (u : Ustr) := ustrToBuffer u
@[inline] def ref              (u : Ustr) (s e : UInt32) := refUstr u s e
@[inline] def encodeUtf16      (u : Ustr) := ustrEncodeUtf16 u

end Ustr

-- ════════════════════════════════════════════════════════════════════════════
-- Joystick
-- ════════════════════════════════════════════════════════════════════════════

namespace Joystick

@[inline] def release    (j : Joystick) := releaseJoystick j
@[inline] def isActive   (j : Joystick) := getJoystickActive j
@[inline] def name       (j : Joystick) := getJoystickName j
@[inline] def numSticks  (j : Joystick) := getJoystickNumSticks j
@[inline] def stickName  (j : Joystick) (stick : UInt32) := getJoystickStickName j stick
@[inline] def numAxes    (j : Joystick) (stick : UInt32) := getJoystickNumAxes j stick
@[inline] def axisName   (j : Joystick) (stick axis : UInt32) := getJoystickAxisName j stick axis
@[inline] def numButtons (j : Joystick) := getJoystickNumButtons j
@[inline] def buttonName  (j : Joystick) (button : UInt32) := getJoystickButtonName j button
@[inline] def getState    (j : Joystick) (s : JoystickState) := getJoystickState j s
@[inline] def stickFlags  (j : Joystick) (stick : UInt32) := getJoystickStickFlags j stick
@[inline] def guid        (j : Joystick) := getJoystickGuid j
@[inline] def joystickType (j : Joystick) := getJoystickType j

end Joystick

-- ════════════════════════════════════════════════════════════════════════════
-- JoystickState
-- ════════════════════════════════════════════════════════════════════════════

namespace JoystickState

@[inline] def destroy (s : JoystickState) := destroyJoystickState s
@[inline] def axis    (s : JoystickState) (stick ax : UInt32) := joystickStateGetAxis s stick ax
@[inline] def button  (s : JoystickState) (b : UInt32) := joystickStateGetButton s b

end JoystickState

-- ════════════════════════════════════════════════════════════════════════════
-- KeyboardState
-- ════════════════════════════════════════════════════════════════════════════

namespace KeyboardState

@[inline] def destroy (ks : KeyboardState) := destroyKeyboardState ks
@[inline] def get     (ks : KeyboardState) := getKeyboardState ks
@[inline] def keyDown (ks : KeyboardState) (keycode : KeyCode) := Allegro.keyDown ks keycode

end KeyboardState

-- ════════════════════════════════════════════════════════════════════════════
-- MouseState
-- ════════════════════════════════════════════════════════════════════════════

namespace MouseState

@[inline] def destroy    (ms : MouseState) := destroyMouseState ms
@[inline] def get        (ms : MouseState) := getMouseState ms
@[inline] def buttonDown (ms : MouseState) (b : UInt32) := mouseButtonDown ms b
@[inline] def axis       (ms : MouseState) (i : UInt32) := getMouseStateAxis ms i

end MouseState

-- ════════════════════════════════════════════════════════════════════════════
-- MouseCursor
-- ════════════════════════════════════════════════════════════════════════════

namespace MouseCursor

@[inline] def destroy (mc : MouseCursor) := destroyMouseCursor mc

end MouseCursor

-- ════════════════════════════════════════════════════════════════════════════
-- State
-- ════════════════════════════════════════════════════════════════════════════

namespace State

@[inline] def destroy (s : State) := destroyState s
@[inline] def store   (s : State) (flags : StateFlags) := storeState s flags
@[inline] def restore (s : State) := restoreState s

end State

-- ════════════════════════════════════════════════════════════════════════════
-- Font
-- ════════════════════════════════════════════════════════════════════════════

namespace Font

@[inline] def destroy              (f : Font) := destroyFont f
@[inline] def drawTextRgb          (f : Font) (r g b : UInt32) (x y : Float) (fl : TextAlign) (text : String) := Allegro.drawTextRgb f r g b x y fl text
@[inline] def drawTextRgba         (f : Font) (r g b a : UInt32) (x y : Float) (fl : TextAlign) (text : String) := Allegro.drawTextRgba f r g b a x y fl text
@[inline] def drawUstrRgb          (f : Font) (r g b : UInt32) (x y : Float) (fl : TextAlign) (u : UInt64) := Allegro.drawUstrRgb f r g b x y fl u
@[inline] def drawJustifiedTextRgb (f : Font) (r g b : UInt32) (x1 x2 y diff : Float) (fl : TextAlign) (text : String) := Allegro.drawJustifiedTextRgb f r g b x1 x2 y diff fl text
@[inline] def drawMultilineTextRgb (f : Font) (r g b : UInt32) (x y maxW lineH : Float) (fl : TextAlign) (text : String) := Allegro.drawMultilineTextRgb f r g b x y maxW lineH fl text
@[inline] def drawGlyphRgb         (f : Font) (r g b : UInt32) (x y : Float) (cp : Int32) := Allegro.drawGlyphRgb f r g b x y cp
@[inline] def glyphWidth           (f : Font) (cp : Int32) := getGlyphWidth f cp
@[inline] def glyphAdvance         (f : Font) (cp1 cp2 : Int32) := getGlyphAdvance f cp1 cp2
@[inline] def textWidth            (f : Font) (text : String) := getTextWidth f text
@[inline] def lineHeight           (f : Font) := getFontLineHeight f
@[inline] def ascent               (f : Font) := getFontAscent f
@[inline] def descent              (f : Font) := getFontDescent f
@[inline] def ranges               (f : Font) (maxRanges : Int32) := getFontRanges f maxRanges
@[inline] def ustrWidth            (f : Font) (u : UInt64) := getUstrWidth f u
@[inline] def textDimensions       (f : Font) (text : String) := getTextDimensions f text
@[inline] def setFallback          (f : Font) (fallback : Font) := setFallbackFont f fallback
@[inline] def fallback             (f : Font) := getFallbackFont f
@[inline] def fallback?            (f : Font) := getFallbackFont? f
@[inline] def doMultiline          (f : Font) (maxW : Float) (text : String) := doMultilineText f maxW text
@[inline] def doMultilineUstr      (f : Font) (maxW : Float) (u : UInt64) := Allegro.doMultilineUstr f maxW u
@[inline] def glyph                (f : Font) (cp : UInt32) := getGlyph f cp

-- Color-accepting overloads
@[inline] def drawText             (f : Font) (c : Color) (x y : Float) (fl : TextAlign) (text : String) := Allegro.drawText f c x y fl text
@[inline] def drawJustifiedText    (f : Font) (c : Color) (x1 x2 y diff : Float) (fl : TextAlign) (text : String) := drawJustifiedTextRgb f c.r c.g c.b x1 x2 y diff fl text
@[inline] def drawMultilineText    (f : Font) (c : Color) (x y maxW lineH : Float) (fl : TextAlign) (text : String) := drawMultilineTextRgb f c.r c.g c.b x y maxW lineH fl text
@[inline] def drawGlyph            (f : Font) (c : Color) (x y : Float) (cp : Int32) := drawGlyphRgb f c.r c.g c.b x y cp
end Font

-- ════════════════════════════════════════════════════════════════════════════
-- Sample
-- ════════════════════════════════════════════════════════════════════════════

namespace Sample

@[inline] def destroy   (s : Sample) := destroySample s
@[inline] def play      (s : Sample) (gain pan speed : Float) (loop : Playmode) := playSample s gain pan speed loop
@[inline] def playOnce  (s : Sample) := Allegro.playOnce s
@[inline] def playLoop  (s : Sample) := Allegro.playLoop s
@[inline] def playWith  (s : Sample) (params : PlayParams := {}) := Allegro.playWith s params
@[inline] def frequency (s : Sample) := getSampleFrequency s
@[inline] def length    (s : Sample) := getSampleLength s
@[inline] def depth     (s : Sample) : IO AudioDepth := getSampleDepth s
@[inline] def channels   (s : Sample) : IO ChannelConf := getSampleChannels s
@[inline] def sampleData (s : Sample) := getSampleData s

end Sample

-- ════════════════════════════════════════════════════════════════════════════
-- SampleInstance
-- ════════════════════════════════════════════════════════════════════════════

namespace SampleInstance

@[inline] def destroy      (si : SampleInstance) := destroySampleInstance si
@[inline] def play         (si : SampleInstance) := playSampleInstance si
@[inline] def stop         (si : SampleInstance) := stopSampleInstance si
@[inline] def isPlaying    (si : SampleInstance) := getSampleInstancePlaying si
@[inline] def setPlaying   (si : SampleInstance) (v : UInt32) := setSampleInstancePlaying si v
@[inline] def gain         (si : SampleInstance) := getSampleInstanceGain si
@[inline] def setGain      (si : SampleInstance) (v : Float) := setSampleInstanceGain si v
@[inline] def pan          (si : SampleInstance) := getSampleInstancePan si
@[inline] def setPan       (si : SampleInstance) (v : Float) := setSampleInstancePan si v
@[inline] def speed        (si : SampleInstance) := getSampleInstanceSpeed si
@[inline] def setSpeed     (si : SampleInstance) (v : Float) := setSampleInstanceSpeed si v
@[inline] def position     (si : SampleInstance) := getSampleInstancePosition si
@[inline] def setPosition  (si : SampleInstance) (v : UInt32) := setSampleInstancePosition si v
@[inline] def length       (si : SampleInstance) := getSampleInstanceLength si
@[inline] def playmode     (si : SampleInstance) : IO Playmode := getSampleInstancePlaymode si
@[inline] def setPlaymode  (si : SampleInstance) (v : Playmode) := setSampleInstancePlaymode si v
@[inline] def detach           (si : SampleInstance) := detachSampleInstance si
@[inline] def attachToMixer     (si : SampleInstance) (m : Mixer) := attachSampleInstanceToMixer si m
@[inline] def frequency         (si : SampleInstance) := getSampleInstanceFrequency si
@[inline] def channels          (si : SampleInstance) : IO ChannelConf := getSampleInstanceChannels si
@[inline] def audioDepth        (si : SampleInstance) : IO AudioDepth := getSampleInstanceDepth si
@[inline] def isAttached        (si : SampleInstance) := getSampleInstanceAttached si
@[inline] def time              (si : SampleInstance) := getSampleInstanceTime si
@[inline] def setLength         (si : SampleInstance) (v : UInt32) := setSampleInstanceLength si v
@[inline] def attachToVoice     (si : SampleInstance) (v : Voice) := attachSampleInstanceToVoice si v
@[inline] def sample            (si : SampleInstance) := getSample si
@[inline] def setSample         (si : SampleInstance) (s : Sample) := Allegro.setSample si s
@[inline] def setChannelMatrix  (si : SampleInstance) (m : @&ByteArray) := setSampleInstanceChannelMatrix si m

end SampleInstance

-- ════════════════════════════════════════════════════════════════════════════
-- AudioStream
-- ════════════════════════════════════════════════════════════════════════════

namespace AudioStream

@[inline] def destroy       (s : AudioStream) := destroyAudioStream s
@[inline] def drain         (s : AudioStream) := drainAudioStream s
@[inline] def rewind        (s : AudioStream) := rewindAudioStream s
@[inline] def isPlaying     (s : AudioStream) := getAudioStreamPlaying s
@[inline] def setPlaying    (s : AudioStream) (v : UInt32) := setAudioStreamPlaying s v
@[inline] def gain          (s : AudioStream) := getAudioStreamGain s
@[inline] def setGain       (s : AudioStream) (v : Float) := setAudioStreamGain s v
@[inline] def pan           (s : AudioStream) := getAudioStreamPan s
@[inline] def setPan        (s : AudioStream) (v : Float) := setAudioStreamPan s v
@[inline] def speed         (s : AudioStream) := getAudioStreamSpeed s
@[inline] def setSpeed      (s : AudioStream) (v : Float) := setAudioStreamSpeed s v
@[inline] def playmode      (s : AudioStream) : IO Playmode := getAudioStreamPlaymode s
@[inline] def setPlaymode   (s : AudioStream) (v : Playmode) := setAudioStreamPlaymode s v
@[inline] def seekSecs      (s : AudioStream) (secs : Float) := seekAudioStreamSecs s secs
@[inline] def positionSecs  (s : AudioStream) := getAudioStreamPositionSecs s
@[inline] def lengthSecs    (s : AudioStream) := getAudioStreamLengthSecs s
@[inline] def setLoopSecs   (s : AudioStream) (start stop : Float) := setAudioStreamLoopSecs s start stop
@[inline] def eventSource      (s : AudioStream) := getAudioStreamEventSource s
@[inline] def attachToMixer    (s : AudioStream) (m : Mixer) := attachAudioStreamToMixer s m
@[inline] def detach           (s : AudioStream) := detachAudioStream s
@[inline] def frequency        (s : AudioStream) := getAudioStreamFrequency s
@[inline] def streamLength     (s : AudioStream) := getAudioStreamLength s
@[inline] def fragments        (s : AudioStream) := getAudioStreamFragments s
@[inline] def availableFragments (s : AudioStream) := getAvailableAudioStreamFragments s
@[inline] def channels         (s : AudioStream) : IO ChannelConf := getAudioStreamChannels s
@[inline] def audioDepth       (s : AudioStream) : IO AudioDepth := getAudioStreamDepth s
@[inline] def isAttached       (s : AudioStream) := getAudioStreamAttached s
@[inline] def playedSamples    (s : AudioStream) := getAudioStreamPlayedSamples s
@[inline] def getFragment      (s : AudioStream) := getAudioStreamFragment s
@[inline] def setFragment      (s : AudioStream) (ptr : UInt64) := setAudioStreamFragment s ptr
@[inline] def attachToVoice    (s : AudioStream) (v : Voice) := attachAudioStreamToVoice s v
@[inline] def setChannelMatrix (s : AudioStream) (m : @&ByteArray) := setAudioStreamChannelMatrix s m

end AudioStream

-- ════════════════════════════════════════════════════════════════════════════
-- Mixer
-- ════════════════════════════════════════════════════════════════════════════

namespace Mixer

@[inline] def destroy       (m : Mixer) := destroyMixer m
@[inline] def setAsDefault  (m : Mixer) := setDefaultMixer m
@[inline] def attachToMixer (m : Mixer) (parent : Mixer) := attachMixerToMixer m parent
@[inline] def detach        (m : Mixer) := detachMixer m
@[inline] def frequency     (m : Mixer) := getMixerFrequency m
@[inline] def setFrequency  (m : Mixer) (v : UInt32) := setMixerFrequency m v
@[inline] def gain          (m : Mixer) := getMixerGain m
@[inline] def setGain       (m : Mixer) (v : Float) := setMixerGain m v
@[inline] def quality       (m : Mixer) : IO MixerQuality := getMixerQuality m
@[inline] def setQuality    (m : Mixer) (v : MixerQuality) := setMixerQuality m v
@[inline] def isPlaying     (m : Mixer) := getMixerPlaying m
@[inline] def setPlaying      (m : Mixer) (v : UInt32) := setMixerPlaying m v
@[inline] def attachToVoice   (m : Mixer) (v : Voice) := attachMixerToVoice m v
@[inline] def channels        (m : Mixer) : IO ChannelConf := getMixerChannels m
@[inline] def audioDepth      (m : Mixer) : IO AudioDepth := getMixerDepth m
@[inline] def isAttached      (m : Mixer) := getMixerAttached m
@[inline] def hasAttachments  (m : Mixer) := mixerHasAttachments m

end Mixer

-- ════════════════════════════════════════════════════════════════════════════
-- Voice
-- ════════════════════════════════════════════════════════════════════════════

namespace Voice

@[inline] def destroy    (v : Voice) := destroyVoice v
@[inline] def detach     (v : Voice) := detachVoice v
@[inline] def frequency  (v : Voice) := getVoiceFrequency v
@[inline] def isPlaying      (v : Voice) := getVoicePlaying v
@[inline] def setPlaying     (v : Voice) (val : UInt32) := setVoicePlaying v val
@[inline] def position       (v : Voice) := getVoicePosition v
@[inline] def setPosition    (v : Voice) (pos : UInt32) := setVoicePosition v pos
@[inline] def channels       (v : Voice) : IO ChannelConf := getVoiceChannels v
@[inline] def audioDepth     (v : Voice) : IO AudioDepth := getVoiceDepth v
@[inline] def hasAttachments (v : Voice) := voiceHasAttachments v

end Voice

-- ════════════════════════════════════════════════════════════════════════════
-- Mutex
-- ════════════════════════════════════════════════════════════════════════════

namespace Mutex

@[inline] def destroy (m : Mutex) := destroyMutex m
@[inline] def lock    (m : Mutex) := lockMutex m
@[inline] def unlock  (m : Mutex) := unlockMutex m

end Mutex

-- ════════════════════════════════════════════════════════════════════════════
-- Cond
-- ════════════════════════════════════════════════════════════════════════════

namespace Cond

@[inline] def destroy   (c : Cond) := destroyCond c
@[inline] def wait      (c : Cond) (m : Mutex) := waitCond c m
@[inline] def waitUntil (c : Cond) (m : Mutex) (secs : Float) := waitCondUntil c m secs
@[inline] def broadcast (c : Cond) := broadcastCond c
@[inline] def signal    (c : Cond) := signalCond c

end Cond

-- ════════════════════════════════════════════════════════════════════════════
-- FileChooser
-- ════════════════════════════════════════════════════════════════════════════

namespace FileChooser

@[inline] def destroy (fc : FileChooser) := destroyNativeFileDialog fc
@[inline] def present (fc : FileChooser) (d : Display) := showNativeFileDialog d fc
@[inline] def count   (fc : FileChooser) := getNativeFileDialogCount fc
@[inline] def path    (fc : FileChooser) (i : UInt32) := getNativeFileDialogPath fc i

end FileChooser

-- ════════════════════════════════════════════════════════════════════════════
-- TextLog
-- ════════════════════════════════════════════════════════════════════════════

namespace TextLog

@[inline] def close       (tl : TextLog) := closeNativeTextLog tl
@[inline] def append      (tl : TextLog) (text : String) := appendNativeTextLog tl text
@[inline] def eventSource (tl : TextLog) := getNativeTextLogEventSource tl

end TextLog

-- ════════════════════════════════════════════════════════════════════════════
-- Menu
-- ════════════════════════════════════════════════════════════════════════════

namespace Menu

@[inline] def destroy          (m : Menu) := destroyMenu m
@[inline] def clone            (m : Menu) := cloneMenu m
@[inline] def cloneForPopup    (m : Menu) := cloneMenuForPopup m
@[inline] def appendItem       (m : Menu) (title : String) (id : UInt32) (flags : MenuItemFlags) (icon : Bitmap) (sub : Menu) := appendMenuItem m title id flags icon sub
@[inline] def insertItem       (m : Menu) (pos : UInt32) (title : String) (id : UInt32) (flags : MenuItemFlags) (icon : Bitmap) (sub : Menu) := insertMenuItem m pos title id flags icon sub
@[inline] def removeItem       (m : Menu) (pos : UInt32) := removeMenuItem m pos
@[inline] def itemCaption      (m : Menu) (pos : UInt32) := getMenuItemCaption m pos
@[inline] def setItemCaption   (m : Menu) (pos : UInt32) (cap : String) := setMenuItemCaption m pos cap
@[inline] def itemFlags        (m : Menu) (pos : UInt32) := getMenuItemFlags m pos
@[inline] def setItemFlags     (m : Menu) (pos : UInt32) (flags : MenuItemFlags) := setMenuItemFlags m pos flags
@[inline] def itemIcon         (m : Menu) (pos : UInt32) := getMenuItemIcon m pos
@[inline] def setItemIcon      (m : Menu) (pos : UInt32) (icon : Bitmap) := setMenuItemIcon m pos icon
@[inline] def find             (m : Menu) (id : UInt32) := findMenu m id
@[inline] def find?            (m : Menu) (id : UInt32) := Allegro.findMenu? m id
@[inline] def toggleItemFlags  (m : Menu) (pos : Int32) (fl : MenuItemFlags) := toggleMenuItemFlags m pos fl
@[inline] def enableEvents     (m : Menu) := enableMenuEventSource m
@[inline] def disableEvents    (m : Menu) := disableMenuEventSource m
@[inline] def popup            (m : Menu) (d : Display) := popupMenu m d

end Menu

-- ════════════════════════════════════════════════════════════════════════════
-- Video
-- ════════════════════════════════════════════════════════════════════════════

namespace Video

@[inline] def close           (v : Video) := closeVideo v
@[inline] def start           (v : Video) (mixer : UInt64) := startVideo v mixer
@[inline] def startWithVoice  (v : Video) (voice : UInt64) := startVideoWithVoice v voice
@[inline] def setPlaying      (v : Video) (p : UInt32) := setVideoPlaying v p
@[inline] def isPlaying       (v : Video) := isVideoPlaying v
@[inline] def seek            (v : Video) (pos : Float) := seekVideo v pos
@[inline] def eventSource     (v : Video) := getVideoEventSource v
@[inline] def audioRate       (v : Video) := getVideoAudioRate v
@[inline] def fps             (v : Video) := getVideoFps v
@[inline] def scaledWidth     (v : Video) := getVideoScaledWidth v
@[inline] def scaledHeight    (v : Video) := getVideoScaledHeight v
@[inline] def frame           (v : Video) := getVideoFrame v
@[inline] def position        (v : Video) (which : VideoPosition) := getVideoPosition v which

end Video

-- ════════════════════════════════════════════════════════════════════════════
-- VertexBuffer
-- ════════════════════════════════════════════════════════════════════════════

namespace VertexBuffer

@[inline] def destroy (vb : VertexBuffer) := destroyVertexBuffer vb
@[inline] def size    (vb : VertexBuffer) := getVertexBufferSize vb
@[inline] def lock    (vb : VertexBuffer) (offset length : UInt32) (flags : PrimBufferFlags) := lockVertexBuffer vb offset length flags
@[inline] def unlock  (vb : VertexBuffer) := unlockVertexBuffer vb

end VertexBuffer

-- ════════════════════════════════════════════════════════════════════════════
-- IndexBuffer
-- ════════════════════════════════════════════════════════════════════════════

namespace IndexBuffer

@[inline] def destroy (ib : IndexBuffer) := destroyIndexBuffer ib
@[inline] def size    (ib : IndexBuffer) := getIndexBufferSize ib
@[inline] def lock    (ib : IndexBuffer) (offset length : UInt32) (flags : PrimBufferFlags) := lockIndexBuffer ib offset length flags
@[inline] def unlock  (ib : IndexBuffer) := unlockIndexBuffer ib

end IndexBuffer

-- ════════════════════════════════════════════════════════════════════════════
-- AudioRecorder
-- ════════════════════════════════════════════════════════════════════════════

namespace AudioRecorder

@[inline] def destroy     (ar : AudioRecorder) := destroyAudioRecorder ar
@[inline] def start       (ar : AudioRecorder) := startAudioRecorder ar
@[inline] def stop        (ar : AudioRecorder) := stopAudioRecorder ar
@[inline] def isRecording (ar : AudioRecorder) := isAudioRecorderRecording ar
@[inline] def eventSource (ar : AudioRecorder) := getAudioRecorderEventSource ar

end AudioRecorder

-- ════════════════════════════════════════════════════════════════════════════
-- VertexDecl
-- ════════════════════════════════════════════════════════════════════════════

namespace VertexDecl

@[inline] def destroy (vd : VertexDecl) := destroyVertexDecl vd

end VertexDecl

-- ════════════════════════════════════════════════════════════════════════════
-- AllegroFile
-- ════════════════════════════════════════════════════════════════════════════

namespace AllegroFile

@[inline] def close       (f : AllegroFile) := fclose f
@[inline] def read         (f : AllegroFile) (size : UInt32) := fread f size
@[inline] def write        (f : AllegroFile) (data : ByteArray) := fwrite f data
@[inline] def flush        (f : AllegroFile) := fflush f
@[inline] def tell         (f : AllegroFile) := ftell f
@[inline] def seek         (f : AllegroFile) (offset : UInt64) (whence : UInt32) := fseek f offset whence
@[inline] def eof          (f : AllegroFile) := feof f
@[inline] def error        (f : AllegroFile) := ferror f
@[inline] def errmsg       (f : AllegroFile) := ferrmsg f
@[inline] def clearerr     (f : AllegroFile) := fclearerr f
@[inline] def size         (f : AllegroFile) := fsize f
@[inline] def getc         (f : AllegroFile) := fgetc f
@[inline] def putc         (f : AllegroFile) (c : UInt32) := fputc f c
@[inline] def ungetc       (f : AllegroFile) (c : UInt32) := fungetc f c
@[inline] def read16le     (f : AllegroFile) := fread16le f
@[inline] def read16be     (f : AllegroFile) := fread16be f
@[inline] def read32le     (f : AllegroFile) := fread32le f
@[inline] def read32be     (f : AllegroFile) := fread32be f
@[inline] def write16le    (f : AllegroFile) (w : UInt32) := fwrite16le f w
@[inline] def write16be    (f : AllegroFile) (w : UInt32) := fwrite16be f w
@[inline] def write32le    (f : AllegroFile) (l : UInt32) := fwrite32le f l
@[inline] def write32be    (f : AllegroFile) (l : UInt32) := fwrite32be f l
@[inline] def gets         (f : AllegroFile) (max : UInt32) := fgets f max
@[inline] def getUstr      (f : AllegroFile) := fgetUstr f
@[inline] def puts         (f : AllegroFile) (s : String) := fputs f s
@[inline] def slice        (f : AllegroFile) (size : UInt32) (mode : String) := fopenSlice f size mode
@[inline] def userdata     (f : AllegroFile) := getFileUserdata f

end AllegroFile

-- ════════════════════════════════════════════════════════════════════════════
-- FsEntry
-- ════════════════════════════════════════════════════════════════════════════

namespace FsEntry

@[inline] def destroy       (e : FsEntry) := destroyFsEntry e
@[inline] def name          (e : FsEntry) := getFsEntryName e
@[inline] def update        (e : FsEntry) := updateFsEntry e
@[inline] def mode          (e : FsEntry) := getFsEntryMode e
@[inline] def atime         (e : FsEntry) := getFsEntryAtime e
@[inline] def mtime         (e : FsEntry) := getFsEntryMtime e
@[inline] def ctime         (e : FsEntry) := getFsEntryCtime e
@[inline] def size          (e : FsEntry) := getFsEntrySize e
@[inline] def exists_       (e : FsEntry) := fsEntryExists e
@[inline] def remove        (e : FsEntry) := removeFsEntry e
@[inline] def openDir       (e : FsEntry) := openDirectory e
@[inline] def readDir       (e : FsEntry) := readDirectory e
@[inline] def closeDir      (e : FsEntry) := closeDirectory e
@[inline] def openAsFile    (e : FsEntry) (mode : String) := openFsEntry e mode

end FsEntry

-- ════════════════════════════════════════════════════════════════════════════
-- Shader
-- ════════════════════════════════════════════════════════════════════════════

namespace Shader

@[inline] def destroy           (s : Shader) := destroyShader s
@[inline] def attachSource      (s : Shader) (type : ShaderType) (src : String) := attachShaderSource s type src
@[inline] def attachSourceFile  (s : Shader) (type : ShaderType) (fn : String) := attachShaderSourceFile s type fn
@[inline] def build             (s : Shader) := buildShader s
@[inline] def log               (s : Shader) := getShaderLog s
@[inline] def platform          (s : Shader) := getShaderPlatform s
@[inline] def use               (s : Shader) := useShader s

end Shader

-- ════════════════════════════════════════════════════════════════════════════
-- Haptic
-- ════════════════════════════════════════════════════════════════════════════

namespace Haptic

@[inline] def release       (h : Haptic) := releaseHaptic h
@[inline] def isActive      (h : Haptic) := isHapticActive h
@[inline] def capabilities  (h : Haptic) := getHapticCapabilities h
@[inline] def isCapable     (h : Haptic) (cap : UInt32) := isHapticCapable h cap
@[inline] def setGain       (h : Haptic) (g : Float) := setHapticGain h g
@[inline] def getGain       (h : Haptic) := getHapticGain h
@[inline] def setAutocenter (h : Haptic) (i : Float) := setHapticAutocenter h i
@[inline] def getAutocenter (h : Haptic) := getHapticAutocenter h
@[inline] def maxEffects    (h : Haptic) := getMaxHapticEffects h
@[inline] def rumble        (h : Haptic) (intensity duration : Float) := rumbleHaptic h intensity duration

end Haptic

-- ════════════════════════════════════════════════════════════════════════════
-- HapticEffectId
-- ════════════════════════════════════════════════════════════════════════════

namespace HapticEffectId

@[inline] def stop       (eid : HapticEffectId) := stopHapticEffect eid
@[inline] def isPlaying  (eid : HapticEffectId) := isHapticEffectPlaying eid
@[inline] def release    (eid : HapticEffectId) := releaseHapticEffect eid

end HapticEffectId

end Allegro
