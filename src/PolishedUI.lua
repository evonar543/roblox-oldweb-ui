--!nonstrict
-- PolishedUI
-- A reusable Roblox Studio-friendly UI library for legitimate in-experience tools,
-- settings panels, admin menus, debug windows, and configuration screens.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local UI = {}
UI.__index = UI

UI.Version = "1.0.0"
UI.Values = {}
UI.Windows = {}
UI.ConfigAdapter = nil

local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 20, 27),
        Surface = Color3.fromRGB(25, 28, 37),
        SurfaceAlt = Color3.fromRGB(32, 36, 48),
        Accent = Color3.fromRGB(89, 130, 246),
        AccentSoft = Color3.fromRGB(39, 54, 93),
        Text = Color3.fromRGB(238, 241, 247),
        MutedText = Color3.fromRGB(152, 160, 176),
        Border = Color3.fromRGB(52, 58, 73),
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(251, 191, 36),
        Error = Color3.fromRGB(248, 113, 113),
        Disabled = Color3.fromRGB(82, 88, 102),
    },
    Midnight = {
        Background = Color3.fromRGB(11, 15, 25),
        Surface = Color3.fromRGB(17, 24, 39),
        SurfaceAlt = Color3.fromRGB(30, 41, 59),
        Accent = Color3.fromRGB(56, 189, 248),
        AccentSoft = Color3.fromRGB(14, 54, 76),
        Text = Color3.fromRGB(240, 249, 255),
        MutedText = Color3.fromRGB(148, 163, 184),
        Border = Color3.fromRGB(51, 65, 85),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(245, 158, 11),
        Error = Color3.fromRGB(239, 68, 68),
        Disabled = Color3.fromRGB(71, 85, 105),
    },
    Light = {
        Background = Color3.fromRGB(243, 246, 250),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceAlt = Color3.fromRGB(235, 240, 247),
        Accent = Color3.fromRGB(37, 99, 235),
        AccentSoft = Color3.fromRGB(214, 226, 255),
        Text = Color3.fromRGB(23, 28, 38),
        MutedText = Color3.fromRGB(94, 105, 124),
        Border = Color3.fromRGB(210, 218, 230),
        Success = Color3.fromRGB(22, 163, 74),
        Warning = Color3.fromRGB(217, 119, 6),
        Error = Color3.fromRGB(220, 38, 38),
        Disabled = Color3.fromRGB(164, 173, 188),
    },
    Blue = {
        Background = Color3.fromRGB(13, 27, 42),
        Surface = Color3.fromRGB(20, 39, 61),
        SurfaceAlt = Color3.fromRGB(27, 52, 82),
        Accent = Color3.fromRGB(0, 180, 216),
        AccentSoft = Color3.fromRGB(12, 74, 110),
        Text = Color3.fromRGB(237, 250, 255),
        MutedText = Color3.fromRGB(160, 190, 208),
        Border = Color3.fromRGB(51, 85, 114),
        Success = Color3.fromRGB(72, 187, 120),
        Warning = Color3.fromRGB(246, 173, 85),
        Error = Color3.fromRGB(245, 101, 101),
        Disabled = Color3.fromRGB(74, 96, 120),
    },
    Purple = {
        Background = Color3.fromRGB(24, 18, 43),
        Surface = Color3.fromRGB(34, 26, 60),
        SurfaceAlt = Color3.fromRGB(45, 34, 78),
        Accent = Color3.fromRGB(168, 85, 247),
        AccentSoft = Color3.fromRGB(74, 39, 114),
        Text = Color3.fromRGB(250, 245, 255),
        MutedText = Color3.fromRGB(196, 181, 253),
        Border = Color3.fromRGB(76, 62, 110),
        Success = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(250, 204, 21),
        Error = Color3.fromRGB(251, 113, 133),
        Disabled = Color3.fromRGB(92, 82, 118),
    },
    Forest = {
        Background = Color3.fromRGB(16, 26, 22),
        Surface = Color3.fromRGB(24, 38, 33),
        SurfaceAlt = Color3.fromRGB(32, 51, 44),
        Accent = Color3.fromRGB(74, 222, 128),
        AccentSoft = Color3.fromRGB(28, 83, 57),
        Text = Color3.fromRGB(240, 253, 244),
        MutedText = Color3.fromRGB(163, 190, 174),
        Border = Color3.fromRGB(56, 80, 70),
        Success = Color3.fromRGB(34, 197, 94),
        Warning = Color3.fromRGB(234, 179, 8),
        Error = Color3.fromRGB(248, 113, 113),
        Disabled = Color3.fromRGB(79, 99, 90),
    },
}

UI.Themes = Themes

local function mergeTheme(base, custom)
    local result = {}
    for key, value in pairs(base or Themes.Dark) do
        result[key] = value
    end
    for key, value in pairs(custom or {}) do
        result[key] = value
    end
    return result
end

local function getTheme(theme)
    if typeof(theme) == "table" then
        return mergeTheme(Themes.Dark, theme)
    end
    return Themes[tostring(theme or "Dark")] or Themes.Dark
end

local function tween(instance, info, props)
    local animation = TweenService:Create(instance, info, props)
    animation:Play()
    return animation
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

local function safeCall(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end

    local ok, err = pcall(callback, ...)
    if not ok then
        warn("[PolishedUI] Callback failed:", err)
    end
end

local function setValue(key, value)
    if key then
        UI.Values[key] = value
    end
end

local function roundToIncrement(value, increment)
    increment = tonumber(increment) or 1
    if increment <= 0 then
        return value
    end
    return math.floor((value / increment) + 0.5) * increment
end

local function formatValue(value, suffix)
    local rounded = math.floor(value * 1000 + 0.5) / 1000
    local text = tostring(rounded)
    if text:find("%.0$") then
        text = text:gsub("%.0$", "")
    end
    return text .. tostring(suffix or "")
end

local function normalizeInputName(input)
    if not input then
        return "None"
    end
    if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
        return input.KeyCode.Name
    end
    if input.UserInputType then
        return input.UserInputType.Name
    end
    return tostring(input)
end

local function inputMatches(input, bind)
    if not bind then
        return false
    end
    if typeof(bind) == "EnumItem" then
        return input.KeyCode == bind or input.UserInputType == bind
    end
    return false
end

local function getDefaultParent()
    if LocalPlayer then
        return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    end
    return game:GetService("CoreGui")
end

local function addCorner(parent, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function addStroke(parent, color, thickness, transparency)
    return make("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent,
    })
end

local function addPadding(parent, padding)
    return make("UIPadding", {
        PaddingBottom = UDim.new(0, padding),
        PaddingLeft = UDim.new(0, padding),
        PaddingRight = UDim.new(0, padding),
        PaddingTop = UDim.new(0, padding),
        Parent = parent,
    })
end

local function applyButtonHover(button, theme, normalColor, hoverColor, disabled)
    if disabled then
        return
    end

    button.MouseEnter:Connect(function()
        tween(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = hoverColor or theme.SurfaceAlt,
        })
    end)

    button.MouseLeave:Connect(function()
        tween(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = normalColor,
        })
    end)
end

local function createText(parent, text, theme, props)
    props = props or {}
    local label = make("TextLabel", {
        BackgroundTransparency = 1,
        Font = props.Font or Enum.Font.Gotham,
        Text = text or "",
        TextColor3 = props.Color or theme.Text,
        TextSize = props.Size or 14,
        TextTransparency = props.Transparency or 0,
        TextWrapped = props.Wrapped == true,
        TextTruncate = props.Truncate or Enum.TextTruncate.AtEnd,
        TextXAlignment = props.XAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = props.YAlignment or Enum.TextYAlignment.Center,
        Size = props.Size2 or UDim2.fromScale(1, 1),
        Parent = parent,
    })
    return label
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local Control = {}
Control.__index = Control

function Control:SetVisible(visible)
    if self.Frame then
        self.Frame.Visible = visible
    end
end

function UI:SetConfigAdapter(adapter)
    self.ConfigAdapter = adapter
end

function UI:ExportConfig()
    local copy = {}
    for key, value in pairs(self.Values) do
        copy[key] = value
    end
    return copy
end

function UI:ImportConfig(values)
    if typeof(values) ~= "table" then
        return false
    end
    for key, value in pairs(values) do
        self.Values[key] = value
    end
    for _, window in ipairs(self.Windows) do
        if window.RefreshValues then
            window:RefreshValues()
        end
    end
    return true
end

function UI:SaveConfig(name)
    if typeof(self.ConfigAdapter) == "table" and typeof(self.ConfigAdapter.Save) == "function" then
        return self.ConfigAdapter.Save(name or "default", self:ExportConfig())
    end
    return false, "No config adapter set. Use UI:SetConfigAdapter({ Save = fn, Load = fn, Reset = fn })."
end

function UI:LoadConfig(name)
    if typeof(self.ConfigAdapter) == "table" and typeof(self.ConfigAdapter.Load) == "function" then
        local values = self.ConfigAdapter.Load(name or "default")
        return self:ImportConfig(values)
    end
    return false, "No config adapter set. Use UI:SetConfigAdapter({ Save = fn, Load = fn, Reset = fn })."
end

function UI:ResetConfig(name)
    self.Values = {}
    if typeof(self.ConfigAdapter) == "table" and typeof(self.ConfigAdapter.Reset) == "function" then
        self.ConfigAdapter.Reset(name or "default")
    end
    for _, window in ipairs(self.Windows) do
        if window.RefreshValues then
            window:RefreshValues()
        end
    end
end

function UI:Notify(options)
    options = options or {}
    local parent = options.Parent or getDefaultParent()
    if not parent then
        warn("[PolishedUI] No parent available for notification.")
        return
    end

    local gui = parent:FindFirstChild("PolishedUINotifications")
    if not gui then
        gui = make("ScreenGui", {
            Name = "PolishedUINotifications",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = parent,
        })

        local holder = make("Frame", {
            Name = "Holder",
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -18, 0, 18),
            Size = UDim2.fromOffset(320, 0),
            Parent = gui,
        })

        make("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Parent = holder,
        })
    end

    local theme = getTheme(options.Theme)
    local holder = gui:FindFirstChild("Holder")
    local kind = tostring(options.Type or "Info")
    local color = theme.Accent
    if kind == "Success" then
        color = theme.Success
    elseif kind == "Warning" then
        color = theme.Warning
    elseif kind == "Error" then
        color = theme.Error
    end

    local card = make("Frame", {
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(320, 86),
        Parent = holder,
    })
    addCorner(card, 10)
    addStroke(card, theme.Border, 1, 0.15)

    local bar = make("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = card,
    })
    addCorner(bar, 10)

    local title = createText(card, tostring(options.Title or kind), theme, {
        Font = Enum.Font.GothamSemibold,
        Size = 15,
        Size2 = UDim2.new(1, -28, 0, 24),
    })
    title.Position = UDim2.fromOffset(16, 10)

    local message = createText(card, tostring(options.Message or ""), theme, {
        Color = theme.MutedText,
        Size = 13,
        Wrapped = true,
        Size2 = UDim2.new(1, -28, 0, 42),
        YAlignment = Enum.TextYAlignment.Top,
    })
    message.Position = UDim2.fromOffset(16, 34)

    card.Position = UDim2.fromOffset(28, 0)
    tween(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.fromOffset(0, 0),
    })

    task.delay(tonumber(options.Duration) or 3, function()
        if not card.Parent then
            return
        end
        local out = tween(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(28, 0),
        })
        out.Completed:Wait()
        card:Destroy()
    end)
end

function UI:CreateWindow(options)
    options = options or {}
    local theme = getTheme(options.Theme)
    local parent = options.Parent or getDefaultParent()
    if not parent then
        error("[PolishedUI] No valid UI parent found.")
    end

    local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local requestedSize = options.Size or UDim2.fromOffset(620, 460)
    local width = math.min(requestedSize.X.Offset, math.max(360, viewportSize.X - 32))
    local height = math.min(requestedSize.Y.Offset, math.max(320, viewportSize.Y - 32))

    local gui = make("ScreenGui", {
        Name = options.Name or "PolishedUI",
        ResetOnSpawn = options.ResetOnSpawn == true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = parent,
    })

    local root = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        Parent = gui,
    })
    addCorner(root, 14)
    addStroke(root, theme.Border, 1, 0.05)

    local scale = make("UIScale", { Scale = 0.96, Parent = root })

    local titleBar = make("Frame", {
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 58),
        Parent = root,
    })

    local title = createText(titleBar, tostring(options.Title or "Polished UI"), theme, {
        Font = Enum.Font.GothamSemibold,
        Size = 18,
        Size2 = UDim2.new(1, -145, 0, 24),
    })
    title.Position = UDim2.fromOffset(18, 9)

    local subtitle = createText(titleBar, tostring(options.Subtitle or ""), theme, {
        Color = theme.MutedText,
        Size = 12,
        Size2 = UDim2.new(1, -145, 0, 18),
    })
    subtitle.Position = UDim2.fromOffset(18, 33)

    local minimize = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.SurfaceAlt,
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = theme.Text,
        TextSize = 18,
        Position = UDim2.new(1, -86, 0, 15),
        Size = UDim2.fromOffset(30, 30),
        Parent = titleBar,
    })
    addCorner(minimize, 8)

    local close = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Error,
        Font = Enum.Font.GothamBold,
        Text = "x",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Position = UDim2.new(1, -48, 0, 15),
        Size = UDim2.fromOffset(30, 30),
        Parent = titleBar,
    })
    addCorner(close, 8)

    local body = make("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 58),
        Size = UDim2.new(1, 0, 1, -58),
        Parent = root,
    })

    local sidebar = make("Frame", {
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 164, 1, 0),
        Parent = body,
    })

    local search = make("TextBox", {
        BackgroundColor3 = theme.SurfaceAlt,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        PlaceholderColor3 = theme.MutedText,
        PlaceholderText = "Search settings",
        Text = "",
        TextColor3 = theme.Text,
        TextSize = 13,
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.new(1, -24, 0, 34),
        Parent = sidebar,
    })
    addCorner(search, 8)
    addStroke(search, theme.Border, 1, 0.25)

    local tabList = make("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(10, 56),
        ScrollBarImageColor3 = theme.Border,
        ScrollBarThickness = 4,
        Size = UDim2.new(1, -20, 1, -68),
        Parent = sidebar,
    })
    make("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList,
    })

    local content = make("Frame", {
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(164, 0),
        Size = UDim2.new(1, -164, 1, 0),
        Parent = body,
    })

    local window = setmetatable({
        Gui = gui,
        Root = root,
        Theme = theme,
        ThemeName = options.Theme or "Dark",
        Title = title,
        Subtitle = subtitle,
        TitleBar = titleBar,
        Sidebar = sidebar,
        TabList = tabList,
        Content = content,
        SearchBox = search,
        MinimizeButton = minimize,
        CloseButton = close,
        Tabs = {},
        Controls = {},
        ActiveTab = nil,
        Minimized = false,
        Closed = false,
        FullSize = UDim2.fromOffset(width, height),
    }, Window)

    local dragStart
    local startPosition
    local dragging = false

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        dragging = true
        dragStart = input.Position
        startPosition = root.Position
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
        root.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end)

    search:GetPropertyChangedSignal("Text"):Connect(function()
        window:ApplySearch(search.Text)
    end)

    minimize.MouseButton1Click:Connect(function()
        window:Minimize()
    end)

    close.MouseButton1Click:Connect(function()
        window:Close()
    end)

    applyButtonHover(minimize, theme, theme.SurfaceAlt, theme.AccentSoft)
    applyButtonHover(close, theme, theme.Error, theme.Warning)

    table.insert(UI.Windows, window)

    tween(root, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
    })
    tween(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = 1,
    })

    return window
end

function Window:CreateTab(name, icon)
    local theme = self.Theme
    local page = make("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(16, 16),
        ScrollBarImageColor3 = theme.Border,
        ScrollBarThickness = 5,
        Size = UDim2.new(1, -32, 1, -32),
        Visible = false,
        Parent = self.Content,
    })
    make("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    local button = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Surface,
        Font = Enum.Font.GothamSemibold,
        Text = (icon and (tostring(icon) .. "  ") or "") .. tostring(name),
        TextColor3 = theme.MutedText,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.TabList,
    })
    addCorner(button, 8)
    addPadding(button, 10)

    local tab = setmetatable({
        Window = self,
        Name = tostring(name),
        Button = button,
        Page = page,
        Sections = {},
    }, Tab)

    button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)

    applyButtonHover(button, theme, theme.Surface, theme.SurfaceAlt)

    table.insert(self.Tabs, tab)
    if not self.ActiveTab then
        self:SelectTab(tab)
    end

    return tab
end

function Window:SelectTab(tab)
    local theme = self.Theme
    for _, existing in ipairs(self.Tabs) do
        local selected = existing == tab
        existing.Page.Visible = selected
        tween(existing.Button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = selected and theme.AccentSoft or theme.Surface,
            TextColor3 = selected and theme.Text or theme.MutedText,
        })
    end
    self.ActiveTab = tab
end

function Window:ApplySearch(query)
    query = string.lower(tostring(query or ""))
    for _, control in ipairs(self.Controls) do
        local match = query == "" or string.find(string.lower(control.SearchText or ""), query, 1, true) ~= nil
        control:SetVisible(match)
    end
end

function Window:RegisterControl(control)
    table.insert(self.Controls, control)
    return control
end

function Window:RefreshValues()
    for _, control in ipairs(self.Controls) do
        if control.Refresh then
            control:Refresh()
        end
    end
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    local target = self.Minimized and UDim2.fromOffset(self.FullSize.X.Offset, 58) or self.FullSize
    tween(self.Root, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = target,
    })
end

function Window:Close()
    if self.Closed then
        return
    end
    self.Closed = true
    local scale = self.Root:FindFirstChildOfClass("UIScale")
    if scale then
        tween(scale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.96 })
    end
    local out = tween(self.Root, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
    })
    out.Completed:Wait()
    self.Gui:Destroy()
end

function Window:SetTheme(theme)
    local nextTheme = getTheme(theme)
    self.Theme = nextTheme
    self.Root.BackgroundColor3 = nextTheme.Background
    self.TitleBar.BackgroundColor3 = nextTheme.Surface
    self.Sidebar.BackgroundColor3 = nextTheme.Surface
    self.Content.BackgroundColor3 = nextTheme.Background
    self.SearchBox.BackgroundColor3 = nextTheme.SurfaceAlt
    self.SearchBox.TextColor3 = nextTheme.Text
    self.SearchBox.PlaceholderColor3 = nextTheme.MutedText
    self.Title.TextColor3 = nextTheme.Text
    self.Subtitle.TextColor3 = nextTheme.MutedText
    self.MinimizeButton.BackgroundColor3 = nextTheme.SurfaceAlt
    self.MinimizeButton.TextColor3 = nextTheme.Text
    self.CloseButton.BackgroundColor3 = nextTheme.Error

    for _, tab in ipairs(self.Tabs) do
        tab.Button.TextColor3 = tab == self.ActiveTab and nextTheme.Text or nextTheme.MutedText
        tab.Button.BackgroundColor3 = tab == self.ActiveTab and nextTheme.AccentSoft or nextTheme.Surface
    end
end

function Tab:CreateSection(name, options)
    options = options or {}
    local theme = self.Window.Theme
    local frame = make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -4, 0, 0),
        Parent = self.Page,
    })
    addCorner(frame, 10)
    addStroke(frame, theme.Border, 1, 0.18)
    addPadding(frame, 12)

    local header = make("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = tostring(name),
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, 0, 0, 24),
        Parent = frame,
    })

    local list = make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = frame,
    })
    make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })

    local section = setmetatable({
        Tab = self,
        Window = self.Window,
        Frame = frame,
        Header = header,
        List = list,
        Collapsed = false,
        Collapsible = options.Collapsible == true,
    }, Section)

    if section.Collapsible then
        header.Text = tostring(name) .. "  -"
        header.MouseButton1Click:Connect(function()
            section.Collapsed = not section.Collapsed
            list.Visible = not section.Collapsed
            header.Text = tostring(name) .. (section.Collapsed and "  +" or "  -")
        end)
    end

    table.insert(self.Sections, section)
    return section
end

function Section:_controlFrame(options, height)
    options = options or {}
    local theme = self.Window.Theme
    local frame = make("Frame", {
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, height or 54),
        Parent = self.List,
    })
    addCorner(frame, 8)

    local name = createText(frame, tostring(options.Name or "Control"), theme, {
        Font = Enum.Font.GothamSemibold,
        Size = 13,
        Size2 = UDim2.new(1, -170, 0, 22),
    })
    name.Position = UDim2.fromOffset(12, options.Description and 8 or 0)

    local description
    if options.Description then
        description = createText(frame, tostring(options.Description), theme, {
            Color = theme.MutedText,
            Size = 12,
            Wrapped = true,
            Size2 = UDim2.new(1, -170, 0, 24),
        })
        description.Position = UDim2.fromOffset(12, 28)
    end

    local control = setmetatable({
        Frame = frame,
        NameLabel = name,
        DescriptionLabel = description,
        SearchText = tostring(options.Name or "") .. " " .. tostring(options.Description or ""),
        Key = options.Key or options.Name,
    }, Control)

    self.Window:RegisterControl(control)
    return control
end

function Section:CreateButton(options)
    options = options or {}
    local theme = self.Window.Theme
    local control = self:_controlFrame(options, options.Description and 62 or 48)
    local disabled = options.Disabled == true
    local waitingForConfirm = false

    local button = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = disabled and theme.Disabled or theme.Accent,
        Font = Enum.Font.GothamSemibold,
        Text = disabled and "Disabled" or "Run",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 13,
        Position = UDim2.new(1, -102, 0.5, -16),
        Size = UDim2.fromOffset(90, 32),
        Parent = control.Frame,
    })
    addCorner(button, 8)
    applyButtonHover(button, theme, button.BackgroundColor3, theme.AccentSoft, disabled)

    button.MouseButton1Click:Connect(function()
        if disabled then
            return
        end
        if options.Confirm and not waitingForConfirm then
            waitingForConfirm = true
            button.Text = "Confirm"
            task.delay(2, function()
                waitingForConfirm = false
                if button.Parent then
                    button.Text = "Run"
                end
            end)
            return
        end
        waitingForConfirm = false
        button.Text = "Run"
        tween(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(86, 30) })
        task.delay(0.08, function()
            if button.Parent then
                tween(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.fromOffset(90, 32) })
            end
        end)
        safeCall(options.Callback)
    end)

    control.Button = button
    return control
end

function Section:CreateToggle(options)
    options = options or {}
    local theme = self.Window.Theme
    local control = self:_controlFrame(options, options.Description and 62 or 48)
    local mode = tostring(options.Mode or "Toggle")
    local disabled = mode == "Disabled" or options.Disabled == true
    local alwaysOn = mode == "AlwaysOn"
    local inverted = mode == "Inverted"
    local value = alwaysOn or options.Default == true
    if inverted then
        value = not value
    end

    local bind = options.Keybind
    local keyLabel = bind and normalizeInputName({ KeyCode = bind, UserInputType = bind }) or ""

    local shell = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = disabled and theme.Disabled or theme.Border,
        Text = "",
        Position = UDim2.new(1, -68, 0.5, -12),
        Size = UDim2.fromOffset(48, 24),
        Parent = control.Frame,
    })
    addCorner(shell, 999)

    local knob = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(18, 18),
        Parent = shell,
    })
    addCorner(knob, 999)

    local indicator = make("Frame", {
        BackgroundColor3 = theme.Error,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -88, 0.5, -4),
        Size = UDim2.fromOffset(8, 8),
        Visible = options.Indicator == true or mode == "ToggleWithBind",
        Parent = control.Frame,
    })
    addCorner(indicator, 999)

    local bindText
    if bind or mode == "KeyToggle" or mode == "Hold" or mode == "ToggleWithBind" then
        bindText = createText(control.Frame, keyLabel ~= "" and keyLabel or "No Bind", theme, {
            Color = theme.MutedText,
            Size = 11,
            Size2 = UDim2.fromOffset(80, 18),
            XAlignment = Enum.TextXAlignment.Right,
        })
        bindText.Position = UDim2.new(1, -156, 0.5, 10)
    end

    local function render(fire)
        local display = value
        if inverted then
            display = not display
        end
        setValue(options.Key or options.Name, display)
        tween(shell, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = display and theme.Accent or (disabled and theme.Disabled or theme.Border),
        })
        tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = display and UDim2.fromOffset(27, 3) or UDim2.fromOffset(3, 3),
        })
        indicator.BackgroundColor3 = display and theme.Success or theme.Error
        if fire then
            safeCall(options.Callback, display)
        end
    end

    local function setToggle(nextValue, fire)
        if disabled then
            return
        end
        if alwaysOn then
            value = true
        else
            value = nextValue == true
        end
        render(fire)
        if mode == "Momentary" and value then
            task.delay(0.18, function()
                value = false
                render(true)
            end)
        end
    end

    shell.MouseButton1Click:Connect(function()
        if mode == "Hold" or mode == "KeyToggle" then
            return
        end
        setToggle(not value, true)
    end)

    if bind then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not inputMatches(input, bind) then
                return
            end
            if mode == "Hold" then
                setToggle(true, true)
            else
                setToggle(not value, true)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if mode == "Hold" and inputMatches(input, bind) then
                setToggle(false, true)
            end
        end)
    end

    function control:Set(nextValue)
        setToggle(nextValue, true)
    end

    function control:Get()
        return UI.Values[options.Key or options.Name]
    end

    function control:Refresh()
        local stored = UI.Values[options.Key or options.Name]
        if stored ~= nil then
            value = inverted and not stored or stored
            render(false)
        end
    end

    render(false)
    return control
end

function Section:CreateSlider(options)
    options = options or {}
    local theme = self.Window.Theme
    local control = self:_controlFrame(options, options.Description and 78 or 66)
    local min = tonumber(options.Min) or 0
    local max = tonumber(options.Max) or 100
    local increment = tonumber(options.Increment) or 1
    local locked = options.Locked == true or tostring(options.Type or "") == "Locked"
    local sliderType = tostring(options.Type or "Normal")
    local value = math.clamp(tonumber(options.Default) or min, min, max)
    local rangeMin = math.clamp(tonumber(options.DefaultMin) or min, min, max)
    local rangeMax = math.clamp(tonumber(options.DefaultMax) or max, min, max)

    local valueText = make("TextBox", {
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = theme.MutedText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Size = UDim2.fromOffset(120, 20),
        Parent = control.Frame,
    })
    valueText.Position = UDim2.new(1, -132, 0, 8)

    local track = make("Frame", {
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 1, -24),
        Size = UDim2.new(1, -24, 0, 8),
        Parent = control.Frame,
    })
    addCorner(track, 999)

    local fill = make("Frame", {
        BackgroundColor3 = locked and theme.Disabled or theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = track,
    })
    addCorner(fill, 999)

    local handle = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Text,
        BorderSizePixel = 0,
        Text = "",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(18, 18),
        Visible = sliderType ~= "Range",
        Parent = track,
    })
    addCorner(handle, 999)

    local handleA = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Text,
        BorderSizePixel = 0,
        Text = "",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(18, 18),
        Visible = sliderType == "Range",
        Parent = track,
    })
    addCorner(handleA, 999)

    local handleB = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Text,
        BorderSizePixel = 0,
        Text = "",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(18, 18),
        Visible = sliderType == "Range",
        Parent = track,
    })
    addCorner(handleB, 999)

    local dragging = nil

    local function percentFromValue(nextValue)
        if max == min then
            return 0
        end
        return math.clamp((nextValue - min) / (max - min), 0, 1)
    end

    local function valueFromInput(input)
        local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local raw = min + ((max - min) * percent)
        if sliderType == "Float" then
            return math.clamp(roundToIncrement(raw, increment), min, max)
        end
        return math.clamp(roundToIncrement(raw, increment), min, max)
    end

    local function render(fire)
        if sliderType == "Range" then
            local p1 = percentFromValue(rangeMin)
            local p2 = percentFromValue(rangeMax)
            handleA.Position = UDim2.fromScale(p1, 0.5)
            handleB.Position = UDim2.fromScale(p2, 0.5)
            fill.Position = UDim2.fromScale(p1, 0)
            fill.Size = UDim2.fromScale(math.max(0, p2 - p1), 1)
            valueText.Text = formatValue(rangeMin, options.Suffix) .. " - " .. formatValue(rangeMax, options.Suffix)
            setValue(options.Key or options.Name, { Min = rangeMin, Max = rangeMax })
            if fire then
                safeCall(options.Callback, rangeMin, rangeMax)
            end
            return
        end

        local percent = percentFromValue(value)
        handle.Position = UDim2.fromScale(percent, 0.5)
        fill.Size = UDim2.fromScale(percent, 1)
        local display = sliderType == "Percentage" and math.floor(percent * 100 + 0.5) or value
        valueText.Text = formatValue(display, sliderType == "Percentage" and "%" or options.Suffix)
        setValue(options.Key or options.Name, value)
        if fire then
            safeCall(options.Callback, value)
        end
    end

    local function update(input)
        if locked then
            return
        end
        local nextValue = valueFromInput(input)
        if sliderType == "Range" then
            if dragging == "min" then
                rangeMin = math.min(nextValue, rangeMax)
            else
                rangeMax = math.max(nextValue, rangeMin)
            end
        else
            value = nextValue
        end
        render(true)
    end

    local function begin(which, input)
        if locked then
            return
        end
        dragging = which
        update(input)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            begin("value", input)
        end
    end)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            begin("value", input)
        end
    end)
    handleA.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            begin("min", input)
        end
    end)
    handleB.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            begin("max", input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = nil
        end
    end)

    valueText.FocusLost:Connect(function(enterPressed)
        if locked or sliderType == "Range" or not enterPressed then
            render(false)
            return
        end

        local typed = tonumber((valueText.Text:gsub("[^%d%.%-]", "")))
        if typed then
            value = math.clamp(roundToIncrement(typed, increment), min, max)
            render(true)
        else
            render(false)
        end
    end)

    function control:Set(nextValue, secondValue)
        if sliderType == "Range" then
            rangeMin = math.clamp(tonumber(nextValue) or rangeMin, min, max)
            rangeMax = math.clamp(tonumber(secondValue) or rangeMax, min, max)
            if rangeMin > rangeMax then
                rangeMin, rangeMax = rangeMax, rangeMin
            end
        else
            value = math.clamp(tonumber(nextValue) or value, min, max)
        end
        render(true)
    end

    function control:Get()
        return UI.Values[options.Key or options.Name]
    end

    function control:Refresh()
        local stored = UI.Values[options.Key or options.Name]
        if sliderType == "Range" and typeof(stored) == "table" then
            rangeMin = stored.Min or rangeMin
            rangeMax = stored.Max or rangeMax
        elseif tonumber(stored) then
            value = stored
        end
        render(false)
    end

    render(false)
    return control
end

function Section:CreateDropdown(options)
    options = options or {}
    local theme = self.Window.Theme
    local control = self:_controlFrame(options, options.Description and 62 or 50)
    local selected
    if options.Multi then
        selected = {}
        if typeof(options.Default) == "table" then
            for key, enabled in pairs(options.Default) do
                if typeof(key) == "number" then
                    selected[enabled] = true
                elseif enabled == true then
                    selected[key] = true
                end
            end
        end
    else
        selected = options.Default
    end
    local open = false
    local optionButtons = {}
    local optionsList = options.Options or {}

    local button = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Surface,
        Font = Enum.Font.Gotham,
        Text = tostring(options.Placeholder or "Select"),
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(1, -192, 0.5, -16),
        Size = UDim2.fromOffset(180, 32),
        Parent = control.Frame,
    })
    addCorner(button, 8)
    addStroke(button, theme.Border, 1, 0.25)
    addPadding(button, 8)

    local menu = make("Frame", {
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -192, 1, 6),
        Size = UDim2.fromOffset(180, 0),
        Visible = false,
        ZIndex = 50,
        Parent = control.Frame,
    })
    addCorner(menu, 8)
    addStroke(menu, theme.Border, 1, 0.1)

    local list = make("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        ScrollBarThickness = 3,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 51,
        Parent = menu,
    })
    make("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list,
    })
    addPadding(list, 5)

    local searchBox
    if options.Searchable then
        searchBox = make("TextBox", {
            BackgroundColor3 = theme.SurfaceAlt,
            ClearTextOnFocus = false,
            Font = Enum.Font.Gotham,
            PlaceholderText = "Search...",
            Text = "",
            TextColor3 = theme.Text,
            TextSize = 12,
            Size = UDim2.new(1, -10, 0, 28),
            ZIndex = 52,
            Parent = list,
        })
        addCorner(searchBox, 6)
    end

    local function selectedText()
        if options.Multi then
            local parts = {}
            for option, enabled in pairs(selected) do
                if enabled then
                    table.insert(parts, tostring(option))
                end
            end
            return #parts > 0 and table.concat(parts, ", ") or tostring(options.Placeholder or "Select")
        end
        return selected and tostring(selected) or tostring(options.Placeholder or "Select")
    end

    local function renderSelection(fire)
        button.Text = selectedText()
        setValue(options.Key or options.Name, selected)
        if fire then
            safeCall(options.Callback, selected)
        end
    end

    local function rebuild()
        for _, optionButton in ipairs(optionButtons) do
            optionButton:Destroy()
        end
        optionButtons = {}

        local query = searchBox and string.lower(searchBox.Text) or ""
        for _, option in ipairs(optionsList) do
            local label = tostring(option)
            if query == "" or string.find(string.lower(label), query, 1, true) then
                local optionButton = make("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = theme.SurfaceAlt,
                    Font = Enum.Font.Gotham,
                    Text = label,
                    TextColor3 = theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Size = UDim2.new(1, -10, 0, 28),
                    ZIndex = 52,
                    Parent = list,
                })
                addCorner(optionButton, 6)
                addPadding(optionButton, 8)
                optionButton.MouseButton1Click:Connect(function()
                    if options.Multi then
                        selected[option] = not selected[option]
                    else
                        selected = option
                        open = false
                        menu.Visible = false
                    end
                    renderSelection(true)
                end)
                table.insert(optionButtons, optionButton)
            end
        end
    end

    button.MouseButton1Click:Connect(function()
        open = not open
        menu.Visible = open
        local targetHeight = open and math.min(180, 38 + (#optionsList * 31)) or 0
        tween(menu, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(180, targetHeight),
        })
    end)

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(rebuild)
    end

    function control:SetOptions(nextOptions)
        optionsList = nextOptions or {}
        rebuild()
    end

    function control:Clear()
        selected = options.Multi and {} or nil
        renderSelection(true)
    end

    function control:Set(nextValue)
        selected = nextValue
        renderSelection(true)
    end

    function control:Get()
        return selected
    end

    function control:Refresh()
        local stored = UI.Values[options.Key or options.Name]
        if stored ~= nil then
            selected = stored
            renderSelection(false)
        end
    end

    rebuild()
    renderSelection(false)
    return control
end

function Section:CreateKeybind(options)
    options = options or {}
    local theme = self.Window.Theme
    local control = self:_controlFrame(options, options.Description and 62 or 50)
    local bind = options.Default
    local mode = tostring(options.Mode or "Press")
    local listening = false
    local held = false

    local button = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Surface,
        Font = Enum.Font.GothamSemibold,
        Text = bind and bind.Name or "None",
        TextColor3 = theme.Text,
        TextSize = 13,
        Position = UDim2.new(1, -154, 0.5, -16),
        Size = UDim2.fromOffset(110, 32),
        Parent = control.Frame,
    })
    addCorner(button, 8)
    addStroke(button, theme.Border, 1, 0.25)

    local clear = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Surface,
        Font = Enum.Font.GothamBold,
        Text = "x",
        TextColor3 = theme.MutedText,
        TextSize = 12,
        Position = UDim2.new(1, -36, 0.5, -14),
        Size = UDim2.fromOffset(24, 28),
        Parent = control.Frame,
    })
    addCorner(clear, 7)

    button.MouseButton1Click:Connect(function()
        listening = true
        button.Text = "Press key..."
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            bind = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
            listening = false
            button.Text = bind.Name
            setValue(options.Key or options.Name, bind.Name)
            safeCall(options.Changed, bind)
            return
        end
        if gameProcessed or not inputMatches(input, bind) then
            return
        end
        if mode == "Hold" then
            held = true
            safeCall(options.Callback, true)
        elseif mode == "Toggle" then
            held = not held
            safeCall(options.Callback, held)
        elseif mode == "Press" then
            safeCall(options.Callback)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not inputMatches(input, bind) then
            return
        end
        if mode == "Hold" then
            held = false
            safeCall(options.Callback, false)
        elseif mode == "Release" then
            safeCall(options.Callback)
        end
    end)

    function control:Clear()
        bind = nil
        button.Text = "None"
        setValue(options.Key or options.Name, nil)
    end

    clear.MouseButton1Click:Connect(function()
        control:Clear()
    end)

    function control:Get()
        return bind
    end

    return control
end

function Section:CreateTextbox(options)
    options = options or {}
    local theme = self.Window.Theme
    local control = self:_controlFrame(options, options.Description and 66 or 54)
    local mode = tostring(options.CallbackMode or "Submit")

    local box = make("TextBox", {
        BackgroundColor3 = theme.Surface,
        ClearTextOnFocus = options.ClearOnFocus == true,
        Font = Enum.Font.Gotham,
        PlaceholderColor3 = theme.MutedText,
        PlaceholderText = tostring(options.Placeholder or ""),
        Text = tostring(options.Default or ""),
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(1, -192, 0.5, -17),
        Size = UDim2.fromOffset(148, 34),
        Parent = control.Frame,
    })
    addCorner(box, 8)
    addStroke(box, theme.Border, 1, 0.25)
    addPadding(box, 8)

    local clear = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme.Surface,
        Font = Enum.Font.GothamBold,
        Text = "x",
        TextColor3 = theme.MutedText,
        TextSize = 12,
        Position = UDim2.new(1, -36, 0.5, -14),
        Size = UDim2.fromOffset(24, 28),
        Parent = control.Frame,
    })
    addCorner(clear, 7)

    local function cleanText(text)
        text = tostring(text or "")
        if options.NumbersOnly then
            text = text:gsub("[^%d%.%-]", "")
        end
        if options.MaxLength then
            text = string.sub(text, 1, tonumber(options.MaxLength))
        end
        return text
    end

    local function submit()
        local text = cleanText(box.Text)
        box.Text = text
        if typeof(options.Validate) == "function" then
            local valid, message = options.Validate(text)
            if not valid then
                warn("[PolishedUI] Textbox validation failed:", message or "Invalid value")
                return
            end
        end
        setValue(options.Key or options.Name, text)
        safeCall(options.Callback, text)
        if options.ClearOnSubmit then
            box.Text = ""
        end
    end

    box:GetPropertyChangedSignal("Text"):Connect(function()
        local text = cleanText(box.Text)
        if text ~= box.Text then
            box.Text = text
            box.CursorPosition = #text + 1
        end
        if mode == "Change" then
            setValue(options.Key or options.Name, box.Text)
            safeCall(options.Callback, box.Text)
        end
    end)

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed or mode == "Submit" then
            submit()
        end
    end)

    clear.MouseButton1Click:Connect(function()
        box.Text = ""
        submit()
    end)

    function control:Set(text)
        box.Text = cleanText(text)
        submit()
    end

    function control:Get()
        return box.Text
    end

    function control:Refresh()
        local stored = UI.Values[options.Key or options.Name]
        if stored ~= nil then
            box.Text = cleanText(stored)
        end
    end

    setValue(options.Key or options.Name, box.Text)
    return control
end

function Section:CreateLabel(text)
    local theme = self.Window.Theme
    local frame = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Parent = self.List,
    })
    local label = createText(frame, tostring(text), theme, {
        Color = theme.Text,
        Size = 13,
        Size2 = UDim2.fromScale(1, 1),
    })
    local control = setmetatable({ Frame = frame, Label = label, SearchText = tostring(text) }, Control)
    self.Window:RegisterControl(control)
    return control
end

function Section:CreateParagraph(options)
    options = options or {}
    local theme = self.Window.Theme
    local frame = make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = self.List,
    })
    local title = createText(frame, tostring(options.Title or ""), theme, {
        Font = Enum.Font.GothamSemibold,
        Size = 13,
        Size2 = UDim2.new(1, 0, 0, 20),
    })
    local body = createText(frame, tostring(options.Text or ""), theme, {
        Color = theme.MutedText,
        Size = 12,
        Wrapped = true,
        Size2 = UDim2.new(1, 0, 0, 48),
        YAlignment = Enum.TextYAlignment.Top,
    })
    body.Position = UDim2.fromOffset(0, 22)
    local control = setmetatable({ Frame = frame, Title = title, Body = body, SearchText = tostring(options.Title or "") .. " " .. tostring(options.Text or "") }, Control)
    self.Window:RegisterControl(control)
    return control
end

function Section:CreateDivider()
    local theme = self.Window.Theme
    local frame = make("Frame", {
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        Parent = self.List,
    })
    local control = setmetatable({ Frame = frame, SearchText = "" }, Control)
    self.Window:RegisterControl(control)
    return control
end

function Section:CreateBox(options)
    options = options or {}
    local theme = self.Window.Theme
    local kind = tostring(options.Type or "Info")
    local color = theme.Accent
    if kind == "Warning" then
        color = theme.Warning
    elseif kind == "Success" then
        color = theme.Success
    elseif kind == "Error" then
        color = theme.Error
    end

    local frame = make("Frame", {
        BackgroundColor3 = theme.SurfaceAlt,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 58),
        Parent = self.List,
    })
    addCorner(frame, 8)
    local bar = make("Frame", {
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = frame,
    })
    addCorner(bar, 8)
    local title = createText(frame, tostring(options.Title or kind), theme, {
        Font = Enum.Font.GothamSemibold,
        Size = 13,
        Size2 = UDim2.new(1, -24, 0, 20),
    })
    title.Position = UDim2.fromOffset(14, 7)
    local text = createText(frame, tostring(options.Text or ""), theme, {
        Color = theme.MutedText,
        Size = 12,
        Wrapped = true,
        Size2 = UDim2.new(1, -24, 0, 24),
    })
    text.Position = UDim2.fromOffset(14, 28)
    local control = setmetatable({ Frame = frame, SearchText = tostring(options.Title or "") .. " " .. tostring(options.Text or "") }, Control)
    self.Window:RegisterControl(control)
    return control
end

function Section:CreateColorPicker(options)
    options = options or {}
    local theme = self.Window.Theme
    local default = options.Default or Color3.fromRGB(255, 255, 255)
    local control = self:_controlFrame(options, options.Description and 150 or 138)
    local current = default

    local preview = make("Frame", {
        BackgroundColor3 = current,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -52, 0, 12),
        Size = UDim2.fromOffset(36, 24),
        Parent = control.Frame,
    })
    addCorner(preview, 7)
    addStroke(preview, theme.Border, 1, 0.2)

    local sliders = {}
    local function channelSlider(label, y, initial)
        local rowLabel = createText(control.Frame, label, theme, {
            Color = theme.MutedText,
            Size = 12,
            Size2 = UDim2.fromOffset(22, 20),
        })
        rowLabel.Position = UDim2.fromOffset(12, y - 6)
        local track = make("Frame", {
            BackgroundColor3 = theme.Border,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(38, y),
            Size = UDim2.new(1, -62, 0, 7),
            Parent = control.Frame,
        })
        addCorner(track, 999)
        local fill = make("Frame", {
            BackgroundColor3 = theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(initial / 255, 1),
            Parent = track,
        })
        addCorner(fill, 999)
        return { Track = track, Fill = fill, Value = initial }
    end

    sliders.R = channelSlider("R", 62, math.floor(current.R * 255 + 0.5))
    sliders.G = channelSlider("G", 88, math.floor(current.G * 255 + 0.5))
    sliders.B = channelSlider("B", 114, math.floor(current.B * 255 + 0.5))

    local draggingChannel = nil

    local function render(fire)
        current = Color3.fromRGB(sliders.R.Value, sliders.G.Value, sliders.B.Value)
        preview.BackgroundColor3 = current
        for _, slider in pairs(sliders) do
            slider.Fill.Size = UDim2.fromScale(slider.Value / 255, 1)
        end
        setValue(options.Key or options.Name, current)
        if fire then
            safeCall(options.Callback, current)
        end
    end

    local function update(channel, input)
        local slider = sliders[channel]
        local percent = math.clamp((input.Position.X - slider.Track.AbsolutePosition.X) / math.max(slider.Track.AbsoluteSize.X, 1), 0, 1)
        slider.Value = math.floor(percent * 255 + 0.5)
        render(true)
    end

    for channel, slider in pairs(sliders) do
        slider.Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingChannel = channel
                update(channel, input)
            end
        end)
    end

    UserInputService.InputChanged:Connect(function(input)
        if draggingChannel and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(draggingChannel, input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingChannel = nil
        end
    end)

    function control:Set(color)
        if typeof(color) ~= "Color3" then
            return
        end
        sliders.R.Value = math.floor(color.R * 255 + 0.5)
        sliders.G.Value = math.floor(color.G * 255 + 0.5)
        sliders.B.Value = math.floor(color.B * 255 + 0.5)
        render(true)
    end

    function control:Get()
        return current
    end

    function control:Refresh()
        local stored = UI.Values[options.Key or options.Name]
        if typeof(stored) == "Color3" then
            self:Set(stored)
        end
    end

    render(false)
    return control
end

return UI
