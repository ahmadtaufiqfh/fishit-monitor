local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1455443365964419264/BUP-YUDGDbCZp6XiVaqDyC62_OWh8N_aOTFotkzs5qwujXzYgnzDSXbiBmjNt9QyccDs"

local HttpService = game:GetService("HttpService")
local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not req then
    warn("Executor tidak mendukung HTTP Request")
    return
end

-- Kirim pesan pembuka ke Discord agar kita tahu skrip mulai bekerja
req({
    Url = DISCORD_WEBHOOK,
    Method = "POST",
    Headers = { ["Content-Type"] = "application/json" },
    Body = HttpService:JSONEncode({ content = "⏳ **[SCANNER]** Sedang mencari database Fishit... Mohon tunggu..." })
})

local keyword_names = {"fish", "data", "item", "rarity", "config", "index", "loot"}
local results = "🕵️‍♂️ **HASIL SCAN DATABASE FISHIT:**\n\n"
local count = 0

for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("ModuleScript") then
        local objName = string.lower(obj.Name)
        local isSuspicious = false
        
        for _, kw in pairs(keyword_names) do
            if string.find(objName, kw) then
                isSuspicious = true
                break
            end
        end

        if isSuspicious then
            local success, data = pcall(function() return require(obj) end)
            if success and type(data) == "table" then
                -- Ambil 3 kunci pertama sebagai cuplikan
                local hints = ""
                local limit = 0
                for k, v in pairs(data) do
                    if limit > 2 then break end
                    hints = hints .. tostring(k) .. ", "
                    limit = limit + 1
                end
                
                results = results .. "✅ **Path:** `" .. obj:GetFullName() .. "`\n"
                results = results .. "↳ Isi: _{ " .. hints .. "... }_\n\n"
                count = count + 1
                
                -- Batasi hasil agar pesan Discord tidak kepanjangan
                if count >= 10 then break end 
            end
        end
    end
end

if count == 0 then
    results = results .. "❌ Tidak ada file ModuleScript yang mencurigakan."
end

-- Kirim hasil akhirnya ke Discord
pcall(function()
    req({
        Url = DISCORD_WEBHOOK,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({ content = results })
    })
end)
