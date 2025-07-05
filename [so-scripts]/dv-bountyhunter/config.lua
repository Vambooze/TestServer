Config = {}

-- General Settings
Config.Debug = true -- Enable/disable debug messages
Config.TriggerDistance = 7.0 -- Distance at which peds will spawn
Config.DespawnDistance = 80.0 -- Distance at which peds will despawn

-- Spawn Locations
Config.SpawnLocations = {
    {
        name = "Downtown Ambush",
        triggerCoords = vector3(124.73, 64.71, 79.74),
        pedSpawnCoords = vector3(135.19, 72.89, 80.08),
        pedModel = "g_m_y_lost_01",
        weapon = "WEAPON_PISTOL",
        accuracy = 50,
        health = 200,
        armor = 100,
        blip = {
            enabled = true,
            sprite = 1,
            color = 1,
            scale = 0.8,
            label = "Hostile Zone"
        }
    },
    {
        name = "Beach Attack",
        triggerCoords = vector3(-1520.0, -1043.0, 5.0),
        pedSpawnCoords = vector3(-1530.0, -1040.0, 5.0),
        pedModel = "g_m_y_ballasout_01",
        weapon = "WEAPON_SMG",
        accuracy = 60,
        health = 250,
        armor = 150,
        blip = {
            enabled = true,
            sprite = 1,
            color = 1,
            scale = 0.8,
            label = "Hostile Zone"
        }
    },
    {
        name = "Mountain Sniper",
        triggerCoords = vector3(500.0, 5593.0, 795.0),
        pedSpawnCoords = vector3(510.0, 5590.0, 796.0),
        pedModel = "s_m_y_blackops_01",
        weapon = "WEAPON_SNIPERRIFLE",
        accuracy = 80,
        health = 150,
        armor = 50,
        blip = {
            enabled = true,
            sprite = 1,
            color = 1,
            scale = 0.8,
            label = "Hostile Zone"
        }
    }
}

-- Ped Models List (for reference)
Config.PedModels = {
    -- Gang Members
    "g_m_y_lost_01",      -- Lost MC
    "g_m_y_lost_02",      -- Lost MC
    "g_m_y_ballasout_01", -- Ballas
    "g_m_y_famca_01",     -- Families
    "g_m_y_mexgoon_01",   -- Cartel
    "g_m_y_mexgoon_02",   -- Cartel
    "g_m_y_mexgoon_03",   -- Cartel
    
    -- Military/Police
    "s_m_y_blackops_01",  -- Black Ops
    "s_m_y_blackops_02",  -- Black Ops
    "s_m_y_swat_01",      -- SWAT
    "s_m_m_marine_01",    -- Marine
    "s_m_y_ranger_01",    -- Ranger
    
    -- Others
    "a_m_y_methhead_01",  -- Meth head
    "u_m_y_juggernaut_01" -- Juggernaut (very tough)
}

-- Weapon List (for reference)
Config.Weapons = {
    -- Handguns
    "WEAPON_PISTOL",
    "WEAPON_COMBATPISTOL",
    "WEAPON_HEAVYPISTOL",
    
    -- SMGs
    "WEAPON_SMG",
    "WEAPON_MICROSMG",
    "WEAPON_ASSAULTSMG",
    
    -- Assault Rifles
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_CARBINERIFLE",
    "WEAPON_ADVANCEDRIFLE",
    
    -- Shotguns
    "WEAPON_PUMPSHOTGUN",
    "WEAPON_SAWNOFFSHOTGUN",
    "WEAPON_BULLPUPSHOTGUN",
    
    -- Sniper Rifles
    "WEAPON_SNIPERRIFLE",
    "WEAPON_HEAVYSNIPER",
    
    -- Heavy Weapons
    "WEAPON_RPG",
    "WEAPON_MINIGUN"
}