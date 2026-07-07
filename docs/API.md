# OldWeb UI API

OldWeb UI returns one table named `library`.

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/evonar543/roblox-oldweb-ui/main/src/oldweb-ui.lua"))()
```

Use this in a Roblox place or environment where you are allowed to run the script.

## `library:Window(text)`

Creates a draggable old-internet styled window.

```lua
local w1 = library:Window("a")
```

## `w1:Button(text, callback)`

Creates a button.

```lua
w1:Button("Print Hi", function()
    print("Hi")
end)
```

## `w1:Slider(text, flag, minimum, maximum, callback, default, flagLocation)`

Creates a slider. `default` and `flagLocation` are optional.

```lua
w1:Slider("Volume", "volume", 0, 100, function(value)
    print(value)
end, 50)
```

The current value is stored at `library.flags[flag]` unless you pass your own table as `flagLocation`.

## `w1:Toggle(text, flag, enabled, callback, flagLocation)`

Creates a toggle. `flagLocation` is optional.

```lua
w1:Toggle("Enabled", "enabled", false, function(toggled)
    print(toggled)
end)
```

The current value is stored at `library.flags[flag]` unless you pass your own table as `flagLocation`.

## `w1:Label(text)`

Creates a decorative label.

```lua
w1:Label("0 x 3 7")
```

## `w1:Destroy()`

Destroys the window's `ScreenGui`.

```lua
w1:Destroy()
```

## `library.flags`

All slider and toggle flags go here by default.

```lua
print(library.flags.WS)
print(library.flags.frz)
```

## `library:SetParent(instance)`

Sets a custom parent for future windows.

```lua
library:SetParent(game.Players.LocalPlayer.PlayerGui)
```
