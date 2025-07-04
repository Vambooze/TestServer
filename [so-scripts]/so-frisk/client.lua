local QBCore = exports['qb-core']:GetCoreObject()
local hasFiredWeapon = {}

-- Add Frisk Target Option
exports['qb-target']:AddGlobalPlayer({
    options = {
        {
            type = "client",
            event = "frisk:checkWeapons",
            icon = "fas fa-search",
            label = "Frisk for Weapons",
            job = { ['police']=0, ['bcso']=0 }, -- Only police can frisk
        }
    },
    distance = 2.0
})

RegisterNetEvent("frisk:checkWeapons", function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.0 then
        TriggerServerEvent("frisk:serverCheck", GetPlayerServerId(player))
    else
        QBCore.Functions.Notify("No one nearby!", "error")
    end
end)