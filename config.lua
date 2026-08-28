Config = {}

-- auto | esx | qb | qbx
Config.Framework = 'auto'

-- Mount Chiliad summit
Config.Dealer = {
    model = `g_m_m_chigoon_02`,
    coords = vec4(450.24, 5566.52, 795.19, 85.0),
    scenario = 'WORLD_HUMAN_SMOKING',
    interactId = 'dj_blackmarket_dealer',
    interactLabel = 'Open Black Market',
    spawnDistance = 80.0,
}

-- Street contact that sells only the GPS so players can find the mountain dealer
Config.GpsVendor = {
    enabled = true,
    model = `g_m_y_mexgoon_01`,
    coords = vec4(127.92, -1929.90, 20.38, 231.0),
    scenario = 'WORLD_HUMAN_STAND_IMPATIENT',
    interactId = 'dj_blackmarket_gps_vendor',
    interactLabel = 'Buy Black Market GPS',
    spawnDistance = 60.0,
    item = 'blackmarket_gps',
    priceBlack = 4000,
    priceCash = 6500,
}

Config.Gps = {
    item = 'blackmarket_gps',
    consumeOnUse = false,
    notifyTitle = 'Black Market GPS',
    notifyDesc = 'Signal locked. Head to the peak of Mount Chiliad.',
    blip = {
        enabled = true,
        sprite = 161,
        color = 1,
        scale = 0.9,
        label = 'Black Market',
        duration = 120000, -- ms, 0 = waypoint only
    },
}

-- interact (darktrovx) | ox_target | drawtext
Config.Interact = {
    system = 'interact',
    distance = 8.0,
    interactDst = 1.6,
    offset = vec3(0.0, 0.0, 0.15),
}

Config.PurchaseCooldown = 1500
Config.MaxDealDistance = 6.0

-- Jobs that cannot use the dealer
Config.BlockedJobs = {
    police = true,
    sheriff = true,
    leo = true,
}

Config.Categories = {
    { id = 'pistols', label = 'Pistols' },
    { id = 'ars',     label = 'ARs' },
    { id = 'ammo',    label = 'Ammo' },
    { id = 'bm',      label = 'BM Items' },
}

--[[
    priceBlack = dirty money cost
    priceCash  = clean cash cost (always higher)
    max        = max quantity per purchase
]]
Config.Items = {
    -- Pistols
    {
        category = 'pistols',
        item = 'WEAPON_SNAKEAP',
        label = 'Snake AP',
        description = 'Neon snakeskin AP pistol. Loud, toxic, and built to dump a mag.',
        priceBlack = 75000,
        priceCash = 115000,
        max = 1,
    },
    {
        category = 'pistols',
        item = 'WEAPON_PATRICKSEMI',
        label = 'Patrick Semi',
        description = 'Pink-and-green custom semi. Stupid looking. Still shoots straight.',
        priceBlack = 70000,
        priceCash = 105000,
        max = 1,
    },
    {
        category = 'pistols',
        item = 'WEAPON_DEVILAP',
        label = 'Devil AP',
        description = 'White slide, ruby crystal frame. Close-range problem solver.',
        priceBlack = 90000,
        priceCash = 135000,
        max = 1,
    },
    {
        category = 'pistols',
        item = 'WEAPON_SINISTERRED',
        label = 'Sinister Red',
        description = 'Black-and-red drum AP with the white-star splash. High capacity.',
        priceBlack = 95000,
        priceCash = 145000,
        max = 1,
    },

    -- ARs
    {
        category = 'ars',
        item = 'WEAPON_PINKWIRESMG',
        label = 'Pink Wire SMG',
        description = 'Wireframe SMG with neon pink guts. Compact and nasty.',
        priceBlack = 140000,
        priceCash = 210000,
        max = 1,
    },
    {
        category = 'ars',
        item = 'WEAPON_KISSAR',
        label = 'Kiss AR',
        description = 'White rifle covered in lipstick marks. Pretty until it isn\'t.',
        priceBlack = 155000,
        priceCash = 235000,
        max = 1,
    },
    {
        category = 'ars',
        item = 'WEAPON_HAZARDAR',
        label = 'Hazard AR',
        description = 'Yellow-and-black caution rifle with a drum. Biohazard branded.',
        priceBlack = 165000,
        priceCash = 250000,
        max = 1,
    },
    {
        category = 'ars',
        item = 'WEAPON_CHROMEWIRESMG',
        label = 'Chrome Wire SMG',
        description = 'Chrome body, honeycomb suppressor, drum mag. Quiet chrome.',
        priceBlack = 150000,
        priceCash = 225000,
        max = 1,
    },

    -- Ammo
    {
        category = 'ammo',
        item = 'ammo-9',
        label = '9mm Ammo',
        description = 'Pistol rounds. Sold per round.',
        priceBlack = 8,
        priceCash = 12,
        max = 250,
        defaultAmount = 30,
    },
    {
        category = 'ammo',
        item = 'ammo-44',
        label = '.44 Ammo',
        description = 'Heavy revolver / pistol rounds. Sold per round.',
        priceBlack = 12,
        priceCash = 18,
        max = 120,
        defaultAmount = 24,
    },
    {
        category = 'ammo',
        item = 'ammo-rifle',
        label = 'Rifle Ammo',
        description = 'Rifle cartridges. Sold per round.',
        priceBlack = 10,
        priceCash = 15,
        max = 250,
        defaultAmount = 30,
    },
    {
        category = 'ammo',
        item = 'ammo-shotgun',
        label = 'Shotgun Ammo',
        description = '12-gauge shells. Sold per round.',
        priceBlack = 15,
        priceCash = 22,
        max = 80,
        defaultAmount = 16,
    },
    {
        category = 'ammo',
        item = 'ammo-50',
        label = '.50 Ammo',
        description = 'Heavy .50 rounds. Sold per round.',
        priceBlack = 25,
        priceCash = 38,
        max = 60,
        defaultAmount = 12,
    },

    -- BM Items
    {
        category = 'bm',
        item = 'robbery_tablet',
        label = 'Robbery Tablet',
        description = 'Encrypted tablet used to run jobs. No questions asked.',
        priceBlack = 12500,
        priceCash = 19000,
        max = 5,
    },
    {
        category = 'bm',
        item = 'lockpick',
        label = 'Lockpick',
        description = 'Slim-jim set. Doors, cars, whatever you shouldn\'t be opening.',
        priceBlack = 350,
        priceCash = 525,
        max = 10,
        defaultAmount = 1,
    },
    {
        category = 'bm',
        item = 'veh_pinkslip',
        label = 'Vehicle Pink Slip',
        description = 'Clean-enough paper for moving a vehicle off the books.',
        priceBlack = 35000,
        priceCash = 52500,
        max = 3,
    },
    {
        category = 'bm',
        item = 'blackmarket_gps',
        label = 'Black Market GPS',
        description = 'Marks the mountain dealer on your map. Keep it close.',
        priceBlack = 4000,
        priceCash = 6500,
        max = 5,
    },
}

Config.Notify = {
    blocked = 'I don\'t sell to your kind. Walk.',
    tooFar = 'You wandered off. Deal\'s dead.',
    cooldown = 'Slow down.',
    invalid = 'That item isn\'t on the list.',
    noMoney = 'You\'re short.',
    noItem = 'Couldn\'t stash that. Check your pockets.',
    purchased = 'We never met.',
    gpsBought = 'Coordinates loaded. Don\'t lose that unit.',
}
