local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/evonar543/roblox-oldweb-ui/main/src/oldweb-ui.lua"))()

local w1 = library:Window("a")

w1:Button("Print Hi", function()
    print("Hi")
end)

w1:Slider("WalkSpeed", "WS", 16, 300, function(value)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = value
    end
end)

w1:Slider("JumpPower", "JP", 50, 300, function(value)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end, 100)

w1:Toggle("Freeze", "frz", false, function(toggled)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:FindFirstChild("HumanoidRootPart")

    if root then
        root.Anchored = toggled
    end
end)

w1:Button("Destroy GUI", function()
    w1:Destroy()
end)

w1:Label("0 x 3 7")
