--[
    DeltaHub v0.3 Beta Testing - только визуал (без читов)
    Автор проекта: lesikarseniuz1
    Тестер: sasha274380
    Оформление: ChatGPT
]--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

local VERSION = "0.3 Beta Testing"
local PLACE_NAME = "DeltaHub"

-- Цветовая палитра интерфейса
local COLORS = {
    background = Color3.fromRGB(18, 14, 27),
    panel = Color3.fromRGB(27, 21, 41),
    panel2 = Color3.fromRGB(39, 28, 57),
    text = Color3.fromRGB(240, 240, 255),
    muted = Color3.fromRGB(150, 150, 170)
}

-- Создание главного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaHubBeta"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = PlayerGui
    end
end)

if not screenGui.Parent then
    screenGui.Parent = PlayerGui
end

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 320)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
mainFrame.BackgroundColor3 = COLORS.background
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Верхняя панель (Шапка)
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = COLORS.panel
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

-- Скрытие острых углов шапки снизу
local fixCover = Instance.new("Frame")
fixCover.Size = UDim2.new(1, 0, 0, 10)
fixCover.Position = UDim2.new(0, 0, 1, -10)
fixCover.BackgroundColor3 = COLORS.panel
fixCover.BorderSizePixel = 0
fixCover.Parent = topBar

-- Название в шапке
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = PLACE_NAME .. " " .. VERSION
titleLabel.TextColor3 = COLORS.text
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Кнопка закрытия окна (крестик)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0.5, -15)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Область для контента
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 200)
contentFrame.ScrollBarThickness = 6
contentFrame.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 10)
uiList.Parent = contentFrame

-- Визуальная информационная карточка (вместо кнопок читов)
local infoCard = Instance.new("Frame")
infoCard.Size = UDim2.new(1, 0, 0, 50)
infoCard.BackgroundColor3 = COLORS.panel2
infoCard.BorderSizePixel = 0
infoCard.Parent = contentFrame

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 8)
cardCorner.Parent = infoCard

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -20, 1, 0)
infoText.Position = UDim2.new(0, 10, 0, 0)
infoText.BackgroundTransparency = 1
infoText.Font = Enum.Font.GothamSemibold
infoText.Text = "Визуальный интерфейс активен. Функции отключены."
infoText.TextColor3 = COLORS.muted
infoText.TextSize = 13
infoText.TextWrapped = true
infoText.Parent = infoCard

print("DeltaHub (только визуал) успешно загружен!")
