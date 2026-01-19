-- Fishit Monitoring (Lightweight)
-- Loadable via GitHub Raw

local Players = game:GetService("Players")
local player = Players.LocalPlayer

while not player do
    task.wait(1)
    player = Players.LocalPlayer
end

local USN = player.Name
local INSTANCE = "RF_" .. tostring(player.UserId)

local URL_ENDPOINT = "https://script.google.com/macros/s/AKfycbwZYafWsYUiB8QlZlRLGbVbUefUhVDxY2toVmpJY9hLnskrB3buAEXQb5JLZdflm5fvXQ/exec"

local INTERVAL = 90

task.spawn(function()
    while true do
        task.wait(INTERVAL)
        pcall(function()
            game:HttpGet(
                URL_ENDPOINT ..
                "?instance=" .. INSTANCE ..
                "&usn=" .. USN
            )
        end)
    end
end)
