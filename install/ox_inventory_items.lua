-- Copy the relevant blocks into ox_inventory.
-- Weapons: ox_inventory/data/weapons.lua  (inside the returned Weapons table)
-- Items:   ox_inventory/data/items.lua
-- Images:  copy install/inventory_images/*.png into ox_inventory/web/images/
-- The shop UI loads those same files via nui://ox_inventory/web/images/<item>.png

--[[
    WEAPONS — paste into ox_inventory/data/weapons.lua
]]

--[[
['WEAPON_SNAKEAP'] = {
    label = 'Snake AP',
    weight = 1400,
    durability = 0.1,
    ammoname = 'ammo-9',
},

['WEAPON_PATRICKSEMI'] = {
    label = 'Patrick Semi',
    weight = 1100,
    durability = 0.1,
    ammoname = 'ammo-9',
},

['WEAPON_DEVILAP'] = {
    label = 'Devil AP',
    weight = 1450,
    durability = 0.1,
    ammoname = 'ammo-9',
},

['WEAPON_SINISTERRED'] = {
    label = 'Sinister Red',
    weight = 1600,
    durability = 0.1,
    ammoname = 'ammo-9',
},

['WEAPON_PINKWIRESMG'] = {
    label = 'Pink Wire SMG',
    weight = 2400,
    durability = 0.1,
    ammoname = 'ammo-9',
},

['WEAPON_KISSAR'] = {
    label = 'Kiss AR',
    weight = 3400,
    durability = 0.1,
    ammoname = 'ammo-rifle',
},

['WEAPON_HAZARDAR'] = {
    label = 'Hazard AR',
    weight = 3600,
    durability = 0.1,
    ammoname = 'ammo-rifle',
},

['WEAPON_CHROMEWIRESMG'] = {
    label = 'Chrome Wire SMG',
    weight = 2500,
    durability = 0.1,
    ammoname = 'ammo-9',
},
]]

--[[
    ITEMS — paste into ox_inventory/data/items.lua
    ammo-9 / ammo-44 / ammo-rifle / ammo-shotgun / ammo-50 already exist in default ox_inventory.
    lockpick often exists too — only add it if you do not already have one.
]]

--[[
['blackmarket_gps'] = {
    label = 'Black Market GPS',
    weight = 200,
    stack = true,
    close = true,
    consume = 0,
    description = 'Marks the mountain black market on your GPS.',
    client = {
        event = 'dj_blackmarket:useGps',
    },
},

['robbery_tablet'] = {
    label = 'Robbery Tablet',
    weight = 500,
    stack = true,
    close = true,
    description = 'Encrypted tablet used to run jobs.',
},

['veh_pinkslip'] = {
    label = 'Vehicle Pink Slip',
    weight = 10,
    stack = true,
    close = false,
    description = 'Title paper for moving a vehicle off the books.',
},

['lockpick'] = {
    label = 'Lockpick',
    weight = 50,
    stack = true,
    close = true,
    description = 'A slim set of picks.',
},
]]
