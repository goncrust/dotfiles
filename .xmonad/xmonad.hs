import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WithAll (sinkAll, killAll)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import qualified Data.Map as M
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, dzenColor, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.SetWMName
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myModMask :: KeyMask
myTerminal :: String
myBorderWidth :: Dimension
myNormColor :: String
myFocusColor :: String

myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"
myModMask = mod4Mask        -- modkey -> windows key
myTerminal = "alacritty"
myBorderWidth = 2
myNormColor   = "#282c34"
myFocusColor  = "#46d9ff"

-- windowCount :: X (Maybe String)
-- windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "picom &"
    spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x1e222a --height 16 --margin 10 --distance 6 &"
    spawnOnce "xscreensaver &"
    spawnOnce "xbindkeys &"
    spawnOnce "volumeicon &"
    spawnOnce "redshift-gtk -l 51.5045300:-0.1257400 &"
    spawnOnce "mocicon &"
    spawnOnce "polychromatic-tray-applet &"
    setWMName "xmonad"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x28,0x2c,0x34) -- lowest inactive bg
                  (0x28,0x2c,0x34) -- highest inactive bg
                  (0xc7,0x92,0xea) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0x28,0x2c,0x34) -- active fg

-- gridSelect
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 200
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

myAppGrid = [ ("Brave", "brave")
                 , ("Apple Music", "cider")
                 , ("Steam", "steam")
                 , ("VSCodium", "codium")
                 , ("Lutris", "lutris")
                 , ("Discord", "discord")
                 , ("PCManFM", "pcmanfm")
            ]

-- scratchPads
myScratchPads :: [NamedScratchpad]
                -- C-s f
myScratchPads = [ NS "vifm" spawnVifm findVifm manageVifm
                -- C-s h
                , NS "htop" spawnHtop findHtop manageHtop
                -- C-s m
                , NS "cider" spawnCider findCider manageCider
                -- C-s c
                , NS "calculator" spawnCalc findCalc manageCalc
                ]
  where
    spawnVifm  = myTerminal ++ " -t vifm -e $HOME/.config/vifm/scripts/vifmrun"
    findVifm   = title =? "vifm"
    manageVifm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnHtop  = myTerminal ++ " -t htop -e htop"
    findHtop   = title =? "htop"
    manageHtop = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCider  = "cider"
    findCider   = className =? "Cider"
    manageCider = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w 
    spawnCalc  = "speedcrunch"
    findCalc   = className =? "SpeedCrunch"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.42
                 t = 0.75 -h
                 l = 0.70 -w

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- layouts
tall     = renamed [Replace "tall"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 6
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
tabs     = renamed [Replace "tabs"]
           $ tabbed shrinkText myTabTheme

-- settings for tabs layout
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#ffffff"
    }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     withBorder myBorderWidth tall
                                 ||| noBorders monocle
                                 ||| floats
                                 ||| noBorders tabs
                                 ||| grid

-- myWorkspaces = ["1", "2", "3", "4", "5"]
myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 "]
-- myWorkspaces = [" main ", " dev ", " web ", " social ", " other "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

-- make workspaces clickable
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- 'doShift ( myWorkspaces !! 7)' -> send program to workspace 8
     [ className =? "confirm"         --> doFloat
     , className =? "file_progress"   --> doFloat
     , className =? "dialog"          --> doFloat
     , className =? "download"        --> doFloat
     , className =? "error"           --> doFloat
     , className =? "notification"    --> doFloat
     , className =? "splash"          --> doFloat
     , className =? "toolbar"         --> doFloat
     , className =? "firefox"         --> doFloat
     , className =? "Tor Browser"     --> doFloat
     , isFullscreen -->  doFullFloat
     ] <+> namedScratchpadManageHook myScratchPads

myKeys :: [(String, X ())]
myKeys =
    -- Xmonad
        [ ("M-q", spawn "xmonad --restart")    -- restart xmonad
        , ("M-S-q", io exitSuccess)            -- quit xmonad

    -- Launch
        , ("M-S-<Return>", spawn "/home/goncrust/.config/rofi/launchers/colorful/launcher.sh")   -- rofi themed
        -- , ("M-S-<Return>", spawn "rofi -show run")   -- rofi
        -- , ("M-S-<Return>", spawn "dmenu_run -fn 'Ubuntu-9' -i -p \"Run: \"")   -- dmenu
        -- , ("M-p", spawn "dmenu_run -fn 'Ubuntu-9' -i -p \"Run: \"")            -- dmenu
        , ("M-<Return>", spawn (myTerminal))                                   -- terminal

    -- Kill windows
        , ("M-S-c", kill1)     -- close window
        , ("M-S-a", killAll)   -- close all windows in workspace

    -- Workspaces
        , ("M-.", nextScreen)                          -- next monitor
        , ("M-,", prevScreen)                          -- previous monitor
        -- Custom keybinds for workspaces
        , ("M-1", windows $ W.greedyView " 1 ")
        , ("M-2", windows $ W.greedyView " 2 ")
        , ("M-3", windows $ W.greedyView " 3 ")
        , ("M-4", windows $ W.greedyView " 4 ")
        , ("M-5", windows $ W.greedyView " 5 ")
        , ("M-6", windows $ W.greedyView " 1 ")
        , ("M-7", windows $ W.greedyView " 2 ")
        , ("M-8", windows $ W.greedyView " 3 ")
        , ("M-9", windows $ W.greedyView " 4 ")
        , ("M-0", windows $ W.greedyView " 5 ")

    -- Floating windows
        , ("M-t", withFocused $ windows . W.sink)  -- floating window to tile
        , ("M-S-t", sinkAll)                       -- all floating windows to tile

    -- Grid Select
        , ("C-g g", spawnSelected' myAppGrid)                 -- apps
        , ("C-g t", goToSelected $ mygridConfig myColorizer)  -- go to window
        , ("C-g b", bringSelected $ mygridConfig myColorizer) -- bring window

    -- Scratchpads
        , ("C-s f", namedScratchpadAction myScratchPads "vifm")        -- vifm
        , ("C-s h", namedScratchpadAction myScratchPads "htop")        -- htop
        , ("C-s m", namedScratchpadAction myScratchPads "cider")        -- mocp
        , ("C-s c", namedScratchpadAction myScratchPads "calculator")  -- calc

    -- Windows navigation
        , ("M-j", windows W.focusDown)    -- focus to next window
        , ("M-k", windows W.focusUp)      -- focus to prev window
        , ("M-S-j", windows W.swapDown)   -- swap window with next window
        , ("M-S-k", windows W.swapUp)     -- swap window with prev window
        , ("M-S-<Tab>", rotAllDown)       -- rotate windows 90

    -- Layouts
        , ("M-<Tab>", sendMessage NextLayout)                                       -- next layout
        , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- fullscreen

    -- Window resizing
        , ("M-h", sendMessage Shrink)                   -- shrink horiz
        , ("M-l", sendMessage Expand)                   -- expand horiz
        -- M1 -> alt_l
        , ("M-M1-j", sendMessage MirrorShrink)          -- shrink vert
        , ("M-M1-k", sendMessage MirrorExpand)          -- expand vert

    -- Multimedia Keys
        , ("<Print>", spawn "flameshot gui")
        ]

    -- The following lines are needed for named scratchpads.
          where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

main :: IO ()
main = do
    xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc0"
    xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc1"
    xmonad $ ewmh def
        { manageHook         = myManageHook <+> manageDocks
        , handleEventHook    = docksEventHook
                               <+> fullscreenEventHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormColor
        , focusedBorderColor = myFocusColor
        , logHook = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
              { ppOutput = \x -> hPutStrLn xmproc0 x                          -- xmobar on monitor 1
                              >> hPutStrLn xmproc1 x                          -- xmobar on monitor 2
              , ppCurrent = xmobarColor "#51afef" "#393d45" . wrap "<box type=Bottom width=2 mb=0 color=#51afef>" "</box>" . wrap "<box type=Top width=2 mb=0 color=#393d45>" "</box>"                         -- Current workspace
              , ppVisible = xmobarColor "#51afef" "#393d45" . wrap "<box type=Top width=2 mb=0 color=#393d45>" "</box>" . clickable              -- Visible but not current workspace
              , ppHidden = xmobarColor "#98be65" "" . wrap "<box type=Bottom width=2 mb=0 color=#98be65>" "</box>" . clickable  -- Hidden workspaces
              , ppHiddenNoWindows = xmobarColor "#b3afc2" ""  . clickable     -- Hidden workspaces (no windows)
              , ppTitle = xmobarColor "#b3afc2" "" . shorten 60               -- Title of active window
              , ppSep =  "<fc=#666666> | </fc>"                               -- Separator character
              , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"            -- Urgent workspace
              -- , ppExtras  = [windowCount]                                     -- number of windows current workspace
              , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]                    -- order of things in xmobar
              }
        } `additionalKeysP` myKeys
