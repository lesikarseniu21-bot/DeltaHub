
--[[
    DELTAHUB v0.3 BETA
    PRIVATE TESTING BUILD
    Fresh UI implementation

    Owner: lesikarseniu21
    UserId: 2048530043

    Client-side UI and local visual effects only.
    Client-side ownership check is NOT secure authorization.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
if not Player then return end

local OWNER_ID = 2048530043

if Player.UserId ~= OWNER_ID then
    warn("DeltaHub v0.3 находится в закрытом тестировании")
    return
end

-- Remove previous version
if _G.DeltaHubCleanup then
    pcall(_G.DeltaHubCleanup)
end

local C = {
    Background = Color3.fromRGB(15, 12, 22),
    Sidebar = Color3.fromRGB(25, 20, 35),
    Card = Color3.fromRGB(34, 27, 48),
    CardHover = Color3.fromRGB(48, 36, 65),
    Purple = Color3.fromRGB(137, 79, 213),
    Glow = Color3.fromRGB(190, 130, 255),
    White = Color3.fromRGB(248, 243, 255),
    Gray = Color3.fromRGB(166, 154, 184),
    Green = Color3.fromRGB(115, 218, 157)
}

local running = true
local menuOpen = true
local selectedTab = "Визуалы"
local profile = "Balanced"
local autoFPS = true
local leavesEnabled = true

local connections = {}
local effects = {}
local leaves = {}

local enabled = {
    Bloom = false,
    Cinematic = false,
    Atmosphere = false,
    ColorStudio = false
}

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end

local function make(class, parent, props)
    local object = Instance.new(class)

    for key, value in pairs(props or {}) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function round(object, radius)
    make("UICorner", object, {
        CornerRadius = UDim.new(0, radius)
    })
end

local function outline(object, color, thickness, transparency)
    return make("UIStroke", object, {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0.2
    })
end

local function animate(object, duration, props)
    local t = TweenService:Create(
        object,
        TweenInfo.new(
            duration,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        props
    )
    t:Play()
    return t
end

local function clearEffect(name)
    local obj = effects[name]
    if obj then
        pcall(function()
            obj:Destroy()
        end)
        effects[name] = nil
    end
end

local function addEffect(name, class, props)
    clearEffect(name)

    local obj = Instance.new(class)
    obj.Name = "DeltaHub_" .. name

    for key, value in pairs(props) do
        pcall(function()
            obj[key] = value
        end)
    end

    obj.Parent = Lighting
    effects[name] = obj
end

-- GUI parent

local guiParent = CoreGui

if typeof(gethui) == "function" then
    local success, result = pcall(gethui)
    if success and result then
        guiParent = result
    end
end

local oldGui = guiParent:FindFirstChild("DeltaHub_v03")
if oldGui then
    oldGui:Destroy()
end

local gui = make("ScreenGui", guiParent, {
    Name = "DeltaHub_v03",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local screenScale = make("UIScale", gui, {
    Scale = 1
})

-- Main window

local main = make("Frame", gui, {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(440, 335),
    BackgroundColor3 = C.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true
})

round(main, 18)
outline(main, C.Purple, 1.5, 0.12)

-- Top gradient

local gradientBar = make("Frame", main, {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = C.Purple,
    BorderSizePixel = 0
})

make("UIGradient", gradientBar, {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.Purple),
        ColorSequenceKeypoint.new(0.5, C.Glow),
        ColorSequenceKeypoint.new(1, C.Purple)
    })
})

-- Header

local header = make("Frame", main, {
    Position = UDim2.fromOffset(0, 3),
    Size = UDim2.new(1, 0, 0, 57),
    BackgroundTransparency = 1
})

local logo = make("Frame", header, {
    Position = UDim2.fromOffset(13, 9),
    Size = UDim2.fromOffset(38, 38),
    BackgroundColor3 = C.Purple,
    BorderSizePixel = 0
})

round(logo, 11)

make("UIGradient", logo, {
    Color = ColorSequence.new(C.Purple, C.Glow),
    Rotation = 45
})

make("TextLabel", logo, {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "Δ",
    TextColor3 = C.White,
    Font = Enum.Font.GothamBold,
    TextSize = 25
})

local title = make("TextLabel", header, {
    Position = UDim2.fromOffset(60, 8),
    Size = UDim2.fromOffset(190, 25),
    BackgroundTransparency = 1,
    Text = "DELTAHUB",
    TextColor3 = C.White,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left
})

make("TextLabel", header, {
    Position = UDim2.fromOffset(61, 31),
    Size = UDim2.fromOffset(190, 16),
    BackgroundTransparency = 1,
    Text = "V0.3 BETA  •  PRIVATE",
    TextColor3 = C.Gray,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left
})

local close = make("TextButton", header, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, 12),
    Size = UDim2.fromOffset(30, 30),
    BackgroundColor3 = C.Card,
    Text = "×",
    TextColor3 = C.White,
    Font = Enum.Font.Gotham,
    TextSize = 21,
    AutoButtonColor = false
})

round(close, 9)

-- Sidebar

local sidebar = make("Frame", main, {
    Position = UDim2.fromOffset(11, 67),
    Size = UDim2.fromOffset(116, 255),
    BackgroundColor3 = C.Sidebar,
    BorderSizePixel = 0
})

round(sidebar, 13)

local sideStroke = outline(sidebar, C.Purple, 1, 0.75)

-- Content panel

local content = make("Frame", main, {
    Position = UDim2.fromOffset(137, 67),
    Size = UDim2.new(1, -148, 1, -80),
    BackgroundColor3 = C.Sidebar,
    BorderSizePixel = 0,
    ClipsDescendants = true
})

round(content, 13)

-- Pages

local pages = {}
local tabs = {}

local function createPage(name)
    local page = make("ScrollingFrame", content, {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.Purple,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false
    })

    local padding = make("UIPadding", page, {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 11),
        PaddingRight = UDim.new(0, 11)
    })

    local layout = make("UIListLayout", page, {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        page.CanvasSize = UDim2.new(
            0, 0, 0,
            layout.AbsoluteContentSize.Y + 24
        )
    end)

    pages[name] = page
    return page
end

local visuals = createPage("Визуалы")
local settings = createPage("Настройки")

-- Button helper

local function button(parent, text, size, position, callback)
    local b = make("TextButton", parent, {
        Size = size,
        Position = position,
        BackgroundColor3 = C.Card,
        Text = text,
        TextColor3 = C.White,
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        AutoButtonColor = false
    })

    round(b, 9)
    outline(b, C.Purple, 1, 0.75)

    connect(b.MouseEnter, function()
        if running then
            animate(b, 0.12, {
                BackgroundColor3 = C.CardHover
            })
        end
    end)

    connect(b.MouseLeave, function()
        if running then
            animate(b, 0.12, {
                BackgroundColor3 = C.Card
            })
        end
    end)

    if callback then
        connect(b.Activated, callback)
    end

    return b
end

local function selectTab(name)
    selectedTab = name

    for tabName, page in pairs(pages) do
        page.Visible = tabName == name
    end

    for tabName, b in pairs(tabs) do
        b.BackgroundColor3 =
            tabName == name and C.Purple or C.Card
    end
end

local tabData = {
    {"◈", "Визуалы"},
    {"⚙", "Настройки"}
}

for index, data in ipairs(tabData) do
    local icon, name = data[1], data[2]

    local b = button(
        sidebar,
        icon .. "   " .. name,
        UDim2.new(1, -14, 0, 37),
        UDim2.fromOffset(7, 12 + (index - 1) * 46),
        function()
            selectTab(name)
        end
    )

    tabs[name] = b
end

make("TextLabel", sidebar, {
    Position = UDim2.fromOffset(9, 207),
    Size = UDim2.new(1, -18, 0, 17),
    BackgroundTransparency = 1,
    Text = "AUTUMN EDITION",
    TextColor3 = C.Gray,
    Font = Enum.Font.GothamBold,
    TextSize = 8
})

make("TextLabel", sidebar, {
    Position = UDim2.fromOffset(9, 222),
    Size = UDim2.new(1, -18, 0, 24),
    BackgroundTransparency = 1,
    Text = "🍂  ✦  🍁",
    TextColor3 = C.Glow,
    Font = Enum.Font.Gotham,
    TextSize = 15
})

-- Section helper

local function section(parent, name, description)
    local height = description and 49 or 34

    local frame = make("Frame", parent, {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = C.Card,
        BorderSizePixel = 0
    })

    round(frame, 9)

    make("TextLabel", frame, {
        Position = UDim2.fromOffset(10, 3),
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = C.White,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    if description then
        make("TextLabel", frame, {
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -20, 0, 18),
            BackgroundTransparency = 1,
            Text = description,
            TextColor3 = C.Gray,
            Font = Enum.Font.Gotham,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left
        })
    end

    return frame
end

-- Toggle helper

local function toggle(parent, name, description, initial, callback)
    local row = make("Frame", parent, {
        Size = UDim2.new(1, 0, 0, 49),
        BackgroundColor3 = C.Card,
        BorderSizePixel = 0
    })

    round(row, 9)

    make("TextLabel", row, {
        Position = UDim2.fromOffset(10, 4),
        Size = UDim2.new(1, -70, 0, 19),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = C.White,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    make("TextLabel", row, {
        Position = UDim2.fromOffset(10, 25),
        Size = UDim2.new(1, -70, 0, 16),
        BackgroundTransparency = 1,
        Text = description or "",
        TextColor3 = C.Gray,
        Font = Enum.Font.Gotham,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local state = initial == true

    local switch = make("TextButton", row, {
        Position = UDim2.new(1, -53, 0.5, -11),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = state and C.Purple or Color3.fromRGB(76, 69, 87),
        Text = "",
        AutoButtonColor = false
    })

    round(switch, 12)

    local dot = make("Frame", switch, {
        Position = state and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = C.White,
        BorderSizePixel = 0
    })

    round(dot, 10)

    local function setState(value)
        state = value

        animate(switch, 0.13, {
            BackgroundColor3 = state and C.Purple
                or Color3.fromRGB(76, 69, 87)
        })

        animate(dot, 0.13, {
            Position = state and UDim2.new(1, -19, 0, 3)
                or UDim2.fromOffset(3, 3)
        })

        callback(state)
    end

    connect(switch.Activated, function()
        setState(not state)
    end)

    return {
        Set = setState,
        Get = function()
            return state
        end
    }
end

-- Visual effects

local function applyEffects()
    local multiplier = 1

    if profile == "Economy" then
        multiplier = 0.5
    elseif profile == "Balanced" then
        multiplier = 0.75
    end

    if enabled.Bloom then
        addEffect("Bloom", "BloomEffect", {
            Intensity = 0.45 * multiplier,
            Size = 24,
            Threshold = 1.1
        })
    else
        clearEffect("Bloom")
    end

    if enabled.Cinematic then
        addEffect("Cinematic", "ColorCorrectionEffect", {
            Brightness = 0.01,
            Contrast = 0.14 * multiplier,
            Saturation = 0.16 * multiplier,
            TintColor = Color3.fromRGB(239, 225, 255)
        })
    else
        clearEffect("Cinematic")
    end

    if enabled.Atmosphere then
        addEffect("Atmosphere", "Atmosphere", {
            Density = 0.18 * multiplier,
            Haze = 1 * multiplier,
            Glare = 0.1,
            Color = Color3.fromRGB(204, 183, 235),
            Decay = Color3.fromRGB(100, 81, 130)
        })
    else
        clearEffect("Atmosphere")
    end

    if enabled.ColorStudio then
        addEffect("ColorStudio", "ColorCorrectionEffect", {
            Brightness = 0,
            Contrast = 0.1 * multiplier,
            Saturation = 0.2 * multiplier,
            TintColor = Color3.fromRGB(255, 225, 205)
        })
    else
        clearEffect("ColorStudio")
    end
end

-- Visuals page

section(
    visuals,
    "ВИЗУАЛЬНЫЕ ЭФФЕКТЫ",
    "Настрой внешний вид игры"
)

toggle(visuals, "Bloom", "Мягкое свечение объектов", false, function(value)
    enabled.Bloom = value
    applyEffects()
end)

toggle(visuals, "Cinematic Shader", "Кинематографичная цветокоррекция", false, function(value)
    enabled.Cinematic = value
    applyEffects()
end)

toggle(visuals, "Atmosphere FX", "Атмосферная дымка", false, function(value)
    enabled.Atmosphere = value
    applyEffects()
end)

toggle(visuals, "Color Studio", "Дополнительная цветокоррекция", false, function(value)
    enabled.ColorStudio = value
    applyEffects()
end)

-- Settings page

section(
    settings,
    "ПРОИЗВОДИТЕЛЬНОСТЬ",
    "Выбери подходящий профиль"
)

local profileFrame = make("Frame", settings, {
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundColor3 = C.Card,
    BorderSizePixel = 0
})

round(profileFrame, 9)

local profileButtons = {}

local function setProfile(name)
    profile = name

    for key, b in pairs(profileButtons) do
        b.BackgroundColor3 = key == name and C.Purple or C.CardHover
    end

    applyEffects()
end

for i, name in ipairs({"Economy", "Balanced", "Max"}) do
    local b = button(
        profileFrame,
        name,
        UDim2.new(1/3, -8, 0, 29),
        UDim2.new((i - 1)/3, 4, 0, 7),
        function()
            setProfile(name)
        end
    )

    profileButtons[name] = b
end

section(
    settings,
    "НАСТРОЙКИ СИСТЕМЫ",
    "Управление нагрузкой и интерфейсом"
)

toggle(settings, "Auto FPS", "Автоматическое снижение эффектов", true, function(value)
    autoFPS = value
end)

toggle(settings, "Autumn Leaves 🍂", "Декоративные листья", true, function(value)
    leavesEnabled = value

    if not value then
        for _, leaf in ipairs(leaves) do
            if leaf and leaf.Parent then
                leaf:Destroy()
            end
        end

        table.clear(leaves)
    end
end)

local deviceType = "Keyboard / Mouse"

if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
    deviceType = "Touch Device"
elseif UserInputService.GamepadEnabled then
    deviceType = "Gamepad"
end

section(
    settings,
    "SMART DEVICE DETECTION",
    deviceType .. " • модель устройства недоступна"
)

-- Reopen button

local reopen = make("TextButton", gui, {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 12),
    Size = UDim2.fromOffset(140, 35),
    BackgroundColor3 = C.Purple,
    Text = "Δ  DeltaHub",
    TextColor3 = C.White,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    Visible = false,
    AutoButtonColor = false,
    ZIndex = 10
})

round(reopen, 11)
outline(reopen, C.Glow, 1.2, 0.15)

local function closeMenu()
    if not menuOpen or not running then return end

    menuOpen = false

    local t = animate(main, 0.18, {
        Size = UDim2.fromOffset(440, 0)
    })

    t.Completed:Connect(function()
        if running and not menuOpen then
            main.Visible = false
            reopen.Visible = true
        end
    end)
end

local function openMenu()
    if menuOpen or not running then return end

    menuOpen = true
    reopen.Visible = false
    main.Visible = true
    main.Size = UDim2.fromOffset(440, 0)

    animate(main, 0.23, {
        Size = UDim2.fromOffset(440, 335)
    })
end

connect(close.Activated, closeMenu)
connect(reopen.Activated, openMenu)

-- Dragging

do
    local dragging = false
    local dragStart
    local startPosition

    connect(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then

            local delta = input.Position - dragStart

            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Responsive scaling

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end

    local size = camera.ViewportSize

    local scale = math.min(
        size.X / 470,
        size.Y / 380,
        1
    )

    screenScale.Scale = math.clamp(scale, 0.65, 1)
end

updateScale()

if workspace.CurrentCamera then
    connect(
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),
        updateScale
    )
end

connect(
    workspace:GetPropertyChangedSignal("CurrentCamera"),
    updateScale
)

-- Autumn leaves

local leafLayer = make("Frame", gui, {
    Name = "AutumnLayer",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ZIndex = 2
})

local function removeLeaves()
    for _, leaf in ipairs(leaves) do
        if leaf and leaf.Parent then
            leaf:Destroy()
        end
    end

    table.clear(leaves)
end

local function spawnLeaf()
    if not running or not leavesEnabled then return end

    local leaf = make("TextLabel", leafLayer, {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.new(math.random(), 0, -0.06, 0),
        BackgroundTransparency = 1,
        Text = math.random(1, 2) == 1 and "🍂" or "🍁",
        TextSize = math.random(13, 19),
        Rotation = math.random(-30, 30),
        TextTransparency = 0.1,
        ZIndex = 2
    })

    table.insert(leaves, leaf)

    local targetX = math.clamp(
        leaf.Position.X.Scale + math.random(-12, 12)/100,
        0,
    