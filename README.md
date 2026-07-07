# Roblox OldWeb UI

A small raw-loadable Roblox Luau UI library inspired by late-90s/early-2000s personal homepages: chunky borders, fake visitor badges, under-construction energy, neon text, and cluttered table-box layout.

## Load

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/evonar543/roblox-oldweb-ui/main/src/oldweb-ui.lua"))()
```

Use it in a Roblox place or environment where you are allowed to run the script.

## Example

```lua
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/evonar543/roblox-oldweb-ui/main/src/oldweb-ui.lua"))()

local w1 = library:Window("a")

w1:Button("Print Hi", function()
    print("Hi")
end)

w1:Slider("WalkSpeed", "WS", 16, 300, function(value)
    local character = game.Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = value
    end
end)

w1:Slider("JumpPower", "JP", 50, 300, function(value)
    local character = game.Players.LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end, 100)

w1:Toggle("Freeze", "frz", false, function(toggled)
    local character = game.Players.LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        root.Anchored = toggled
    end
end)

w1:Button("Destroy GUI", function()
    w1:Destroy()
end)

w1:Label("0 x 3 7")
```

The full example is in [examples/example.client.lua](examples/example.client.lua).

## API

See [docs/API.md](docs/API.md).

## Style

The UI intentionally looks like a forgotten old web shrine:

- framed homepage boxes
- bright clashing web-safe colors
- "best viewed on desktop" badge text
- fake visitor counter
- under-construction banner energy
- chunky borders and low-res texture dots

## License

MIT
