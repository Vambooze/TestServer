local QBCore = exports['qb-core']:GetCoreObject()
local models = {
  "prop_dumpster_01a",
  "prop_cs_dumpster_01a",
  "prop_dumpster_4a",
  "prop_dumpster_3a",
  "prop_dumpster_4b",
  "m23_2_prop_m32_dumpster_01a",
  "prop_dumpster_02a",
  "p_dumpster_t"
}

CreateThread(function()
    for _, model in pairs(models) do
        exports['qb-target']:AddTargetModel(models, {
            options = {
                {
                    icon = 'fas fa-trash',
                    label = 'Hide in Dumpster',
                    action = function(entity)
                        if not isHiding then
                            HideInDumpster(entity)
                        end
                    end,
                },
            },
            distance = 2.5
        })
    end
end)


function HideInDumpster(dumpster)
    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_BUM_STANDING", 0, true)
    Wait(1500)
    local coords = GetEntityCoords(dumpster)
    SetEntityCoords(ped, coords.x, coords.y, coords.z - 1.0, false, false, false, false)
    SetEntityVisible(ped, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityCollision(ped, false, false)
    isHiding = true
    QBCore.Functions.Notify("You are now hiding. Press (E) to exit.", "primary", 5000)


    CreateThread(function()
        while isHiding do
            Wait(0)
            if IsControlJustReleased(0, 38) then 
                ExitDumpster()
            end
        end
    end)
end

function ExitDumpster()
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    SetEntityCollision(ped, true, true)
    ClearPedTasks(ped)
    local coords = GetEntityCoords(PlayerPedId())
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z +2.0 )
    isHiding = false
    hidingDumpster = nil
    QBCore.Functions.Notify("You exited the dumpster.", "success", 3000)
end