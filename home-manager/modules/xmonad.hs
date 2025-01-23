{-# LANGUAGE BlockArguments #-}

module Main (main) where

import Data.Map.Strict (Map)
import Data.Ratio

import XMonad.Actions.TopicSpace

import System.Environment (lookupEnv)
import System.Exit (exitSuccess)

import XMonad.StackSet (RationalRect (RationalRect))
import XMonad.StackSet qualified as W

import XMonad
import XMonad.Prelude

import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.DwmPromote (dwmpromote)
import XMonad.Actions.GroupNavigation
import XMonad.Actions.Minimize
import XMonad.Actions.MouseResize (mouseResize)
import XMonad.Actions.Prefix
import XMonad.Actions.Search hiding (Query)
import XMonad.Actions.WindowGo
import XMonad.Actions.WithAll (killAll)
import XMonad.Actions.WorkspaceNames

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.Minimize
import XMonad.Hooks.RefocusLast
import XMonad.Hooks.Rescreen
import XMonad.Hooks.ShowWName
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WindowSwallowing (swallowEventHook)

import XMonad.Layout.Accordion
import XMonad.Layout.BoringWindows (boringWindows, clearBoring, focusDown, focusUp, markBoringEverywhere)
import XMonad.Layout.CenterMainFluid (CenterMainFluid (CenterMainFluid))
import XMonad.Layout.CenteredMaster (centerMaster)
import XMonad.Layout.Decoration
import XMonad.Layout.FocusTracking (focusTracking)
import XMonad.Layout.Groups.Examples (TiledTabsConfig (tabsTheme))
import XMonad.Layout.HintedGrid
import XMonad.Layout.Magnifier (magnifiercz')
import XMonad.Layout.Master (mastered)
import XMonad.Layout.Minimize
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Renamed
import XMonad.Layout.Spacing
import XMonad.Layout.Spiral (spiral)
import XMonad.Layout.Tabbed (tabbed)
import XMonad.Layout.ThreeColumns
import XMonad.Layout.WorkspaceDir

import XMonad.Prompt
import XMonad.Prompt.FuzzyMatch (fuzzyMatch, fuzzySort)
import XMonad.Prompt.Ssh
import XMonad.Prompt.Workspace

import XMonad.Actions.Submap
import XMonad.Prompt.Man
import XMonad.Util.ClickableWorkspaces (clickablePP)
import XMonad.Util.EZConfig
import XMonad.Util.Hacks
import XMonad.Util.Loggers (logTitles)
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Util.Themes (xmonadTheme)
import XMonad.Util.XUtils (WindowConfig (..))
import XMonad.Prompt.Shell (shellPrompt)

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
        . withUrgencyHook NoUrgencyHook
        . withSB (statusBarProp "xmobar" myXmobarPP)
        . spawnExternalProcess def
        . addDescrKeys ((mod4Mask, xK_F1), xMessage) myKeys
        $ myConfig

myConfig =
    def
        { modMask = mod4Mask
        , terminal = "kitty"
        , borderWidth = 3
        , focusedBorderColor = foreground
        , normalBorderColor = background
        , layoutHook = myLayout
        , logHook =
            historyHook
                *> refocusLastLogHook
                *> workspaceHistoryHookExclude [scratchpadWorkspaceTag]
                *> showWNameLogHook
                    def
                        { swn_font = "xft:" ++ myFont ++ ":size=21"
                        , swn_bgcolor = background
                        , swn_color = foreground
                        }
        , handleEventHook = myHandleEventHook
        , manageHook = myManageHook
        , startupHook = do
            -- return () >> checkKeymap myConfig myKeymap -- WARN: return needed to avoid infinite recursion
            myStartupHook
        , workspaces = topicNames topics
        }
  where
    background = "#25273A"
    foreground = "#CAD3F5"

myFont = "FiraCode Nerd Font"

browser :: Browser
browser = "firefox"

visualConfig :: WindowConfig
visualConfig =
    def
        { winFont = "xft:" ++ myFont ++ ":size=21"
        , winBg = "#25273A"
        , winFg = "#CAD3F5"
        }

--------------------------------------------------------------------------------
-- TOPICS
--------------------------------------------------------------------------------

topicConfig :: TopicConfig
topicConfig =
    def
        { topicDirs = tiDirs topics
        , topicActions = tiActions topics
        , defaultTopicAction = const (pure ())
        , defaultTopic = tHSK
        }

tHSK :: Topic = "`"

topics :: [TopicItem]
topics =
    [ noAction tHSK "Documents"
    , TI "1:WEB" "Downloads" $ spawn browser
    , TI "2:SHELL" "Documents" spawnTermInTopic
    , TI "3:EDITOR" "Documents" spawnEditorInTopic
    , TI "4:PLAYGROUND" "Documents/Playground" spawnTermInTopic
    , only "5"
    , only "6"
    , inHome "7:CAL" $ spawnInTerm "cal -y"
    , inHome "8:IM" $ spawn "slack"
    , TI "9:MEDIA" "Videos" spawnTermInTopic
    , sshHost "mn5"
    , sshHost "hut"
    , sshHost "hca"
    , TI "paraver" "Documents/traces" $ spawn "wxparaver" *> switchToLayout "TwoPane Tab"
    , TI "zotero" "Zotero" $ spawn "zotero"
    , inHome "discord" $ spawn "legcord"
    , TI "minecraft" ".local/share/PrismLauncher" $ spawn "prismlauncher"
    , inHome "gaming" $ spawn "steam"
    ]
        ++ fmap
            ($ spawnTermInTopic)
            ( [ TI "dotfiles" ".dotfiles"
              , TI "downloads" "Downloads"
              ]
                ++ [ TI name ("Documents/" ++ name)
                   | name <-
                        [ "nixpkgs"
                        , "bscpkgs"
                        , "nos-v"
                        , "tampi"
                        , "nodes"
                        , "nanos6"
                        , "pocl-v"
                        , "hpccg"
                        , "jungle"
                        , "ovni"
                        , "haskell/jutge"
                        , "aoc-25"
                        ]
                   ]
            )
  where
    only :: Topic -> TopicItem
    only n = noAction n "~/."

switchToLayout = sendMessage . JumpToLayout

sshHost host = inHome host $ spawnInTerm ("ssh " ++ host)

-- | Go to a topic, shift a window to it, or do both at the same time.
gotoWs, shiftWin, copyTo :: Topic -> X ()
gotoWs = switchTopic topicConfig
shiftWin = windows . W.shift
copyTo = windows . copy

{- | Prompt version of 'goto' for topics that are not available via
direct keybindings.
-}
promptedGoto :: X ()
promptedGoto = workspacePrompt topicPrompt gotoWs

-- | Modify our standard prompt a bit.
topicPrompt :: XPConfig
topicPrompt =
    prompt
        { autoComplete = Just 3000 -- Time is in μs.
        , historySize = 0 -- No history in the prompt.
        }

-- | Spawn terminal in topic directory.
spawnTermInTopic :: X ()
spawnTermInTopic = proc termInTopic

termInTopic = termInDir >-$ currentTopicDir topicConfig

spawnEditorInTopic = spawnInTerm "nvim ."
spawnEditorInTopicOpen file = spawnInTerm $ "nvim " ++ file
spawnInTerm prog = proc $ inTermHold >-> executeNoQuote prog
spawnInTerm' prog = proc $ inTerm >-> executeNoQuote prog
inTermHold = termInTopic >-$ pure " --hold"

-- | Base colours to be used.
colorBg :: String = "#1e1e2e"

colorBlue :: String = "#b4befe"
colorCyan :: String = "#89dceb"
colorFg :: String = "#f8f8f2"
colorLowWhite :: String = "#bbbbbb"
colorMagenta :: String = "#eba0ac"
colorRed :: String = "#f38ba8"
colorText :: String = "#cdd6f4"
colorYellow :: String = "#f9e2af"

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

{- | I really don't want a history for some things; just clutters up the
@promptHistory@ file.
-}
promptNoHist :: XPConfig
promptNoHist = prompt{historySize = 0}

setName :: String -> l a -> ModifiedLayout Rename l a
setName n = renamed [Replace n]

myLayout =
    avoidStruts
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
    tiled = spacer $ Tall nmaster delta ratio
    threeColsMid = spacer $ magnifiercz' 1.3 $ CenterMainFluid nmaster delta ratio
    threeCols = spacer $ ThreeCol nmaster delta ratio
    twoPaneA = setName "TwoPane Acc" $ spacer $ mastered delta ratioTwoPane $ focusTracking Accordion
    twoPane = setName "TwoPane Tab" $ spacer' $ mastered delta ratioTwoPane $ focusTracking $ tabbed shrinkText myTabTheme

    myTabTheme =
        def
            { activeColor = "#8AADF4"
            , urgentColor = "#ED8796"
            , inactiveColor = "#25273A"
            , activeTextColor = "#25273A"
            , urgentTextColor = "#25273A"
            , inactiveTextColor = "#CAD3F5"
            , activeBorderColor = "#CAD3F5"
            , inactiveBorderColor = "#676B84"
            , urgentBorderColor = "#676B84"
            , decoHeight = 40
            , fontName = "xft:JetBrainsMono Nerd Font:size=8"
            , activeBorderWidth = 3
            , inactiveBorderWidth = 3
            , urgentBorderWidth = 3
            }

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
    getIconName "TwoPane Tab" = Just "mastertab"
    getIconName "TwoPane Acc" = Just "masteracc"
    getIconName x
        | "Spacing" `isPrefixOf` x = getIconName $ stripPrefix "Spacing " x
        | "Magnifier" `isPrefixOf` x = getIconName $ stripPrefix "Magnifier " x
        | "NoMaster" `isPrefixOf` x = getIconName $ stripPrefix "NoMaster " x
        | "Hinted" `isPrefixOf` x = getIconName $ stripPrefix "Hinted " x
        | "Minimize" `isPrefixOf` x = getIconName $ stripPrefix "Minimize " x
        | "Mirror" `isPrefixOf` x = fmap ("mirror_" ++) . getIconName $ stripPrefix "Mirror " x
        | otherwise = Nothing

endsWith, startsWith :: (Eq a) => Query [a] -> [a] -> Query Bool
qa `endsWith` a = qa <&> isSuffixOf a
qa `startsWith` a = qa <&> isPrefixOf a

qNot :: Query Bool -> Query Bool
qNot = fmap not

myHandleEventHook =
    composeAll
        [ handleEventHook def
        , windowedFullscreenFixEventHook
        , swallowEventHook
            ( className
                =? "kitty"
                <&&> qNot ((title `endsWith` "NVIM") <||> (title `startsWith` "gdb"))
            )
            (return True)
        , refocusLastWhen refocusingIsActive
        , minimizeEventHook
        , trayerAboveXmobarEventHook
        , trayerPaddingXmobarEventHook
        ]

rectfloatCenter ratio = doRectFloat $ RationalRect border border ratio ratio
    where
        border = (1 - ratio) / 2

doCenterFloatFixed = rectfloatCenter (1 % 2) <+> doF W.swapUp
doCenterFloatFixedBig = rectfloatCenter (4 % 5) <+> doF W.swapUp

scratchpads =
    [ NS "scratchpad" (myTerm ++ " --name scratchpad --class scratchpad") (className =? "scratchpad") doCenterFloatFixed
    , NS "qalc" "qalculate-gtk" (className =? "Qalculate-gtk") doCenterFloatFixed
    , NS "mail" "thunderbird" (appName =? "Mail" <&&> className =? "thunderbird") doCenterFloatFixedBig
    , NS "btm" (myTerm ++ " --name btm --class btm -e btm") (className =? "btm") doCenterFloatFixedBig
    ]

myManageHook =
    composeAll
        [ composeOne
            [ className =? "confirm" -?> doCenterFloatUp
            , className =? "file_progress" -?> doCenterFloatUp
            , className =? "dialog" -?> doCenterFloatUp
            , className =? "download" -?> doCenterFloatUp
            , className =? "error" -?> doCenterFloatUp
            , className =? "notification" -?> doCenterFloatUp
            , className =? "pinentry-gtk-2" -?> doCenterFloatUp
            , className =? "splash" -?> doCenterFloatUp
            , className =? "toolbar" -?> doCenterFloatUp
            , className =? "Slack" -?> doShift (myWorkspaces !! 8)
            , (appName =? "Alert" <&&> className =? "Zotero") -?> doIgnore
            , (className =? "Qalculate-gtk") -?> doCenterFloatUp
            , (className =? "Pavucontrol") -?> doCenterFloatUp
            , (className =? "Wxparaver") -?> doShift "paraver"
            , (className =? "firefox") -?> doShift (myWorkspaces !! 1)
            , (stringProperty "WM_NAME" =? "Picture-in-Picture") -?> doFloat
            , isDialog -?> doCenterFloatUp
            , isFullscreen -?> doFullFloat
            ]
        , not <$> willFloat --> insertPosition Below Newer
        , title =? "Calendar" --> (doFocus *> doCenterFloatUp)
        , namedScratchpadManageHook scratchpads
        ]
  where
    doCenterFloatUp = doCenterFloat <+> doF W.swapUp

myStartupHook =
    mconcat
        [ restoreBackground
        , spawnOnce "thunderbird"
        , spawnOnce "slack -u"
        ]
  where
    restoreBackground = spawnOnce "~/.fehbg"

subtitle' :: String -> ((KeyMask, KeySym), NamedAction)
subtitle' x =
    ( (0, 0)
    , NamedAction $
        map toUpper $
            sep ++ "\n-- " ++ x ++ " --\n" ++ sep
    )
  where
    sep = replicate (6 + length x) '-'

-- | Toggle between the current and the last topic.
toggleTopic :: X ()
toggleTopic = switchNthLastFocusedByScreen topicConfig 1

-- | Shift the currently focused window to the last visited topic.
shiftToLastTopic :: X ()
shiftToLastTopic = shiftNthLastFocused 1

-- https://github.com/xmonad/xmonad/blob/master/src/XMonad/Config.hs
myKeys c =
    let subKeys str ks = subtitle' str : mkNamedKeymap c ks
     in -- in (subtitle "Custom Keys" :) $
        -- mkNamedKeymap c $
        subKeys
            "Base"
            [ ("M-S-q", addName "Quit Xmonad" $ io exitSuccess)
            , ("M-d", addName "Open rofi" $ spawn "rofi -show")
            , ("M-k", addName "Focus Up" focusUp)
            , ("M-j", addName "Focus Down" focusDown)
            , ("M-w", addName "Remove window from workspace" kill1)
            , ("M-S-w", addName "Kill window" kill)
            , ("M-C-S-w", addName "Remove Window from all workspaces" killAll)
            , ("C-M1-l", addName "Lock screen" $ spawn "i3lock-fancy-rapid 5 5")
            , ("M-S-m", addName "Focus previous" $ nextMatch History (return True))
            , ("M-f", addName "Toggle fullscreen" $ sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts)
            , ("M-x", addName "Toggle mirror" $ sendMessage $ Toggle MIRROR)
            , ("M-<Return>", addName "Open terminal" spawnTermInTopic)
            , ("M-S-<Return>", addName "Promote to master" dwmpromote)
            , ("M-a", addName "Topic Action" $ currentTopicAction topicConfig)
            , ("M-C-t", addName "Tile floating windows" $ withFocused $ windows . W.sink)
            , ("M-s", addName "Sticky" $ windows copyToAll)
            , ("M-S-s", addName "Unsticky" killAllOtherCopies)
            , ("M-z", addName "Toggle Scratchpad" $ namedScratchpadAction [] "scratchpad")
            , ("M-c", addName "Toggle qalc" $ namedScratchpadAction [] "qalc")
            , ("M-t", addName "Toggle btm" $ namedScratchpadAction [] "btm")
            , ("M-n", addName "Nvim" $ runOrRaiseNext (myTerm ++ " nvim") ((isSuffixOf "NVIM" <$> title) <||> (isSuffixOf "- NVIM\" " <$> title)))
            , ("M-b", addName "firefox" $ runOrRaiseNext "firefox" (className =? "firefox"))
            , ("M-S-b", addName "run or copy firefox" $ runOrCopy "firefox" (className =? "firefox"))
            , ("M-v", addName "Terminal" $ runOrRaiseNext myTerm (className =? myTerm))
            , ("M-u", addName "Focus urgent" focusUrgent)
            , ("M-;", addName "Minimize" $ withFocused minimizeWindow)
            , ("M-S-;", addName "UnMinimize" $ withLastMinimized maximizeWindowAndFocus)
            , ("M-'", addName "Mark Boring" markBoringEverywhere)
            , ("M-S-'", addName "Clear Boring" clearBoring)
            , ("M-g", addName "Mail" $ namedScratchpadAction [] "mail")
            , ("M-/", addName "Goto" $ workspacePrompt topicPrompt gotoWs)
            , ("M-S-/", addName "Move to" $ workspacePrompt topicPrompt shiftWin)
            , ("M-C-/", addName "Copy to" $ workspacePrompt topicPrompt copyTo)
            , ("M-p", addName "Prompt" $ shellPrompt prompt)
            , ("M-o", addName "toggletopic" toggleTopic)
            , ("M-S-o", addName "move toggle topic" shiftToLastTopic)
            , ("M-[", addName "prev topic" $ moveTo Prev $ hiddenWS :&: Not emptyWS :&: ignoringWSs [scratchpadWorkspaceTag])
            , ("M-]", addName "next topic" $ moveTo Next $ hiddenWS :&: Not emptyWS :&: ignoringWSs [scratchpadWorkspaceTag])
            , ("M-S-[", addName "shift prev topic" $ shiftTo Prev $ hiddenWS :&: Not emptyWS :&: ignoringWSs [scratchpadWorkspaceTag])
            , ("M-S-]", addName "shift next topic" $ shiftTo Next $ hiddenWS :&: Not emptyWS :&: ignoringWSs [scratchpadWorkspaceTag])
            , ("M-i", addName "swap screens" swapNextScreen)
            , ("M-S-i", addName "swap screens" swapPrevScreen)
            , ("M-e", addName "search" $ visualSubmap visualConfig searchEngineMap)
            ]
            ^++^ subKeys
                "Volume"
                [ -- Volume
                  ("<XF86AudioLowerVolume>", addName "volume up" $ spawn "amixer -q sset Master 5%-")
                , ("<XF86AudioRaiseVolume>", addName "volume down" $ spawn "amixer -q sset Master 5%+")
                , ("<XF86AudioMute>", addName "volume mute" $ spawn "amixer -q sset Master toggle")
                ]
            ^++^ subKeys
                "Media"
                -- Media
                [ ("<XF86AudioPlay>", addName "Play/Pause" $ spawn "playerctl play-pause")
                , ("<XF86AudioNext>", addName "Next" $ spawn "playerctl next")
                , ("<XF86AudioPrev>", addName "Prev" $ spawn "playerctl previous")
                , ("<XF86AudioStop>", addName "Stop" $ spawn "playerctl stop")
                -- ("M-<KP_5>", addName "volume up" $ spawn "hass-cli state toggle light.desk_lamp")
                ]
            ^++^ subKeys
                "Brightness"
                -- Brightness
                [ ("<XF86MonBrightnessUp>", addName "Increase brightness" $ spawn "light -A 1")
                , ("<XF86MonBrightnessDown>", addName "Decrease brightness" $ spawn "light -U 1")
                ]
            ^++^ subKeys
                "Workspaces"
                -- Copy client to other workspaces
                [ ("M-C-" ++ ws, addName "" $ windows $ copy name)
                | (ws, name) <- zip wsKeys myWorkspaces
                ]
            ^++^ subKeys
                "Goto"
                [("M-" <> m <> k, addName "" $ f i) | (i, k) <- zip (topicNames topics) wsKeys, (f, m) <- [(gotoWs, ""), (windows . W.shift, "S-")]]

wsKeys = "`" : map (show @Int) [1 .. 9]
myWorkspaces = topicNames topics

myLogHook = dynamicLogWithPP . filterOutWsPP [scratchpadWorkspaceTag] $ def

myXmobarPP :: X PP
myXmobarPP = do
    red <- getColorOrDefault "color1" "#ED8796"
    green <- getColorOrDefault "color2" "#A6DA95"
    yellow <- getColorOrDefault "color3" "#EED49F"
    blue <- getColorOrDefault "color4" "#8AADF4"
    magenta <- getColorOrDefault "color5" "#C6A0F6"
    white <- getColorOrDefault "color7" "#B8C0E0"
    cyan' <- liftIO $ fromMaybe "#8BD5CA" <$> xrdbGet "color6"
    foreground <- getColorOrDefault "foreground" "#CAD3F5"
    lowWhite <- getColorOrDefault "color8" "#5B6078"

    let formatFocused = wrap (foreground "[") (foreground "]") . magenta . ppWindow
    let formatUnfocused = wrap (lowWhite "[") (lowWhite "]") . blue . ppWindow

    (copiesPP (pad . green) >=> workspaceNamesPP >=> clickablePP) $
        filterOutWsPP [scratchpadWorkspaceTag] $
            def
                { ppSep = magenta " | "
                , ppTitleSanitize = xmobarStrip
                , ppCurrent = pad . xmobarBorder "Top" cyan' 2
                , ppVisible = wrap "(" ")"
                , ppHidden = pad
                , -- , ppHiddenNoWindows = lowWhite . pad
                  ppLayout = white . myLayoutPrinter
                , ppUrgent = red . wrap (yellow "!") (yellow "!")
                , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
                , ppExtras = [logTitles formatFocused formatUnfocused]
                }
  where
    -- \| Windows should have *some* title, which should not not exceed a
    -- sane length.
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30

    fgColor = flip xmobarColor ""

    getColorOrDefault :: String -> String -> X (String -> String)
    getColorOrDefault color def = liftIO $ fmap (fgColor . fromMaybe def) . xrdbGet $ color

rescreenCfg :: RescreenConfig
rescreenCfg =
    def
        { afterRescreenHook = spawn "pkill xmobar; sleep 1; xmonad --restart; ~/.fehbg"
        , randrChangeHook = spawn "autorandr --change"
        }

myTerm = "kitty"

-- xrdbGet :: (MonadIO m) => String -> m (Maybe String)
xrdbGet :: String -> IO (Maybe String)
xrdbGet value = do
    res <- lines <$> runProcessWithInput "xrdb" ["-get", value] ""
    return $ case res of
        [] -> Nothing
        a : _ -> Just a

searchEngineMap :: Map (KeyMask, KeySym) (String, X ())
searchEngineMap =
    basicSubmapFromList
        [ (xK_a, "[a]rXiv", sw arXiv)
        , (xK_w, "[w]ikipedia", sw wikipedia)
        , (xK_y, "[y]ouTube", sw youtube)
        , (xK_h, "[h]oogle", sw hoogle)
        , (xK_g, "[g]oogle", sw google)
        , (xK_d, "[d]uckduckgo", sw duckduckgo)
        , (xK_s, "[s]ourcegraph", sw sourcegraph)
        , (xK_p, "re[p]ology", sw repology)
        , (xK_c, "[c]ppreference", sw cppreference)
        , (xK_h, "git[h]ub", sw github)
        ,
            ( xK_n
            , "[n]ix"
            , visualSubmap visualConfig $
                basicSubmapFromList
                    [ (xK_n, "[n]oogle", sw noogle')
                    , (xK_p, "nixos [p]ackages", sw nixos)
                    , (xK_h, "[h]ome", sw homeManager)
                    , (xK_o, "nixos [o]ptions", sw nixosOptions)
                    ]
            )
        ,
            ( xK_r
            , "[r]ust"
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
        , (xK_o, "[o]sm", sw openstreetmap)
        ]
  where
    basicSubmapFromList :: (Ord key) => [(key, desc, action)] -> Map (KeyMask, key) (desc, action)
    basicSubmapFromList = fromList . map \(k, d, a) -> ((0, k), (d, a))

    sw = promptSearchBrowser prompt browser

    nixosOptions = searchEngine "nixosOptions" "https://search.nixos.org/options?channel=unstable&from=0&size=200&sort=relevance&type=packages&query="
    sourcegraph = searchEngine "sourcegraph" "https://sourcegraph.com/search?q="
    repology = searchEngine "repology" "https://repology.org/projects/?search="
    cppreference = searchEngine "cppreference" "https://duckduckgo.com/?sites=cppreference.com&q="
    noogle' = searchEngine "noogle" "https://noogle.dev/q?term="
