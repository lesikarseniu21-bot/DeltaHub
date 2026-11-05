-- DELTA HUB v1.1
-- Creator: ChatGPT | Author: lesikarseniu21
-- Client-side visual GUI. Feature availability depends on the Roblox experience.

if _G.DeltaHubV11Loaded then warn("[DELTA HUB] Already running"); return end
_G.DeltaHubV11Loaded = true

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("DeltaHubV11")
if old then old:Destroy() end

local C = {
    bg = Color3.fromRGB(20,21,29),
    panel = Color3.fromRGB(30,31,43),
    accent = Color3.fromRGB(112,86,255),
    text = Color3.fromRGB(245,245,250),
    muted = Color3.fromRGB(165,168,185),
    off = Color3.fromRGB(65,66,82)
}
local lang = "RU"
local words = {
 RU = {subtitle="Визуальные настройки", visual="ВИЗУАЛЬНЫЕ ФУНКЦИИ",
 esp="ESP игроков", bright="Полная яркость", bloom="Bloom эффект",
 color="Цветокоррекция", settings="НАСТРОЙКИ", sat="Насыщенность",
 contrast="Контраст", language="Язык интерфейса", on="ВКЛ", off="ВЫКЛ",
 hint="RightShift — показать/скрыть меню", footer="Creator: ChatGPT | Author: lesikarseniu21"},
 EN = {subtitle="Visual settings", visual="VISUAL FEATURES",
 esp="Player ESP", bright="Fullbright", bloom="Bloom effect",
 color="Color correction", settings="SETTINGS", sat="Saturation",
 contrast="Contrast", language="Interface language", on="ON", off="OFF",
 hint="RightShift — show/hide menu", footer="Creator: ChatGPT | Author: lesikarseniu21"}
}
local function T(k) return words[lang][k] or k end
local function new(class, props, parent)
    local x = Instance.new(class)
    for k,v in pairs(props or {}) do x[k] = v end
    x.Parent = parent
    return x
end
local function round(x, n)
    new("UICorner",{CornerRadius=UDim.new(0,n or 9)},x)
end
local function tw(x, props)
    TweenService:Create(x,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
end

local saved = {
 Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime,
 GlobalShadows=Lighting.GlobalShadows, Ambient=Lighting.Ambient,
 OutdoorAmbient=Lighting.OutdoorAmbient, ExposureCompensation=Lighting.ExposureCompensation
}
local function restoreLighting()
 for k,v in pairs(saved) do pcall(function() Lighting[k]=v end) end
end

local bloom = Lighting:FindFirstChild("DeltaHub_Bloom")
if not bloom or not bloom:IsA("BloomEffect") then
 if bloom then bloom:Destroy() end
 bloom = Instance.new("BloomEffect"); bloom.Name="DeltaHub_Bloom"; bloom.Parent=Lighting
end
bloom.Intensity=.35; bloom.Size=24; bloom.Threshold=1; bloom.Enabled=false

local cc = Lighting:FindFirstChild("DeltaHub_ColorCorrection")
if not cc or not cc:IsA("ColorCorrectionEffect") then
 if cc then cc:Destroy() end
 cc=Instance.new("ColorCorrectionEffect"); cc.Name="DeltaHub_ColorCorrection"; cc.Parent=Lighting
end
cc.Enabled=false
local saturation, contrast = 0, 0
local function updateColor()
 cc.Saturation=saturation/100
 cc.Contrast=contrast/100
end

local gui=new("ScreenGui",{Name="DeltaHubV11",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},playerGui)
local main=new("Frame",{Name="Main",Size=UDim2.fromOffset(360,480),Position=UDim2.new(.5,-180,.5,-240),BackgroundColor3=C.bg,BorderSizePixel=0},gui)
round(main,15)
new("UIStroke",{Color=C.accent,Transparency=.2,Thickness=1},main)

local header=new("Frame",{Size=UDim2.new(1,0,0,72),BackgroundColor3=C.panel,BorderSizePixel=0},main)
round(header,15)
new("Frame",{Position=UDim2.new(0,0,1,-14),Size=UDim2.new(1,0,0,14),BackgroundColor3=C.panel,BorderSizePixel=0},header)
local title=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(16,8),Size=UDim2.new(1,-65,0,30),Font=Enum.Font.GothamBold,Text="DELTA HUB v1.1",TextColor3=C.text,TextSize=21,TextXAlignment=Enum.TextXAlignment.Left},header)
local subtitle=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(17,39),Size=UDim2.new(1,-30,0,20),Font=Enum.Font.Gotham,Text=T("subtitle"),TextColor3=C.muted,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},header)
local close=new("TextButton",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-42,0,13),BackgroundColor3=C.off,Text="—",TextColor3=C.text,Font=Enum.Font.GothamBold,TextSize=17,AutoButtonColor=false},header)
round(close,8)

local content=new("ScrollingFrame",{Position=UDim2.fromOffset(13,83),Size=UDim2.new(1,-26,1,-139),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.accent,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new()},main)
new("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},content)
local controls={}
local function section(key)
 local l=new("TextLabel",{Size=UDim2.new(1,-3,0,23),BackgroundTransparency=1,Font=Enum.Font.GothamBold,Text=T(key),TextColor3=C.accent,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},content)
 table.insert(controls,{label=l,key=key})
end
local function toggle(key,callback)
 local row=new("Frame",{Size=UDim2.new(1,-3,0,42),BackgroundColor3=C.panel,BorderSizePixel=0},content); round(row,9)
 local label=new("TextLabel",{Name="Caption",BackgroundTransparency=1,Position=UDim2.fromOffset(11,0),Size=UDim2.new(1,-95,1,0),Font=Enum.Font.GothamMedium,Text=T(key),TextColor3=C.text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row)
 local button=new("TextButton",{Size=UDim2.fromOffset(62,26),Position=UDim2.new(1,-72,.5,-13),BackgroundColor3=C.off,Text=T("off"),TextColor3=C.text,Font=Enum.Font.GothamBold,TextSize=10,AutoButtonColor=false},row); round(button,8)
 local state=false
 local item={key=key,label=label,button=button}
 function item:Set(value)
  state=value
  tw(button,{BackgroundColor3=state and C.accent or C.off})
  button.Text=T(state and "on" or "off")
  local ok,err=pcall(callback,state)
  if not ok then warn("[DELTA HUB] "..tostring(err)) end
 end
 function item:Refresh()
  label.Text=T(key); button.Text=T(state and "on" or "off")
 end
 button.MouseButton1Click:Connect(function() item:Set(not state) end)
 table.insert(controls,item)
 return item
end
local function slider(key,minV,maxV,initial,callback)
 local row=new("Frame",{Size=UDim2.new(1,-3,0,57),BackgroundColor3=C.panel,BorderSizePixel=0},content); round(row,9)
 local label=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(11,4),Size=UDim2.new(1,-70,0,20),Font=Enum.Font.GothamMedium,Text=T(key),TextColor3=C.text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row)
 local number=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(1,-55,0,4),Size=UDim2.fromOffset(43,20),Font=Enum.Font.GothamBold,Text=tostring(initial),TextColor3=C.accent,TextSize=11},row)
 local bar=new("Frame",{Position=UDim2.fromOffset(11,34),Size=UDim2.new(1,-22,0,7),BackgroundColor3=C.off,BorderSizePixel=0},row); round(bar,5)
 local fill=new("Frame",{Size=UDim2.new((initial-minV)/(maxV-minV),0,1,0),BackgroundColor3=C.accent,BorderSizePixel=0},bar); round(fill,5)
 local knob=new("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(fill.Size.X.Scale,0,.5,0),Size=UDim2.fromOffset(14,14),BackgroundColor3=C.text},bar); round(knob,10)
 local dragging=false
 local function setFromX(x)
  local a=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
  local v=math.floor(minV+(maxV-minV)*a+.5)
  fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,0,.5,0); number.Text=tostring(v)
  callback(v)
 end
 local function begin(input)
  if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true; setFromX(input.Position.X) end
 end
 bar.InputBegan:Connect(begin); knob.InputBegan:Connect(begin)
 UIS.InputChanged:Connect(function(input)
  if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
   setFromX(input.Position.X)
  end
 end)
 UIS.InputEnded:Connect(function(input)
  if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
 end)
 local item={key=key,label=label}
 function item:Refresh() label.Text=T(key) end
 table.insert(controls,item)
 return item
end

local espEnabled=false
local highlights={}
local function removeESP()
 for plr,h in pairs(highlights) do if h then h:Destroy() end; highlights[plr]=nil end
end
local function addESP(plr)
 if not espEnabled or plr==player or not plr.Character then return end
 if highlights[plr] then highlights[plr]:Destroy() end
 local h=Instance.new("Highlight")
 h.Name="DeltaHub_ESP"; h.Adornee=plr.Character
 h.FillColor=C.accent; h.OutlineColor=Color3.new(1,1,1)
 h.FillTransparency=.65; h.OutlineTransparency=0
 h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=plr.Character
 highlights[plr]=h
end
local function refreshESP()
 removeESP()
 if espEnabled then for _,p in ipairs(Players:GetPlayers()) do addESP(p) end end
end

section("visual")
local espToggle=toggle("esp",function(on) espEnabled=on; refreshESP() end)
local brightToggle=toggle("bright",function(on)
 if on then
  Lighting.Brightness=3; Lighting.ClockTime=14; Lighting.GlobalShadows=false
  Lighting.Ambient=Color3.fromRGB(180,180,180); Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180)
  Lighting.ExposureCompensation=.5
 else restoreLighting() end
end)
local bloomToggle=toggle("bloom",function(on) bloom.Enabled=on end)
local colorToggle=toggle("color",function(on) cc.Enabled=on end)

section("settings")
slider("sat",-100,100,0,function(v) saturation=v; updateColor() end)
slider("contrast",-100,100,0,function(v) contrast=v; updateColor() end)

local langRow=new("Frame",{Size=UDim2.new(1,-3,0,42),BackgroundColor3=C.panel,BorderSizePixel=0},content); round(langRow,9)
local langLabel=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(11,0),Size=UDim2.new(1,-115,1,0),Font=Enum.Font.GothamMedium,Text=T("language"),TextColor3=C.text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},langRow)
local langButton=new("TextButton",{Size=UDim2.fromOffset(78,26),Position=UDim2.new(1,-88,.5,-13),BackgroundColor3=C.accent,Text=lang,TextColor3=C.text,Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=false},langRow); round(langButton,8)

local footer=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,8,1,-49),Size=UDim2.new(1,-16,0,17),Font=Enum.Font.Gotham,Text=T("footer"),TextColor3=C.muted,TextSize=9},main)
local hint=new("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,8,1,-29),Size=UDim2.new(1,-16,0,15),Font=Enum.Font.Gotham,Text=T("hint"),TextColor3=C.muted,TextSize=9},main)

local floating=new("TextButton",{Name="DHButton",Size=UDim2.fromOffset(48,48),Position=UDim2.new(0,18,.5,-24),BackgroundColor3=C.accent,Text="DH",TextColor3=C.text,Font=Enum.Font.GothamBold,TextSize=15,Visible=false,AutoButtonColor=false},gui); round(floating,13)
new("UIStroke",{Color=Color3.new(1,1,1),Transparency=.5},floating)

local function setLanguage(value)
 lang=value
 subtitle.Text=T("subtitle"); footer.Text=T("footer"); hint.Text=T("hint")
 langLabel.Text=T("language"); langButton.Text=lang
 for _,item in ipairs(controls) do
  if item.Refresh then item:Refresh() end
 end
end
langButton.MouseButton1Click:Connect(function() setLanguage(lang=="RU" and "EN" or "RU") end)

local visible=true
local function hide()
 visible=false
 tw(main,{Position=UDim2.new(.5,-180,1,20)})
 task.delay(.2,function() if not visible then main.Visible=false; floating.Visible=true end end)
end
local function show()
 visible=true; floating.Visible=false; main.Visible=true
 main.Position=UDim2.new(.5,-180,1,20)
 tw(main,{Position=UDim2.new(.5,-180,.5,-240)})
end
close.MouseButton1Click:Connect(hide)
floating.MouseButton1Click:Connect(show)
UIS.InputBegan:Connect(function(input,processed)
 if not processed and input.KeyCode==Enum.KeyCode.RightShift then
  if visible then hide() else show() end
 end
end)

-- Drag panel by its header; supports mouse and touch.
local dragging=false
local dragStart,startPos
header.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
  dragging=true; dragStart=input.Position; startPos=main.Position
 end
end)
UIS.InputChanged:Connect(function(input)
 if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
  local d=input.Position-dragStart
  main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
 end
end)
UIS.InputEnded:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)

local function watchPlayer(p)
 if p==player then return end
 p.CharacterAdded:Connect(function()
  task.wait(.5)
  if espEnabled then addESP(p) end
 end)
 if p.Character and espEnabled then addESP(p) end
end
Players.PlayerAdded:Connect(watchPlayer)
for _,p in ipairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerRemoving:Connect(function(p)
 if highlights[p] then highlights[p]:Destroy(); highlights[p]=nil end
end)

gui.Destroying:Connect(function()
 removeESP()
 bloom.Enabled=false; cc.Enabled=false
 restoreLighting()
 _G.DeltaHubV11Loaded=nil
end)

print("[DELTA HUB] v1.1 loaded")
