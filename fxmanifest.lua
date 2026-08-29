fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'djfivem-blackmarket'
author 'DieselJones21'
description 'Custom black market dealer with pistols, ARs, ammo, BM items, and a GPS locator'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/bridge.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/images/*.png',
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'interact',
}
