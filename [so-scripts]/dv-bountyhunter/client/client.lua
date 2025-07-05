-- Variables
local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPeds = {}
local blips = {}

-- Simple notification function
function NotifyPlayer(message, type)
    if Config.Debug then
        QBCore.Functions.Notify(message, type)
        print("[HOSTILE PED SPAWN] " .. message)
    end
end

-- Create a command to test ped spawning directly
RegisterCommand('testspawnped', function(source, args)
    local locationId = tonumber(args[1]) or 1
    if Config.SpawnLocations[locationId] then
        local success = ForceSpawnPed(locationId)
        if success then
            NotifyPlayer("Hostile ped spawned at location " .. locationId, "success")
        else
            NotifyPlayer("Failed to spawn hostile ped at location " .. locationId, "error")
        end
    else
        NotifyPlayer("Invalid location ID. Available locations: 1-" .. #Config.SpawnLocations, "error")
    end
end, false)

-- Create a command to teleport to a trigger area
RegisterCommand('gototrigger', function(source, args)
    local locationId = tonumber(args[1]) or 1
    if Config.SpawnLocations[locationId] then
        local playerPed = PlayerPedId()
        local coords = Config.SpawnLocations[locationId].triggerCoords
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, false)
        NotifyPlayer("Teleported to trigger area " .. locationId, "primary")
    else
        NotifyPlayer("Invalid location ID. Available locations: 1-" .. #Config.SpawnLocations, "error")
    end
end, false)

-- Initialize blips
Citizen.CreateThread(function()
    for i, location in ipairs(Config.SpawnLocations) do
        if location.blip and location.blip.enabled then
            local blip = AddBlipForCoord(location.triggerCoords.x, location.triggerCoords.y, location.triggerCoords.z)
            SetBlipSprite(blip, location.blip.sprite)
            SetBlipColour(blip, location.blip.color)
            SetBlipScale(blip, location.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(location.blip.label)
            EndTextCommandSetBlipName(blip)
            
            table.insert(blips, blip)
        end
    end
    
    NotifyPlayer("Script initialized with " .. #Config.SpawnLocations .. " spawn locations", "primary")
end)

-- Main thread for checking player distance and spawning peds
Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local anyNearby = false
        
        for i, location in ipairs(Config.SpawnLocations) do
            local distanceToTrigger = #(playerCoords - location.triggerCoords)
            
            -- If player is within range and ped hasn't been spawned yet
            if distanceToTrigger < Config.TriggerDistance then
                anyNearby = true
                if not spawnedPeds[i] or not DoesEntityExist(spawnedPeds[i]) then
                    NotifyPlayer("Player in range of " .. location.name .. ", spawning hostile ped...", "primary")
                    local success = ForceSpawnPed(i)
                    
                    if success then
                        NotifyPlayer("Hostile " .. location.name .. " spawned! Watch out!", "error")
                    else
                        NotifyPlayer("Failed to spawn hostile ped at " .. location.name, "error")
                    end
                end
            elseif distanceToTrigger > Config.DespawnDistance and spawnedPeds[i] and DoesEntityExist(spawnedPeds[i]) then
                -- Reset when player is far away
                DeleteEntity(spawnedPeds[i])
                spawnedPeds[i] = nil
                NotifyPlayer("Hostile ped at " .. location.name .. " removed as player left area", "primary")
            end
        end
        
        -- Adjust wait time based on if player is near any spawn points
        if anyNearby then
            Citizen.Wait(1000)
        else
            Citizen.Wait(3000)
        end
    end
end)

-- Function to force spawn a hostile ped
function ForceSpawnPed(locationId)
    local location = Config.SpawnLocations[locationId]
    if not location then return false end
    
    -- Delete existing ped if it exists
    if spawnedPeds[locationId] and DoesEntityExist(spawnedPeds[locationId]) then
        DeleteEntity(spawnedPeds[locationId])
        spawnedPeds[locationId] = nil
    end
    
    -- Try to load the model
    local modelHash = GetHashKey(location.pedModel)
    
    -- Check if model exists
    if not IsModelInCdimage(modelHash) then
        NotifyPlayer("Model does not exist: " .. location.pedModel, "error")
        -- Try a different model
        location.pedModel = "g_m_y_ballasout_01"
        modelHash = GetHashKey(location.pedModel)
        NotifyPlayer("Trying alternative model: " .. location.pedModel, "primary")
    end
    
    -- Request the model
    RequestModel(modelHash)
    
    -- Wait for model to load with timeout
    local startTime = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(10)
        
        -- Timeout after 5 seconds
        if GetGameTimer() - startTime > 5000 then
            NotifyPlayer("Model load timeout: " .. location.pedModel, "error")
            return false
        end
        
        -- Request model again
        RequestModel(modelHash)
    end
    
    -- Get ground Z coordinate
    local groundZ = location.pedSpawnCoords.z
    local success, zPos = GetGroundZFor_3dCoord(
        location.pedSpawnCoords.x, 
        location.pedSpawnCoords.y, 
        location.pedSpawnCoords.z + 10.0, 
        groundZ, 
        false
    )
    if success then
        groundZ = zPos
    end
    
    -- Create the ped
    spawnedPeds[locationId] = CreatePed(
        4, 
        modelHash, 
        location.pedSpawnCoords.x, 
        location.pedSpawnCoords.y, 
        groundZ, 
        0.0, 
        true, 
        false
    )
    
    -- Check if ped was created
    if not DoesEntityExist(spawnedPeds[locationId]) then
        NotifyPlayer("Failed to create hostile ped", "error")
        return false
    end
    
    -- Configure the ped
    SetEntityAsMissionEntity(spawnedPeds[locationId], true, true)
    SetModelAsNoLongerNeeded(modelHash)
    
    -- Make the ped hostile
    SetPedCombatAttributes(spawnedPeds[locationId], 46, true) -- BF_CanFightArmedPedsWhenNotArmed
    SetPedCombatAttributes(spawnedPeds[locationId], 5, true) -- BF_AlwaysFight
    SetPedCombatAttributes(spawnedPeds[locationId], 0, true) -- BF_CanUseCover
    SetPedCombatAttributes(spawnedPeds[locationId], 3, false) -- BF_BlockPermanentEvents
    SetPedFleeAttributes(spawnedPeds[locationId], 0, false) -- Don't flee
    SetPedRelationshipGroupHash(spawnedPeds[locationId], GetHashKey("HATES_PLAYER"))
    
    -- Give the ped a weapon
    GiveWeaponToPed(spawnedPeds[locationId], GetHashKey(location.weapon), 999, false, true)
    SetCurrentPedWeapon(spawnedPeds[locationId], GetHashKey(location.weapon), true)
    SetPedAccuracy(spawnedPeds[locationId], location.accuracy) -- Set accuracy (0-100)
    SetPedDropsWeaponsWhenDead(spawnedPeds[locationId], true)
    
    -- Make the ped attack the player
    local playerPed = PlayerPedId()
    TaskCombatPed(spawnedPeds[locationId], playerPed, 0, 16)
    
    -- Set relationship with player to hate
    SetRelationshipBetweenGroups(5, GetHashKey("HATES_PLAYER"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("HATES_PLAYER"))
    
    -- Make the ped more durable but not invincible
    SetPedArmour(spawnedPeds[locationId], location.armor)
    SetPedMaxHealth(spawnedPeds[locationId], location.health)
    SetEntityHealth(spawnedPeds[locationId], location.health)
    
    -- Start a thread to ensure the ped keeps attacking
    Citizen.CreateThread(function()
        local pedId = spawnedPeds[locationId]
        while DoesEntityExist(pedId) and not IsEntityDead(pedId) do
            local playerPed = PlayerPedId()
            if not IsPedInCombat(pedId, playerPed) then
                TaskCombatPed(pedId, playerPed, 0, 16)
            end
            Citizen.Wait(1000)
        end
    end)
    
    return true
end

-- Handle ped death and rewards
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        for i, ped in pairs(spawnedPeds) do
            if DoesEntityExist(ped) and IsEntityDead(ped) then
                local location = Config.SpawnLocations[i]
                NotifyPlayer("You defeated the hostile enemy at " .. location.name .. "!", "success")
                
                -- Wait a bit before removing the body
                Citizen.Wait(10000)
                
                -- Remove the ped
                DeleteEntity(ped)
                spawnedPeds[i] = nil
            end
        end
    end
end)

-- Draw markers and debug info
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local anyNearby = false
        
        for i, location in ipairs(Config.SpawnLocations) do
            local distanceToTrigger = #(playerCoords - location.triggerCoords)
            
            if distanceToTrigger < 50.0 then
                anyNearby = true
                
                if Config.Debug then
                    -- Draw marker at trigger location
                    DrawMarker(1, 
                        location.triggerCoords.x, 
                        location.triggerCoords.y, 
                        location.triggerCoords.z - 1.0, 
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                        Config.TriggerDistance * 2.0, 
                        Config.TriggerDistance * 2.0, 
                        0.5, 
                        255, 0, 0, 100, 
                        false, true, 2, nil, nil, false
                    )
                    
                    -- Draw marker at ped spawn location
                    DrawMarker(1, 
                        location.pedSpawnCoords.x, 
                        location.pedSpawnCoords.y, 
                        location.pedSpawnCoords.z - 1.0, 
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                        1.0, 1.0, 1.0, 
                        0, 255, 0, 100, 
                        false, true, 2, nil, nil, false
                    )
                    
                    -- Draw text at trigger location
                    DrawText3D(
                        location.triggerCoords.x, 
                        location.triggerCoords.y, 
                        location.triggerCoords.z, 
                        location.name .. " Trigger"
                    )
                    
                    -- Draw text at ped spawn location
                    DrawText3D(
                        location.pedSpawnCoords.x, 
                        location.pedSpawnCoords.y, 
                        location.pedSpawnCoords.z, 
                        location.name .. " Spawn"
                    )
                end
            end
        end
        
        if anyNearby then
            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

-- Function to draw 3D text
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end