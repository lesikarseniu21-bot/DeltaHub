--[[
    DeltaHub v0.3 Beta Testing — исправленная сборка
    Полностью новая версия, написанная с нуля.
    Автор проекта: lesikarseniu21
    Тестер: sasha2274380
    Оформление: ChatGPT

    Важно:
    - Это локальный визуальный интерфейс для Roblox.
    - Скрипт не подключается к серверу и не отправляет данные пользователей.
    - Настоящий запуск в Delta Executor необходимо проверить отдельно.
    - Использование сторонних executor-инструментов может нарушать правила Roblox.
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local VERSION = "0.3 Beta Testing"
local GUI_NAME = "DeltaHub_v03"
local OWNER_NAME = "lesikarseniu21"
local TESTER_NAME = "sasha2274380"

local COLORS = {
    background = Color3.fromRGB(18, 14, 27),
    panel = Color3.fromRGB(29, 21, 43),
    panel2 = Color3.fromRGB(39, 28, 57),
    accent = Color3.fromRGB(157, 91, 235),
    accent2 = Color3.fromRGB(111, 64, 176),
    text = Color3.fromRGB(245, 238, 255),
    muted = Color3.fromRGB(171, 158, 190),
    success = Color3.fromRGB(111, 211, 151),
    danger = Color3.fromRGB(232, 104, 125),
}

local alive = true
local animationsEnabled = true
local currentLanguage = "RU"
local activeTab = "Главная"
local connections = {}
local activeTweens = {}
local ownedEffects = {}
local toggleStates = {
    Bloom = false,
    ColorCorrection = false,
    SunRays = false,
    Atmosphere = false,
    Brightness = false,
    Contrast = false,
    Saturation = false,
}

local function trackConnection(connection)
    table.insert(connections, connection)
    return connection
end

local function tween(object, duration, properties)
    if not alive or not animationsEnabled then
        for property, value in pairs(properties) do
            pcall(function()
                object[property] = value
            end)
        end
        return nil
    end

    local info = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local animation = TweenService:Create(object, info, properties)
    table.insert(activeTweens, animation)
    animation:Play()
    return animation
end

local function addCorner(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = object
    return corner
end

local function addStroke(object, color, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.accent
    stroke.Transparency = transparency or 0.45
    stroke.Thickness = 1
    stroke.Parent = object
    return stroke
end

local function makeLabel(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or COLORS.text
    label.TextSize = size or 14
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function makeButton(parent, text, size, position, callback, color)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.Text = text
    button.TextColor3 = COLORS.text
    button.TextSize = 13
    button.Font = Enum.Font.GothamSemibold
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color or COLORS.panel2
    button.Parent = parent
    addCorner(button, 10)
    addStroke(button, COLORS.accent, 0.72)

    trackConnection(button.Activated:Connect(function()
        if alive and callback then
            callback()
        end
    end))

    trackConnection(button.MouseEnter:Connect(function()
        if alive then
            tween(button, 0.12, {BackgroundColor3 = COLORS.accent2})
        end
    end))
    trackConnection(button.MouseLeave:Connect(function()
        if alive then
            tween(button, 0.12, {BackgroundColor3 = color or COLORS.panel2})
        end
    end))
    return button
end

local function getGuiParent()
    local ok, hiddenGui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return nil
    end)

    if ok and hiddenGui then
        return hiddenGui
    end

    local coreOk = pcall(function()
        local _ = CoreGui.Name
    end)
    if coreOk then
        return CoreGui
    end
    return PlayerGui
end

local existing = getGuiParent():FindFirstChild(GUI_NAME)
if existing then
    existing:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentOk = pcall(function()
    screenGui.Parent = getGuiParent()
end)
if not parentOk then
    screenGui.Parent = PlayerGui
end

local main = Instance.new("Frame")
main.Name = "MainWindow"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.52, 0)
main.Size = UDim2.fromOffset(620, 420)
main.BackgroundColor3 = COLORS.background
main.BorderSizePixel = 0
main.Parent = screenGui
addCorner(main, 18)
addStroke(main, COLORS.accent, 0.25)

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = main

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    local viewport = camera.ViewportSize
    local widthScale = (viewport.X - 24) / 620
    local heightScale = (viewport.Y - 32) / 420
    -- Не увеличиваем меню выше доступного пространства даже на очень маленьких экранах.
    scale.Scale = math.max(0.1, math.min(widthScale, heightScale, 1))
end

local cameraViewportConnection
local function bindCurrentCamera()
    if cameraViewportConnection then
        cameraViewportConnection:Disconnect()
        cameraViewportConnection = nil
    end
    local camera = workspace.CurrentCamera
    if camera then
        cameraViewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        trackConnection(cameraViewportConnection)
    end
    updateScale()
end

bindCurrentCamera()
trackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCurrentCamera))

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 58)
topbar.BackgroundColor3 = COLORS.panel
topbar.BorderSizePixel = 0
topbar.Parent = main
addCorner(topbar, 18)

local topbarCover = Instance.new("Frame")
topbarCover.Size = UDim2.new(1, 0, 0, 18)
topbarCover.Position = UDim2.new(0, 0, 1, -18)
topbarCover.BackgroundColor3 = COLORS.panel
topbarCover.BorderSizePixel = 0
topbarCover.Parent = topbar

local logo = makeLabel(topbar, "Δ", 27, COLORS.text, Enum.Font.GothamBlack)
logo.Position = UDim2.fromOffset(18, 7)
logo.Size = UDim2.fromOffset(34, 42)

local title = makeLabel(topbar, "DeltaHub", 19, COLORS.text, Enum.Font.GothamBold)
title.Position = UDim2.fromOffset(58, 7)
title.Size = UDim2.fromOffset(180, 25)

local subtitle = makeLabel(topbar, VERSION, 10, COLORS.muted)
subtitle.Position = UDim2.fromOffset(60, 31)
subtitle.Size = UDim2.fromOffset(160, 16)

local function makeWindowControl(text, x, color, callback)
    local button = makeButton(topbar, text, UDim2.fromOffset(30, 28), UDim2.new(1, x, 0, 15), callback, COLORS.panel2)
    button.TextSize = 16
    button.TextColor3 = color or COLORS.text
    return button
end

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.fromOffset(0, 58)
content.Size = UDim2.new(1, 0, 1, -58)
content.BackgroundTransparency = 1
content.Parent = main

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Position = UDim2.fromOffset(12, 12)
sidebar.Size = UDim2.new(0, 150, 1, -24)
sidebar.BackgroundColor3 = COLORS.panel
sidebar.BorderSizePixel = 0
sidebar.Parent = content
addCorner(sidebar, 14)

local navTitle = makeLabel(sidebar, "МЕНЮ", 10, COLORS.muted, Enum.Font.GothamBold)
navTitle.Position = UDim2.fromOffset(15, 12)
navTitle.Size = UDim2.new(1, -25, 0, 22)

local navHolder = Instance.new("ScrollingFrame")
navHolder.Name = "NavigationScroll"
navHolder.Position = UDim2.fromOffset(8, 42)
navHolder.Size = UDim2.new(1, -16, 1, -54)
navHolder.BackgroundTransparency = 1
navHolder.BorderSizePixel = 0
navHolder.ScrollBarThickness = 3
navHolder.ScrollBarImageColor3 = COLORS.accent
navHolder.ScrollingDirection = Enum.ScrollingDirection.Y
navHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
navHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
navHolder.ClipsDescendants = true
navHolder.Parent = sidebar

local navLayout = Instance.new("UIListLayout")
navLayout.Padding = UDim.new(0, 7)
navLayout.SortOrder = Enum.SortOrder.LayoutOrder
navLayout.Parent = navHolder

local page = Instance.new("ScrollingFrame")
page.Name = "Page"
page.Position = UDim2.fromOffset(174, 12)
page.Size = UDim2.new(1, -186, 1, -24)
page.BackgroundColor3 = COLORS.panel
page.BorderSizePixel = 0
page.ScrollBarThickness = 3
page.ScrollBarImageColor3 = COLORS.accent
page.CanvasSize = UDim2.new(0, 0, 0, 0)
page.AutomaticCanvasSize = Enum.AutomaticSize.Y
page.Parent = content
addCorner(page, 14)

local pagePadding = Instance.new("UIPadding")
pagePadding.PaddingTop = UDim.new(0, 16)
pagePadding.PaddingBottom = UDim.new(0, 16)
pagePadding.PaddingLeft = UDim.new(0, 16)
pagePadding.PaddingRight = UDim.new(0, 16)
pagePadding.Parent = page

local pageLayout = Instance.new("UIListLayout")
pageLayout.Padding = UDim.new(0, 10)
pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
pageLayout.Parent = page

local navButtons = {}
local renderPage
local tabs

local function clearPage()
    for _, child in ipairs(page:GetChildren()) do
        if child ~= pagePadding and child ~= pageLayout then
            child:Destroy()
        end
    end
end

local function addPageTitle(text, description)
    local heading = makeLabel(page, text, 21, COLORS.text, Enum.Font.GothamBold)
    heading.Size = UDim2.new(1, -4, 0, 30)

    if description then
        local desc = makeLabel(page, description, 11, COLORS.muted)
        desc.Size = UDim2.new(1, -4, 0, 28)
        desc.TextWrapped = true
    end
end

local function addInfoCard(titleText, bodyText)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, 72)
    card.BackgroundColor3 = COLORS.panel2
    card.BorderSizePixel = 0
    card.Parent = page
    addCorner(card, 11)

    local heading = makeLabel(card, titleText, 13, COLORS.text, Enum.Font.GothamBold)
    heading.Position = UDim2.fromOffset(12, 8)
    heading.Size = UDim2.new(1, -24, 0, 22)

    local body = makeLabel(card, bodyText, 11, COLORS.muted)
    body.Position = UDim2.fromOffset(12, 31)
    body.Size = UDim2.new(1, -24, 0, 30)
    body.TextWrapped = true
    return card
end

local function addToggle(titleText, description, key, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 62)
    row.BackgroundColor3 = COLORS.panel2
    row.BorderSizePixel = 0
    row.Parent = page
    addCorner(row, 10)

    local label = makeLabel(row, titleText, 12, COLORS.text, Enum.Font.GothamSemibold)
    label.Position = UDim2.fromOffset(11, 7)
    label.Size = UDim2.new(1, -100, 0, 22)

    local desc = makeLabel(row, description, 10, COLORS.muted)
    desc.Position = UDim2.fromOffset(11, 30)
    desc.Size = UDim2.new(1, -100, 0, 20)
    desc.TextTruncate = Enum.TextTruncate.AtEnd

    local button = makeButton(row, toggleStates[key] and "ВКЛ" or "ВЫКЛ",
        UDim2.fromOffset(62, 28), UDim2.new(1, -73, 0.5, -14), nil,
        toggleStates[key] and COLORS.accent2 or COLORS.background)
    button.TextSize = 10
    button.TextColor3 = toggleStates[key] and COLORS.success or COLORS.muted

    trackConnection(button.Activated:Connect(function()
        if not alive then return end
        toggleStates[key] = not toggleStates[key]
        button.Text = toggleStates[key] and "ВКЛ" or "ВЫКЛ"
        button.TextColor3 = toggleStates[key] and COLORS.success or COLORS.muted
        tween(button, 0.12, {
            BackgroundColor3 = toggleStates[key] and COLORS.accent2 or COLORS.background
        })
        if callback then
            callback(toggleStates[key])
        end
    end))
end

local function getOwnedEffect(className, effectName)
    local effect = ownedEffects[effectName]
    if effect then
        return effect
    end

    effect = Instance.new(className)
    effect.Name = "DeltaHub_" .. effectName
    -- Atmosphere выключается отсоединением от Lighting, остальные эффекты — через Enabled.
    if className ~= "Atmosphere" then
        pcall(function()
            effect.Enabled = false
        end)
        effect.Parent = Lighting
    end
    ownedEffects[effectName] = effect
    return effect
end

local function setEffect(key, enabled)
    if key == "Bloom" then
        local effect = getOwnedEffect("BloomEffect", "Bloom")
        effect.Intensity = 0.35
        effect.Size = 24
        effect.Threshold = 1
        effect.Enabled = enabled
    elseif key == "ColorCorrection" or key == "Brightness" or key == "Contrast" or key == "Saturation" then
        local effect = getOwnedEffect("ColorCorrectionEffect", "ColorCorrection")
        effect.Enabled = toggleStates.ColorCorrection or toggleStates.Brightness or toggleStates.Contrast or toggleStates.Saturation
        effect.Brightness = toggleStates.Brightness and 0.08 or 0
        effect.Contrast = toggleStates.Contrast and 0.12 or 0
        effect.Saturation = toggleStates.Saturation and 0.15 or 0
    elseif key == "SunRays" then
        local effect = getOwnedEffect("SunRaysEffect", "SunRays")
        effect.Intensity = 0.08
        effect.Spread = 0.8
        effect.Enabled = enabled
    elseif key == "Atmosphere" then
        local effect = getOwnedEffect("Atmosphere", "Atmosphere")
        effect.Density = 0.25
        effect.Offset = 0.1
        effect.Color = Color3.fromRGB(199, 180, 255)
        effect.Decay = Color3.fromRGB(92, 75, 130)
        effect.Glare = 0.08
        effect.Haze = 0.7
        -- Atmosphere включается добавлением в Lighting и выключается удалением из Lighting.
        effect.Parent = enabled and Lighting or nil
    end
end

local function setLanguage()
    if currentLanguage == "RU" then
        currentLanguage = "EN"
    else
        currentLanguage = "RU"
    end
    for _, tab in ipairs(tabs or {}) do
        local button = navButtons[tab.ru]
        if button then
            button.Text = "   " .. (currentLanguage == "RU" and tab.ru or tab.en)
        end
    end
    renderPage(activeTab)
end

local function makeFloatingButton(text, size, position, callback)
    local button = Instance.new("TextButton")
    button.Name = "DeltaHubReopen"
    button.AnchorPoint = Vector2.new(0.5, 0)
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = COLORS.panel
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.text
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = screenGui
    addCorner(button, 12)
    addStroke(button, COLORS.accent, 0.2)
    trackConnection(button.Activated:Connect(function()
        if alive and callback then callback() end
    end))
    return button
end

local reopenButton
local function showMain()
    if not alive then return end
    if reopenButton then
        reopenButton:Destroy()
        reopenButton = nil
    end
    main.Visible = true
    main.Size = UDim2.fromOffset(600, 405)
    tween(main, 0.16, {Size = UDim2.fromOffset(620, 420)})
end

local function showReopenButton(mode)
    if reopenButton then
        reopenButton:Destroy()
        reopenButton = nil
    end
    main.Visible = false

    if mode == "minimize" then
        reopenButton = makeFloatingButton("Δ", UDim2.fromOffset(48, 48), UDim2.new(0.5, 0, 0, 12), showMain)
        reopenButton.TextSize = 23
    else
        reopenButton = makeFloatingButton("Δ  DeltaHub", UDim2.fromOffset(132, 36), UDim2.new(0.5, 0, 0, 12), showMain)
        reopenButton.TextSize = 12
    end
end

local function unload()
    if not alive then return end
    alive = false

    for _, animation in ipairs(activeTweens) do
        pcall(function() animation:Cancel() end)
    end
    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end
    for _, effect in pairs(ownedEffects) do
        pcall(function() effect:Destroy() end)
    end
    ownedEffects = {}

    pcall(function() screenGui:Destroy() end)
end

makeWindowControl("−", -112, COLORS.text, function()
    showReopenButton("minimize")
end)
makeWindowControl("×", -74, COLORS.text, function()
    showReopenButton("hide")
end)
makeWindowControl("⏻", -36, COLORS.danger, unload)

-- Перетаскивание окна мышью и касанием.
local dragging = false
local dragStart
local startPosition

trackConnection(topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end))

trackConnection(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end))

trackConnection(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

local function renderHome()
    if currentLanguage == "RU" then
        addPageTitle("Добро пожаловать в DeltaHub", "Лёгкий визуальный интерфейс. Выбирай нужные настройки.")
        addInfoCard("Текущая версия", "DeltaHub " .. VERSION)
        addInfoCard("Производительность", "Интерфейс использует лёгкие анимации и не запускает постоянные тяжёлые циклы.")
        addInfoCard("Управление", "− свернуть · × скрыть · ⏻ полностью выключить")
    else
        addPageTitle("Welcome to DeltaHub", "A lightweight visual interface. Choose the settings you need.")
        addInfoCard("Current version", "DeltaHub " .. VERSION)
        addInfoCard("Performance", "The interface uses lightweight animations and avoids heavy permanent loops.")
        addInfoCard("Controls", "− minimize · × hide · ⏻ fully unload")
    end
end

local function renderVisuals()
    if currentLanguage == "RU" then
        addPageTitle("Визуалы", "Эффекты создаются отдельно и удаляются при выключении скрипта.")
        addToggle("Bloom", "Мягкое свечение ярких объектов", "Bloom", setEffect)
        addToggle("Color Correction", "Общая цветовая коррекция", "ColorCorrection", setEffect)
        addToggle("Sun Rays", "Лёгкие солнечные лучи", "SunRays", setEffect)
        addToggle("Atmosphere", "Атмосферный эффект", "Atmosphere", setEffect)
        addToggle("Brightness", "Небольшое повышение яркости", "Brightness", setEffect)
        addToggle("Contrast", "Небольшое повышение контраста", "Contrast", setEffect)
        addToggle("Saturation", "Небольшое усиление насыщенности", "Saturation", setEffect)
    else
        addPageTitle("Visuals", "Effects are created separately and removed when the script unloads.")
        addToggle("Bloom", "Soft glow for bright objects", "Bloom", setEffect)
        addToggle("Color Correction", "Overall color correction", "ColorCorrection", setEffect)
        addToggle("Sun Rays", "Light sun rays", "SunRays", setEffect)
        addToggle("Atmosphere", "Atmospheric effect", "Atmosphere", setEffect)
        addToggle("Brightness", "Slight brightness boost", "Brightness", setEffect)
        addToggle("Contrast", "Slight contrast boost", "Contrast", setEffect)
        addToggle("Saturation", "Slight saturation boost", "Saturation", setEffect)
    end
end

local function renderSettings()
    if currentLanguage == "RU" then
        addPageTitle("Настройки", "Персонализация интерфейса DeltaHub.")
        addInfoCard("Анимации", "Лёгкие анимации интерфейса можно отключить.")
        local animationButton = makeButton(page, animationsEnabled and "Анимации: ВКЛ" or "Анимации: ВЫКЛ",
            UDim2.new(1, -4, 0, 38), UDim2.new(), function()
                animationsEnabled = not animationsEnabled
                renderPage("Настройки")
            end)
        animationButton.LayoutOrder = 100
        makeButton(page, "Сбросить положение меню", UDim2.new(1, -4, 0, 38), UDim2.new(), function()
            main.Position = UDim2.new(0.5, 0, 0.52, 0)
        end)
        makeButton(page, "Язык: " .. currentLanguage .. " (нажми для смены)", UDim2.new(1, -4, 0, 38), UDim2.new(), setLanguage)
        addInfoCard("Сохранение настроек", "Функция сохранения добавлена в план будущих улучшений; в этой сборке пока не реализована.")
    else
        addPageTitle("Settings", "Personalize the DeltaHub interface.")
        addInfoCard("Animations", "Light interface animations can be disabled.")
        local animationButton = makeButton(page, animationsEnabled and "Animations: ON" or "Animations: OFF",
            UDim2.new(1, -4, 0, 38), UDim2.new(), function()
                animationsEnabled = not animationsEnabled
                renderPage("Settings")
            end)
        animationButton.LayoutOrder = 100
        makeButton(page, "Reset menu position", UDim2.new(1, -4, 0, 38), UDim2.new(), function()
            main.Position = UDim2.new(0.5, 0, 0.52, 0)
        end)
        makeButton(page, "Language: " .. currentLanguage .. " (tap to switch)", UDim2.new(1, -4, 0, 38), UDim2.new(), setLanguage)
        addInfoCard("Settings save", "Settings persistence is on the roadmap; it is not implemented in this build.")
    end
end

local function renderAbout()
    if currentLanguage == "RU" then
        addPageTitle("О программе", "Информация о проекте.")
        addInfoCard("DeltaHub", "Версия " .. VERSION .. " — новая разработка с нуля.")
        addInfoCard("Автор", OWNER_NAME)
        addInfoCard("Тестер", TESTER_NAME)
        addInfoCard("Оформление", "ChatGPT")
        addInfoCard("Важно", "Это сторонний локальный скрипт. Использование executor может нарушать правила Roblox и привести к ограничениям аккаунта.")
    else
        addPageTitle("About", "Project information.")
        addInfoCard("DeltaHub", "Version " .. VERSION .. " — a new build written from scratch.")
        addInfoCard("Author", OWNER_NAME)
        addInfoCard("Tester", TESTER_NAME)
        addInfoCard("Design", "ChatGPT")
        addInfoCard("Notice", "This is a third-party local script. Using an executor may violate Roblox rules and can result in account restrictions.")
    end
end


local function renderPremium()
    if currentLanguage == "RU" then
        addPageTitle("Premium", "Предварительный интерфейс подписки DeltaHub.")
        addInfoCard("Статус", "Текущий статус: FREE. Проверка подписки пока не подключена.")
        addInfoCard("Тарифы — план", "1 месяц · 3 месяца · навсегда. Покупка и выдача пока не работают.")
        addInfoCard("Премиум-возможности", "Дополнительные визуальные эффекты и будущие функции Premium.")
        addInfoCard("Защита", "Настоящий Premium должен проверяться сервером. Локальный переключатель не выдаёт подписку.")
    else
        addPageTitle("Premium", "Preview interface for DeltaHub membership.")
        addInfoCard("Status", "Current status: FREE. Membership verification is not connected.")
        addInfoCard("Planned plans", "1 month · 3 months · lifetime. Purchase and granting are not active.")
        addInfoCard("Premium features", "Additional visual effects and future Premium features.")
        addInfoCard("Security", "Real Premium status must be verified server-side. A local toggle cannot grant membership.")
    end
end

local function renderAdmin()
    if LocalPlayer.Name ~= OWNER_NAME then
        if currentLanguage == "RU" then
            addPageTitle("Админ-панель", "Доступ не предоставлен.")
            addInfoCard("Только владелец", "Эта вкладка предназначена для владельца проекта.")
        else
            addPageTitle("Admin panel", "Access not granted.")
            addInfoCard("Owner only", "This tab is intended for the project owner.")
        end
        return
    end

    if currentLanguage == "RU" then
        addPageTitle("Админ-панель", "Макет панели владельца. Серверные действия отключены.")
        addInfoCard("Выдача Premium", "Планируется выдача по Roblox UserId или имени. Сейчас функция не подключена.")
        addInfoCard("Управление Premium", "Продление и отзыв подписки появятся после подключения защищённого сервера.")
        addInfoCard("Безопасность", "Проверка имени на клиенте — только визуальное ограничение, не защита. Нельзя хранить секретные ключи в этом файле.")
    else
        addPageTitle("Admin panel", "Owner panel mockup. Server actions are disabled.")
        addInfoCard("Grant Premium", "Granting by Roblox UserId or username is planned. Not connected yet.")
        addInfoCard("Manage Premium", "Renewal and revocation require a secure backend.")
        addInfoCard("Security", "A client-side username check is only a UI restriction, not real security. Never put secret keys in this file.")
    end
end

local function renderPlayerCounter()
    if currentLanguage == "RU" then
        addPageTitle("Player Counter", "Планируемый счётчик пользователей DeltaHub v0.2.")
        addInfoCard("Активные пользователи v0.2", "—")
        addInfoCard("Состояние", "Серверная регистрация ещё не подключена, поэтому реальное количество пока неизвестно.")
        addInfoCard("Как будет работать", "Счётчик будет получать агрегированное число от серверной системы. Имена и UserId в панели показываться не будут.")
    else
        addPageTitle("Player Counter", "Planned counter for DeltaHub v0.2 users.")
        addInfoCard("Active v0.2 users", "—")
        addInfoCard("Status", "Server registration is not connected, so the real count is currently unavailable.")
        addInfoCard("How it will work", "The counter will receive an aggregate number from the backend. Names and UserIds will not be displayed.")
    end
end

local function renderHelp()
    if currentLanguage == "RU" then
        addPageTitle("Помощь", "Краткое руководство по управлению.")
        addInfoCard("Свернуть", "Кнопка − скрывает окно и оставляет маленькую кнопку Δ.")
        addInfoCard("Скрыть", "Кнопка × скрывает окно и оставляет компактную кнопку Δ DeltaHub сверху.")
        addInfoCard("Выключить", "Кнопка ⏻ выгружает интерфейс и удаляет созданные DeltaHub эффекты.")
        addInfoCard("Повторное открытие", "Нажми на плавающую кнопку DeltaHub, чтобы вернуть меню.")
    else
        addPageTitle("Help", "Quick guide to the controls.")
        addInfoCard("Minimize", "The − button hides the window and leaves a small Δ button.")
        addInfoCard("Hide", "The × button hides the window and leaves a compact Δ DeltaHub button at the top.")
        addInfoCard("Unload", "The ⏻ button unloads the interface and removes DeltaHub effects.")
        addInfoCard("Reopen", "Tap the floating DeltaHub button to restore the menu.")
    end
end

renderPage = function(tabName)
    if not alive then return end
    activeTab = tabName
    clearPage()

    if tabName == "Главная" or tabName == "Home" then
        renderHome()
    elseif tabName == "Визуалы" or tabName == "Visuals" then
        renderVisuals()
    elseif tabName == "Настройки" or tabName == "Settings" then
        renderSettings()
    elseif tabName == "О программе" or tabName == "About" then
        renderAbout()
    elseif tabName == "Premium" then
        renderPremium()
    elseif tabName == "Админ-панель" or tabName == "Admin" then
        renderAdmin()
    elseif tabName == "Счётчик" or tabName == "Counter" then
        renderPlayerCounter()
    else
        renderHelp()
    end

    for _, tab in ipairs(tabs or {}) do
        local button = navButtons[tab.ru]
        if button then
            local selected = (tab.ru == activeTab) or (tab.en == activeTab)
            button.BackgroundColor3 = selected and COLORS.accent2 or COLORS.panel2
            button.TextColor3 = selected and COLORS.text or COLORS.muted
        end
    end
end

tabs = {
    {ru = "Главная", en = "Home"},
    {ru = "Визуалы", en = "Visuals"},
    {ru = "Настройки", en = "Settings"},
    {ru = "О программе", en = "About"},
    {ru = "Помощь", en = "Help"},
    {ru = "Premium", en = "Premium"},
    {ru = "Админ-панель", en = "Admin"},
    {ru = "Счётчик", en = "Counter"},
}

for index, tab in ipairs(tabs) do
    local tabName = tab.ru
    local button = makeButton(navHolder, currentLanguage == "RU" and tab.ru or tab.en,
        UDim2.new(1, 0, 0, 38), UDim2.new(), function()
            renderPage(currentLanguage == "RU" and tab.ru or tab.en)
        end)
    button.LayoutOrder = index
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 11
    button.Text = "   " .. button.Text
    navButtons[tabName] = button
    navButtons[tab.en] = button
end

renderPage("Главная")

-- Небольшое появление меню без тяжёлых циклов и частиц.
if animationsEnabled then
    main.Size = UDim2.fromOffset(590, 400)
    tween(main, 0.22, {Size = UDim2.fromOffset(620, 420)})
end

print("DeltaHub " .. VERSION .. " loaded.")
