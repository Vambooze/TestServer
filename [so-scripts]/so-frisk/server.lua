local QBCore = exports['qb-core']:GetCoreObject()
Config = Config or {}

local gsrPlayers = {}


RegisterNetEvent("frisk:serverCheck", function(target)
    local src = source
    local Player = QBCore.Functions.GetPlayer(target)

    if Player then
        local weapons = {}
        for _, item in pairs(Player.PlayerData.items) do
            if item.name:find("weapon_") then -- Check for weapons
                table.insert(weapons, item.label)
            end
        end

        if #weapons > 0 then
            TriggerClientEvent("QBCore:Notify", src, "Player has: " .. table.concat(weapons, ", "), "error")
        else
            TriggerClientEvent("QBCore:Notify", src, "No weapons found.", "success")
        end
    end
end)