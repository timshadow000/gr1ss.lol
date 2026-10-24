local Players          = game:GetService("Players")
local TeleportService  = game:GetService("TeleportService")
local Workspace        = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")
local VirtualUser      = game:GetService("VirtualUser")

local SCRIPT_URL = "https://gist.githubusercontent.com/timshadow000/0a6a58c3b9e6069c48daed5c2748d6ed/raw/gistfile1.txt"
local Player = Players.LocalPlayer

local CONFIG = {
    Interval      = 1,
    AutoHop       = true,
    AntiAFK       = true,
}

local State = {
    Running    = false,
    Touches    = 0,
    ServerHops = 0,
    LastCount  = 0,
}

local function httpGet(url)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok, res = pcall(req, { Url = url, Method = "GET" })
        if ok and res and res.Body then return res.Body end
    end
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok then return res end
    return nil
end

local function fetchServers()
    local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local body = httpGet(url)
    if not body then return {} end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or not data or not data.data then return {} end
    
    local list = {}
    for _, s in ipairs(data.data) do
        if s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 0) then
            table.insert(list, s)
        end
    end
    return list
end

local function touchAllDoors()
    local char = Player.Character
    if not char then return 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end

    local folder = Workspace:FindFirstChild("Houses")
    if not folder then return 0 end

    local count = 0
    for _, v in ipairs(folder:GetChildren()) do
        if v.Name:match("^TrickOrTreatHouse") then
            local door  = v:FindFirstChild("Door")
            local touch = door and door:FindFirstChild("DoorInnerTouch")
            if touch then
                local ok = pcall(function()
                    firetouchinterest(touch, hrp, 0)
                    task.wait()
                    firetouchinterest(touch, hrp, 1)
                end)
                if ok then count += 1 end
            end
        end
    end
    return count
end

local function queueScript()
    local code = string.format([[
        task.wait(4)
        local ok, err = pcall(function()
            loadstring(game:HttpGet(%q))()
        end)
    ]], SCRIPT_URL)
    local qot = (syn and syn.queue_on_teleport) or queue_on_teleport or (getgenv() and getgenv().queue_on_teleport)
    if qot then pcall(qot, code) end
end

local function hopServer()
    State.ServerHops += 1
    queueScript()
    addLog("Searching for new server...")

    local servers = fetchServers()
    if #servers == 0 then
        addLog("Server list empty, rejoining...")
        task.wait(0.3)
        TeleportService:Teleport(game.PlaceId, Player)
        return
    end

    for i = #servers, 2, -1 do
        local j = math.random(1, i)
        servers[i], servers[j] = servers[j], servers[i]
    end

    for idx = 1, math.min(5, #servers) do
        local target = servers[idx]
        addLog("Hopping to: " .. string.sub(target.id, 1, 8))
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, Player)
        end)
        if ok then return end
        task.wait(0.5)
    end
    TeleportService:Teleport(game.PlaceId, Player)
end

local function parentGui()
    if gethui then
        local ok, ui = pcall(gethui)
        if ok and ui then return ui end
    end
    return game:GetService("CoreGui")
end

local gui = Instance.new("ScreenGui")
gui.Name = "gr1ss_fun_TouchFarm"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parentGui()

local COL_BG     = Color3.fromRGB(204, 204, 204)
local COL_WHITE  = Color3.fromRGB(255, 255, 255)
local COL_TEXT   = Color3.fromRGB(0, 0, 0)
local COL_BTN    = Color3.fromRGB(230, 230, 230)
local COL_BORDER = Color3.fromRGB(100, 100, 100)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 580, 0, 420)
main.Position = UDim2.new(0.5, -290, 0.5, -210)
main.BackgroundColor3 = COL_BG
main.BorderSizePixel = 1
main.BorderColor3 = COL_BORDER
main.Active = true
main.Parent = gui

local dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 24)
titleBar.BackgroundColor3 = COL_BG
titleBar.BorderSizePixel = 0
titleBar.Parent = main
local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(1, 0, 0, 1)
titleLine.Position = UDim2.new(0, 0, 1, -1)
titleLine.BackgroundColor3 = COL_BORDER
titleLine.BorderSizePixel = 0
titleLine.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.5, -10, 1, 0)
titleText.Position = UDim2.new(0, 5, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "gr1ss.fun"
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.ArialBold
titleText.TextSize = 14
titleText.TextColor3 = COL_TEXT
titleText.Parent = titleBar

local discordText = Instance.new("TextButton")
discordText.Size = UDim2.new(0.5, -10, 1, 0)
discordText.Position = UDim2.new(0.5, 5, 0, 0)
discordText.BackgroundTransparency = 1
discordText.Text = "Discord: https://discord.gg/e7npF2QDgc"
discordText.TextXAlignment = Enum.TextXAlignment.Right
discordText.Font = Enum.Font.Arial
discordText.TextSize = 12
discordText.TextColor3 = Color3.fromRGB(50, 50, 200)
discordText.Parent = titleBar

discordText.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard("https://discord.gg/e7npF2QDgc")
        addLog("Discord link copied to clipboard!")
    end)
end)

local leftPanel = Instance.new("Frame")
leftPanel.Size = UDim2.new(0, 420, 0, 340)
leftPanel.Position = UDim2.new(0, 10, 0, 34)
leftPanel.BackgroundColor3 = COL_WHITE
leftPanel.BorderSizePixel = 1
leftPanel.BorderColor3 = COL_BORDER
leftPanel.Parent = main

local function createStatText(text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 16
    lbl.TextColor3 = COL_TEXT
    lbl.Parent = leftPanel
    return lbl
end

local lblStatus = createStatText("Status: Waiting...", 10)
local lblDoors  = createStatText("Doors per pass: 0", 40)
local lblTouch  = createStatText("Total touches: 0", 70)
local lblHops   = createStatText("Server hops: 0", 100)

local rightPanel = Instance.new("Frame")
rightPanel.Size = UDim2.new(0, 130, 0, 340)
rightPanel.Position = UDim2.new(1, -140, 0, 34)
rightPanel.BackgroundColor3 = COL_BG
rightPanel.BorderSizePixel = 0
rightPanel.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = rightPanel

local function createBtn(text, height)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, height or 40)
    btn.BackgroundColor3 = COL_BTN
    btn.BorderSizePixel = 1
    btn.BorderColor3 = COL_BORDER
    btn.Text = text
    btn.Font = Enum.Font.ArialBold
    btn.TextSize = 14
    btn.TextColor3 = COL_TEXT
    btn.Parent = rightPanel
    return btn
end

local bottomPanel = Instance.new("Frame")
bottomPanel.Size = UDim2.new(0, 420, 0, 34)
bottomPanel.Position = UDim2.new(0, 10, 1, -44)
bottomPanel.BackgroundColor3 = COL_WHITE
bottomPanel.BorderSizePixel = 1
bottomPanel.BorderColor3 = COL_BORDER
bottomPanel.Parent = main

local logLbl = Instance.new("TextLabel")
logLbl.Size = UDim2.new(1, -10, 1, 0)
logLbl.Position = UDim2.new(0, 5, 0, 0)
logLbl.BackgroundTransparency = 1
logLbl.Text = "click here to enable output(just for looks m)"
logLbl.TextXAlignment = Enum.TextXAlignment.Left
logLbl.Font = Enum.Font.Arial
logLbl.TextSize = 12
logLbl.TextColor3 = COL_TEXT
logLbl.Parent = bottomPanel

function addLog(msg)
    logLbl.Text = "> " .. msg
end

local creditLbl = Instance.new("TextLabel")
creditLbl.Size = UDim2.new(0, 150, 0, 20)
creditLbl.Position = UDim2.new(1, -150, 1, -20)
creditLbl.BackgroundTransparency = 1
creditLbl.Text = "made by timshadow"
creditLbl.TextXAlignment = Enum.TextXAlignment.Right
creditLbl.Font = Enum.Font.Arial
creditLbl.TextSize = 11
creditLbl.TextColor3 = Color3.fromRGB(100, 100, 100)
creditLbl.Parent = main

local btnStart = createBtn("START", 50)
local btnHop   = createBtn("HOP", 50)
local btnAutoHop = createBtn("[X] AUTO HOP", 50)
local btnAntiAfk = createBtn("[X] ANTI-AFK", 50)
local btnClear = createBtn("CLEAR STATS", 50)

btnStart.MouseButton1Click:Connect(function()
    if State.Running then
        State.Running = false
        btnStart.Text = "START"
        lblStatus.Text = "Status: Stopped"
        addLog("Farm stopped manually.")
    else
        State.Running = true
        btnStart.Text = "STOP"
        addLog("Farm started.")
        task.spawn(function()
            while State.Running do
                local c = Player.Character
                if c and c:FindFirstChild("HumanoidRootPart") then break end
                task.wait(0.2)
            end
            
            while State.Running do
                local count = touchAllDoors()
                if count == 0 then
                    lblStatus.Text = "Status: No doors found"
                    if CONFIG.AutoHop then
                        addLog("No doors. Hopping server...")
                        hopServer()
                        break
                    else
                        task.wait(2)
                    end
                else
                    State.Touches += count
                    State.LastCount = count
                    lblStatus.Text = "Status: Touching doors"
                end
                task.wait(CONFIG.Interval)
            end
            if not State.Running then btnStart.Text = "START" end
        end)
    end
end)

btnHop.MouseButton1Click:Connect(function()
    addLog("Manual hop triggered.")
    hopServer()
end)

btnAutoHop.MouseButton1Click:Connect(function()
    CONFIG.AutoHop = not CONFIG.AutoHop
    btnAutoHop.Text = CONFIG.AutoHop and "[X] AUTO HOP" or "[ ] AUTO HOP"
    addLog("Auto Hop: " .. tostring(CONFIG.AutoHop))
end)

btnAntiAfk.MouseButton1Click:Connect(function()
    CONFIG.AntiAFK = not CONFIG.AntiAFK
    btnAntiAfk.Text = CONFIG.AntiAFK and "[X] ANTI-AFK" or "[ ] ANTI-AFK"
    addLog("Anti-AFK: " .. tostring(CONFIG.AntiAFK))
end)

btnClear.MouseButton1Click:Connect(function()
    State.Touches = 0
    State.ServerHops = 0
    State.LastCount = 0
    addLog("Stats cleared.")
end)

Player.Idled:Connect(function()
    if CONFIG.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        addLog("Anti-AFK triggered (jumped).")
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        lblDoors.Text = "Doors per pass: " .. State.LastCount
        lblTouch.Text = "Total touches: " .. State.Touches
        lblHops.Text  = "Server hops: " .. State.ServerHops
    end
end)

task.spawn(function()
    task.wait(0.1)
    btnStart.MouseButton1Click()
end)
