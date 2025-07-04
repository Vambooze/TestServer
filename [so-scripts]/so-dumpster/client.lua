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

exports['qb-target']:AddTargetModel(models, {
  options = {
    {
      num = 1,
      type = "client",
      event = "so-dumpster:client:hide",
      icon = "fas fa-dumpster",
      label = "Hide",
      targeticon = "fas fa-dumpster",
    }
  },
  distance = 1.5
})

-- Function to get the closest dumpster to a player
RegisterNetEvent('so-dumpster:client:hide', function()
    local function getClosestDumpster(playerPed)
    local dumpsterModels = {
    "prop_dumpster_01a",
    "prop_cs_dumpster_01a",
    "prop_dumpster_4a",
    "prop_dumpster_3a",
    "prop_dumpster_4b",
    "m23_2_prop_m32_dumpster_01a",
    "prop_dumpster_02a",
    "p_dumpster_t"
    }, -- Example dumpster model, you might need to add more
    local closestDumpster = nil
    local closestDistance = 1000.0
    
    for _, model in ipairs(dumpsterModels) do
        local dumpsterHash = GetHashKey(model)
        local dumpsters = GetGamePool('CObject')
        
        for _, dumpster in ipairs(dumpsters) do
            if GetEntityModel(dumpster) == dumpsterHash then
                local dumpsterCoords = GetEntityCoords(dumpster)
                local distance = #(dumpsterCoords - GetEntityCoords(playerPed))
                
                if distance < closestDistance then
                    closestDumpster = dumpster
                    closestDistance = distance
                end
            end
        end
    end
    
    return closestDumpster
end

-- Main execution
local playerPed = PlayerPedId()
local closestDumpster = getClosestDumpster(playerPed)

if closestDumpster ~= nil then
    local dumpsterCoords = GetEntityCoords(closestDumpster)
    -- Adjust the position slightly to "inside" the dumpster
    -- This is a simple adjustment; you might need to adjust based on the dumpster's orientation or size
    local insideDumpsterCoords = vector3(dumpsterCoords.x, dumpsterCoords.y, dumpsterCoords.z + 0.5)
    
    -- Set the player inside the dumpster
    SetEntityCoords(playerPed, insideDumpsterCoords.x, insideDumpsterCoords.y, insideDumpsterCoords.z, false, false, false, false)
else
    print("No dumpster found nearby.")
end)