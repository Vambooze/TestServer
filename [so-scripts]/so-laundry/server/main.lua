local QBCore = exports['qb-core']:GetCoreObject()
local timeOut = false

local cachedPoliceAmount = {}
local flags = {}

-- Callback

QBCore.Functions.CreateCallback('so-laundry:server:getCops', function(source, cb)
    local amount = 0
    for _, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if (v.PlayerData.job.name == 'police' or v.PlayerData.job.type == 'leo') and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cachedPoliceAmount[source] = amount
    cb(amount)
end)

QBCore.Functions.CreateCallback('so-laundry:server:getmachineState', function(_, cb)
    cb(Config.Locations)
end)

-- Functions


local function getRewardBasedOnProbability(table)
    local random, probability = math.random(), 0

    for k, v in pairs(table) do
        probability = probability + v.probability
        if random <= probability then
            return k
        end
    end

    return math.random(#table)
end

-- Events

RegisterNetEvent('so-laundry:server:setmachineState', function(stateType, state, k)
    if stateType == 'isBusy' and type(state) == 'boolean' and Config.Locations[k] then
        Config.Locations[k][stateType] = state
        TriggerClientEvent('so-laundry:client:setmachineState', -1, stateType, state, k)
    end
end)

RegisterNetEvent('so-laundry:server:machineReward', function(machineIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cheating = false
    if Config.Locations[machineIndex] == nil or Config.Locations[machineIndex].isOpened ~= false then
        exploitBan(src, 'Trying to trigger an exploitable event \"so-laundry:server:machineReward\"')
        return
    end
    if cachedPoliceAmount[source] == nil then
        return
    end
    local plrPed = GetPlayerPed(src)
    local plrCoords = GetEntityCoords(plrPed)
    local machineCoords = Config.Locations[machineIndex].coords
    if cachedPoliceAmount[source] >= Config.RequiredCops then
        if plrPed then
            local dist = #(plrCoords - machineCoords)
            if dist <= 25.0 then
                Config.Locations[machineIndex]['isOpened'] = true
                Config.Locations[machineIndex]['isBusy'] = false
                TriggerClientEvent('so-laundry:client:setmachineState', -1, 'isOpened', true, machineIndex)
                TriggerClientEvent('so-laundry:client:setmachineState', -1, 'isBusy', false, machineIndex)
                local reward = math.random(500, 1250)
                Player.Functions.AddItem("markedbills", 1, false, { worth = reward })
            else
                cheating = true
            end
        end
    else
        cheating = true
    end
    if cheating then
        local license = Player.PlayerData.license
        if flags[license] then
            flags[license] = flags[license] + 1
        else
            flags[license] = 1
        end
        if flags[license] >= 3 then
        else
        end
    end
end)

RegisterNetEvent('so-laundry:server:setTimeout', function()
    if not timeOut then
        timeOut = true
        TriggerEvent('qb-scoreboard:server:SetActivityBusy', 'Laundry', true)
        Citizen.CreateThread(function()
            Citizen.Wait(Config.Timeout)

            for k, _ in pairs(Config.Locations) do
                Config.Locations[k]['isOpened'] = false
                TriggerClientEvent('so-laundry:client:setmachineState', -1, 'isOpened', false, k)
                TriggerClientEvent('so-laundry:client:setAlertState', -1, false)
                TriggerEvent('qb-scoreboard:server:SetActivityBusy', 'Laundry', false)
            end
            timeOut = false
        end)
    end
end)

RegisterNetEvent('so-laundry:server:removeThermite', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    Player.Functions.RemoveItem('Thermite', 1)

end)

 RegisterNetEvent('so-laundry:server:AddThermite', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem('laundrykey', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["laundrykey"], "add")
    print("testing")
end)
