local QBCore = exports['qb-core']:GetCoreObject()
local firstAlarm = false
local smashing = false

-- Functions

local function loadParticle()
    if not HasNamedPtfxAssetLoaded('scr_jewelheist') then
        RequestNamedPtfxAsset('scr_jewelheist')
    end
    while not HasNamedPtfxAssetLoaded('scr_jewelheist') do
        Wait(0)
    end
    SetPtfxAssetNextCall('scr_jewelheist')
end

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(3)
    end
end

local function validWeapon()
    local ped = PlayerPedId()
    local pedWeapon = GetSelectedPedWeapon(ped)

    for k, _ in pairs(Config.WhitelistedWeapons) do
        if pedWeapon == k then
            return true
        end
    end
    return false
end

local function smashmachine(k)
    if not firstAlarm then
        TriggerServerEvent('police:server:policeAlert', 'Suspicious Activity')
        firstAlarm = true
    end

    QBCore.Functions.TriggerCallback('so-laundry:server:getCops', function(cops)
        if cops >= Config.RequiredCops then
            local animDict = 'missheist_jewel'
            local animName = 'smash_case'
            local ped = PlayerPedId()
            local plyCoords = GetOffsetFromEntityInWorldCoords(ped, 0, 0.6, 0)
            local pedWeapon = GetSelectedPedWeapon(ped)
            if math.random(1, 100) <= 80 and not QBCore.Functions.IsWearingGloves() then
                TriggerServerEvent('evidence:server:CreateFingerDrop', plyCoords)
            elseif math.random(1, 100) <= 5 and QBCore.Functions.IsWearingGloves() then
                TriggerServerEvent('evidence:server:CreateFingerDrop', plyCoords)
                QBCore.Functions.Notify(Lang:t('error.fingerprints'), 'error')
            end
            smashing = true
            QBCore.Functions.Progressbar('smash_machine', Lang:t('info.progressbar'), Config.WhitelistedWeapons[pedWeapon]['timeOut'], false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                TriggerServerEvent('so-laundry:server:machineReward', k)
                TriggerServerEvent('so-laundry:server:setTimeout')
                TriggerServerEvent('police:server:policeAlert', 'Robbery in progress')
                smashing = false
                TaskPlayAnim(ped, animDict, 'exit', 3.0, 3.0, -1, 2, 0, 0, 0, 0)
            end, function() -- Cancel
                TriggerServerEvent('so-laundry:server:setmachineState', 'isBusy', false, k)
                smashing = false
                TaskPlayAnim(ped, animDict, 'exit', 3.0, 3.0, -1, 2, 0, 0, 0, 0)
            end)
            TriggerServerEvent('so-laundry:server:setmachineState', 'isBusy', true, k)

            CreateThread(function()
                while smashing do
                    loadAnimDict(animDict)
                    TaskPlayAnim(ped, animDict, animName, 3.0, 3.0, -1, 2, 0, 0, 0, 0)
                    Wait(500)
                    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'breaking_machine_glass', 0.25)
                    loadParticle()
                    StartParticleFxLoopedAtCoord('scr_jewel_cab_smash', plyCoords.x, plyCoords.y, plyCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
                    Wait(2500)
                end
            end)
        else
            QBCore.Functions.Notify(Lang:t('error.minimum_police', { value = Config.RequiredCops }), 'error')
        end
    end)
end

-- Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('so-laundry:server:getmachineState', function(result)
        Config.Locations = result
    end)
end)

RegisterNetEvent('so-laundry:client:setmachineState', function(stateType, state, k)
    Config.Locations[k][stateType] = state
end)

-- Threads

CreateThread(function()
    local Dealer = AddBlipForCoord(Config.LaundryLocation['coords']['x'], Config.LaundryLocation['coords']['y'], Config.LaundryLocation['coords']['z'])
    SetBlipSprite(Dealer, 617)
    SetBlipDisplay(Dealer, 4)
    SetBlipScale(Dealer, 0.7)
    SetBlipAsShortRange(Dealer, true)
    SetBlipColour(Dealer, 3)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName('Laundromat')
    EndTextCommandSetBlipName(Dealer)
end)

local listen = false
local function Listen4Control(case)
    listen = true
    CreateThread(function()
        while listen do
            if IsControlJustPressed(0, 38) then
                listen = false
                if not Config.Locations[case]['isBusy'] and not Config.Locations[case]['isOpened'] then
                    exports['qb-core']:KeyPressed()
                    if validWeapon() then
                        smashmachine(case)
                    else
                        QBCore.Functions.Notify(Lang:t('error.wrong_weapon'), 'error')
                    end
                else
                    exports['qb-core']:DrawText(Lang:t('general.drawtextui_broken'), 'left')
                end
            end
            Wait(1)
        end
    end)
end

CreateThread(function()
    if Config.UseTarget then
        for k, v in pairs(Config.Locations) do
            exports['qb-target']:AddBoxZone('laundry' .. k, v.coords, 1, 1, {
                name = 'laundry' .. k,
                heading = 40,
                minZ = v.coords.z - 1,
                maxZ = v.coords.z + 1,
                debugPoly = false
            }, {
                options = {
                    {
                        type = 'client',
                        icon = 'fa fa-hand',
                        label = Lang:t('general.target_label'),
                        action = function()
                            if validWeapon() then
                                smashmachine(k)
                            else
                                QBCore.Functions.Notify(Lang:t('error.wrong_weapon'), 'error')
                            end
                        end,
                        canInteract = function()
                            if v['isOpened'] or v['isBusy'] then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.5
            })
        end
    else
        for k, v in pairs(Config.Locations) do
            local boxZone = BoxZone:Create(v.coords, 1, 1, {
                name = 'laundry' .. k,
                heading = 40,
                minZ = v.coords.z - 1,
                maxZ = v.coords.z + 1,
                debugPoly = false
            })
            boxZone:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    Listen4Control(k)
                    exports['qb-core']:DrawText(Lang:t('general.drawtextui_grab'), 'left')
                else
                    listen = false
                    exports['qb-core']:HideText()
                end
            end)
        end
    end
end)

exports['qb-target']:AddBoxZone("laundry", vector3(897.53, -1036.32, 35.11), 1.5, 1.5, {
	name = "laundry",
	heading = 192.54,
	debugPoly = false,
	minZ = 34.78,
	maxZ = 36.18,
}, {
	options = {
		{
            type = "client",
            event = "laundry:UseThermite",
			icon = "fas fa-sign-in-alt",
			label = "Use-Thermite",
		},
	},
	distance = 2.5
})

RegisterNetEvent('laundry:UseThermite', function()
    local ped = PlayerPedId()

    -- Load animation dictionary
    local animDict = "anim@gangops@facility@servers@"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    -- Play animation
    TaskPlayAnim(ped, animDict, 'hotwire', 3.0, 3.0, -1, 1, 0, false, false, false)

    -- Start progress bar
    QBCore.Functions.Progressbar("hack_gate", Lang:t("Looking for the hidden key!"), math.random(5000, 10000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- On Finish
        StopAnimTask(ped, animDict, "hotwire", 1.0)
        exports['ps-ui']:Circle(function(success)
            if success then
                print("success")
                QBCore.Functions.Notify(Lang:t("You found the hidden Key!"), "success")
                local doorModel = -846791359
                local doorCoords = vector3(895.748352, -1037.058960, 35.398453)

                local door = GetClosestObjectOfType(doorCoords.x, doorCoords.y, doorCoords.z, 1.0, doorModel, false, false, false)
                if door and door ~= 0 then
                    FreezeEntityPosition(door, false)
                    print("Door unlocked manually.")
                else
                    print("Door not found.")
                end
                
                TriggerServerEvent('so-laundry:server:removeThermite')
                TriggerServerEvent('so-laundry:server:AddThermite')
            else
                print("fail")
                TriggerServerEvent('so-laundry:server:removeThermite')
                QBCore.Functions.Notify(Lang:t("You didnt find anything"), "error")
            end
        end, 1,10)

        -- Cooldown for calling cops
        copsCalled = true
        SetTimeout(60000, function() copsCalled = false end)
    end, function() -- On Cancel
        StopAnimTask(ped, animDict, "hotwire", 1.0)
        QBCore.Functions.Notify(Lang:t("error.cancel_message"), "error")
    end)
end)
