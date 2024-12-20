import Data.Ratio
import System.Environment (lookupEnv)
import System.Exit (exitSuccess)
import XMonad
import XMonad.Actions.CopyWindow
import XMonad.Actions.DwmPromote (dwmpromote)
import XMonad.Actions.GroupNavigation
import XMonad.Actions.Minimize
import XMonad.Actions.MouseResize (mouseResize)
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
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed (addTabs, simpleTabbed, tabbed)
import XMonad.Layout.ThreeColumns
import XMonad.Layout.TwoPanePersistent (TwoPanePersistent (TwoPanePersistent))
import XMonad.Layout.WorkspaceDir
import XMonad.Prelude
import XMonad.Prompt (amberXPConfig, complCaseSensitivity, ComplCaseSensitivity (CaseInSensitive))
import XMonad.StackSet (RationalRect (RationalRect))
import XMonad.StackSet qualified as W
import XMonad.Util.ClickableWorkspaces (clickablePP)
import XMonad.Util.EZConfig
import XMonad.Util.Hacks
import XMonad.Util.Loggers (logTitles)
import XMonad.Util.NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput)
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Util.Themes (xmonadTheme)

data Settings = Settings
    { term :: String
    , theme :: MyTheme
    }

data MyTheme = MyTheme
    { background :: String
    , foreground :: String
    , font :: String
    }

defaultSettings =
    Settings
        { term = "kitty"
        , theme =
            MyTheme
                { background = "#25273A"
                , foreground = "#CAD3F5"
                , font = "JetBrainsMono Nerd Font"
                }
        }

getTheme :: IO MyTheme
getTheme = do
    fg <- fromMaybe (foreground defaultTheme) <$> xrdbGet "foreground"
    bg <- fromMaybe (background defaultTheme) <$> xrdbGet "background"

    font <- fromMaybe (font defaultTheme) <$> xrdbGet "font_family"

    return $ MyTheme{font = font, background = bg, foreground = fg}
  where
    defaultTheme = theme defaultSettings

getSettings :: IO Settings
getSettings = do
    theme <- getTheme
    term <- fromMaybe (term defaultSettings) <$> lookupEnv "TERMINAL"

    return $ Settings{term = term, theme = theme}

myLayout =
    avoidStruts
        . mkToggle (MIRROR ?? NBFULL ?? NOBORDERS ?? EOT)
        . smartBorders
        . mouseResize
        . boringWindows
        . minimize
        . modWorkspaces myWorkspaces (workspaceDir "~")
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
    twoPaneA = spacer $ renamed [Replace "TwoPane Acc"] $ mastered delta ratioTwoPane $ focusTracking Accordion
    twoPane = spacer' $ renamed [Replace "TwoPane Tab"] $ mastered delta ratioTwoPane $ focusTracking $ tabbed shrinkText myTabTheme

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

doCenterFloatFixed = doRectFloat (RationalRect (1 % 4) (1 % 4) (1 % 2) (1 % 2)) <+> doF W.swapUp

scratchpads =
    [ NS "scratchpad" (myTerm ++ " --name scratchpad --class scratchpad") (className =? "scratchpad") doCenterFloatFixed
    , NS "taskwarrior" (myTerm ++ " --name taskwarrior --class taskwarrior vit") (className =? "taskwarrior") doCenterFloatFixed
    , NS "qalc" "qalculate-gtk" (className =? "Qalculate-gtk") doCenterFloatFixed
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
            , (className =? "leagueclientux.exe") -?> (doCenterFloat <+> doShift (myWorkspaces !! 1))
            , -- , className =? "Wxparaver" -?> title >>= \case
              --     "Paraver" -> doF id -- We tile the main window, but float the rest (mainly popups and plots)
              --     _ -> doFloat
              (className =? "thunderbird" <&&> title /=? "Calendar") -?> doShift (myWorkspaces !! 6)
            , className =? "Slack" -?> doShift (myWorkspaces !! 5)
            , (appName =? "Alert" <&&> className =? "Zotero") -?> doIgnore
            , (className =? "riotclientux.exe") -?> (doCenterFloat <+> doShift (myWorkspaces !! 1))
            , (className =? "Qalculate-gtk") -?> doCenterFloatUp
            , (className =? "Pavucontrol") -?> doCenterFloatUp
            , (stringProperty "WM_NAME" =? "Picture-in-Picture") -?> doFloat
            , isDialog -?> doCenterFloatUp
            , isFullscreen -?> doFullFloat
            , return True -?> insertPosition Below Newer
            ]
        , title =? "Calendar" --> (doFocus *> doCenterFloatUp)
        , title =? "Mozilla Firefox" --> doShift (myWorkspaces !! 0)
        , (className =? "ArmCord") --> doShift (myWorkspaces !! 2)
        , namedScratchpadManageHook scratchpads
        ]
  where
    doCenterFloatUp = doCenterFloat <+> doF W.swapUp

myStartupHook =
    mconcat
        [ restoreBackground
        , -- , spawnHereNamedScratchpadAction scratchpads "taskwarrior"
          spawnOnce "thunderbird"
        , spawnOnce "kdeconnect-indicator"
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

-- https://github.com/xmonad/xmonad/blob/master/src/XMonad/Config.hs
myKeys c =
    let subKeys str ks = subtitle' str : mkNamedKeymap c ks
     in -- in (subtitle "Custom Keys" :) $
        -- mkNamedKeymap c $
        subKeys
            "Base"
            [ ("M-S-q", addName "Quit Xmonad" $ io exitSuccess)
            , ("M-d", addName "Open rofi" $ spawn "rofi -show")
            , ("M-k", addName "Focus Up" $ focusUp)
            , ("M-j", addName "Focus Down" $ focusDown)
            , ("M-w", addName "Remove window from workspace" $ kill1)
            , ("M-S-w", addName "Kill window" $ kill)
            , ("M-C-S-w", addName "Remove Window from all workspaces" $ killAll)
            , ("C-M1-l", addName "Lock screen" $ spawn "i3lock-fancy-rapid 5 5")
            , ("M-S-m", addName "Focus previous" $ nextMatch History (return True))
            , ("M-f", addName "Toggle fullscreen" $ sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts)
            , ("M-x", addName "Toggle mirror" $ sendMessage $ Toggle MIRROR)
            , ("M-<Return>", addName "Open terminal" $ spawn myTerm)
            , ("M-S-<Return>", addName "Promote to master" $ dwmpromote)
            , ("M-C-t", addName "Tile floating windows" $ withFocused $ windows . W.sink)
            , ("M-s", addName "Sticky" $ windows copyToAll)
            , ("M-S-s", addName "Unsticky" $ killAllOtherCopies)
            , ("M-z", addName "Toggle Scratchpad" $ namedScratchpadAction scratchpads "scratchpad")
            , ("M-S-z", addName "Toggle vit" $ namedScratchpadAction scratchpads "taskwarrior")
            , ("M-c", addName "Toggle qalc" $ namedScratchpadAction scratchpads "qalc")
            , ("M-n", addName "Nvim" $ runOrRaiseNext (myTerm ++ " nvim") (isSuffixOf "NVIM" <$> title <||> isSuffixOf "- NVIM\" " <$> title))
            , ("M-b", addName "firefox" $ runOrRaiseNext "firefox" (className =? "firefox"))
            , ("M-S-b", addName "run or copy firefox" $ runOrCopy "firefox" (className =? "firefox"))
            , ("M-v", addName "Terminal" $ runOrRaiseNext myTerm (className =? myTerm))
            , ("M-u", addName "Focus urgent" focusUrgent)
            , ("M-;", addName "Minimize" $ withFocused minimizeWindow)
            , ("M-S-;", addName "UnMinimize" $ withLastMinimized maximizeWindowAndFocus)
            , ("M-'", addName "Mark Boring" $ markBoringEverywhere)
            , ("M-S-'", addName "Clear Boring" $ clearBoring)
            , ("M-y", addName "Rename workspace" $ renameWorkspace def)
            , ("M-S-y", addName "Change workspace dir" $ changeDir def {complCaseSensitivity = CaseInSensitive})
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
            -- Move to other screens
            ^++^ subKeys
                "Workspaces"
                [ ("M-" ++ m ++ k, addName "" $ screenWorkspace sc >>= flip whenJust (windows . f))
                | (k, sc) <- zip ["e", "r", "t"] [0 ..]
                , (f, m) <- [(W.view, ""), (W.shift, "S-")]
                ]
            ^++^ subKeys
                "Workspaces"
                -- Copy client to other workspaces
                [ ("M-S-C-" ++ ws, addName "" $ windows $ copy name)
                | (ws, name) <- zip (map show [1 .. 9]) myWorkspaces
                ]
            ^++^ subKeys
                "Sublayouts"
                [ ("M-C-h", addName "" $ sendMessage $ pullGroup L)
                , ("M-C-l", addName "" $ sendMessage $ pullGroup R)
                , ("M-C-k", addName "" $ sendMessage $ pullGroup U)
                , ("M-C-j", addName "" $ sendMessage $ pullGroup D)
                , ("M-C-m", addName "" $ withFocused (sendMessage . MergeAll))
                , ("M-C-u", addName "" $ withFocused (sendMessage . UnMerge))
                , ("M-C-S-u", addName "" $ withFocused (sendMessage . UnMergeAll))
                , ("M-C-.", addName "" $ onGroup W.focusUp')
                , ("M-C-,", addName "" $ onGroup W.focusDown')
                ]

myWorkspaces = map show [1 .. 9]

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

    click <-
        clickablePP . filterOutWsPP [scratchpadWorkspaceTag] $
            def
                { ppSep = magenta " | "
                , ppTitleSanitize = xmobarStrip
                , ppCurrent = pad . xmobarBorder "Top" cyan' 2
                , ppVisible = wrap "(" ")"
                , ppHidden = pad
                , ppHiddenNoWindows = lowWhite . pad
                , ppLayout = white . myLayoutPrinter
                , ppUrgent = red . wrap (yellow "!") (yellow "!")
                , ppOrder = \[ws, l, _, wins] -> [ws, l, wins]
                , ppExtras = [logTitles formatFocused formatUnfocused]
                }
    copiesPP (pad . green) click >>= workspaceNamesPP
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

main =
    myConfig
        >>= xmonad
            . docks
            . ewmhFullscreen
            . ewmh
            . javaHack
            . rescreenHook rescreenCfg
            . withUrgencyHook NoUrgencyHook
            . withSB (statusBarProp "xmobar" myXmobarPP)
            . addDescrKeys ((mod4Mask, xK_F1), xMessage) myKeys

myTerm = "kitty"

myConfig = do
    settings <- getSettings

    return $
        def
            { terminal = term settings
            , modMask = mod4Mask
            , borderWidth = 3
            , focusedBorderColor = foreground . theme $ settings
            , normalBorderColor = background . theme $ settings
            , layoutHook = myLayout
            , logHook =
                historyHook
                    *> refocusLastLogHook
                    *> showWNameLogHook
                        def
                            { swn_font = "xft:" ++ (font . theme $ settings) ++ ":size=21"
                            , swn_bgcolor = background . theme $ settings
                            , swn_color = foreground . theme $ settings
                            }
            , handleEventHook = myHandleEventHook
            , manageHook = myManageHook
            , startupHook = do
                -- return () >> checkKeymap myConfig myKeymap -- WARN: return needed to avoid infinite recursion
                myStartupHook
            , workspaces = myWorkspaces
            }

-- xrdbGet :: (MonadIO m) => String -> m (Maybe String)
xrdbGet :: String -> IO (Maybe String)
xrdbGet value = do
    res <- lines <$> runProcessWithInput "xrdb" ["-get", value] ""
    return $ case res of
        [] -> Nothing
        a : _ -> Just a
