local spawned = {}
local nuiOpen = false
local gpsBlip

local function vec3From(coords)
    return vec3(coords.x, coords.y, coords.z)
end

local function loadModel(model)
    if type(model) == 'string' then
        model = joaat(model)
    end
    if not IsModelInCdimage(model) or not IsModelValid(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return false end
        Wait(10)
    end
    return model
end

local function waitForInteract()
    local timeout = GetGameTimer() + 15000
    while GetResourceState('interact') ~= 'started' do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(100)
    end
    return true
end

local function deletePed(id)
    local data = spawned[id]
    if not data then return end

    if GetResourceState('interact') == 'started' then
        local interactId = data.interactId
        pcall(function()
            if data.ped then
                exports.interact:RemoveLocalEntityInteraction(data.ped, interactId)
            end
        end)
        pcall(function()
            exports.interact:RemoveInteraction(interactId)
        end)
    end

    if data.ped and DoesEntityExist(data.ped) then
        DeleteEntity(data.ped)
    end

    spawned[id] = nil
end

local function addInteract(id, def, ped, onSelect)
    if not waitForInteract() then
        return nil
    end

    local interactId = def.interactId or ('dj_blackmarket_%s'):format(id)

    pcall(function()
        exports.interact:RemoveLocalEntityInteraction(ped, interactId)
        exports.interact:RemoveInteraction(interactId)
    end)

    local ok = pcall(function()
        exports.interact:AddLocalEntityInteraction({
            entity = ped,
            id = interactId,
            name = interactId,
            distance = Config.Interact.distance,
            interactDst = Config.Interact.interactDst,
            ignoreLos = Config.Interact.ignoreLos ~= false,
            offset = Config.Interact.offset or vec3(0.0, 0.0, 1.0),
            options = {
                {
                    label = def.interactLabel,
                    action = function()
                        onSelect()
                    end,
                },
            },
        })
    end)

    if not ok then
        return nil
    end

    return interactId
end

local function placePed(ped, coords)
    local x, y, z, heading = coords.x, coords.y, coords.z, coords.w
    RequestCollisionAtCoord(x, y, z)
    SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
    SetEntityHeading(ped, heading)
    FreezeEntityPosition(ped, true)
end

local function spawnPed(id, def)
    if spawned[id] and spawned[id].ped and DoesEntityExist(spawned[id].ped) then
        local dist = #(GetEntityCoords(spawned[id].ped) - vec3(def.coords.x, def.coords.y, def.coords.z))
        if dist > 1.5 then
            placePed(spawned[id].ped, def.coords)
        end
        return
    end

    if spawned[id] then
        deletePed(id)
    end

    local model = loadModel(def.model)
    if not model then return end

    local x, y, z, heading = def.coords.x, def.coords.y, def.coords.z, def.coords.w
    RequestCollisionAtCoord(x, y, z)

    local ped = CreatePed(0, model, x, y, z, heading, false, true)
    if not ped or ped == 0 then
        SetModelAsNoLongerNeeded(model)
        return
    end

    SetEntityAsMissionEntity(ped, true, true)
    placePed(ped, def.coords)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetPedDefaultComponentVariation(ped)

    if def.scenario then
        ClearPedTasksImmediately(ped)
        placePed(ped, def.coords)
        TaskStartScenarioInPlace(ped, def.scenario, 0, true)
        placePed(ped, def.coords)
    end

    SetModelAsNoLongerNeeded(model)
    Wait(100)
    placePed(ped, def.coords)

    spawned[id] = {
        ped = ped,
        def = def,
    }

    local ok, interactId = pcall(addInteract, id, def, ped, function()
        OpenBlackMarket(id)
    end)
    spawned[id].interactId = ok and interactId or (def.interactId or ('dj_blackmarket_%s'):format(id))
end

local function itemImage(itemName, custom)
    local file = custom
    if not file or file == '' then
        file = ('%s.%s'):format(itemName, Config.Images.extension or 'png')
    elseif not file:find('%.') then
        file = ('%s.%s'):format(file, Config.Images.extension or 'png')
    end

    if file:find('nui://', 1, true) or file:find('http', 1, true) or file:find('images/', 1, true) then
        return file
    end

    local resource = Config.Images.resource or 'ox_inventory'
    local folder = Config.Images.folder or 'web/images'
    return ('nui://%s/%s/%s'):format(resource, folder, file)
end

local function shopPayload(shop)
    if shop == 'gps' then
        return {
            shop = 'gps',
            title = 'Street Contact',
            subtitle = 'Los Santos',
            initials = 'BM',
            location = 'Los Santos',
            categories = {
                { id = 'gps', label = 'Locator' },
            },
            items = {
                {
                    category = 'gps',
                    item = Config.GpsVendor.item,
                    label = 'Black Market GPS',
                    description = 'Marks the mountain dealer. Don\'t flash it around cops.',
                    priceBlack = Config.GpsVendor.priceBlack,
                    priceCash = Config.GpsVendor.priceCash,
                    max = 5,
                    defaultAmount = 1,
                    image = itemImage(Config.GpsVendor.item),
                },
            },
        }
    end

    local items = {}
    for i = 1, #Config.Items do
        local entry = Config.Items[i]
        items[#items + 1] = {
            category = entry.category,
            item = entry.item,
            label = entry.label,
            description = entry.description,
            priceBlack = entry.priceBlack,
            priceCash = entry.priceCash,
            max = entry.max or 1,
            defaultAmount = entry.defaultAmount or 1,
            image = itemImage(entry.item, entry.image),
        }
    end

    return {
        shop = 'dealer',
        title = Config.Shop.name or 'Black Market',
        subtitle = Config.Shop.location or 'Mount Chiliad',
        initials = Config.Shop.initials or 'BM',
        location = Config.Shop.location or 'Mount Chiliad',
        categories = Config.Categories,
        items = items,
    }
end

function OpenBlackMarket(shop)
    if nuiOpen then return end

    local result = lib.callback.await('dj_blackmarket:canOpen', false, shop)
    if not result or not result.ok then
        local reason = result and result.reason
        if reason == 'blocked' then
            lib.notify({ title = 'Black Market', description = Config.Notify.blocked, type = 'error' })
        else
            lib.notify({ title = 'Black Market', description = Config.Notify.tooFar, type = 'error' })
        end
        return
    end

    local payload = shopPayload(shop)
    payload.money = result.money or { cash = 0, black_money = 0 }
    payload.player = result.player or {
        name = GetPlayerName(PlayerId()),
        role = Config.Shop.customerRole or 'Customer',
    }

    nuiOpen = true
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({
        action = 'open',
        data = payload,
    })
end

local function closeUi()
    if not nuiOpen then return end
    nuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb({ ok = true })
end)

RegisterNUICallback('checkout', function(data, cb)
    local result = lib.callback.await('dj_blackmarket:checkout', false, data)
    if result and result.ok then
        lib.notify({ title = 'Black Market', description = result.message or Config.Notify.purchased, type = 'success' })
    elseif result and result.error then
        lib.notify({ title = 'Black Market', description = result.error, type = 'error' })
    end
    cb(result or { ok = false })
end)

RegisterNUICallback('purchase', function(data, cb)
    local result = lib.callback.await('dj_blackmarket:purchase', false, data)
    if result and result.ok then
        lib.notify({ title = 'Black Market', description = result.message or Config.Notify.purchased, type = 'success' })
    elseif result and result.error then
        lib.notify({ title = 'Black Market', description = result.error, type = 'error' })
    end
    cb(result or { ok = false })
end)

local function useGps()
    local coords = Config.Dealer.coords
    SetNewWaypoint(coords.x, coords.y)

    if gpsBlip and DoesBlipExist(gpsBlip) then
        RemoveBlip(gpsBlip)
        gpsBlip = nil
    end

    if Config.Gps.blip.enabled then
        gpsBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(gpsBlip, Config.Gps.blip.sprite)
        SetBlipColour(gpsBlip, Config.Gps.blip.color)
        SetBlipScale(gpsBlip, Config.Gps.blip.scale)
        SetBlipAsShortRange(gpsBlip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Gps.blip.label)
        EndTextCommandSetBlipName(gpsBlip)

        if Config.Gps.blip.duration and Config.Gps.blip.duration > 0 then
            local blip = gpsBlip
            SetTimeout(Config.Gps.blip.duration, function()
                if gpsBlip == blip and DoesBlipExist(blip) then
                    RemoveBlip(blip)
                    if gpsBlip == blip then
                        gpsBlip = nil
                    end
                end
            end)
        end
    end

    lib.notify({
        title = Config.Gps.notifyTitle,
        description = Config.Gps.notifyDesc,
        type = 'success',
    })
end

exports('useGps', useGps)

CreateThread(function()
    pcall(function()
        exports.ox_inventory:displayMetadata({
            registered = 'Registered',
        })
    end)
end)

-- ox_inventory usable item via export in items.lua; also register a fallback event
RegisterNetEvent('dj_blackmarket:useGps', function()
    useGps()
end)

CreateThread(function()
    while GetResourceState('interact') ~= 'started' do
        Wait(200)
    end

    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dealerDist = #(playerCoords - vec3From(Config.Dealer.coords))

        if dealerDist < Config.Dealer.spawnDistance then
            pcall(spawnPed, 'dealer', Config.Dealer)
        else
            deletePed('dealer')
        end

        if Config.GpsVendor.enabled then
            local gpsDist = #(playerCoords - vec3From(Config.GpsVendor.coords))
            if gpsDist < Config.GpsVendor.spawnDistance then
                pcall(spawnPed, 'gps', Config.GpsVendor)
            else
                deletePed('gps')
            end
        end

        Wait(1000)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= 'interact' then return end
    deletePed('dealer')
    deletePed('gps')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeUi()
    deletePed('dealer')
    deletePed('gps')
    if gpsBlip and DoesBlipExist(gpsBlip) then
        RemoveBlip(gpsBlip)
    end
end)
