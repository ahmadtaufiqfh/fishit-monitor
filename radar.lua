local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1455443365964419264/BUP-YUDGDbCZp6XiVaqDyC62_OWh8N_aOTFotkzs5qwujXzYgnzDSXbiBmjNt9QyccDs"

local HttpService = game:GetService("HttpService")
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local lastMsg = ""

local function sendToDiscord(msgText, reason)
    if not req then return end
    if msgText == lastMsg then return end
    lastMsg = msgText

    pcall(function()
        req({
            Url = DISCORD_WEBHOOK,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                content = "🌟 **[FISHIT VIP RADAR]** " .. reason .. " Terdeteksi!\n```ansi\n\u001b[1;33m" .. msgText .. "\u001b[0m\n```"
            })
        })
    end)
end

local function checkMessage(msg)
    local lowerMsg = string.lower(msg)
    
    -- 1. CEK MUTASI SPESIFIK: RUBY GEMSTONE
    if string.find(lowerMsg, "ruby gemstone") then
        sendToDiscord(msg, "Mutasi Ruby Gemstone")
        return
    end

    -- 2. CEK DATABASE IKAN UNTUK RARITY "SECRET"
    local itemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
    if not itemsFolder then return end

    for _, itemModule in pairs(itemsFolder:GetChildren()) do
        if itemModule:IsA("ModuleScript") then
            local fishName = string.lower(itemModule.Name)
            
            if string.find(lowerMsg, fishName) then
                local success, data = pcall(function() return require(itemModule) end)
                if success and type(data) == "table" then
                    local rarity = tostring(data.Rarity or data.rarity or data.Tier or "")
                    
                    if string.lower(rarity) == "secret" then
                        sendToDiscord(msg, "Ikan Secret (" .. itemModule.Name .. ")")
                        return
                    end
                end
            end
        end
    end
end

-- ==========================================
-- LISTENER CHAT GAME
-- ==========================================
pcall(function()
    local TCS = game:GetService("TextChatService")
    TCS.MessageReceived:Connect(function(textChatMessage)
        local prefix = textChatMessage.PrefixText or ""
        local text = textChatMessage.Text or ""
        checkMessage(prefix .. " " .. text)
    end)
end)

pcall(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local chatEvents = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 5)
    if chatEvents then
        chatEvents:WaitForChild("OnMessageDoneFiltering", 5).OnClientEvent:Connect(function(messageData)
            local msg = messageData.Message or ""
            local from = messageData.FromSpeaker or ""
            local channel = messageData.OriginalChannel or ""
            
            if from == "" then
                checkMessage("[" .. channel .. "] " .. msg)
            else
                checkMessage("[" .. channel .. "] " .. from .. ": " .. msg)
            end
        end)
    end
end)

-- Pesan ini hanya untuk memastikan skrip yang dieksekusi adalah yang benar
req({
    Url = DISCORD_WEBHOOK,
    Method = "POST",
    Headers = { ["Content-Type"] = "application/json" },
    Body = HttpService:JSONEncode({ content = "✅ **[SISTEM]** Radar VIP berhasil dihidupkan! Menunggu tangkapan Sultan..." })
})
