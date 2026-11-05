--[[
    DELTA HUB UNIVERSAL v1.0
    Creator: Chat GPT
    Author: lesikarseniu21
    Languages: Russian / English
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Remove old GUI
local old = PlayerGui:FindFirstChild("DeltaHub")
if old then old:Destroy() end

-- Settings
local Settings = {
    Language = "RU",
    Bloom = false,
    Fullbright = false,
    ColorEffect = false,
    ESP = false,
    Saturation = 0.3,
    Contrast = 0.1
}

local Texts = {
    RU = {
        Title = "DELTA HUB",
        Visual = "Визуалы",
        Effects = "Эффекты",
        Settings = "Настройки",
        Bloom = "Bloom",
        Fullbright = "Полная яркость",
        Color = "Цветокоррекция",
        ESP = "Подсветка игроков",
        Saturation = "Насыщенность",
        Contrast = "Контрастность",
        Language = "Язык",
        Creator = "Создатель: Chat GPT",
        Author = "Автор: lesikarseniu21",
        Hide = "Скрыть меню"
    },
    EN = {
        Title = "DELTA HUB",
        Visual = "Visuals",
        Effects = "Effects",
        Settings = "Settings",
        Bloom = "Bloom",
        Fullbright = "Fullbright",
        Color = "Color correction",
        ESP = "Player highlight",
        Saturation = "Saturation",
        Contrast = "Contrast",
        Language = "Language",
        Creator = "Creator: Chat GPT",
        Author = "Author: lesikarseniu21",
        Hide = "Hide menu"
    }
}

local function T(key)
    return Texts[Settings.Language][key]
end

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "DeltaHub"
GUI.ResetOnSpawn = false
GUI.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(480, 340)
Main.Position = UDim2.new(0.5, -240, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 255, 140)
Stroke.Thickness = 1.5
Stroke.Parent = Main

local function Label(parent, text, size, position)
    local obj = Instance.new("TextLabel")
    obj.Size = size
    obj.Position = position
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.TextSize = 16
    obj.Font = Enum.Font.GothamBold
    obj.Parent = parent
    return obj
end

Label(Main, "DELTA HUB  |  v1.0",
    UDim2.new(1, 0, 0, 48), UDim2.new())

-- Animated opening
Main.Size = UDim2.fromOffset(0, 0)
TweenService:Create(
    Main,
    TweenInfo.new(0.5, Enum.EasingStyle.Back),
    {Size = UDim2.fromOffset(480, 340)}
):Play()

-- Effects
local Bloom = Instance.new("BloomEffect")
Bloom.Intensity = 0
Bloom.Size = 24
Bloom.Threshold = 1
Bloom.Parent = Lighting

local Correction = Instance.new("ColorCorrectionEffect")
Correction.Saturation = 0
Correction.Contrast = 0
Correction.Parent = Lighting

local function ToggleEffect(key, value)
    Settings[key] = value

    if key == "Bloom" then
        Bloom.Intensity = value and 1.2 or 0
    elseif key == "Fullbright" then
        Lighting.Brightness = value and 3 or 1
        Lighting.GlobalShadows = not value
    elseif key == "ColorEffect" then
        Correction.Enabled = value
    end
end

-- Player highlighting
local Highlights = {}

local function UpdateESP()
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= Player and target.Character then
            local character = target.Character
            local highlight = Highlights[target]

            if Settings.ESP then
                if not highlight or highlight.Parent ~= character then
                    if highlight then highlight:Destroy() end

                    highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(0, 255, 140)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.65
                    highlight.Parent = character
                    Highlights[target] = highlight
                end
            elseif highlight then
                highlight:Destroy()
                Highlights[target] = nil
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    Correction.Saturation = Settings.Saturation
    Correction.Contrast = Settings.Contrast
    UpdateESP()
end)

-- UI buttons
local function Button(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 205, 0, 36)
    btn.Position = UDim2.fromOffset(15, y)
    btn.BackgroundColor3 = Color3.fromRGB(30, 40, 42)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local y = 65

local function AddToggle(key)
    local btn
    btn = Button(T(key) .. ": OFF", y, function()
        Settings[key] = not Settings[key]
        btn.Text = T(key) .. (Settings[key] and ": ON" or ": OFF")
        ToggleEffect(key, Settings[key])
    end)
    y = y + 42
end

AddToggle("Bloom")
AddToggle("Fullbright")
AddToggle("ColorEffect")
AddToggle("ESP")

-- Language
Button("RU / EN", 245, function()
    Settings.Language = Settings.Language == "RU" and "EN" or "RU"
    print("Language:", Settings.Language)
end)

-- Hide / show
local hidden = false
local hideButton = Button("Hide / Show", 287, function()
    hidden = not hidden
    Main.Visible = not hidden
end)

-- Creator information
Label(Main, "Creator: Chat GPT | Author: lesikarseniu21",
    UDim2.new(1, -15, 0, 22),
    UDim2.new(0, 10, 1, -25))
