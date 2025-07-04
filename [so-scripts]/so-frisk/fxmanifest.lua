fx_version 'cerulean'
game 'gta5'

author 'Shadow Ops'
description 'Frisk system for police to check weapons'
version '1.0.0'

shared_script 'config.lua' -- Load config file
client_script 'client.lua' -- Client-side script
server_script 'server.lua' -- Server-side script

dependencies {
    'qb-core',    -- QBCore framework
    'qb-target',   -- Target system for interaction
    'qb-radialmenu'
}
