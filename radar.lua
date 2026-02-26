local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

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
local success, result = pcall(function() return gethui() end)
ScreenGui.Parent = success and result or CoreGui

-- MAIN FRAME (KOTAK ATAS - NAIK KE ATAS SEJAJAR MENU)
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Size = UDim2.new(0, 135, 0, 26)
MainFrame.AnchorPoint = Vector2.new(1, 0) 
MainFrame.Position = UDim2.new(1, -70, 0, 10) -- DIUBAH DARI 15 KE 4 AGAR NAIK MENTOK ATAS
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true 
MainFrame.GroupTransparency = 0 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 13)

-- FILTER FRAME (MENU DROP-DOWN BAWAH)
local FilterFrame = Instance.new("Frame")
FilterFrame.Size = UDim2.new(0, 180, 0, 265)
FilterFrame.AnchorPoint = Vector2.new(1, 0) 
FilterFrame.Position = UDim2.new(1, -45, 0, 34) -- DIUBAH DARI 45 KE 34 MENYESUAIKAN MAINFRAME
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

-- SISTEM DRAG (MENGIKUTI POSISI BARU)
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
        FilterFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X + 25, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 30)
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
CloseBtn.MouseButton1Click:Connect(
