--[[
    OldWeb UI
    A tiny Roblox Luau UI library with a late-90s personal homepage look.

    Usage:
        local library = loadstring(game:HttpGet("RAW_URL_HERE"))()
        local window = library:Window("My Window")
        window:Button("Print Hi", function()
            print("Hi")
        end)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local library = {}
library.flags = {}
library.theme = {
    background = Color3.fromRGB(8, 0, 28),
    panel = Color3.fromRGB(25, 0, 61),
    panelAlt = Color3.fromRGB(0, 36, 64),
    text = Color3.fromRGB(241, 255, 102),
    link = Color3.fromRGB(85, 255, 255),
    hot = Color3.fromRGB(255, 61, 183),
    acid = Color3.fromRGB(68, 255, 68),
    warning = Color3.fromRGB(255, 215, 0),
    border = Color3.fromRGB(255, 255, 255),
    shadow = Color3.fromRGB(0, 0, 0),
}

local windowCount = 0

local function getDefaultParent()
    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if playerGui then
            return playerGui
        end
    end

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok then
        return coreGui
    end

    return nil
end

local function make(className, props, children)
    local object = Instance.new(className)

    for key, value in pairs(props or {}) do
        object[key] = value
    end

    for _, child in ipairs(children or {}) do
        child.Parent = object
    end

    return object
end

local function stroke(color, thickness)
    return make("UIStroke", {
        Color = color or library.theme.border,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function textLabel(text, size, color)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.Code,
        Text = text,
        TextColor3 = color or library.theme.text,
        TextSize = size or 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
    })
end

local function buttonLike(text)
    return make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = library.theme.warning,
        BorderColor3 = library.theme.shadow,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 2,
        Font = Enum.Font.ArialBold,
        Text = text,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        TextWrapped = true,
    }, {
        stroke(library.theme.border, 1),
    })
end

local function safeCall(callback, ...)
    if typeof(callback) == "function" then
        local ok, err = pcall(callback, ...)
        if not ok then
            warn("[OldWeb UI] callback failed:", err)
        end
    end
end

local function setFlag(flagLocation, flag, value)
    local target = flagLocation

    if typeof(target) ~= "table" then
        target = library.flags
    end

    if flag ~= nil then
        target[flag] = value
    end
end

local function makeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPosition = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)
end

local function addHomepageTexture(parent)
    local dots = make("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ZIndex = parent.ZIndex + 1,
    })

    for x = 0, 9 do
        for y = 0, 5 do
            if (x + y) % 2 == 0 then
                make("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.82,
                    BorderSizePixel = 0,
                    Position = UDim2.new(x / 10, 2, y / 6, 2),
                    Size = UDim2.fromOffset(2, 2),
                    ZIndex = dots.ZIndex,
                }).Parent = dots
            end
        end
    end

    dots.Parent = parent
end

local Window = {}
Window.__index = Window

function Window:_resize()
    task.defer(function()
        local height = self._layout.AbsoluteContentSize.Y + 95
        self._frame.Size = UDim2.fromOffset(380, math.clamp(height, 180, 620))
    end)
end

function Window:_row(height)
    local row = make("Frame", {
        BackgroundColor3 = library.theme.panelAlt,
        BorderColor3 = library.theme.border,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 1,
        Size = UDim2.new(1, 0, 0, height),
        ZIndex = self._content.ZIndex + 1,
    }, {
        stroke(Color3.fromRGB(0, 0, 0), 1),
    })

    row.Parent = self._content
    self:_resize()

    return row
end

function Window:Button(text, callback)
    local row = self:_row(38)
    row.BackgroundColor3 = Color3.fromRGB(51, 0, 82)

    local button = buttonLike(">> " .. tostring(text) .. " <<")
    button.Position = UDim2.fromOffset(8, 6)
    button.Size = UDim2.new(1, -16, 1, -12)
    button.Parent = row

    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = library.theme.hot
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = library.theme.warning
        button.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)

    button.MouseButton1Click:Connect(function()
        safeCall(callback)
    end)

    return button
end

function Window:Label(text)
    local row = self:_row(34)
    row.BackgroundColor3 = Color3.fromRGB(0, 18, 45)

    local label = textLabel("*** " .. tostring(text) .. " ***", 14, library.theme.acid)
    label.Font = Enum.Font.Arcade
    label.Position = UDim2.fromOffset(8, 0)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Parent = row

    return label
end

function Window:Toggle(text, flag, enabled, callback, flagLocation)
    local state = enabled == true
    setFlag(flagLocation, flag, state)

    local row = self:_row(42)
    local box = buttonLike(state and "X" or "")
    box.Font = Enum.Font.Code
    box.Position = UDim2.fromOffset(8, 8)
    box.Size = UDim2.fromOffset(26, 26)
    box.Parent = row

    local label = textLabel(tostring(text), 14, library.theme.link)
    label.Position = UDim2.fromOffset(44, 0)
    label.Size = UDim2.new(1, -52, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local function render()
        box.Text = state and "X" or ""
        box.BackgroundColor3 = state and library.theme.acid or Color3.fromRGB(170, 170, 170)
        setFlag(flagLocation, flag, state)
    end

    local function toggle()
        state = not state
        render()
        safeCall(callback, state)
    end

    box.MouseButton1Click:Connect(toggle)
    row.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            toggle()
        end
    end)

    render()

    return {
        Set = function(_, value)
            state = value == true
            render()
            safeCall(callback, state)
        end,
        Get = function()
            return state
        end,
        Instance = row,
    }
end

function Window:Slider(text, flag, minimum, maximum, callback, default, flagLocation)
    minimum = tonumber(minimum) or 0
    maximum = tonumber(maximum) or 100

    if maximum < minimum then
        minimum, maximum = maximum, minimum
    end

    local value = tonumber(default)
    if value == nil then
        value = minimum
    end

    value = math.clamp(value, minimum, maximum)
    setFlag(flagLocation, flag, value)

    local row = self:_row(64)

    local name = textLabel(tostring(text), 14, library.theme.text)
    name.Position = UDim2.fromOffset(8, 3)
    name.Size = UDim2.new(1, -90, 0, 24)
    name.Parent = row

    local valueText = textLabel(tostring(value), 14, library.theme.warning)
    valueText.Font = Enum.Font.Code
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Position = UDim2.new(1, -76, 0, 3)
    valueText.Size = UDim2.fromOffset(68, 24)
    valueText.Parent = row

    local track = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = library.theme.border,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(8, 35),
        Size = UDim2.new(1, -16, 0, 18),
        ZIndex = row.ZIndex + 1,
    })
    track.Parent = row

    local fill = make("Frame", {
        BackgroundColor3 = library.theme.hot,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        ZIndex = track.ZIndex + 1,
    })
    fill.Parent = track
    addHomepageTexture(fill)

    local dragging = false

    local function render(newValue, fireCallback)
        value = math.clamp(newValue, minimum, maximum)
        local percent = 0

        if maximum > minimum then
            percent = (value - minimum) / (maximum - minimum)
        end

        fill.Size = UDim2.fromScale(percent, 1)
        valueText.Text = tostring(math.floor(value + 0.5))
        setFlag(flagLocation, flag, value)

        if fireCallback then
            safeCall(callback, value)
        end
    end

    local function updateFromInput(input)
        local x = input.Position.X - track.AbsolutePosition.X
        local percent = math.clamp(x / math.max(track.AbsoluteSize.X, 1), 0, 1)
        render(minimum + ((maximum - minimum) * percent), true)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        updateFromInput(input)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    render(value, false)

    return {
        Set = function(_, newValue)
            render(tonumber(newValue) or value, true)
        end,
        Get = function()
            return value
        end,
        Instance = row,
    }
end

function Window:Destroy()
    if self._gui then
        self._gui:Destroy()
    end
end

function library:SetParent(parent)
    self.parent = parent
    return self
end

function library:Window(title)
    windowCount += 1

    local gui = make("ScreenGui", {
        Name = "OldWebUI_" .. tostring(windowCount),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local frame = make("Frame", {
        Active = true,
        BackgroundColor3 = library.theme.background,
        BorderColor3 = library.theme.border,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 3,
        Position = UDim2.fromOffset(80 + ((windowCount - 1) * 28), 70 + ((windowCount - 1) * 22)),
        Size = UDim2.fromOffset(380, 220),
        ZIndex = 10 + windowCount,
    }, {
        stroke(Color3.fromRGB(0, 0, 0), 2),
    })
    frame.Parent = gui
    addHomepageTexture(frame)

    local top = make("TextButton", {
        Name = "Top",
        AutoButtonColor = false,
        BackgroundColor3 = library.theme.hot,
        BorderColor3 = library.theme.border,
        BorderMode = Enum.BorderMode.Outline,
        BorderSizePixel = 2,
        Font = Enum.Font.Arcade,
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 0, 34),
        Text = "WELCOME 2 " .. tostring(title),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextWrapped = true,
        ZIndex = frame.ZIndex + 2,
    }, {
        stroke(Color3.fromRGB(255, 255, 0), 1),
    })
    top.Parent = frame

    local badges = make("TextLabel", {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = library.theme.border,
        BorderSizePixel = 1,
        Font = Enum.Font.Code,
        Position = UDim2.fromOffset(8, 48),
        Size = UDim2.new(1, -16, 0, 24),
        Text = "[ UNDER CONSTRUCTION ] [ BEST VIEWED ON DESKTOP ] [ VISITOR #" .. tostring(math.random(1000, 9999)) .. " ]",
        TextColor3 = library.theme.acid,
        TextSize = 12,
        TextWrapped = true,
        ZIndex = frame.ZIndex + 2,
    })
    badges.Parent = frame

    local content = make("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 78),
        Size = UDim2.new(1, -16, 1, -86),
        ZIndex = frame.ZIndex + 2,
    })
    content.Parent = frame

    local layout = make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = content

    local window = setmetatable({
        _gui = gui,
        _frame = frame,
        _top = top,
        _content = content,
        _layout = layout,
    }, Window)

    makeDraggable(frame, top)

    local parent = self.parent or getDefaultParent()
    if not parent then
        error("[OldWeb UI] No valid UI parent found. Use library:SetParent(instance) before creating a window.")
    end

    gui.Parent = parent

    return window
end

return library
