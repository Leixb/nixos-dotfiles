import Control.Monad
import Data.Maybe (fromMaybe)
import XMonad.Hooks.StatusBar.PP
import XMonad.Util.Run (runProcessWithInput)
import Xmobar

addAction :: String -> [Int] -> String -> String
addAction action buttons = wrap ("<action=`" ++ action ++ "` button=" ++ mergedButtons ++ ">") "</action>"
  where
    mergedButtons = foldl1 (++) $ map show buttons

foldActions :: [(String, [Int])] -> String -> String
foldActions actions base = foldl (\b (a, c) -> addAction a c b) base actions

volumeActions :: String
volumeActions = foldActions actions "<volumestatus>"
  where
    actions =
        [ ("amixer -q sset Master toggle", [1])
        , ("pavucontrol", [2])
        , ("switch-audio", [3])
        , ("amixer -q sset Master 1%+", [4])
        , ("amixer -q sset Master 1%-", [5])
        ]

config = do
    font_family <- fromMaybe "FiraCode" <$> xrdbGet "font_family"
    font_size <- fromMaybe "11" <$> xrdbGet "font_size"

    colors <- getColors

    return $
        defaultConfig
            { overrideRedirect = True
            , lowerOnStart = True
            , font = unwords [font_family, font_size]
            , bgColor = background colors
            , fgColor = foreground colors
            , position = TopH 40
            , commands = myCommands colors
            , iconRoot = "/home/leix/.config/xmobar/icons"
            , sepChar = "%"
            , alignSep = "}{"
            , template = "} %UnsafeXMonadLog% { %mail% | %alsa:default:Master% | %cpu% | %memory% %swap% | %battery% | %LEBL% | %date% %_XMONAD_TRAYPAD%"
            }

getColors :: IO Colors
getColors = do
    black <- fromMaybe "#494D64" <$> xrdbGet "color0"
    red <- fromMaybe "#ED8796" <$> xrdbGet "color1"
    green <- fromMaybe "#A6DA95" <$> xrdbGet "color2"
    yellow <- fromMaybe "#EED49F" <$> xrdbGet "color3"
    blue <- fromMaybe "#8AADF4" <$> xrdbGet "color4"
    magenta <- fromMaybe "#F5BDE6" <$> xrdbGet "color5"
    cyan <- fromMaybe "#8BD5CA" <$> xrdbGet "color6"
    white <- fromMaybe "#B8C0E0" <$> xrdbGet "color7"

    background <- fromMaybe "#CAD3F5" <$> xrdbGet "background"
    foreground <- fromMaybe "#25273A" <$> xrdbGet "foreground"

    return Colors{black, red, green, yellow, blue, magenta, cyan, white, foreground, background}

main :: IO ()
main = config >>= xmobar

data Colors = Colors
    { black :: String
    , red :: String
    , green :: String
    , yellow :: String
    , blue :: String
    , magenta :: String
    , cyan :: String
    , white :: String
    , background :: String
    , foreground :: String
    }

myCommands color =
    [ Run $ XPropertyLog "_XMONAD_TRAYPAD"
    -- , Run $ Mpris2 "firefox" ["-t", "<artist> - [<composer>] <title>"] 10
    , Run $ Mail [
        ("BSC 📬", "~/Mail/bsc/Inbox") ,
        ("UPC 📬", "~/Mail/upc/mail")
    ] "mail"
    , Run $
        WeatherX
            "LEBL"
            [ ("clear", "☀️")
            , ("sunny", "☀️")
            , ("mostly clear", "🌤️")
            , ("mostly sunny", "🌤️")
            , ("partly sunny", "⛅")
            , ("fair", "🌑")
            , ("partly cloudy", "⛅")
            , ("mostly cloudy", "🌥️")
            , ("cloudy", "☁️")
            , ("overcast", "☁️")
            , ("considerable cloudiness", "☁️")
            -- ("light drizzle", ""),
            -- ("patches of fog")
            -- ("rain")
            -- ("heavy rain")
            -- ("snow")
            -- ("light rain showers")
            -- ("showers in the vicinity"
            -- ("mist"
            -- ("fog"
            -- ("precipitation"
            -- ("thunder"
            -- ("haze"
            -- ("light rain"
            -- ("drizzle"
            -- ("hail"
            -- ("hailstone"
            ] -- <weather> is only populated when there is some weather event, most of the time it's empty
            [ "--template"
            , "<fn=2><skyConditionS></fn><weather> <tempC>°C"
            , "-L"
            , "15"
            , "-H"
            , "25"
            , "--low"
            , blue color
            , "--normal"
            , foreground color
            , "--high"
            , yellow color
            ]
            36000
    , Run $
        Cpu
            [ "-L"
            , "3"
            , "-H"
            , "50"
            , "--high"
            , red color
            , "--normal"
            , green color
            , "--template"
            , "\xf4bc <total>%"
            ]
            10
    , Run $
        Alsa
            "default"
            "Master"
            [ "--template"
            , volumeActions
            , "--suffix"
            , "True"
            , "--"
            , "--on"
            , ""
            ]
    , Run $
        Memory
            [ "--Low"
            , "33" -- units: %
            , "--High"
            , "90" -- units: %
            , "--low"
            , green color
            , "--normal"
            , yellow color
            , "--high"
            , red color
            , "--template"
            , "\xeae6 <usedratio>%"
            ]
            10
    , Run $
        Swap
            [ "--template"
            , "\xe6aa <usedratio>%"
            ]
            10
    , Run $ Date ("%a %Y-%m-%d <fc=" ++ cyan color ++ ">%H:%M</fc>") "date" 10
    , Run $
        BatteryP
            ["BAT0"]
            [ "--template"
            , "<acstatus>"
            , "--suffix"
            , "True"
            , "--Low"
            , "15"
            , "--High"
            , "66"
            , "--low"
            , red color
            , "--normal"
            , cyan color
            , "--high"
            , green color
            , "--"
            , "-O"
            , "<left> ↑"
            , "-o"
            , "<leftvbar><left> (<timeleft>)"
            , "-i"
            , "<left> ~"
            ]
            10
    , Run UnsafeXMonadLog
    ]

xrdbGet :: String -> IO (Maybe String)
xrdbGet value = do
    res <- lines <$> runProcessWithInput "xrdb" ["-get", value] ""
    return $ case res of
        [] -> Nothing
        a : _ -> Just a
