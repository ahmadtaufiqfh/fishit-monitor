local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- ==========================================
-- ANTI-DUPLIKAT (PEMBERSIH UI LAMA)
-- ==========================================
local success, result = pcall(function() return gethui() end)
local targetParent = (success and result) or CoreGui
if targetParent:FindFirstChild("Radar") then
    targetParent.Radar:Destroy()
end

-- ==========================================
-- WEBHOOK & KEYWORD CONFIG (AUTO-SAVE)
-- ==========================================
local CONFIG_FILE = "Radar_Config.json"
local webhookLink = ""
local savedKeywords = {"", "", "", "", "", "", "", "", "", ""}

pcall(function()
    if isfile(CONFIG_FILE) then
        local saved = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if saved and saved.webhook then webhookLink = saved.webhook end
        if saved and saved.keywords then 
            for i = 1, 10 do
                if saved.keywords[i] then savedKeywords[i] = saved.keywords[i] end
            end
        end
    end
end)

local function saveConfig()
    pcall(function() 
        writefile(CONFIG_FILE, HttpService:JSONEncode({webhook = webhookLink, keywords = savedKeywords})) 
    end)
end

-- ==========================================
-- WIDGET UI (MAC STYLE MICRO - ARSY EDITION)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Radar"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

-- MAIN FRAME (KOTAK ATAS)
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 135, 0, 26)
-- Menggunakan Offset Murni (Aman untuk Drag Delta Android)
MainFrame.Position = UDim2.new(1, -260, 0, 4) 
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true 
MainFrame.GroupTransparency = 0 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 13)

-- FILTER FRAME (MENU DROP-DOWN BAWAH)
local FilterFrame = Instance.new("Frame")
FilterFrame.Size = UDim2.new(0, 180, 0, 265)
FilterFrame.Position = UDim2.new(1, -282, 0, 34) -- Menyesuaikan posisi MainFrame
FilterFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
FilterFrame.Visible = false
FilterFrame.Parent = ScreenGui
Instance.new("UICorner", FilterFrame).CornerRadius = UDim.new(0, 8)

local FilterLayout = Instance.new("UIListLayout", FilterFrame)
FilterLayout.Padding = UDim.new(0, 4)
FilterLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
FilterLayout.SortOrder = Enum.SortOrder.LayoutOrder

local FilterPad = Instance.new("UIPadding", FilterFrame)
FilterPad.PaddingTop = UDim.new(0, 8)
FilterPad.PaddingBottom = UDim.new(0, 8)

-- 0. KOTAK INPUT LINK DISCORD 
local WebhookBox = Instance.new("TextBox")
WebhookBox.Size = UDim2.new(0, 160, 0, 20)
WebhookBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
WebhookBox.TextColor3 = Color3.fromRGB(85, 170, 255)
WebhookBox.PlaceholderText = "Paste Link Discord Di Sini..."
WebhookBox.Text = webhookLink
WebhookBox.Font = Enum.Font.GothamBold
WebhookBox.TextSize = 9
WebhookBox.Parent = FilterFrame
WebhookBox.ClearTextOnFocus = false
WebhookBox.ClipsDescendants = true 
WebhookBox.TextXAlignment = Enum.TextXAlignment.Left
WebhookBox.LayoutOrder = 1
Instance.new("UICorner", WebhookBox).CornerRadius = UDim.new(0, 4)

local BoxPadding = Instance.new("UIPadding", WebhookBox)
BoxPadding.PaddingLeft = UDim.new(0, 6)
BoxPadding.PaddingRight = UDim.new(0, 6)

WebhookBox.FocusLost:Connect(function() 
    webhookLink = WebhookBox.Text; 
    saveConfig() 
end)

local Divider = Instance.new("Frame", FilterFrame)
Divider.Size = UDim2.new(0, 150, 0, 1)
Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
Divider.BorderSizePixel = 0
Divider.LayoutOrder = 2

-- 1-10. KOTAK INPUT KEYWORD
for i = 1, 10 do
    local kwBox = Instance.new("TextBox")
    kwBox.Size = UDim2.new(0, 160, 0, 18)
    kwBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    kwBox.TextColor3 = Color3.fromRGB(200, 200, 200)
    kwBox.PlaceholderText = "Target Keyword " .. i
    kwBox.Text = savedKeywords[i]
    kwBox.Font = Enum.Font.Gotham
    kwBox.TextSize = 10
    kwBox.LayoutOrder = i + 2
    kwBox.Parent = FilterFrame
    kwBox.ClearTextOnFocus = false
    Instance.new("UICorner", kwBox).CornerRadius = UDim.new(0, 4)
    
    kwBox.FocusLost:Connect(function()
        savedKeywords[i] = string.lower(kwBox.Text)
        saveConfig()
    end)
end

-- SISTEM DRAG (AMAN UNTUK SEMUA EXECUTOR ANDROID)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        FilterFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X - 22, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 30)
    end
end)

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- 1. TOMBOL "ARSY"
local ArsyBtn = Instance.new("TextButton", MainFrame)
ArsyBtn.Size = UDim2.new(0, 60, 0, 18)
ArsyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ArsyBtn.Text = "ARSY" 
ArsyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
ArsyBtn.Font = Enum.Font.GothamBold
ArsyBtn.TextSize = 11
ArsyBtn.LayoutOrder = 1
Instance.new("UICorner", ArsyBtn).CornerRadius = UDim.new(0, 5)

ArsyBtn.MouseButton1Click:Connect(function() 
    FilterFrame.Visible = not FilterFrame.Visible 
end)

-- 2. TOMBOL PLAY (Hijau)
local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0, 9, 0, 9)
PlayBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 60)
PlayBtn.Text = "" 
PlayBtn.LayoutOrder = 2
Instance.new("UICorner", PlayBtn).CornerRadius = UDim.new(1, 0)

-- 3. TOMBOL STOP (Kuning)
local StopBtn = Instance.new("TextButton", MainFrame)
StopBtn.Size = UDim2.new(0, 9, 0, 9)
StopBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
StopBtn.Text = "" 
StopBtn.LayoutOrder = 3
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(1, 0)

-- 4. TOMBOL CLOSE (Merah)
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 9, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
CloseBtn.Text = "" 
CloseBtn.LayoutOrder = 4
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==========================================
-- MESIN RADAR & DISCORD SENDER (AUTO-UPDATE)
-- ==========================================
local isRunning = false
local waitingForFirstCatch = false
local connectionTCS, connectionLegacy
local lastMsg = ""

local currentMessageId = nil
local catchList = {}
local MAX_LINES = 10 

local function sendToDiscord(cleanMsg)
    if not req or webhookLink == "" then return end
    if cleanMsg == lastMsg then return end
    lastMsg = cleanMsg

    local newLine = ""
    
    -- [PERBAIKAN SPOILER]: Kebal terhadap spasi gaib
    local prefix, username, rest = string.match(cleanMsg, "(.*%[Server%]%:?%s*)(%S+)(.*)")
    
    if prefix and username and rest then
        newLine = prefix .. "||" .. username .. "||" .. rest
    else
        newLine = cleanMsg
    end

    table.insert(catchList, newLine)

    if #catchList > MAX_LINES then
        currentMessageId = nil
        catchList = {newLine}
    end

    local finalContent = table.concat(catchList, "\n")

    task.spawn(function()
        local cleanLink = string.gsub(webhookLink, "%?wait=true", "")
        if currentMessageId == nil then
            local response = req({Url = cleanLink .. "?wait=true", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode({ content = finalContent })})
            if response and response.StatusCode == 200 then
                local success, data = pcall(function() return HttpService:JSONDecode(response.Body) end)
                if success and data and data.id then currentMessageId = data.id end
            end
        else
            local response = req({Url = cleanLink .. "/messages/" .. currentMessageId, Method = "PATCH", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode({ content = finalContent })})
            if response and (response.StatusCode == 404 or response.StatusCode == 400) then currentMessageId = nil end
        end
    end)
end

local function checkMessage(rawMsg)
    local cleanMsg = string.gsub(rawMsg, "<[^>]+>", "")
    local lowerMsg = string.lower(cleanMsg)
    
    if waitingForFirstCatch and string.find(lowerMsg, "obtained") then
        waitingForFirstCatch = false
        sendToDiscord(cleanMsg)
        return
    end

    local isTargetFound = false
    for _, boxText in ipairs(savedKeywords) do
        if boxText ~= "" then
            local textLower = string.lower(boxText)
            if string.find(textLower, "+") then
                local allWordsFound = true
                for word in string.gmatch(textLower, "[^+]+") do
                    local cleanWord = string.match(word, "^%s*(.-)%s*$")
                    if cleanWord ~= "" and not string.find(lowerMsg, cleanWord) then
                        allWordsFound = false
                        break
                    end
                end
                if allWordsFound then isTargetFound = true; break end
            else
                if string.find(lowerMsg, textLower) then isTargetFound = true; break end
            end
        end
    end

    if isTargetFound then sendToDiscord(cleanMsg) end
end

-- FUNGSI PLAY
PlayBtn.MouseButton1Click:Connect(function()
    if isRunning then return end
    
    if webhookLink == "" then
        FilterFrame.Visible = true
        WebhookBox.Text = "ISI LINK DISCORD!"
        task.wait(1.5)
        WebhookBox.Text = webhookLink
        return
    end

    isRunning = true
    waitingForFirstCatch = true 
    MainFrame.GroupTransparency = 0.7 

    pcall(function()
        local TCS = game:GetService("TextChatService")
        connectionTCS = TCS.MessageReceived:Connect(function(t) checkMessage((t.PrefixText or "") .. " " .. (t.Text or "")) end)
    end)
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local ce = RS:WaitForChild("DefaultChatSystemChatEvents", 5)
        if ce then connectionLegacy = ce:WaitForChild("OnMessageDoneFiltering", 5).OnClientEvent:Connect(function(d) checkMessage((d.FromSpeaker or "")=="" and ("["..d.OriginalChannel.."] "..d.Message) or ("["..d.OriginalChannel.."] "..d.FromSpeaker..": "..d.Message)) end) end
    end)
end)

-- FUNGSI STOP
StopBtn.MouseButton1Click:Connect(function()
    if not isRunning then return end
    isRunning = false
    waitingForFirstCatch = false
    MainFrame.GroupTransparency = 0 
    
    if connectionTCS then connectionTCS:Disconnect() end
    if connectionLegacy then connectionLegacy:Disconnect() end
end)
