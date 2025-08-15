--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

-- NOTE: xmobar config used from http://www.haskell.org/haskellwiki/Xmonad/Config_archive/John_Goerzen's_Configuration
-- but I still don't know what made the xmonad to tile xmobar and other windows properly (and not one over another)

import XMonad
import Data.Monoid
import XMonad.Hooks.DynamicLog
import XMonad.Util.Run(spawnPipe)
import System.IO
import System.Directory
import System.Exit
import XMonad.Hooks.ManageDocks
import XMonad.Layout.NoBorders
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioNext,
    xF86XK_AudioMute,
    xF86XK_AudioPlay,
    xF86XK_AudioPrev)

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal  = "urxvt"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask
-- modmS           = mod1Mask

-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
myNumlockMask   = mod2Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = map show [0..12]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#222222"
myFocusedBorderColor = "#ff0000"

button8 = 8 :: Button
button9 = 9 :: Button

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

  , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
  -- The 'sleep' before running the 'scrot -s' command is to leave time for keys to be released before scrot -s tries to grab the keyboard.
  -- http://www.haskell.org/haskellwiki/Xmonad/Config_archive/John_Goerzen's_Configuration
  , ((0, xK_Print), spawn "scrot")

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")

    , ((0, xF86XK_AudioNext), spawn "mpc next")
    , ((0, xF86XK_AudioMute), spawn "amixer set Master toggle")
    , ((0, xF86XK_AudioPlay), spawn "mpc toggle")
    , ((0, xF86XK_AudioPrev), spawn "mpc prev")

  --  launch clean terminal
  , ((mod1Mask .|. shiftMask, xK_Return), spawn myTerminal)

    , ((mod1Mask .|. shiftMask,           xK_1   ), spawn "urxvt -e tmux new -ADs primary") , ((mod1Mask,           xK_F2   ), spawn "urxvt -e tmux new -ADs wip")
    , ((mod1Mask,           xK_equal  ), spawn "urxvt -e su -l -c 'tmux new -ADs primary'")

  -- toggle keymap
  , ((shiftMask, xK_F1    ), spawn "jm keymap toggle")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    , ((modm , xK_o     ), spawn "jm tmux-dmenu --no-attached")
    , ((modm .|. shiftMask, xK_o     ), spawn "jm tmux-dmenu")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    , ((modm .|. shiftMask, xK_l     ), spawn "jm xlock")

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_r     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_r     ), spawn "xmonad --recompile && xmonad --restart")
    ]
    ++

    --
    -- mod-[0..9] and F1..F12, Switch to workspace N
    -- mod-shift-[0..9] and F1..F12, Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) (
          [xK_1 .. xK_9] ++ [xK_0, xK_minus, xK_equal])
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

  {- [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip myWorkspaces [xK_F1..xK_F12]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
  ++ -}

    --
    -- mod-{q,w,e}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{q,w,e}, Move focus to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        -- | (key, sc) <- zip [xK_q, xK_w, xK_e] [0..] -- 3 screen setup
        | (key, sc) <- zip [xK_w, xK_e] [0..] -- 2 screen setup
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    , ((0, button8   ), \w -> windows W.focusDown)
    , ((0, button9   ), \w -> windows W.focusUp)
    {- remap thumb-buttons to switch focus (windows in fullscreen) when
       dreadfully reading through piles of docs without contact with
       keyboard
    -}
    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = smartBorders $ tiled ||| Mirror tiled ||| Full ||| eq_tiled
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled    = Tall nmaster delta ratio

     -- tile each window equally with no special treatment to master
     eq_tiled = Tall 0 delta ratio

     -- The default number of windows in the master pane
     nmaster  = 1

     -- Default proportion of screen occupied by master pane
     ratio    = 1/2

     -- Percent of screen to increment by when resizing panes
     delta    = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
  [ className =? "MPlayer"          --> doFloat
  , className =? "Gimp"             --> doFloat
  , resource  =? "desktop_window"   --> doIgnore
  , resource  =? "kdesktop"         --> doIgnore
  , className =? "Hotot"            --> doShift "18"
  , className =? "Claws-mail"       --> doShift "19"
  , className =? "Pidgin"           --> doShift "20"
  , className =? "Chromium-browser" --> doShift "21"
  ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = return ()
--do
--  xmproc <- spawnPipe "/usr/bin/xmobar /home/yac/.xmobarrc"
--  dynamicLogWithPP xmobarPP
--        { ppOutput = hPutStrLn xmproc,
--         ppTitle = xmobarColor "green" "" . shorten 50
--        }

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    home_dir <- getHomeDirectory
    xmproc <- spawnPipe ("/usr/bin/xmobar " ++ home_dir ++ "/.xmobarrc")
    xmproc <- spawnPipe ("/usr/bin/xmobar " ++ home_dir ++ "/.xmobarrc2")
    xmonad $ docks defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = defaultConfig {
      -- simple stuff
        terminal           = myTerminal ++ " -e /usr/bin/tmux",
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        --numlockMask        = myNumlockMask, -- invalid on my xmonad  0.10 on opensuse
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = avoidStruts $ myLayout,
        manageHook         = manageDocks <+> myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
