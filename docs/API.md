# API

The current Roblox Studio ModuleScript library is documented in [POLISHED_API.md](POLISHED_API.md).

Use it like this:

```lua
local UI = require(game.ReplicatedStorage.PolishedUI)

local Window = UI:CreateWindow({
    Title = "Example UI",
    Theme = "Dark",
})

local Main = Window:CreateTab("Main")
local Section = Main:CreateSection("Movement")

Section:CreateToggle({
    Name = "Sprint",
    Key = "sprint",
    Default = false,
    Callback = function(value)
        print(value)
    end,
})
```

For the complete component reference, see [POLISHED_API.md](POLISHED_API.md).
