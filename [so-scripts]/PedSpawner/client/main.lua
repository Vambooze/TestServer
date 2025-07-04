-- Configuration
local buttonCoords = vector3(100.0, 100.0, 70.0) -- Where the button is
local pedSpawnCoords = vector3(150.0, 150.0, 70.0) -- Where the ped will spawn
local pedModel = "a_m_m_business_01" -- Model of the ped to spawn
local interactionKey = 38 -- E key

-- Variables
local buttonBlip = nil
local spawnedPed = nil

Citizen.CreateThread(function()
    -- Create a blip for the button
    buttonBlip = AddBlipForCoord(buttonCoords.x, buttonCoords.y, buttonCoords.z)
    SetBlipSprite(buttonBlip, 1)
    SetBlipColour(buttonBlip, 2)
    SetBlipAsShortRange(buttonBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Spawn Ped")
    EndTextCommandSetBlipName(buttonBlip)

    -- Main loop
    while true do
        Citizen.Wait(0)
        
        -- Draw text label at button location
        DrawText3D(buttonCoords.x, buttonCoords.y, buttonCoords.z, "Press ~g~E~s~ to spawn ped")

        -- Check if player is near the button and presses the interaction key
        local playerCoords = GetEntityCoords(GetPlayerPed(-1))
        local distanceToButton = #(playerCoords - buttonCoords)
        if distanceToButton < 2.0 then
            if IsControlJustReleased(0, interactionKey) then
                -- Spawn the ped
                SpawnPed()
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function SpawnPed()
    -- Load the ped model
    RequestModel(GetHashKey(pedModel))
    while not HasModelLoaded(GetHashKey(pedModel)) do
        Citizen.Wait(1)
    end

    -- Spawn the ped
    spawnedPed = CreatePed(4, GetHashKey(pedModel), pedSpawnCoords.x, pedSpawnCoords.y, pedSpawnCoords.z, 0.0, true, false)
    SetEntityAsMissionEntity(spawnedPed, true, true)
    SetModelAsNoLongerNeeded(GetHashKey(pedModel))
end