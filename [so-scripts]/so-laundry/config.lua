Config = Config or {}

-- Set to true or false or GetConvar('UseTarget', 'false') == 'true' to use global option or script specific
-- These have to be a string thanks to how Convars are returned.
Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'

Config.Timeout = 30 * (60 * 2000)
Config.RequiredCops = 0
Config.LaundryLocation = {
    ['coords'] = vector3(894.50, -1030.27, 39.98),
}

Config.WhitelistedWeapons = {
    [`weapon_assaultrifle`] = {
        ['timeOut'] = 10000
    },
    [`weapon_carbinerifle`] = {
        ['timeOut'] = 10000
    },
    [`weapon_pumpshotgun`] = {
        ['timeOut'] = 10000
    },
    [`weapon_sawnoffshotgun`] = {
        ['timeOut'] = 10000
    },
    [`weapon_compactrifle`] = {
        ['timeOut'] = 10000
    },
    [`weapon_microsmg`] = {
        ['timeOut'] = 10000
    },
    [`weapon_ceramicpistol`] = {
        ['timeOut'] = 10000
    },
    [`weapon_pistol`] = {
        ['timeOut'] = 10000
    },
    [`weapon_pistol_mk2`] = {
        ['timeOut'] = 10000
    },
    [`weapon_heavypistol`] = {
        ['timeOut'] = 10000
    },
    [`weapon_appistol`] = {
        ['timeOut'] = 10000
    },
    [`weapon_pistol50`] = {
        ['timeOut'] = 10000
    },
}


Config.Locations = {
    [1] = {
        ['coords'] = vector3(897.11, -1039.76, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [2] = {
        ['coords'] = vector3(898.37, -1039.96, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [3] = {
        ['coords'] = vector3(899.40, -1039.75, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [4] = {
        ['coords'] = vector3(900.66, -1039.96, 35.52),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [5] = {
        ['coords'] = vector3(901.70, -1040.05, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [6] = {
        ['coords'] = vector3(901.89, -1042.99, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [7] = {
        ['coords'] = vector3(900.73, -1042.96, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [8] = {
        ['coords'] = vector3(899.53, -1043.17, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [9] = {
        ['coords'] = vector3(898.32, -1042.95, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    },
    [10] = {
        ['coords'] = vector3(897.13, -1042.96, 35.25),
        ['isOpened'] = false,
        ['isBusy'] = false,
    }
}
