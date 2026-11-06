--[[
    DeltaHub v0.2 Beta (rewrite)
    Client-side UI + cosmetic lighting effects
    Changes vs original:
      * Fixed minimize (UISizeConstraint blocked it)
      * Open/close animation via UIScale
      * Working "Осенние листья" layer
      * Performance profiles now actually change effects
      * Responsive profile buttons, auto canvas size
      * All connections cleaned up on close
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GUI_NAME = "DeltaHub_v02"

-- Remove previous copies (UI + lighting effects)
for _, name in ipairs({ GUI_NAME }) do
    local old = PlayerGui:FindFirstChild(name)
    if old then old:Destroy() end
end
for _, name in ipairs({ "DeltaHub_Bloom", "DeltaHub_ColorCorrection", "DeltaHub_SunRays" }) do
    local old = Lighting:FindFirstChild(name)
    if old then old:Destroy() end
end

----------------------------------------------------------------
-- Theme
----------------------------------------------------------------
local Theme = {
    Purple = Color3.fromRGB(158, 35, 255),
    PurpleDark = Color3.fromRGB(91, 15, 160),
    Dark = Color3.fromRGB(20, 7, 38),
    Sidebar = Color3.fromRGB(25, 9, 43),
    Panel = Color3.fromRGB(35, 13, 58),
    Row = Color3.fromRGB(43, 17, 69),
    Off = Color3.fromRGB(75, 65, 85),
    Text = Color3.fromRGB(245, 235, 255),
    Muted = Color3.fromRGB(185, 160, 205),
}

local FULL_SIZE = UDim2.fromScale(0.88, 0.82)
local MIN_SIZE = Vector2.new(300, 300)
local MAX_SIZE = Vector2.new(1050, 760)

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
local connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function new(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, parent)
end

local function stroke(parent, thickness, transparency)
    return new("UIStroke", {
        Color = Theme.Purple,
        Thickness = thickness or 1,
        Transparency = transparency or 0.25,
    }, parent)
end

local function tween(obj, props, duration, style, direction)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function label(parent, props)
    local base = {
        BackgroundTransparency = 1,
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }
    for k, v in pairs(props) do base[k] = v end
    return new("TextLabel", base, parent)
end

----------------------------------------------------------------
-- Root GUI
----------------------------------------------------------------
local gui = new("ScreenGui", {
    Name = GUI_NAME,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

-- Leaf layer sits behind the window
local leafLayer = new("Frame", {
    Name = "LeafLayer",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Active = false,
    ZIndex = 1,
}, gui)

local main = new("Frame", {
    Name = "MainWindow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = FULL_SIZE,
    BackgroundColor3 = Theme.Dark,
    BorderSizePixel = 0,
    ZIndex = 2,
}, gui)
corner(main, 20)
stroke(main, 2, 0.1)

local sizeLimit = new("UISizeConstraint", { MinSize = MIN_SIZE, MaxSize = MAX_SIZE }, main)
local scale = new("UIScale", { Scale = 0.85 }, main)

new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 9, 53)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 5, 27)),
    }),
    Rotation = 35,
}, main)

----------------------------------------------------------------
-- Header
----------------------------------------------------------------
local header = new("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 76),
    BackgroundTransparency = 1,
}, main)

label(header, {
    Position = UDim2.fromOffset(18, 8),
    Size = UDim2.fromOffset(54, 54),
    Text = "Δ",
    TextColor3 = Theme.Purple,
    TextSize = 48,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Center,
})

label(header, {
    Position = UDim2.fromOffset(78, 12),
    Size = UDim2.new(0.5, 0, 0, 32),
    Text = "DeltaHub",
    TextSize = 27,
    Font = Enum.Font.GothamBold,
})

label(header, {
    Position = UDim2.fromOffset(80, 43),
    Size = UDim2.fromOffset(140, 20),
    Text = "v0.2 Beta",
    TextColor3 = Theme.Purple,
    TextSize = 15,
    Font = Enum.Font.GothamMedium,
})

local function headerButton(text, offsetX, textSize)
    local b = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, offsetX, 0, 12),
        Size = UDim2.fromOffset(42, 42),
        BackgroundColor3 = Theme.Panel,
        Text = text,
        TextColor3 = Theme.Purple,
        TextSize = textSize,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    }, header)
    corner(b, 12)
    return b
end

local closeButton = headerButton("×", -12, 30)
local minimizeButton = headerButton("−", -62, 28)

----------------------------------------------------------------
-- Sidebar / content / pages
----------------------------------------------------------------
local sidebar = new("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(12, 82),
    Size = UDim2.new(0, 145, 1, -96),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0,
}, main)
corner(sidebar, 14)
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, sidebar)
new("UIPadding", {
    PaddingTop = UDim.new(0, 12),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
}, sidebar)

local content = new("Frame", {
    Name = "Content",
    Position = UDim2.new(0, 168, 0, 82),
    Size = UDim2.new(1, -180, 1, -96),
    BackgroundTransparency = 1,
}, main)

local pages, tabButtons = {}, {}

local function createPage(name)
    local page = new("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Purple,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)
    new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    new("UIPadding", { PaddingBottom = UDim.new(0, 15) }, page)
    pages[name] = page
    return page
end

local function switchPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = (pageName == name)
    end
    for tabName, button in pairs(tabButtons) do
        tween(button, {
            BackgroundColor3 = (tabName == name) and Theme.PurpleDark or Theme.Panel,
        }, 0.18)
    end
end

local function createTab(name, icon)
    local button = new("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Panel,
        Text = icon .. "  " .. name,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
    }, sidebar)
    corner(button, 11)
    tabButtons[name] = button
    connect(button.Activated, function() switchPage(name) end)
end

local function createCard(parent, titleText, height)
    local card = new("Frame", {
        Size = UDim2.new(1, -8, 0, height or 100),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
    }, parent)
    corner(card, 13)
    stroke(card, 1, 0.65)
    label(card, {
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -28, 0, 28),
        Text = titleText,
        TextSize = 17,
        Font = Enum.Font.GothamBold,
    })
    return card
end

local function cardText(card, text, y, height, color, size)
    return label(card, {
        Position = UDim2.fromOffset(15, y or 42),
        Size = UDim2.new(1, -30, 0, height or 50),
        Text = text,
        TextColor3 = color or Theme.Muted,
        TextSize = size or 14,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
end

-- Returns a setter: setter(true/false)
local function createToggle(parent, text, callback)
    local row = new("Frame", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 0, 42),
        BackgroundColor3 = Theme.Row,
        BorderSizePixel = 0,
    }, parent)
    corner(row, 10)

    label(row, {
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -85, 1, 0),
        Text = text,
    })

    local button = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(48, 25),
        BackgroundColor3 = Theme.Off,
        Text = "",
        AutoButtonColor = false,
    }, row)
    corner(button, 20)

    local knob = new("Frame", {
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(19, 19),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
    }, button)
    corner(knob, 20)

    local enabled = false
    local function apply(value)
        enabled = value
        tween(button, { BackgroundColor3 = enabled and Theme.Purple or Theme.Off }, 0.18)
        tween(knob, { Position = enabled and UDim2.fromOffset(26, 3) or UDim2.fromOffset(3, 3) }, 0.18)
        if callback then callback(enabled) end
    end

    connect(button.Activated, function() apply(not enabled) end)
    return apply
end

----------------------------------------------------------------
-- Tabs and pages
----------------------------------------------------------------
createTab("Главная", "⌂")
createTab("Визуалы", "✦")
createTab("Настройки", "⚙")
createTab("Админ-панель", "♛")
createTab("О программе", "ⓘ")

local home = createPage("Главная")
local visuals = createPage("Визуалы")
local settings = createPage("Настройки")
local admin = createPage("Админ-панель")
local about = createPage("О программе")

----------------------------------------------------------------
-- Lighting effects
----------------------------------------------------------------
local bloom = new("BloomEffect", {
    Name = "DeltaHub_Bloom", Intensity = 0.35, Size = 24, Threshold = 1, Enabled = false,
}, Lighting)

local colorCorrection = new("ColorCorrectionEffect", {
    Name = "DeltaHub_ColorCorrection", Saturation = 0.15, Contrast = 0.08, Brightness = 0, Enabled = false,
}, Lighting)

local sunRays = new("SunRaysEffect", {
    Name = "DeltaHub_SunRays", Intensity = 0.08, Spread = 0.7, Enabled = false,
}, Lighting)

----------------------------------------------------------------
-- Falling leaves
----------------------------------------------------------------
local leaves = {}
local leafTarget = 16
local leavesEnabled = false
local leafConnection
local leafClock = 0

local function newLeaf(spread)
    local x = math.random()
    local y = spread and math.random() or -0.05
    local lbl = new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(30, 30),
        Position = UDim2.fromScale(x, y),
        BackgroundTransparency = 1,
        Text = "🍂",
        TextSize = math.random(18, 30),
        TextTransparency = 0.15,
        Rotation = math.random(0, 360),
        Active = false,
        ZIndex = 1,
    }, leafLayer)
    return {
        label = lbl,
        x = x,
        y = y,
        speed = math.random(6, 14) / 100,
        sway = math.random(15, 40) / 1000,
        phase = math.random() * math.pi * 2,
        spin = math.random(-60, 60),
    }
end

local function syncLeafCount()
    while #leaves < leafTarget do
        table.insert(leaves, newLeaf(true))
    end
    while #leaves > leafTarget do
        local leaf = table.remove(leaves)
        leaf.label:Destroy()
    end
end

local function setLeaves(on)
    leavesEnabled = on
    if on then
        syncLeafCount()
        if not leafConnection then
            leafConnection = RunService.Heartbeat:Connect(function(dt)
                leafClock += dt
                for _, leaf in ipairs(leaves) do
                    leaf.y += leaf.speed * dt
                    if leaf.y > 1.05 then
                        leaf.y = -0.05
                        leaf.x = math.random()
                    end
                    local px = leaf.x + math.sin(leafClock + leaf.phase) * leaf.sway
                    leaf.label.Position = UDim2.fromScale(px, leaf.y)
                    leaf.label.Rotation += leaf.spin * dt
                end
            end)
        end
    else
        if leafConnection then
            leafConnection:Disconnect()
            leafConnection = nil
        end
        for _, leaf in ipairs(leaves) do leaf.label:Destroy() end
        table.clear(leaves)
    end
end

----------------------------------------------------------------
-- Home page
----------------------------------------------------------------
local deviceName = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)
    and "Мобильное" or "ПК"

local info = createCard(home, "★  Информация", 115)
cardText(info, "Версия: 0.2 Beta\nСтатус: Интерфейс запущен\nУстройство: " .. deviceName, 40, 65)

local quick = createCard(home, "⚡  Быстрые настройки", 90)
cardText(quick, "Настраивай эффекты отдельно во вкладке «Визуалы».", 42, 40, nil, 13)

----------------------------------------------------------------
-- Visuals page
----------------------------------------------------------------
local fxCard = createCard(visuals, "✦  Визуальные эффекты", 225)

local function addVisualToggle(index, text, callback)
    local holder = new("Frame", {
        Position = UDim2.fromOffset(0, 38 + (index - 1) * 44),
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
    }, fxCard)
    return createToggle(holder, text, callback)
end

addVisualToggle(1, "Bloom — мягкое свечение", function(on) bloom.Enabled = on end)
addVisualToggle(2, "Color Correction — цвет", function(on) colorCorrection.Enabled = on end)
addVisualToggle(3, "Sun Rays — солнечные лучи", function(on) sunRays.Enabled = on end)
addVisualToggle(4, "Осенние листья 🍂", setLeaves)

----------------------------------------------------------------
-- Settings page: performance profiles
----------------------------------------------------------------
local profiles = {
    { name = "Economy", desc = "Минимальная нагрузка", bloom = 0.15, bloomSize = 16, rays = 0.04, leaves = 8 },
    { name = "Balanced", desc = "Баланс качества и FPS", bloom = 0.35, bloomSize = 24, rays = 0.08, leaves = 16 },
    { name = "Max", desc = "Максимальное качество", bloom = 0.60, bloomSize = 40, rays = 0.15, leaves = 28 },
}

local perf = createCard(settings, "⚙  Производительность", 150)
local perfRow = new("Frame", {
    Position = UDim2.fromOffset(12, 52),
    Size = UDim2.new(1, -24, 0, 70),
    BackgroundTransparency = 1,
}, perf)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, perfRow)

local profileButtons = {}

local function applyProfile(profile)
    bloom.Intensity = profile.bloom
    bloom.Size = profile.bloomSize
    sunRays.Intensity = profile.rays
    leafTarget = profile.leaves
    if leavesEnabled then syncLeafCount() end

    for name, button in pairs(profileButtons) do
        tween(button, { BackgroundColor3 = (name == profile.name) and Theme.Purple or Theme.Dark }, 0.15)
    end
end

for i, profile in ipairs(profiles) do
    local button = new("TextButton", {
        LayoutOrder = i,
        Size = UDim2.new(1 / 3, -6, 1, 0),
        BackgroundColor3 = (profile.name == "Balanced") and Theme.Purple or Theme.Dark,
        Text = profile.name .. "\n" .. profile.desc,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextWrapped = true,
        AutoButtonColor = false,
    }, perfRow)
    corner(button, 10)
    profileButtons[profile.name] = button
    connect(button.Activated, function() applyProfile(profile) end)
end

----------------------------------------------------------------
-- Admin / About pages
----------------------------------------------------------------
local adminCard = createCard(admin, "♛  Админ-панель", 110)
cardText(adminCard, "Административные действия требуют серверной проверки прав.", 42, 55, nil, 13)

local aboutCard = createCard(about, "ⓘ  О программе", 110)
cardText(aboutCard, "DeltaHub v0.2 Beta\nНовая сборка интерфейса.", 42, 55)

----------------------------------------------------------------
-- Window behaviour
----------------------------------------------------------------
switchPage("Главная")
tween(scale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)

local minimized = false
connect(minimizeButton.Activated, function()
    minimized = not minimized
    if minimized then
        sidebar.Visible = false
        content.Visible = false
        sizeLimit.MinSize = Vector2.new(300, 76)
        tween(main, { Size = UDim2.fromOffset(300, 76) }, 0.25)
    else
        sizeLimit.MinSize = MIN_SIZE
        tween(main, { Size = FULL_SIZE }, 0.25)
        task.delay(0.15, function()
            if not minimized then
                sidebar.Visible = true
                content.Visible = true
            end
        end)
    end
end)

local closing = false
connect(closeButton.Activated, function()
    if closing then return end
    closing = true
    setLeaves(false)
    local t = tween(scale, { Scale = 0 }, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    t.Completed:Wait()

    for _, c in ipairs(connections) do c:Disconnect() end
    table.clear(connections)

    bloom:Destroy()
    colorCorrection:Destroy()
    sunRays:Destroy()
    gui:Destroy()
end)

-- Dragging (mouse or touch)
local dragging, dragStart, startPosition = false, nil, nil

local function isPointer(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

connect(header.InputBegan, function(input)
    if isPointer(input) then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

connect(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

connect(UserInputService.InputEnded, function(input)
    if isPointer(input) then dragging = false end
end)

-- Safety net: if the GUI is destroyed externally, clean everything up
gui.Destroying:Connect(function()
    setLeaves(false)
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, fx in ipairs({ bloom, colorCorrection, sunRays }) do
        if fx.Parent then fx:Destroy() end
    end
end)

print("DeltaHub v0.2 Beta UI loaded")
