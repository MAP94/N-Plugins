SetScriptTitle("Watch")
SetScriptInfo("(c) by MAP94")
SetScriptUseSettingPage(1)

AddEventListener("OnRenderLevel17", "RenderWatch")
AddEventListener("OnKeyLevel11", "KeyEvent")

watch = TextureLoad("watch.png")
hand = TextureLoad("watchhand.png")

Config = {}
Config["bindkeycode"] = 0
Config["bindkeyname"] = 0
include ("lua/watch.config")

function Clamp(val, min, max)
    if (val < min) then
        return min
    end
    if (val > max) then
        return max
    end
    return val
end

NumInputs = 0
Inputs = {}
Inputs["Flags"] = {}
Inputs["Code"] = {}
Inputs["Unicode"] = {}
function KeyEvent(KeyCode, Unicode, Flags)
    Print("k", KeyCode)
    if (KeyCode == 0) then
        return
    end
    NumInputs = NumInputs + 1

    Inputs["Flags"][NumInputs] = Flags
    Inputs["Code"][NumInputs] = KeyCode
    Inputs["Unicode"][NumInputs] = Unicode
end

function FindInput(KeyCode)
    for i = 1, NumInputs do
        if (Inputs["Code"][i] == tonumber(KeyCode)) then
            Print("..", Inputs["Flags"][i])
            return Inputs["Flags"][i]
        end
    end
end

Show = 0
function RenderWatch()
    if (FindInput(Config["bindkeycode"])) then
        Show = 1.5
    elseif(Show > 0) then
        Show = Show  - 0.01
    end
    if (Show > 0) then
        w = GetScreenWidth()
        h = GetScreenHeight()

        s = h / 1.2
        RenderTexture(watch, w / 2 - s / 2, h / 2 - s / 2, s, s, nil, nil, nil, nil, 1, 1, 1, Show)

        Date = GetDate("*t")

        f = 0.3
        w1 = s * f / 6
        h1 = s * f
        RenderTexture(hand, w / 2 - w1 / 2, h / 2 - h1 + w1 / 2, w1, h1, nil, nil, nil, nil, 1, 1, 1, Show, (tonumber(Date["hour"]) / 12 + tonumber(Date["min"]) / 60 / 12) * math.pi * 2, w1 / 2, h1 - w1 / 2)

        f = 0.4
        w1 = s * f / 6
        h1 = s * f
        RenderTexture(hand, w / 2 - w1 / 2, h / 2 - h1 + w1 / 2, w1, h1, nil, nil, nil, nil, 1, 1, 1, Show, tonumber(Date["min"]) / 60 * math.pi * 2, w1 / 2, h1 - w1 / 2)
    end
end

BindKey = false
GTime = 0
function Tick(Time, ServerTick)
    GTime = Time / 1000

    if (BindKey and NumInputs > 0) then
        Config["bindkeycode"] = Inputs["Code"][1]
        Config["bindkeyname"] = string.char(Inputs["Code"][1])
        UiSetText(UiBindButton, "Change bind key (" .. Config["bindkeyname"] .. ")")
        BindKey = false

        configout = io.open("lua/watch.config", "wb")
        configout:write("--Configfile for Watch\n")
        configout:write("Config = {}\n")
        configout:write("Config[\"bindkeycode\"] = \"" .. Config["bindkeycode"] .. "\"\n")
        configout:write("Config[\"bindkeyname\"] = \"" .. Config["bindkeyname"] .. "\"\n")
        configout:close()
        include ("lua/watch.config")
    end

    NumInputs = 0
end

function Change()
    UiSetText(UiBindButton, "Press a key")
    BindKey = true
end
UiBindButton = nil
function ConfigOpen(x, y, w, h)
    local i = 0
    UiBindButton = UiDoButton(x, y, 200, 20, 0, "Change bind key (" .. Config["bindkeyname"] .. ")", "Change")
end

function ConfigClose()
    UiRemoveElement(UiBindButton)
    BindKey = false
end
