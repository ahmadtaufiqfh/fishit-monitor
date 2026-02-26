local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- ==========================================
-- WEBHOOK CONFIG
-- ==========================================
local CONFIG_FILE = "Radar_Config.json"
local webhookLink = ""

pcall(function()
    if isfile(CONFIG_FILE) then
        local saved = HttpService:JSONDecode(readfile(CONFIG_FILE))
        if saved and saved.webhook then webhookLink = saved.webhook end
    end
end)

local function saveConfig()
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode({webhook = webhookLink})) end)
end

-- ==========================================
-- WIDGET UI (MAC STYLE MICRO)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Radar"
ScreenGui.ResetOnSpawn = false
local success, result = pcall(function() return gethui() end)
ScreenGui.Parent = success and result or CoreGui

local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 180, 0, 26)
MainFrame.Position = UDim2.new(0.5, -90, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true 
MainFrame.GroupTransparency = 0 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 13)

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
    end
end)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

-- 1. Kotak Input Webhook
local WebhookBox = Instance.new("TextBox")
WebhookBox.Size = UDim2.new(0, 105, 0, 18)
WebhookBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
WebhookBox.Text = webhookLink
WebhookBox.PlaceholderText = "Paste Webhook..."
WebhookBox.TextColor3 = Color3.fromRGB(200, 200, 200)
WebhookBox.Font = Enum.Font.Gotham
WebhookBox.TextSize = 10
WebhookBox.ClearTextOnFocus = false
WebhookBox.ClipsDescendants = true 
WebhookBox.TextXAlignment = Enum.TextXAlignment.Left
WebhookBox.TextTruncate = Enum.TextTruncate.AtEnd
WebhookBox.LayoutOrder = 1
WebhookBox.Parent = MainFrame
Instance.new("UICorner", WebhookBox).CornerRadius = UDim.new(0, 5)

local BoxPadding = Instance.new("UIPadding")
BoxPadding.PaddingLeft = UDim.new(0, 6)
BoxPadding.PaddingRight = UDim.new(0, 6)
BoxPadding.Parent = WebhookBox

WebhookBox.FocusLost:Connect(function()
    webhookLink = WebhookBox.Text
    saveConfig()
end)

-- 2. Tombol PLAY (Hijau)
local PlayBtn = Instance.new("TextButton")
PlayBtn.Size = UDim2.new(0, 9, 0, 9)
PlayBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 60)
PlayBtn.Text = "" 
PlayBtn.LayoutOrder = 2
PlayBtn.Parent = MainFrame
Instance.new("UICorner", PlayBtn).CornerRadius = UDim.new(1, 0)

-- 3. Tombol STOP (Kuning)
local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0, 9, 0, 9)
StopBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
StopBtn.Text = "" 
StopBtn.LayoutOrder = 3
StopBtn.Parent = MainFrame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(1, 0)

-- 4. Tombol CLOSE (Merah)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 9, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
CloseBtn.Text = "" 
CloseBtn.LayoutOrder = 4
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ==========================================
-- MESIN RADAR & BUKTI TANGKAPAN
-- ==========================================
local isRunning = false
local waitingForFirstCatch = false
local connectionTCS, connectionLegacy
local lastMsg = ""

local function sendToDiscord(cleanMsg, reason)
    if not req or webhookLink == "" then return end
    if cleanMsg == lastMsg then return end
    lastMsg = cleanMsg
    pcall(function()
        req({
            Url = webhookLink, Method = "POST", Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ content = "🌟 **[FISHIT VIP]** Tangkapan " .. reason .. " Terdeteksi!\n```text\n" .. cleanMsg .. "\n```" })
        })
    end)
end

local function checkMessage(rawMsg)
    local cleanMsg = string.gsub(rawMsg, "<[^>]+>", "")
    local lowerMsg = string.lower(cleanMsg)
    
    -- [FITUR KONFIRMASI] Bukti tangkapan pertama saat radar baru nyala
    if waitingForFirstCatch and string.find(lowerMsg, "obtained") then
        waitingForFirstCatch = false
        pcall(function()
            req({
                Url = webhookLink, Method = "POST", Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ content = "✅ **[WIDGET AKTIF]** \n\n **First_Caught**\n```text\n" .. cleanMsg .. "\n```" })
            })
        end)
    end

    -- LOGIKA FILTER TARGET (SECRET & GEMSTONE RUBY)
    local isSecret = string.find(lowerMsg, "m chance")
    local isGemstoneRuby = string.find(lowerMsg, "gemstone") and string.find(lowerMsg, "ruby")

    if isSecret or isGemstoneRuby then
        local reason = ""
        if isSecret and isGemstoneRuby then reason = "Ikan Secret & Gemstone Ruby"
        elseif isSecret then reason = "Ikan Secret"
        elseif isGemstoneRuby then reason = "Ikan Gemstone Ruby" end
        sendToDiscord(cleanMsg, reason)
    end
end

-- Fungsi Saat Tombol Hijau (Play) Ditekan
PlayBtn.MouseButton1Click:Connect(function()
    if isRunning then return end
    if webhookLink == "" then
        WebhookBox.Text = "Isi Link Dulu!"
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

-- Fungsi Saat Tombol Kuning (Stop) Ditekan
StopBtn.MouseButton1Click:Connect(function()
    if not isRunning then return end
    isRunning = false
    waitingForFirstCatch = false
    MainFrame.GroupTransparency = 0 
    
    if connectionTCS then connectionTCS:Disconnect() end
    if connectionLegacy then connectionLegacy:Disconnect() end
end)
