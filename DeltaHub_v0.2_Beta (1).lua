--[[
    DELTA HUB v0.2 Beta
    Author: lesikarseniu21
    Tester: sasha2274380
    Design: ChatGPT
    Administrator: lesikarseniu21 (UserId 2048530043)
    
    Features:
    - Autumn falling leaves
    - Smooth open/close animations
    - Mobile & Tablet adaptation
    - Tabs: Visuals / Settings / Admin (admin only)
    - Automatic device quality detection (Low / Medium / High)
    - Optimization for weak phones
    - No ESP / No cheats / No Premium
]]

if _G.DeltaHubV02Loaded then
    warn("[DELTA HUB] Already running")
    return
end
_G.DeltaHubV02Loaded = true

-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ADMIN_ID = 2048530043
local isAdmin = LocalPlayer.UserId == ADMIN_ID

-- Cleanup old GUI
local old = PlayerGui:FindFirstChild("DeltaHubV02")
if old then old:Destroy() end

-- ==================== DEVICE DETECTION ====================
local DeviceInfo = {
    IsMobile = UserInputService.TouchEnabled,
    IsTablet = false,
    Quality = "High",
    LeafCount = 18,
    LeafSpawnInterval = 0.45,
    EnableBloom = true,
    EnableLeaves = true,
    AnimationSpeed = 0.28
}

local function DetectDevice()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local width = viewport.X
    local height = viewport.Y

    if DeviceInfo.IsMobile and width >= 700 then
        DeviceInfo.IsTablet = true
    end

    if not DeviceInfo.IsMobile then
        -- PC
        DeviceInfo.Quality = "High"
        DeviceInfo.LeafCount = 20
        DeviceInfo.LeafSpawnInterval = 0.4
        DeviceInfo.EnableBloom = true
        DeviceInfo.EnableLeaves = true
        DeviceInfo.AnimationSpeed = 0.25
    else
        if width <= 400 or height <= 700 then
            -- Very weak phones
            DeviceInfo.Quality = "Low"
            DeviceInfo.LeafCount = 5
            DeviceInfo.LeafSpawnInterval = 1.0
            DeviceInfo.EnableBloom = false
            DeviceInfo.EnableLeaves = true
            DeviceInfo.AnimationSpeed = 0.38
        elseif width <= 520 then
            -- Average phones
            DeviceInfo.Quality = "Medium"
            DeviceInfo.LeafCount = 10
            DeviceInfo.LeafSpawnInterval = 0.65
            DeviceInfo.EnableBloom = true
            DeviceInfo.EnableLeaves = true
            DeviceInfo.AnimationSpeed = 0.32
        else
            -- Good phones / tablets
            DeviceInfo.Quality = "High"
            DeviceInfo.LeafCount = 15
            DeviceInfo.LeafSpawnInterval = 0.45
            DeviceInfo.EnableBloom = true
            DeviceInfo.EnableLeaves = true
            DeviceInfo.AnimationSpeed = 0.26
        end
    end
end

DetectDevice()

-- Optional FPS-based downgrade
task.spawn(function()
    local frames = 0
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        frames += 1
        if os.clock() - startTime >= 1.3 then
            conn:Disconnect()
            local fps = frames / (os.clock() - startTime)
            if fps < 27 and DeviceInfo.Quality ~= "Low" then
                DeviceInfo.Quality = "Low"
                DeviceInfo.LeafCount = 4
                DeviceInfo.LeafSpawnInterval = 1.2
                DeviceInfo.EnableBloom = false
                print("[DELTA HUB] Low FPS detected → Quality set to Low")
            end
        end
    end)
end)

print(string.format("[DELTA HUB] Device: %s | Quality: %s | Leaves: %d",
    DeviceInfo.IsMobile and (DeviceInfo.IsTablet and "Tablet" or "Phone") or "PC",
    DeviceInfo.Quality,
    DeviceInfo.LeafCount
))

-- ==================== THEME ====================
local Theme = {
    Background = Color3.fromRGB(16, 17, 24),
    Panel = Color3.fromRGB(26, 27, 38),
    Accent = Color3.fromRGB(255, 140, 50),
    Text = Color3.fromRGB(245, 245, 250),
    Muted = Color3.fromRGB(160, 160, 175),
    Off = Color3.fromRGB(50, 51, 65),
}

-- ==================== LOCALIZATION ====================
local Language = "RU"
local L = {
    RU = {
        Title = "DELTA HUB",
        Version = "v0.2 Beta",
        Subtitle = "Осенняя версия",
        Visuals = "Визуалы",
        Settings = "Настройки",
        Admin = "Админ",
        Bloom = "Bloom эффект",
        ColorCorrection = "Цветокоррекция",
        Saturation = "Насыщенность",
        Contrast = "Контраст",
        Language = "Язык",
        Leaves = "Падающие листья",
        On = "ВКЛ",
        Off = "ВЫКЛ",
        Hint = "RightShift / кнопка — открыть/закрыть",
        Credits = "Author: lesikarseniu21  •  Tester: sasha2274380  •  Design: ChatGPT",
        AdminTitle = "Админ-панель",
        Welcome = "Добро пожаловать,",
        Quality = "Качество",
        Device = "Устройство"
    },
    EN = {
        Title = "DELTA HUB",
        Version = "v0.2 Beta",
        Subtitle = "Autumn Edition",
        Visuals = "Visuals",
        Settings = "Settings",
        Admin = "Admin",
        Bloom = "Bloom effect",
        ColorCorrection = "Color correction",
        Saturation = "Saturation",
        Contrast = "Contrast",
        Language = "Language",
        Leaves = "Falling Leaves",
        On = "ON",
        Off = "OFF",
        Hint = "RightShift / button — open/close",
        Credits = "Author: lesikarseniu21  •  Tester: sasha2274380  •  Design: ChatGPT",
        AdminTitle = "Admin Panel",
        Welcome = "Welcome,",
        Quality = "Quality",
        Device = "Device"
    }
}

local function T(key)
    return L[Language][key] or key
end

-- ==================== UTILS ====================
local function Create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end

local function Stroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Theme.Accent,
        Thickness = thickness or 1.2,
        Transparency = transparency or 0.3
    }, parent)
end

local function Tween(obj, props, time)
    local tween = TweenService:Create(
        obj,
        TweenInfo.new(time or DeviceInfo.AnimationSpeed, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
    tween:Play()
    return tween
end

-- ==================== LIGHTING EFFECTS ====================
local Bloom = Lighting:FindFirstChild("DeltaHub_Bloom")
if not Bloom or not Bloom:IsA("BloomEffect") then
    if Bloom then Bloom:Destroy() end
    Bloom = Instance.new("BloomEffect")
    Bloom.Name = "DeltaHub_Bloom"
    Bloom.Parent = Lighting
end
Bloom.Intensity = DeviceInfo.Quality == "Low" and 0.25 or 0.45
Bloom.Size = DeviceInfo.Quality == "Low" and 16 or 30
Bloom.Threshold = 0.9
Bloom.Enabled = false

local ColorCorrection = Lighting:FindFirstChild("DeltaHub_CC")
if not ColorCorrection or not ColorCorrection:IsA("ColorCorrectionEffect") then
    if ColorCorrection then ColorCorrection:Destroy() end
    ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Name = "DeltaHub_CC"
    ColorCorrection.Parent = Lighting
end
ColorCorrection.Enabled = false

local SaturationValue = 0
local ContrastValue = 0

local function UpdateColorCorrection()
    ColorCorrection.Saturation = SaturationValue / 100
    ColorCorrection.Contrast = ContrastValue / 100
end

-- ==================== GUI ====================
local ScreenGui = Create("ScreenGui", {
    Name = "DeltaHubV02",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true
}, PlayerGui)

local isPhone = DeviceInfo.IsMobile and not DeviceInfo.IsTablet
local MainWidth = isPhone and 340 or (DeviceInfo.IsTablet and 400 or 380)
local MainHeight = isPhone and 500 or 540

local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(MainWidth, MainHeight),
    Position = UDim2.new(0.5, -MainWidth/2, 1.3, 0),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, ScreenGui)
Corner(Main, 18)
Stroke(Main, Theme.Accent, 1.5, 0.25)

-- ===== Falling Leaves =====
local LeavesFolder = Create("Folder", {Name = "AutumnLeaves"}, Main)
local activeLeaves = {}
local leafConnection = nil
local lastLeafSpawn = 0

local function CreateLeaf()
    if not DeviceInfo.EnableLeaves then return end
    if #activeLeaves >= DeviceInfo.LeafCount then return end

    local size = math.random(13, 20)
    local leaf = Create("TextLabel", {
        Size = UDim2.fromOffset(size, size),
        Position = UDim2.new(math.random(), 0, -0.08, 0),
        BackgroundTransparency = 1,
        Text = "🍂",
        TextSize = size,
        Rotation = math.random(0, 360),
        ZIndex = 3
    }, LeavesFolder)

    table.insert(activeLeaves, {
        Instance = leaf,
        Speed = math.random(28, 55) / 100,
        RotSpeed = math.random(-50, 50),
        Sway = math.random(-12, 12) / 100,
        Time = 0
    })
end

local function UpdateLeaves(dt)
    for i = #activeLeaves, 1, -1 do
        local data = activeLeaves[i]
        local leaf = data.Instance
        if not leaf or not leaf.Parent then
            table.remove(activeLeaves, i)
            continue
        end

        data.Time += dt
        local y = leaf.Position.Y.Scale + data.Speed * dt * 0.38
        local x = leaf.Position.X.Scale + math.sin(data.Time * 1.4) * data.Sway * dt

        leaf.Position = UDim2.new(math.clamp(x, -0.05, 1.05), 0, y, 0)
        leaf.Rotation = leaf.Rotation + data.RotSpeed * dt

        if y > 1.18 then
            leaf:Destroy()
            table.remove(activeLeaves, i)
        end
    end
end

local function StartLeaves()
    if leafConnection then return end
    lastLeafSpawn = 0
    leafConnection = RunService.Heartbeat:Connect(function(dt)
        lastLeafSpawn += dt
        if lastLeafSpawn >= DeviceInfo.LeafSpawnInterval then
            lastLeafSpawn = 0
            CreateLeaf()
        end
        UpdateLeaves(dt)
    end)
end

local function StopLeaves()
    if leafConnection then
        leafConnection:Disconnect()
        leafConnection = nil
    end
    for _, data in ipairs(activeLeaves) do
        if data.Instance then
            data.Instance:Destroy()
        end
    end
    table.clear(activeLeaves)
end

-- Header
local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 76),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, Main)
Corner(Header, 18)

Create("Frame", {
    Position = UDim2.new(0, 0, 1, -18),
    Size = UDim2.new(1, 0, 0, 18),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, Header)

local Title = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 10),
    Size = UDim2.new(1, -70, 0, 28),
    Font = Enum.Font.GothamBold,
    Text = T("Title"),
    TextColor3 = Theme.Text,
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local Subtitle = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(18, 38),
    Size = UDim2.new(1, -70, 0, 18),
    Font = Enum.Font.Gotham,
    Text = T("Version") .. "  •  " .. T("Subtitle"),
    TextColor3 = Theme.Muted,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

local CloseBtn = Create("TextButton", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -48, 0, 14),
    BackgroundColor3 = Theme.Off,
    Text = "×",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    AutoButtonColor = false
}, Header)
Corner(CloseBtn, 9)

-- Tabs
local TabBar = Create("Frame", {
    Position = UDim2.fromOffset(14, 86),
    Size = UDim2.new(1, -28, 0, 38),
    BackgroundTransparency = 1
}, Main)

local tabCount = isAdmin and 3 or 2

local function CreateTabButton(text, order)
    local btn = Create("TextButton", {
        Size = UDim2.new(1 / tabCount, -6, 1, 0),
        Position = UDim2.new((order - 1) / tabCount, 3, 0, 0),
        BackgroundColor3 = Theme.Panel,
        Text = text,
        TextColor3 = Theme.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        AutoButtonColor = false
    }, TabBar)
    Corner(btn, 10)
    return btn
end

local VisualsTabBtn = CreateTabButton(T("Visuals"), 1)
local SettingsTabBtn = CreateTabButton(T("Settings"), 2)
local AdminTabBtn = isAdmin and CreateTabButton(T("Admin"), 3) or nil

-- Content Pages
local Content = Create("Frame", {
    Position = UDim2.fromOffset(14, 132),
    Size = UDim2.new(1, -28, 1, -190),
    BackgroundTransparency = 1,
    ClipsDescendants = true
}, Main)

local function CreatePage()
    local page = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false
    }, Content)
    Create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)
    return page
end

local VisualsPage = CreatePage()
local SettingsPage = CreatePage()
local AdminPage = isAdmin and CreatePage() or nil

-- Controls storage for language refresh
local Controls = {}

local function Section(page, text)
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = Theme.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, page)
end

local function CreateToggle(page, key, callback, defaultState)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0
    }, page)
    Corner(row, 11)

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = T(key),
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    local btn = Create("TextButton", {
        Size = UDim2.fromOffset(68, 30),
        Position = UDim2.new(1, -80, 0.5, -15),
        BackgroundColor3 = Theme.Off,
        Text = T("Off"),
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false
    }, row)
    Corner(btn, 8)

    local state = defaultState or false

    local function Set(value)
        state = value
        Tween(btn, {BackgroundColor3 = state and Theme.Accent or Theme.Off}, 0.15)
        btn.Text = T(state and "On" or "Off")
        pcall(callback, state)
    end

    if defaultState then
        Set(true)
    end

    btn.MouseButton1Click:Connect(function()
        Set(not state)
    end)

    table.insert(Controls, {
        Refresh = function()
            label.Text = T(key)
            btn.Text = T(state and "On" or "Off")
        end
    })
end

local function CreateSlider(page, key, minV, maxV, initial, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0
    }, page)
    Corner(row, 11)

    local label = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -70, 0, 20),
        Font = Enum.Font.GothamMedium,
        Text = T(key),
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    }, row)

    local valueLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -58, 0, 8),
        Size = UDim2.fromOffset(46, 20),
        Font = Enum.Font.GothamBold,
        Text = tostring(initial),
        TextColor3 = Theme.Accent,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right
    }, row)

    local bar = Create("Frame", {
        Position = UDim2.fromOffset(14, 40),
        Size = UDim2.new(1, -28, 0, 8),
        BackgroundColor3 = Theme.Off,
        BorderSizePixel = 0
    }, row)
    Corner(bar, 4)

    local fill = Create("Frame", {
        Size = UDim2.new((initial - minV) / (maxV - minV), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    }, bar)
    Corner(fill, 4)

    local knob = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0
    }, bar)
    Corner(knob, 8)

    local dragging = false

    local function SetFromX(x)
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local value = math.floor(minV + (maxV - minV) * alpha + 0.5)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end

    local function Begin(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            SetFromX(input.Position.X)
        end
    end

    bar.InputBegan:Connect(Begin)
    knob.InputBegan:Connect(Begin)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            SetFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(Controls, {
        Refresh = function()
            label.Text = T(key)
        end
    })
end

-- ===== Visuals Page =====
Section(VisualsPage, "ЭФФЕКТЫ")

CreateToggle(VisualsPage, "Bloom", function(state)
    if DeviceInfo.EnableBloom then
        Bloom.Enabled = state
    else
        Bloom.Enabled = false
    end
end, false)

CreateToggle(VisualsPage, "ColorCorrection", function(state)
    ColorCorrection.Enabled = state
end, false)

CreateToggle(VisualsPage, "Leaves", function(state)
    DeviceInfo.EnableLeaves = state
    if state then
        StartLeaves()
    else
        StopLeaves()
    end
end, DeviceInfo.EnableLeaves)

Section(VisualsPage, "НАСТРОЙКИ ЦВЕТА")

CreateSlider(VisualsPage, "Saturation", -100, 100, 0, function(value)
    SaturationValue = value
    UpdateColorCorrection()
end)

CreateSlider(VisualsPage, "Contrast", -100, 100, 0, function(value)
    ContrastValue = value
    UpdateColorCorrection()
end)

-- ===== Settings Page =====
Section(SettingsPage, "ИНТЕРФЕЙС")

local LangRow = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0
}, SettingsPage)
Corner(LangRow, 11)

local LangLabel = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(14, 0),
    Size = UDim2.new(1, -110, 1, 0),
    Font = Enum.Font.GothamMedium,
    Text = T("Language"),
    TextColor3 = Theme.Text,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
}, LangRow)

local LangBtn = Create("TextButton", {
    Size = UDim2.fromOffset(78, 30),
    Position = UDim2.new(1, -90, 0.5, -15),
    BackgroundColor3 = Theme.Accent,
    Text = Language,
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false
}, LangRow)
Corner(LangBtn, 8)

Section(SettingsPage, "ИНФОРМАЦИЯ ОБ УСТРОЙСТВЕ")

local DeviceInfoLabel = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 78),
    BackgroundColor3 = Theme.Panel,
    Font = Enum.Font.Gotham,
    Text = "",
    TextColor3 = Theme.Muted,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextWrapped = true
}, SettingsPage)
Corner(DeviceInfoLabel, 11)

local function UpdateDeviceInfoText()
    local deviceType = "PC"
    if DeviceInfo.IsMobile then
        deviceType = DeviceInfo.IsTablet and "Tablet" or "Phone"
    end
    DeviceInfoLabel.Text = string.format(
        "  %s: %s\n  %s: %s\n  Leaves limit: %d",
        T("Device"), deviceType,
        T("Quality"), DeviceInfo.Quality,
        DeviceInfo.LeafCount
    )
end
UpdateDeviceInfoText()

-- ===== Admin Page (only for UserId 2048530043) =====
if isAdmin and AdminPage then
    Section(AdminPage, T("AdminTitle"))

    local welcomeLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Panel,
        Font = Enum.Font.GothamMedium,
        Text = T("Welcome") .. " " .. LocalPlayer.Name,
        TextColor3 = Theme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    }, AdminPage)
    Corner(welcomeLabel, 11)

    local adminInfo = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 90),
        BackgroundColor3 = Theme.Panel,
        Font = Enum.Font.Gotham,
        Text = "UserId: " .. tostring(LocalPlayer.UserId) ..
               "\nQuality: " .. DeviceInfo.Quality ..
               "\nDevice detected automatically\nAdmin access granted",
        TextColor3 = Theme.Muted,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, AdminPage)
    Corner(adminInfo, 11)
end

-- Footer
local Footer = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 1, -48),
    Size = UDim2.new(1, -28, 0, 16),
    Font = Enum.Font.Gotham,
    Text = T("Credits"),
    TextColor3 = Theme.Muted,
    TextSize = 10,
    TextTruncate = Enum.TextTruncate.AtEnd
}, Main)

local Hint = Create("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 14, 1, -30),
    Size = UDim2.new(1, -28, 0, 16),
    Font = Enum.Font.Gotham,
    Text = T("Hint"),
    TextColor3 = Theme.Muted,
    TextSize = 10
}, Main)

-- Floating Button
local FloatingBtn = Create("TextButton", {
    Size = UDim2.fromOffset(52, 52),
    Position = UDim2.new(0, 18, 0.5, -26),
    BackgroundColor3 = Theme.Accent,
    Text = "DH",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Visible = false,
    AutoButtonColor = false
}, ScreenGui)
Corner(FloatingBtn, 14)
Stroke(FloatingBtn, Color3.new(1, 1, 1), 1, 0.5)

-- ==================== TAB & LANGUAGE LOGIC ====================
local currentPage = VisualsPage
VisualsPage.Visible = true
VisualsTabBtn.BackgroundColor3 = Theme.Accent
VisualsTabBtn.TextColor3 = Theme.Text

local function SwitchTab(page, button)
    if currentPage then
        currentPage.Visible = false
    end
    currentPage = page
    page.Visible = true

    VisualsTabBtn.BackgroundColor3 = Theme.Panel
    VisualsTabBtn.TextColor3 = Theme.Muted
    SettingsTabBtn.BackgroundColor3 = Theme.Panel
    SettingsTabBtn.TextColor3 = Theme.Muted
    if AdminTabBtn then
        AdminTabBtn.BackgroundColor3 = Theme.Panel
        AdminTabBtn.TextColor3 = Theme.Muted
    end

    button.BackgroundColor3 = Theme.Accent
    button.TextColor3 = Theme.Text
end

VisualsTabBtn.MouseButton1Click:Connect(function()
    SwitchTab(VisualsPage, VisualsTabBtn)
end)

SettingsTabBtn.MouseButton1Click:Connect(function()
    SwitchTab(SettingsPage, SettingsTabBtn)
end)

if AdminTabBtn and AdminPage then
    AdminTabBtn.MouseButton1Click:Connect(function()
        SwitchTab(AdminPage, AdminTabBtn)
    end)
end

local function SetLanguage(newLang)
    Language = newLang
    Title.Text = T("Title")
    Subtitle.Text = T("Version") .. "  •  " .. T("Subtitle")
    Footer.Text = T("Credits")
    Hint.Text = T("Hint")
    LangLabel.Text = T("Language")
    LangBtn.Text = Language
    VisualsTabBtn.Text = T("Visuals")
    SettingsTabBtn.Text = T("Settings")
    if AdminTabBtn then
        AdminTabBtn.Text = T("Admin")
    end
    UpdateDeviceInfoText()

    for _, control in ipairs(Controls) do
        if control.Refresh then
            control.Refresh()
        end
    end
end

LangBtn.MouseButton1Click:Connect(function()
    SetLanguage(Language == "RU" and "EN" or "RU")
end)

-- ==================== SHOW / HIDE ====================
local isVisible = false

local function Hide()
    isVisible = false
    Tween(Main, {
        Position = UDim2.new(0.5, -MainWidth/2, 1.3, 0)
    }, 0.35)
    task.delay(0.36, function()
        if not isVisible then
            Main.Visible = false
            FloatingBtn.Visible = true
            StopLeaves()
        end
    end)
end

local function Show()
    isVisible = true
    FloatingBtn.Visible = false
    Main.Visible = true
    Main.Position = UDim2.new(0.5, -MainWidth/2, 1.3, 0)
    Tween(Main, {
        Position = UDim2.new(0.5, -MainWidth/2, 0.5, -MainHeight/2)
    }, 0.4)
    if DeviceInfo.EnableLeaves then
        StartLeaves()
    end
end

CloseBtn.MouseButton1Click:Connect(Hide)
FloatingBtn.MouseButton1Click:Connect(Show)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if isVisible then
            Hide()
        else
            Show()
        end
    end
end)

-- ==================== DRAGGING ====================
local dragging = false
local dragStart = nil
local startPos = nil

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==================== CLEANUP ====================
ScreenGui.Destroying:Connect(function()
    StopLeaves()
    Bloom.Enabled = false
    ColorCorrection.Enabled = false
    _G.DeltaHubV02Loaded = false
end)

-- Auto open on load
task.defer(Show)

print("[DELTA HUB] v0.2 Beta loaded successfully")
print("[DELTA HUB] Quality profile:", DeviceInfo.Quality)
