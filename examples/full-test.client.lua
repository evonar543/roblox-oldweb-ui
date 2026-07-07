local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/evonar543/roblox-oldweb-ui/main/src/oldweb-ui.lua"))()

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local customFlags = {}

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local character = getCharacter()
    return character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local character = getCharacter()
    return character:FindFirstChild("HumanoidRootPart")
end

local function setWalkSpeed(value)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = value
    end
end

local function setJumpPower(value)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end

local function setFreeze(enabled)
    local root = getRoot()
    if root then
        root.Anchored = enabled
    end
end

local main = library:Window("OLDWEB CONTROL PANEL")
main:Label("visitor tools and character tests")

main:Button("Print Hi", function()
    print("Hi from OldWeb UI")
end)

local walkSpeedSlider = main:Slider("WalkSpeed", "WS", 16, 300, function(value)
    setWalkSpeed(value)
    print("WalkSpeed:", math.floor(value + 0.5))
end, 16)

local jumpPowerSlider = main:Slider("JumpPower", "JP", 50, 300, function(value)
    setJumpPower(value)
    print("JumpPower:", math.floor(value + 0.5))
end, 100)

local freezeToggle = main:Toggle("Freeze Character", "frz", false, function(toggled)
    setFreeze(toggled)
    print("Freeze:", toggled)
end)

main:Button("Set Movement Defaults", function()
    walkSpeedSlider:Set(16)
    jumpPowerSlider:Set(50)
    freezeToggle:Set(false)
end)

main:Button("Print Library Flags", function()
    print("WS flag:", library.flags.WS)
    print("JP flag:", library.flags.JP)
    print("frz flag:", library.flags.frz)
end)

main:Button("Destroy Main Window", function()
    main:Destroy()
end)

local visuals = library:Window("MY NEOCITIES PAGE")
visuals:Label("glitter zone")

local brightnessSlider = visuals:Slider("Lighting Brightness", "brightness", 0, 10, function(value)
    Lighting.Brightness = value
end, Lighting.Brightness, customFlags)

local clockSlider = visuals:Slider("Clock Time", "clock", 0, 24, function(value)
    Lighting.ClockTime = value
end, Lighting.ClockTime, customFlags)

local fogToggle = visuals:Toggle("Purple Fog", "purpleFog", false, function(enabled)
    if enabled then
        Lighting.FogColor = Color3.fromRGB(170, 70, 255)
        Lighting.FogEnd = 180
    else
        Lighting.FogEnd = 100000
    end
end, customFlags)

visuals:Button("Midnight Shrine Preset", function()
    brightnessSlider:Set(2)
    clockSlider:Set(0)
    fogToggle:Set(true)
end)

visuals:Button("Noon Reset Preset", function()
    brightnessSlider:Set(3)
    clockSlider:Set(12)
    fogToggle:Set(false)
end)

visuals:Button("Print Custom Flags", function()
    print("brightness:", customFlags.brightness)
    print("clock:", customFlags.clock)
    print("purpleFog:", customFlags.purpleFog)
end)

local tests = library:Window("API TESTS")
tests:Label("buttons sliders toggles labels")

local testToggle = tests:Toggle("Starts Enabled", "startsEnabled", true, function(toggled)
    print("Starts Enabled changed:", toggled)
end)

local testSlider = tests:Slider("Zero To One", "zeroToOne", 0, 1, function(value)
    print("Zero To One:", value)
end, 0.5)

tests:Button("Read Returned Controls", function()
    print("testToggle:Get():", testToggle:Get())
    print("testSlider:Get():", testSlider:Get())
end)

tests:Button("Set Returned Controls", function()
    testToggle:Set(not testToggle:Get())
    testSlider:Set(math.random())
end)

tests:Button("Close All Demo Windows", function()
    setFreeze(false)
    main:Destroy()
    visuals:Destroy()
    tests:Destroy()
end)

tests:Label("0 x 3 7 / guestbook offline")
