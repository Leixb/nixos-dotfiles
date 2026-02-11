{-# LANGUAGE BlockArguments #-}

module Main (main) where

import Data.Map.Strict (Map)
import Data.Map.Strict qualified as M
import Data.Ratio

import System.Environment (lookupEnv)
import System.Exit (exitSuccess)

import Graphics.X11.ExtraTypes.XF86

import XMonad.StackSet (RationalRect (RationalRect))
import XMonad.StackSet qualified as W

import XMonad
import XMonad.Prelude

import XMonad.Actions.CopyWindow (copiesPP, copy, copyToAll, kill1, killAllOtherCopies, runOrCopy)
import XMonad.Actions.CycleWS (Direction1D (..), WSType (..), emptyWS, hiddenWS, ignoringWSs, moveTo, nextScreen, prevScreen, shiftNextScreen, shiftTo, swapNextScreen, swapPrevScreen, doTo)
import XMonad.Actions.DwmPromote (dwmpromote)
import XMonad.Actions.GroupNavigation (Direction (History), historyHook, nextMatch)
import XMonad.Actions.Minimize (maximizeWindow, maximizeWindowAndFocus, minimizeWindow, withLastMinimized)
import XMonad.Actions.MouseResize (mouseResize)
import XMonad.Actions.RotSlaves (rotAllUp, rotSlavesUp)
import XMonad.Actions.Search hiding (Query)
import XMonad.Actions.Submap (visualSubmap)
import XMonad.Actions.SwapPromote (masterHistoryHook, swapHybrid)
import XMonad.Actions.TopicSpace
import XMonad.Actions.WindowGo (runOrRaiseNext)
import XMonad.Actions.WithAll (killAll)

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.FloatConfigureReq (fixSteamFlicker)
import XMonad.Hooks.InsertPosition (Focus (Newer), Position (Below), insertPosition)
import XMonad.Hooks.ManageDocks (Direction1D (Next, Prev), ToggleStruts (ToggleStruts), avoidStruts, docks)
import XMonad.Hooks.ManageHelpers (composeOne, doCenterFloat, doFocus, doFullFloat, doRectFloat, isDialog, isFullscreen, (-?>))
import XMonad.Hooks.RefocusLast (refocusLastLayoutHook, refocusLastWhen, refocusingIsActive)
import XMonad.Hooks.Rescreen (RescreenConfig (..), rescreenHook)
import XMonad.Hooks.ShowWName (SWNConfig (..), showWNameLogHook)
import XMonad.Hooks.StatusBar (statusBarProp, withSB)
import XMonad.Hooks.UrgencyHook (BorderUrgencyHook (..), focusUrgent, withUrgencyHook)
import XMonad.Hooks.WindowSwallowing (swallowEventHook)

import XMonad.Layout.Accordion (Accordion (Accordion))
import XMonad.Layout.BoringWindows (boringWindows, clearBoring, focusDown, focusUp, markBoringEverywhere)
import XMonad.Layout.CenterMainFluid (CenterMainFluid (CenterMainFluid))
import XMonad.Layout.CenteredMaster (centerMaster)
import XMonad.Layout.Decoration
import XMonad.Layout.FocusTracking (focusTracking)
import XMonad.Layout.Groups.Examples (TiledTabsConfig (tabsTheme))
import XMonad.Layout.HintedGrid (Grid (Grid))
import XMonad.Layout.MagicFocus
import XMonad.Layout.Magnifier (magnifiercz')
import XMonad.Layout.Master (mastered)
import XMonad.Layout.Minimize (minimize)
import XMonad.Layout.MultiToggle (EOT (EOT), Toggle (Toggle), mkToggle, (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (..))
import XMonad.Layout.NoBorders (smartBorders)
import XMonad.Layout.Renamed (Rename (Replace), renamed)
import XMonad.Layout.Spacing (Border (Border), spacingRaw)
import XMonad.Layout.Spiral (spiral)
import XMonad.Layout.Tabbed (tabbed)
import XMonad.Layout.ThreeColumns (ThreeCol (ThreeCol))

import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch (fuzzyMatch, fuzzySort)
import XMonad.Prompt.Man (manPrompt)
import XMonad.Prompt.Shell (shellPrompt)
import XMonad.Prompt.Workspace (workspacePrompt)

import XMonad.Actions.Warp (warpToWindow)
import XMonad.Util.ClickableWorkspaces (clickablePP)
import XMonad.Util.Hacks (fixSteamFlicker, javaHack, trayerAboveXmobarEventHook, trayerPaddingXmobarEventHook, windowedFullscreenFixEventHook)
import XMonad.Util.Loggers (logTitles)
import XMonad.Util.NamedScratchpad (NamedScratchpad (..), namedScratchpadAction, namedScratchpadManageHook, scratchpadWorkspaceTag)
import XMonad.Util.Run (executeNoQuote, inTerm, proc, spawnExternalProcess, termInDir, (>-$), (>->))
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Util.XUtils (WindowConfig (..))
import XMonad.Util.WorkspaceCompare (getSortByIndex)

--------------------------------------------------------------------------------
-- MAIN
--------------------------------------------------------------------------------

main =
    xmonad
        . docks
        . ewmhFullscreen
        . ewmh
        . javaHack
        . rescreenHook rescreenCfg
        . withUrgencyHook (BorderUrgencyHook colorRed)
        . withSB (statusBarProp "xmobar" myXmobarPP)
        . spawnExternalProcess def
        $ myConfig
  where
    rescreenCfg :: RescreenConfig
    rescreenCfg =
        def
            { afterRescreenHook = spawn "sleep 0.5; pkill -USR2 xmobar" *> spawn wallpaperCmd
            , randrChangeHook = spawn "autorandr --change"
            }

    myConfig =
        def
            { modMask = mod4Mask
            , keys = myKeys
            , terminal = myTerm
            , borderWidth = 3
            , focusedBorderColor = colorFg
            , normalBorderColor = colorBg
            , layoutHook = myLayout
            , logHook = myLogHook
            , handleEventHook = myHandleEventHook
            , manageHook = myManageHook
            , startupHook = myStartupHook
            , workspaces = myWorkspaces
            }

myTerm = "ghostty"
isTerm = className =? "com.mitchellh.ghostty"

myBrowser :: Browser = "firefox"
isBrowser = className =? myBrowser

lock = spawn "loginctl lock-session"
rofi = spawn "rofi -show"
screenshotFull = spawn "flameshot screen"
screenshot = withFocused $ getGeom >=> (spawn . ("flameshot gui --region " ++))
  where
    getGeom :: Window -> X String
    getGeom w = do
        d <- asks display
        formatGeometry <$> io (getWindowAttributes d w)

    formatGeometry WindowAttributes{wa_border_width = border, wa_x = x, wa_y = y, wa_height = height, wa_width = width} =
        show width ++ "x" ++ show height ++ "+" ++ show (x + border) ++ "+" ++ show (y + border)

--------------------------------------------------------------------------------
-- THEME
--------------------------------------------------------------------------------
myFont = "FiraCode Nerd Font"

colorBg :: String = "#25273A"
colorBlue :: String = "#8AADF4"
colorCyan :: String = "#8BD5CA"
colorGreen :: String = "#A6DA95"
colorFg :: String = "#CAD3F5"
colorLowWhite :: String = "#676B84"
colorMagenta :: String = "#C6A0F6"
colorRed :: String = "#ED8796"
colorText :: String = "#B8C0E0"
colorYellow :: String = "#EED49F"

wallpaperCmd = "~/.fehbg"

--------------------------------------------------------------------------------
-- TOPICS
--------------------------------------------------------------------------------

myWorkspaces = topicNames topics

topicConfig :: TopicConfig
topicConfig =
    def
        { topicDirs = tiDirs topics
        , topicActions = tiActions topics
        , defaultTopicAction = const . pure $ mempty
        , defaultTopic = head myWorkspaces
        }

home = "/home/leix/"

-- use 3-7 to copy windows from other topics into them and create custom views
topics :: [TopicItem]
topics =
    [ noAction "\xf35e" "Documents"
    , ti "1:WEB" "Downloads" $ spawn myBrowser
    , ti "2:SHELL" "Documents" spawnTermInTopic
    , onlyDoc "3"
    , onlyDoc "4"
    , onlyDoc "5"
    , onlyDoc "6"
    , onlyDoc "7"
    , inHome "8:im" $ spawn "slack" *> spawn "telegram-desktop"
    , ti "9:media" "Videos" spawnTermInTopic
    , ti "0:music" "Music" $ spawn "plexamp"
-- End of numbered topics (mapped to mod + n)
    , sshHost "mn5"
    , sshHost "hut"
    , sshHost "hca"
    , ti "paraver" "Documents/traces" $ spawn "wxparaver" *> switchToLayout paraverLayout
    , ti "zotero" "Zotero" $ spawn "zotero"
    , inHome "discord" $ spawn "legcord"
    , ti "minecraft" ".local/share/PrismLauncher" $ spawn "prismlauncher"
    , inHome "gaming" $ spawn "steam"
    ]
        ++ ( ($ spawnTermInTopic)
                <$> [ ti "dotfiles" ".dotfiles"
                    , ti "downloads" "Downloads"
                    ]
                    ++ [ ti name ("Documents/" ++ name)
                       | name <-
                            [ "nixpkgs"
                            , "bscpkgs"
                            , "nixos-riscv"
                            , "alpi"
                            , "alpinfo"
                            , "mpi-nosv-ipc"
                            , "nos-v"
                            , "ovni"
                            , "nodes"
                            , "llvm"
                            , "nanos6"
                            , "pocl-v"
                            , "rodinia"
                            , "velocity"
                            , "tampi"
                            , "hpccg"
                            , "gpt2"
                            , "jungle"
                            , "haskell/jutge"
                            , "aoc-25"
                            , "modulefiles"
                            , "cgenarate"
                            , "gromacs"
                            , "tacuda"
                            , "tasycl"
                            , "bench6"
                            , "ompss-2-exercises"
                            , "ci-infrastructure"
                            , "slides/team-meetings"
                            , "nsys2prv"
                            , "fgcs_document"
                            , "qemu"
                            , "task-awareness/taopencl"
                            , "oneTBB"
                            , "ggml"
                            , "iwocl-benchmarks"
                            ]
                       ]
           )
  where
    only, onlyDoc :: Topic -> TopicItem
    only n = noAction n home
    onlyDoc n = noAction n "Documents"

    sshHost host = inHome host $ spawnInTerm ("ssh " ++ host)

    switchToLayout = sendMessage . JumpToLayout

    spawnEditorInTopic = spawnInTerm "nvim ."
    spawnEditorInTopicOpen file = spawnInTerm $ "nvim " ++ file
    spawnInTerm prog = proc $ inTermHold >-> executeNoQuote prog
    spawnInTerm' prog = proc $ inTerm >-> executeNoQuote prog
    inTermHold = termInTopic >-$ pure " --wait-after-command"

    ti name folder = TI name (home ++ folder)

-- | Spawn terminal in topic directory.
spawnTermInTopic :: X ()
spawnTermInTopic = proc termInTopic

termInTopic =
    inTerm >-$ do
        d <- currentTopicDir topicConfig
        return $ "--working-directory=" ++ d

-------------------------------------------------------------------------
-- PROMPT
-------------------------------------------------------------------------

-- | Create a graphical prompt for xmonad that functions can use.
prompt :: XPConfig
prompt =
    def
        { fgColor = colorFg
        , fgHLight = colorBg
        , bgColor = colorBg
        , bgHLight = colorCyan
        , font = "xft:" ++ myFont ++ ":size=11"
        , alwaysHighlight = True -- Current best match
        , height = 40
        , position = Top
        , promptBorderWidth = 0 -- Fit in with rest of config
        , historySize = 50
        , historyFilter = deleteAllDuplicates
        , maxComplRows = Just 5 -- Max rows to show in completion window
        , promptKeymap = myXPKeyMap
        , searchPredicate = fuzzyMatch
        , sorter = fuzzySort
        , completionKey = (0, xK_Right)
        , prevCompletionKey = (0, xK_Left)
        }
  where
    myXPKeyMap :: Map (KeyMask, KeySym) (XP ())
    myXPKeyMap =
        mconcat
            [ fromList [((controlMask, xK_w), killWord' isSpace Prev)]
            , emacsLikeXPKeymap
            ]

--------------------------------------------------------------------------------
-- Layouts
--------------------------------------------------------------------------------

paraverLayout = "TwoPane Tab"
twoPaneAccDesc = "TwoPane Acc"

myLayout =
    avoidStruts
        . refocusLastLayoutHook
        . mkToggle (MIRROR ?? NBFULL ?? NOBORDERS ?? EOT)
        . smartBorders
        . mouseResize
        . boringWindows
        . minimize
        $ tiled ||| twoPane ||| twoPaneA ||| threeCols ||| spir ||| grid ||| threeColsMid ||| Full
  where
    nmaster = 1 -- Default number of windows in the master pane
    ratio = 1 / 2 -- Default proportion of screen occupied by master pane
    ratioTwoPane = 6 / 25 -- Proportion of screen occupied by master pane for Two Pane (for paraver)
    delta = 3 / 100 -- Percent of screen to increment by when resizing panes
    spacer = spacingRaw False (Border 10 0 10 0) True (Border 0 10 0 10) True
    spacer' = spacingRaw False (Border 10 10 10 10) True (Border 0 0 0 0) True

    grid = spacer $ Grid False
    spir = spacer $ spiral (6 / 7)
    tiled = spacer $ XMonad.Tall nmaster delta ratio
    threeColsMid = spacer $ magnifiercz' 1.3 $ CenterMainFluid nmaster delta ratio
    threeCols = spacer $ ThreeCol nmaster delta ratio
    twoPaneA = setName twoPaneAccDesc $ spacer $ mastered delta ratioTwoPane $ focusTracking Accordion
    twoPane = setName paraverLayout $ spacer' $ mastered delta ratioTwoPane $ focusTracking $ tabbed shrinkText myTabTheme

    setName :: String -> l a -> ModifiedLayout Rename l a
    setName n = renamed [Replace n]

    myTabTheme =
        def
            { activeColor = colorBlue
            , urgentColor = colorRed
            , inactiveColor = colorBg
            , activeTextColor = colorBg
            , urgentTextColor = colorBg
            , inactiveTextColor = colorFg
            , activeBorderColor = colorFg
            , inactiveBorderColor = colorLowWhite
            , urgentBorderColor = colorLowWhite
            , decoHeight = 40
            , fontName = "xft:" ++ myFont ++ ":size=9"
            , activeBorderWidth = 3
            , inactiveBorderWidth = 3
            , urgentBorderWidth = 3
            }

--------------------------------------------------------------------------------
-- HOOKS
--------------------------------------------------------------------------------

myStartupHook =
    mconcat
        [ restoreBackground
        , spawnOnce "slack -u"
        ]
  where
    restoreBackground = spawnOnce wallpaperCmd

myLogHook =
    historyHook
        *> workspaceHistoryHookExclude [scratchpadWorkspaceTag]
        *> masterHistoryHook
        *> showWNameLogHook
            def
                { swn_font = "xft:" ++ myFont ++ ":size=21"
                , swn_bgcolor = colorBg
                , swn_color = colorFg
                }

isAccord :: X Bool
isAccord = do
    wset <- gets windowset
    let ldesc = description . W.layout . W.workspace . W.current $ wset
    return $ isSuffixOf twoPaneAccDesc ldesc

myHandleEventHook =
    composeAll
        [ handleEventHook def
        , windowedFullscreenFixEventHook
        , followOnlyIf (not <$> isAccord)
        , swallowEventHook
            ( isTerm <&&> (not <$> ((title `endsWith` "NVIM") <||> (title `startsWith` "gdb")))
            )
            (not <$> (isTerm <||> isPapercut))
        , refocusLastWhen (refocusingIsActive <&&> (not <$> isFullscreen))
        , trayerAboveXmobarEventHook
        , trayerPaddingXmobarEventHook
        , fixSteamFlicker
        ]
  where
    endsWith, startsWith :: (Eq a) => Query [a] -> [a] -> Query Bool
    qa `endsWith` a = qa <&> isSuffixOf a
    qa `startsWith` a = qa <&> isPrefixOf a

isPapercut = className =? "biz-papercut-pcng-client-uit-UserClient"

myManageHook =
    composeAll
        [ composeOne
            ( floats
                ++ [ className =? "pavucontrol" -?> doCenterFloatFixed
                   , wmName =? "Picture-in-Picture" -?> doFloat
                   , isDialog <&&> isParaver <&&> wmName =? "Drawing window..." -?> doIgnore -- paraver drawing window steals focus and its annoying
                   , isDialog -?> doCenterFloat
                   , isFullscreen -?> doFullFloat
                   , title =? "Calendar" -?> (doFocus *> doCenterFloat)
                   , isPapercut -?> doFloat
                   ]
            )
        , composeOne
            [ appName =? "Alert" <&&> className =? "Zotero" -?> doIgnore
            , className =? "Slack" -?> doShift (myWorkspaces !! 8)
            , isParaver -?> doShift "paraver"
            , isBrowser -?> doShift (myWorkspaces !! 1)
            ]
        , not <$> willFloat --> insertPosition Below Newer
        , namedScratchpadManageHook scratchpads
        ]
  where
    wmName = stringProperty "WM_NAME"
    isParaver = className =? "Wxparaver"
    floats =
        [ className =? name -?> doCenterFloat
        | name <-
            [ "confirm"
            , "file_progress"
            , "dialog"
            , "download"
            , "error"
            , "notification"
            , "pinentry-gtk-2"
            , "splash"
            , "toolbar"
            , "Qalculate-gtk"
            ]
        ]
    rectfloatCenter ratio = doRectFloat $ RationalRect border border ratio ratio
      where
        border = (1 - ratio) / 2

    doCenterFloatFixed = rectfloatCenter (1 % 2) <+> doF W.swapUp
    doCenterFloatFixedBig = rectfloatCenter (4 % 5) <+> doF W.swapUp

    scratchpads =
        [ NS "scratchpad" (myTerm ++ " --title=scratchpad --class=scratchpad.ghostty") (className =? "scratchpad.ghostty") doCenterFloatFixed
        , NS "qalc" "qalculate-gtk" (className =? "Qalculate-gtk") doCenterFloatFixed
        , NS "mail" (myTerm ++ " --title=neomutt --class=neomutt.ghostty -e neomutt") (className =? "neomutt.ghostty") doCenterFloatFixedBig
        , NS "btm" (myTerm ++ " --title=btm --class=btm.ghostty -e btm") (className =? "btm.ghostty") doCenterFloatFixedBig
        ]

--------------------------------------------------------------------------------
-- KEYBINDS
--------------------------------------------------------------------------------

{- ORMOLU_DISABLE -}
myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf@(XConfig {modMask = modMask}) = fromList $
    -- launching and killing programs
    [ ((modMask,                 xK_Return), spawnTermInTopic) -- %! Launch terminal
    , ((modMask,                 xK_d     ), rofi) -- %! Launch rofi
    , ((modMask .|. shiftMask,   xK_d     ), shellPrompt prompt) -- %! Launch shell prompt

    , ((modMask,                 xK_w     ), kill1) -- %! Close the focused window in workspace
    , ((modMask .|. shiftMask,   xK_w     ), kill) -- %! Close the focused window
    , ((modMask .|. controlMask, xK_w     ), killAll) -- %! Close the focused window in all workspaces
    , ((modMask,                 xK_s     ), windows copyToAll) -- %! Make window sticky
    , ((modMask .|. shiftMask,   xK_s     ), killAllOtherCopies) -- %! Close all other windows

    , ((modMask  .|. controlMask, xK_l    ), lock) -- %! Lock screen
    , ((mod1Mask .|. controlMask, xK_l    ), lock) -- %! Lock screen

    , ((modMask,               xK_space ), sendMessage NextLayout) -- %! Rotate through the available layout algorithms
    , ((modMask .|. shiftMask, xK_space ), setLayout $ layoutHook conf) -- %!  Reset the layouts on the current workspace to default

    , ((modMask              , xK_r     ), rotAllUp) -- %!  Rotate all windows in stack
    , ((modMask .|. shiftMask, xK_r     ), rotSlavesUp) -- %!  Rotate slave windows in stack

    , ((modMask,               xK_n     ), refresh) -- %! Resize viewed windows to the correct size

    -- move focus up or down the window stack
    , ((modMask,               xK_j     ), focusDown) -- %! Move focus to the next window
    , ((modMask,               xK_k     ), focusUp  ) -- %! Move focus to the previous window
    , ((modMask,               xK_m     ), windows W.focusMaster  ) -- %! Move focus to the master window
    , ((modMask .|. shiftMask, xK_m     ), nextMatch History $ pure True) -- %! Move focus to previous window
    , ((modMask,               xK_u     ), focusUrgent) -- %! Move focus to urgent window

    -- modifying the window order
    , ((modMask .|. shiftMask, xK_Return), whenX (swapHybrid True) dwmpromote) -- %! Swap the focused window and the master window
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  ) -- %! Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    ) -- %! Swap the focused window with the previous window

    -- resizing the master/slave ratio
    , ((modMask,               xK_h     ), sendMessage Shrink) -- %! Shrink the master area
    , ((modMask,               xK_l     ), sendMessage Expand) -- %! Expand the master area

    , ((modMask,               xK_f     ), sendMessage (Toggle NBFULL) *> sendMessage ToggleStruts) -- %! Toggle Fullscreen
    , ((modMask,               xK_x     ), sendMessage $ Toggle MIRROR) -- %! Toggle layout mirror

    -- floating layer support
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink) -- %! Push window back into tiling

    -- increase or decrease number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1)) -- %! Increment the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1))) -- %! Decrement the number of windows in the master area

    -- quit, or restart
    , ((modMask .|. shiftMask, xK_q     ), io exitSuccess) -- %! Quit xmonad
    , ((modMask              , xK_q     ), spawn "xmonad --recompile && xmonad --restart") -- %! Restart xmonad

    -- raise
    , ((modMask              , xK_b     ), runOrRaiseNext myBrowser isBrowser) -- %! Raise browser
    , ((modMask .|. shiftMask, xK_b     ), runOrCopy myBrowser isBrowser) -- %! Copy browser

    , ((modMask .|. controlMask, xK_b   ), sendMessage ToggleStruts)

    -- boring and minimized windows
    , ((modMask                , xK_semicolon ), withFocused minimizeWindow) -- %! Minimize window
    , ((modMask .|. shiftMask  , xK_semicolon ), withLastMinimized maximizeWindow) -- %! Restore last minimized
    , ((modMask .|. controlMask, xK_semicolon ), withLastMinimized maximizeWindowAndFocus) -- %! Restore last minimized
    , ((modMask                , xK_apostrophe), markBoringEverywhere) -- %! Mark window as boring
    , ((modMask .|. shiftMask  , xK_apostrophe), clearBoring) -- %! Restore boring windows

    , ((modMask                , xK_e), searchEngineMap) -- %! Open search engines

    , ((modMask,                               xK_i     ), swapNextScreen) -- %! Swap with next screen
    , ((modMask .|. shiftMask,                 xK_i     ), shiftNextScreen) -- %! Swap with prev screen
    , ((modMask .|. controlMask,               xK_i     ), nextScreen *> centerMouse) -- %! Focus next screen
    , ((modMask .|. controlMask .|. shiftMask, xK_i     ), prevScreen *> centerMouse) -- %! Focus prev screen

    , ((modMask, xK_y     ), centerMouse) -- %! Center mouse on window

    -- topics
    , ((modMask,                 xK_a           ), currentTopicAction topicConfig) -- %! Run topic action
    , ((modMask,                 xK_o           ), switchNthLastFocusedByScreen topicConfig 1) -- %! Switch between current and last topic
    , ((modMask .|. shiftMask,   xK_o           ), shiftNthLastFocused 1) -- %! Shift to last topic
    , ((modMask .|. controlMask, xK_o           ), copyNthLastFocused 1) -- %! Copy to last topic
    , ((modMask,                 xK_bracketleft ), moveTo Prev activeTopics) -- %! Move through active topics
    , ((modMask,                 xK_bracketright), moveTo Next activeTopics)
    , ((modMask .|. shiftMask,   xK_bracketleft ), shiftTo Prev activeTopics) -- %! Shift to next topic
    , ((modMask .|. shiftMask,   xK_bracketright), shiftTo Next activeTopics) -- %! Shift to prev topic
    , ((modMask .|. controlMask, xK_bracketleft),  doTo Prev activeTopics getSortByIndex $ windows . copy) -- %! Copy to next topic
    , ((modMask .|. controlMask, xK_bracketright), doTo Next activeTopics getSortByIndex $ windows . copy) -- %! Copy to prev topic
    , ((modMask,                 xK_slash       ), workspacePrompt topicPrompt $ switchTopic topicConfig) -- %! Focus prompt
    , ((modMask .|. shiftMask,   xK_slash       ), workspacePrompt topicPrompt $ windows . W.shift) -- %! Shift prompt
    , ((modMask .|. controlMask, xK_slash       ), workspacePrompt topicPrompt $ windows . copy) -- %! Copy prompt

    , ((noModMask,               xK_Print), screenshot)
    , ((modMask,                 xK_F10  ), screenshot)
    , ((shiftMask,               xK_Print), screenshotFull)
    , ((modMask .|. shiftMask,   xK_F10  ), screenshotFull)

    , ((noModMask, xF86XK_AudioLowerVolume), spawn "amixer -q sset Master 5%-")
    , ((noModMask, xF86XK_AudioRaiseVolume), spawn "amixer -q sset Master 5%+")
    , ((shiftMask, xF86XK_AudioLowerVolume), spawn "amixer -q sset Master 1%-")
    , ((shiftMask, xF86XK_AudioRaiseVolume), spawn "amixer -q sset Master 1%+")
    , ((noModMask, xF86XK_AudioMute       ), spawn "amixer -q sset Master toggle")
    , ((noModMask, xF86XK_AudioMicMute    ), spawn "amixer -q sset Capture toggle")

    , ((noModMask, xF86XK_AudioPlay       ), spawn "playerctl play-pause")
    , ((noModMask, xF86XK_AudioPause      ), spawn "playerctl pause")
    , ((noModMask, xF86XK_AudioStop       ), spawn "playerctl stop")
    , ((noModMask, xF86XK_AudioNext       ), spawn "playerctl next")
    , ((noModMask, xF86XK_AudioPrev       ), spawn "playerctl previous")

    , ((modMask, xK_F1                    ), spawn "amixer -q sset Master toggle")
    , ((modMask, xK_F2                    ), spawn "amixer -q sset Master 5%-")
    , ((modMask, xK_F3                    ), spawn "amixer -q sset Master 5%+")
    , ((modMask .|. shiftMask, xK_F2      ), spawn "amixer -q sset Master 1%-")
    , ((modMask .|. shiftMask, xK_F3      ), spawn "amixer -q sset Master 1%+")
    , ((modMask, xK_F4                    ), spawn "amixer -q sset Capture toggle")
    , ((modMask, xK_F5                    ), spawn "light -U 5")
    , ((modMask, xK_F6                    ), spawn "light -A 5")
    , ((modMask, xK_F7                    ), spawn "playerctl previous")
    , ((modMask, xK_F8                    ), spawn "playerctl play-pause")
    , ((modMask, xK_F9                    ), spawn "playerctl next")

    , ((noModMask, xF86XK_MonBrightnessUp   ), spawn "light -A 5")
    , ((noModMask, xF86XK_MonBrightnessDown ), spawn "light -U 5")
    , ((shiftMask, xF86XK_MonBrightnessUp   ), spawn "light -A 1")
    , ((shiftMask, xF86XK_MonBrightnessDown ), spawn "light -U 1")

    , ((shiftMask, xF86XK_MenuKB ), rofi)

    ] ++ [ ((modMask, k), namedScratchpadAction mempty name) | (k, name) <-
        [ (xK_z, "scratchpad")
        , (xK_c, "qalc")
        , (xK_p, "btm")
        , (xK_g, "mail")
      ]
    ] ++ [ ((modMask .|. m, k), action wsName)
           | (wsName, k) <- zip myWorkspaces wsKeys
           , (m, action) <-
                [ (noModMask  , switchTopic topicConfig)
                , (shiftMask  , windows . W.shift)
                , (controlMask, windows . copy)
                ]
    ]
      where
        activeTopics = hiddenWS :&: Not emptyWS :&: ignoringWSs [scratchpadWorkspaceTag , "8:im", "9:media" , "0:music"]

        wsKeys = xK_grave : [xK_1 .. xK_9] ++ [xK_0]

        topicPrompt :: XPConfig
        topicPrompt =
            prompt
                { autoComplete = Just 3000 -- Time is in μs.
                , historySize = 0 -- No history in the prompt.
                }
        copyNthLastFocused n = do
            ws <- fmap (listToMaybe . drop n) workspaceHistory
            whenJust ws $ windows . copy

        centerMouse = warpToWindow (1/2) (1/2)
{- ORMOLU_ENABLE -}

--------------------------------------------------------------------------------
-- xmobar pretty printer
--------------------------------------------------------------------------------

myXmobarPP :: X PP
myXmobarPP =
    copiesPP (pad . fgColor colorGreen) >=> clickablePP $
        filterOutWsPP [scratchpadWorkspaceTag] $
            def
                { ppSep = fgColor colorMagenta " | "
                , ppTitleSanitize = xmobarStrip
                , ppCurrent = pad . xmobarBorder "Top" colorCyan 2
                , ppVisible = wrap "(" ")"
                , ppHidden = pad
                , -- , ppHiddenNoWindows = lowWhite . pad
                  ppLayout = fgColor colorFg . myLayoutPrinter
                , ppUrgent = fgColor colorRed . wrap (fgColor colorYellow "!") (fgColor colorYellow "!")
                , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
                , ppRename = \wsName _ -> case wsName of
                    "1:WEB" -> "1:W"
                    "2:SHELL" -> "2:SH"
                    "8:im" -> "8:im"
                    "9:media" -> "9:med"
                    "0:music" -> "0:mus"
                    _ -> wsName
                , ppExtras = [logTitles formatFocused formatUnfocused]
                }
  where
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    formatFocused = wrap (fgColor colorFg "[") (fgColor colorFg "]") . fgColor colorMagenta . ppWindow
    formatUnfocused = wrap (fgColor colorLowWhite "[") (fgColor colorLowWhite "]") . fgColor colorBlue . ppWindow

    fgColor = (`xmobarColor` "")

    myLayoutPrinter x = let iconstr = icon x in fromMaybe x iconstr
      where
        icon = fmap asIcon . getIconName
        asIcon x = "<icon=" ++ x ++ ".xbm/>"
        stripPrefix :: String -> String -> String
        stripPrefix [] s = s
        stripPrefix _ [] = []
        stripPrefix (p : ps) (s : ss) = if p == s then stripPrefix ps ss else s : ss

        getIconName :: String -> Maybe String
        getIconName "Full" = Just "full"
        getIconName "Tall" = Just "tall"
        getIconName "Spiral" = Just "spiral"
        getIconName "ThreeCol" = Just "threeCol"
        getIconName "CenterMainFluid" = Just "threeCol"
        getIconName "Accordion" = Just "accordion"
        getIconName "Grid False" = Just "grid"
        getIconName "Grid" = Just "grid"
        getIconName x
            | x == twoPaneAccDesc = Just "masteracc"
            | x == paraverLayout = Just "mastertab"
            | "Spacing" `isPrefixOf` x = getIconName $ stripPrefix "Spacing " x
            | "Magnifier" `isPrefixOf` x = getIconName $ stripPrefix "Magnifier " x
            | "NoMaster" `isPrefixOf` x = getIconName $ stripPrefix "NoMaster " x
            | "Hinted" `isPrefixOf` x = getIconName $ stripPrefix "Hinted " x
            | "Minimize" `isPrefixOf` x = getIconName $ stripPrefix "Minimize " x
            | "Mirror" `isPrefixOf` x = fmap ("mirror_" ++) . getIconName $ stripPrefix "Mirror " x
            | otherwise = Nothing

--------------------------------------------------------------------------------
-- search engine visual prompt
--------------------------------------------------------------------------------

searchEngineMap =
    visualSubmap visualConfig $
        basicSubmapFromList
            [ (xK_a, "[a]rXiv", sw arXiv)
            , (xK_w, "[w]ikipedia", sw wikipedia)
            , (xK_y, "[y]ouTube", sw' youtube)
            , (xK_h, "[h]oogle", sw hoogle)
            , (xK_g, "[g]oogle", sw google)
            , (xK_d, "[d]uckduckgo", sw duckduckgo)
            , (xK_s, "[s]ourcegraph", sw sourcegraph)
            , (xK_p, "re[p]ology", sw repology)
            , (xK_c, "[c]ppreference", sw cppreference)
            ,
                ( xK_n
                , "[n]ix ->"
                , visualSubmap visualConfig $
                    basicSubmapFromList
                        [ (xK_n, "[n]oogle", sw noogle')
                        , (xK_p, "nixos [p]ackages", sw nixos)
                        , (xK_h, "[h]ome", sw homeManager')
                        , (xK_o, "nixos [o]ptions", sw nixosOptions)
                        ]
                )
            ,
                ( xK_r
                , "[r]ust ->"
                , visualSubmap visualConfig $
                    basicSubmapFromList
                        [ (xK_c, "[c]rates.io", sw cratesIo)
                        , (xK_r, "[r]ust std", sw rustStd)
                        ]
                )
            ,
                ( xK_m
                , "[m]an"
                , manPrompt
                    promptNoHist
                        { searchPredicate = searchPredicate def
                        , sorter = sorter def
                        }
                )
            , (xK_o, "[o]sm", sw' openstreetmap)
            ]
            `M.union` fromList
                [ ((shiftMask, xK_g), ("[G]ithub", sw github))
                ]
  where
    visualConfig :: WindowConfig
    visualConfig =
        def
            { winFont = "xft:" ++ myFont ++ ":size=21"
            , winBg = colorBg
            , winFg = colorFg
            }

    basicSubmapFromList :: (Ord key) => [(key, desc, action)] -> Map (KeyMask, key) (desc, action)
    basicSubmapFromList = fromList . map \(k, d, a) -> ((noModMask, k), (d, a))

    promptNoHist = prompt{historySize = 0}

    sw = promptSearchBrowser prompt myBrowser
    sw' = promptSearchBrowser promptNoHist myBrowser

    nixosOptions = searchEngine "nixosOptions" "https://search.nixos.org/options?channel=unstable&from=0&size=200&sort=relevance&type=packages&query="
    sourcegraph = searchEngine "sourcegraph" "https://sourcegraph.com/search?q="
    repology = searchEngine "repology" "https://repology.org/projects/?search="
    cppreference = searchEngine "cppreference" "https://duckduckgo.com/?sites=cppreference.com&q="
    noogle' = searchEngine "noogle" "https://noogle.dev/q?term="
    homeManager' = searchEngine "home-manager" "https://home-manager-options.extranix.com/?release=master&query="
