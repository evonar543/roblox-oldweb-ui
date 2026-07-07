# PolishedUI API

`src/PolishedUI.lua` is a Roblox ModuleScript UI library for legitimate Roblox projects. Put it in `ReplicatedStorage` or another shared place and require it from a `LocalScript`.

```lua
local UI = require(game.ReplicatedStorage.PolishedUI)
```

## Window

```lua
local Window = UI:CreateWindow({
    Title = "Example UI",
    Subtitle = "Settings and tools",
    Theme = "Dark",
    Size = UDim2.fromOffset(620, 460),
})
```

Windows support a draggable title bar, close button, minimize button, open animation, sidebar tabs, search, and responsive size clamping.

## Tabs And Sections

```lua
local MainTab = Window:CreateTab("Main")
local Section = MainTab:CreateSection("Movement", {
    Collapsible = true,
})
```

## Controls

```lua
Section:CreateButton({
    Name = "Reset Settings",
    Description = "Restores default values.",
    Confirm = true,
    Callback = function()
        print("Reset")
    end,
})
```

```lua
Section:CreateToggle({
    Name = "Auto Sprint",
    Key = "autoSprint",
    Default = false,
    Mode = "Toggle",
    Keybind = Enum.KeyCode.LeftShift,
    Callback = function(enabled)
        print(enabled)
    end,
})
```

Toggle modes:

- `Toggle`
- `AlwaysOn`
- `KeyToggle`
- `Hold`
- `Momentary`
- `Inverted`
- `Disabled`
- `ToggleWithBind`

```lua
Section:CreateSlider({
    Name = "Walk Speed",
    Key = "walkSpeed",
    Min = 16,
    Max = 100,
    Default = 24,
    Increment = 1,
    Suffix = " studs",
    Callback = function(value)
        print(value)
    end,
})
```

Slider types:

- `Normal`
- `Range`
- `Stepped`
- `Percentage`
- `Float`
- `Locked`

```lua
Section:CreateDropdown({
    Name = "Graphics Mode",
    Key = "graphicsMode",
    Options = { "Low", "Medium", "High", "Ultra" },
    Default = "Medium",
    Searchable = true,
    Callback = function(selected)
        print(selected)
    end,
})
```

Other controls:

- `CreateKeybind`
- `CreateTextbox`
- `CreateLabel`
- `CreateParagraph`
- `CreateDivider`
- `CreateBox`
- `CreateColorPicker`

## Notifications

```lua
UI:Notify({
    Title = "Saved",
    Message = "Your settings were saved.",
    Type = "Success",
    Duration = 3,
})
```

Types: `Info`, `Success`, `Warning`, `Error`.

## Themes

Built-in themes:

- `Dark`
- `Midnight`
- `Light`
- `Blue`
- `Purple`
- `Forest`

You can also pass a custom theme table to `UI:CreateWindow({ Theme = customTheme })`.

## Config

Roblox ModuleScripts cannot persist local files by themselves. PolishedUI uses an adapter so your project can choose the safe storage layer.

```lua
UI:SetConfigAdapter({
    Save = function(name, values)
        -- Save values somewhere safe for your environment.
        return true
    end,
    Load = function(name)
        return {}
    end,
    Reset = function(name)
    end,
})
```

Available methods:

- `UI:ExportConfig()`
- `UI:ImportConfig(values)`
- `UI:SaveConfig(name)`
- `UI:LoadConfig(name)`
- `UI:ResetConfig(name)`
