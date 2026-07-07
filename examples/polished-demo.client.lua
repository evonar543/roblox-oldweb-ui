-- Place PolishedUI.lua in ReplicatedStorage as a ModuleScript named "PolishedUI".
-- Put this demo in StarterPlayerScripts as a LocalScript.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local UI = require(ReplicatedStorage:WaitForChild("PolishedUI"))
local LocalPlayer = Players.LocalPlayer

local memoryConfig = {}

UI:SetConfigAdapter({
    Save = function(name, values)
        memoryConfig[name] = values
        return true
    end,
    Load = function(name)
        return memoryConfig[name] or {}
    end,
    Reset = function(name)
        memoryConfig[name] = nil
    end,
})

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    return getCharacter():FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    return getCharacter():FindFirstChild("HumanoidRootPart")
end

local Window = UI:CreateWindow({
    Title = "Project Control Panel",
    Subtitle = "PolishedUI full component demo",
    Theme = "Dark",
    Size = UDim2.fromOffset(660, 500),
})

local Main = Window:CreateTab("Main")
local Player = Window:CreateTab("Player")
local World = Window:CreateTab("World")
local Settings = Window:CreateTab("Settings")
local Debug = Window:CreateTab("Debug")
local Credits = Window:CreateTab("Credits")

local Quick = Main:CreateSection("Quick Actions")

Quick:CreateButton({
    Name = "Show Notification",
    Description = "Creates a stacked toast notification.",
    Callback = function()
        UI:Notify({
            Title = "Saved",
            Message = "The notification system is working.",
            Type = "Success",
            Duration = 3,
        })
    end,
})

Quick:CreateButton({
    Name = "Confirmed Reset",
    Description = "Requires a second click before it runs.",
    Confirm = true,
    Callback = function()
        UI:Notify({
            Title = "Reset",
            Message = "Confirmed button callback fired.",
            Type = "Warning",
        })
    end,
})

Quick:CreateToggle({
    Name = "Auto Sprint",
    Description = "Standard click toggle.",
    Key = "autoSprint",
    Default = false,
    Mode = "Toggle",
    Callback = function(value)
        print("Auto Sprint:", value)
    end,
})

Quick:CreateToggle({
    Name = "Always On System",
    Description = "Locked enabled state.",
    Key = "alwaysOnSystem",
    Mode = "AlwaysOn",
    Indicator = true,
    Callback = function(value)
        print("Always On:", value)
    end,
})

Quick:CreateToggle({
    Name = "Disable Shadows",
    Description = "Inverted toggle example.",
    Key = "disableShadows",
    Default = false,
    Mode = "Inverted",
    Callback = function(enabled)
        Lighting.GlobalShadows = not enabled
    end,
})

local Movement = Player:CreateSection("Movement", { Collapsible = true })

Movement:CreateSlider({
    Name = "Walk Speed",
    Description = "Normal stepped slider.",
    Key = "walkSpeed",
    Min = 16,
    Max = 100,
    Default = 24,
    Increment = 1,
    Suffix = " studs",
    Callback = function(value)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end,
})

Movement:CreateSlider({
    Name = "Jump Power",
    Key = "jumpPower",
    Min = 50,
    Max = 200,
    Default = 75,
    Increment = 5,
    Callback = function(value)
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = value
        end
    end,
})

Movement:CreateToggle({
    Name = "Hold Freeze",
    Description = "Hold LeftShift to anchor your character.",
    Key = "holdFreeze",
    Mode = "Hold",
    Keybind = Enum.KeyCode.LeftShift,
    Callback = function(value)
        local root = getRoot()
        if root then
            root.Anchored = value
        end
    end,
})

Movement:CreateToggle({
    Name = "Key Toggle Freeze",
    Description = "Press F to toggle anchored state.",
    Key = "keyFreeze",
    Mode = "KeyToggle",
    Keybind = Enum.KeyCode.F,
    Callback = function(value)
        local root = getRoot()
        if root then
            root.Anchored = value
        end
    end,
})

Movement:CreateToggle({
    Name = "Pulse Action",
    Description = "Momentary toggle returns to off.",
    Key = "pulseAction",
    Mode = "Momentary",
    Callback = function(value)
        print("Pulse:", value)
    end,
})

local Visuals = World:CreateSection("Visuals")

Visuals:CreateSlider({
    Name = "Brightness",
    Key = "brightness",
    Type = "Float",
    Min = 0,
    Max = 8,
    Default = Lighting.Brightness,
    Increment = 0.1,
    Callback = function(value)
        Lighting.Brightness = value
    end,
})

Visuals:CreateSlider({
    Name = "Clock Time",
    Key = "clockTime",
    Type = "Percentage",
    Min = 0,
    Max = 24,
    Default = Lighting.ClockTime,
    Increment = 0.25,
    Callback = function(value)
        Lighting.ClockTime = value
    end,
})

Visuals:CreateSlider({
    Name = "Fog Range",
    Description = "Range slider with two handles.",
    Key = "fogRange",
    Type = "Range",
    Min = 0,
    Max = 1000,
    DefaultMin = 100,
    DefaultMax = 600,
    Increment = 25,
    Callback = function(minValue, maxValue)
        Lighting.FogStart = minValue
        Lighting.FogEnd = maxValue
    end,
})

Visuals:CreateColorPicker({
    Name = "Fog Color",
    Key = "fogColor",
    Default = Lighting.FogColor,
    Callback = function(color)
        Lighting.FogColor = color
    end,
})

local Options = Settings:CreateSection("Options")

Options:CreateDropdown({
    Name = "Graphics Mode",
    Key = "graphicsMode",
    Options = { "Low", "Medium", "High", "Ultra" },
    Default = "Medium",
    Placeholder = "Choose mode",
    Searchable = true,
    Callback = function(selected)
        print("Graphics Mode:", selected)
    end,
})

Options:CreateDropdown({
    Name = "Enabled Modules",
    Description = "Multi-select dropdown.",
    Key = "enabledModules",
    Options = { "Movement", "Visuals", "Debug", "Admin", "World" },
    Multi = true,
    Searchable = true,
    Callback = function(selected)
        print("Enabled Modules:", selected)
    end,
})

Options:CreateTextbox({
    Name = "Player Search",
    Key = "playerSearch",
    Placeholder = "Enter player name...",
    ClearOnSubmit = false,
    MaxLength = 24,
    Callback = function(text)
        print("Player Search:", text)
    end,
})

Options:CreateTextbox({
    Name = "Max Distance",
    Key = "maxDistance",
    Placeholder = "Numbers only",
    NumbersOnly = true,
    Default = "250",
    Callback = function(text)
        print("Max Distance:", tonumber(text))
    end,
})

Options:CreateKeybind({
    Name = "Open Menu",
    Key = "openMenuBind",
    Default = Enum.KeyCode.RightShift,
    Mode = "Press",
    Callback = function()
        Window:Minimize()
    end,
})

local ThemeSection = Settings:CreateSection("Themes")

ThemeSection:CreateDropdown({
    Name = "Theme",
    Key = "theme",
    Options = { "Dark", "Midnight", "Light", "Blue", "Purple", "Forest" },
    Default = "Dark",
    Callback = function(theme)
        Window:SetTheme(theme)
        UI:Notify({
            Title = "Theme Changed",
            Message = "Core window colors changed to " .. tostring(theme) .. ".",
            Type = "Info",
            Duration = 2,
        })
    end,
})

ThemeSection:CreateButton({
    Name = "Save Config",
    Description = "Uses the demo memory adapter.",
    Callback = function()
        UI:SaveConfig("demo")
        UI:Notify({ Title = "Config Saved", Message = "Values saved in memory.", Type = "Success" })
    end,
})

ThemeSection:CreateButton({
    Name = "Load Config",
    Callback = function()
        UI:LoadConfig("demo")
        UI:Notify({ Title = "Config Loaded", Message = "Values imported from memory.", Type = "Info" })
    end,
})

ThemeSection:CreateButton({
    Name = "Reset Config",
    Confirm = true,
    Callback = function()
        UI:ResetConfig("demo")
        UI:Notify({ Title = "Config Reset", Message = "Stored values cleared.", Type = "Warning" })
    end,
})

local DebugSection = Debug:CreateSection("Diagnostics")

DebugSection:CreateBox({
    Type = "Info",
    Title = "Search",
    Text = "Use the sidebar search box to filter controls by name or description.",
})

DebugSection:CreateBox({
    Type = "Warning",
    Title = "Studio Storage",
    Text = "This demo uses memory config storage. Wire UI:SetConfigAdapter to your own safe storage layer for persistence.",
})

DebugSection:CreateButton({
    Name = "Print Exported Config",
    Callback = function()
        print(UI:ExportConfig())
    end,
})

DebugSection:CreateButton({
    Name = "Error Notification",
    Callback = function()
        UI:Notify({
            Title = "Error Example",
            Message = "This is what an error toast looks like.",
            Type = "Error",
        })
    end,
})

local CreditsSection = Credits:CreateSection("Credits")

CreditsSection:CreateParagraph({
    Title = "PolishedUI",
    Text = "A compact Roblox Luau UI library for legitimate in-game settings, tools, debug panels, and admin interfaces.",
})

CreditsSection:CreateDivider()
CreditsSection:CreateLabel("Built with Roblox UI objects and TweenService.")
