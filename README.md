# Polished Roblox UI

A reusable Roblox Luau UI library for legitimate Roblox projects. It is built for in-experience menus, settings panels, debug tools, admin panels, configuration windows, and internal developer UI.

The main library is [src/PolishedUI.lua](src/PolishedUI.lua). It uses normal Roblox UI objects and is meant to be used as a `ModuleScript` with `require`.

## Install In Roblox Studio

1. Create a `ModuleScript` in `ReplicatedStorage`.
2. Name it `PolishedUI`.
3. Paste the contents of [src/PolishedUI.lua](src/PolishedUI.lua) into that ModuleScript.
4. Create a `LocalScript` in `StarterPlayerScripts`, `StarterGui`, or another client-side location.
5. Require the module:

```lua
local UI = require(game.ReplicatedStorage.PolishedUI)
```

## Basic Usage

```lua
local UI = require(game.ReplicatedStorage.PolishedUI)

local Window = UI:CreateWindow({
    Title = "Example UI",
    Subtitle = "Settings and tools",
    Theme = "Dark",
    Size = UDim2.fromOffset(620, 460),
})

local MainTab = Window:CreateTab("Main")
local Section = MainTab:CreateSection("Movement")

Section:CreateToggle({
    Name = "Sprint",
    Key = "sprint",
    Default = false,
    Mode = "Toggle",
    Callback = function(value)
        print("Sprint:", value)
    end,
})

Section:CreateSlider({
    Name = "Walk Speed",
    Key = "walkSpeed",
    Min = 16,
    Max = 100,
    Default = 24,
    Increment = 1,
    Callback = function(value)
        print("Walk Speed:", value)
    end,
})
```

## Components

Supported in [src/PolishedUI.lua](src/PolishedUI.lua):

- Windows with draggable title bars, minimize, close, open animation, sidebar, content area, and search
- Tabs with active highlighting
- Scrollable sections with optional collapse
- Buttons with descriptions, disabled state, confirmation mode, hover/click animation
- Toggles: `Toggle`, `AlwaysOn`, `KeyToggle`, `Hold`, `Momentary`, `Inverted`, `Disabled`, `ToggleWithBind`
- Sliders: normal, range, stepped, percentage, float, and locked
- Dropdowns with single-select, multi-select, search, clear, and option refresh methods
- Keybind picker with press, release, hold, and toggle modes
- Text boxes with placeholder, numbers-only, max length, validation, submit/change callbacks
- Labels, paragraphs, dividers, info/warning/success/error boxes
- RGB color picker
- Toast notifications
- Theme system with `Dark`, `Midnight`, `Light`, `Blue`, `Purple`, `Forest`, and custom tables
- Adapter-based config export/import/save/load/reset

## Full Demo

Use [examples/polished-demo.client.lua](examples/polished-demo.client.lua) to test every major component in Studio.

The demo covers:

- Window
- Tabs
- Sections
- Buttons
- Standard, key, hold, momentary, inverted, and always-on toggles
- Normal, percentage, float, and range sliders
- Dropdowns
- Keybinds
- Text boxes
- Color picker
- Notifications
- Theme switching
- Config export/import through a memory adapter

## API Docs

See [docs/POLISHED_API.md](docs/POLISHED_API.md).

## Config Saving

PolishedUI does not hardcode private data or unsafe storage. A normal Roblox ModuleScript cannot save local files by itself, so the library exposes:

```lua
UI:SetConfigAdapter({
    Save = function(name, values)
        return true
    end,
    Load = function(name)
        return {}
    end,
    Reset = function(name)
    end,
})
```

Use this adapter to connect your own safe Studio/plugin/project storage layer.

## Still Needs Improvement

- Runtime theme switching updates the core window and tab chrome; existing individual controls keep most of their original colors.
- The color picker is RGB-only. Hex input and transparency can be added next.
- Config persistence depends on the adapter you provide for your environment.

## License

MIT
