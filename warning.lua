local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")

local LIME       = Color3.fromRGB(132, 204, 22)
local LIME_DIM   = Color3.fromRGB(60, 90, 15)
local BG         = Color3.fromRGB(18, 18, 18)
local BG_HEADER  = Color3.fromRGB(12, 12, 12)
local STROKE     = Color3.fromRGB(40, 40, 40)
local TEXT       = Color3.fromRGB(225, 225, 225)
local TEXT_DIM   = Color3.fromRGB(110, 110, 110)

local LOCK_TIME = 10

for _, v in ipairs((gethui and gethui() or CoreGui):GetChildren()) do
    if v.Name == "gr1ss_warning" then v:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = "gr1ss_warning"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = (gethui and gethui()) or CoreGui

local backdrop = Instance.new("Frame")
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
backdrop.BackgroundTransparency = 1
backdrop.BorderSizePixel = 0
backdrop.Parent = gui
TweenService:Create(backdrop, TweenInfo.new(0.2), { BackgroundTransparency = 0.55 }):Play()

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(360, 200)
panel.Position = UDim2.new(0.5, -180, 0.5, -100)
panel.BackgroundColor3 = BG
panel.BorderSizePixel = 0
panel.Parent = backdrop

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 4)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = STROKE
panelStroke.Thickness = 1
panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
panelStroke.Parent = panel

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = BG_HEADER
header.BorderSizePixel = 0
header.Parent = panel

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 4)
headerCorner.Parent = header

local headerMask = Instance.new("Frame")
headerMask.Size = UDim2.new(1, 0, 0, 8)
headerMask.Position = UDim2.new(0, 0, 1, -8)
headerMask.BackgroundColor3 = BG_HEADER
headerMask.BorderSizePixel = 0
headerMask.Parent = header

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, 0, 0, 1)
sep.Position = UDim2.new(0, 0, 1, -1)
sep.BackgroundColor3 = STROKE
sep.BorderSizePixel = 0
sep.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "warning"
title.TextColor3 = LIME
title.Font = Enum.Font.Code
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -24, 0, 100)
body.Position = UDim2.fromOffset(12, 44)
body.BackgroundTransparency = 1
body.Text = "Hello, we are sorry if you only see the character head.\n\nTo fix this, go to a tab named \"Misc\" and change \"Camera FOV\" to any value and it's fixed."
body.TextColor3 = TEXT
body.Font = Enum.Font.Code
body.TextSize = 12
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextWrapped = true
body.LineHeight = 1.2
body.Parent = panel

local footSep = Instance.new("Frame")
footSep.Size = UDim2.new(1, -24, 0, 1)
footSep.Position = UDim2.new(0, 12, 1, -52)
footSep.BackgroundColor3 = STROKE
footSep.BorderSizePixel = 0
footSep.Parent = panel

local okBtn = Instance.new("TextButton")
okBtn.Size = UDim2.fromOffset(90, 26)
okBtn.Position = UDim2.new(1, -102, 1, -42)
okBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
okBtn.BorderSizePixel = 0
okBtn.Text = "ok (" .. LOCK_TIME .. ")"
okBtn.TextColor3 = TEXT_DIM
okBtn.Font = Enum.Font.Code
okBtn.TextSize = 12
okBtn.AutoButtonColor = false
okBtn.Active = false
okBtn.Parent = panel

local okCorner = Instance.new("UICorner")
okCorner.CornerRadius = UDim.new(0, 4)
okCorner.Parent = okBtn

local okStroke = Instance.new("UIStroke")
okStroke.Color = STROKE
okStroke.Thickness = 1
okStroke.Parent = okBtn

local unlocked = false

task.spawn(function()
    for i = LOCK_TIME, 1, -1 do
        okBtn.Text = "ok (" .. i .. ")"
        task.wait(1)
    end
    okBtn.Text = "ok"
    okBtn.TextColor3 = TEXT
    okBtn.Active = true
    okStroke.Color = STROKE
    unlocked = true
end)

okBtn.MouseEnter:Connect(function()
    if not unlocked then return end
    TweenService:Create(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(42, 42, 42) }):Play()
    okStroke.Color = LIME
end)
okBtn.MouseLeave:Connect(function()
    if not unlocked then return end
    TweenService:Create(okBtn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(30, 30, 30) }):Play()
    okStroke.Color = STROKE
end)

okBtn.MouseButton1Click:Connect(function()
    if not unlocked then return end
    local outTween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(panel, outTween, {
        Size = UDim2.fromOffset(340, 190),
        Position = UDim2.new(0.5, -170, 0.5, -95),
    }):Play()
    TweenService:Create(backdrop, outTween, { BackgroundTransparency = 1 }):Play()
    for _, d in ipairs(panel:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            TweenService:Create(d, outTween, { TextTransparency = 1 }):Play()
        end
    end
    task.wait(0.2)
    gui:Destroy()
end)

local dragging, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
    end
end)
header.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

panel.Size = UDim2.fromOffset(340, 190)
panel.Position = UDim2.new(0.5, -170, 0.5, -95)
panel.BackgroundTransparency = 1
TweenService:Create(panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.fromOffset(360, 200),
    Position = UDim2.new(0.5, -180, 0.5, -100),
    BackgroundTransparency = 0,
}):Play()
