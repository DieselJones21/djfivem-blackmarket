local spawned = {}
local nuiOpen = false
local gpsBlip

local function vec3From(coords)
    return vec3(coords.x, coords.y, coords.z)
end

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return false end
        Wait(10)
    end
    return true
end

local function groundZ(coords)
    local found, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 2.0, false)
    if found then
        return z
    end
    return coords.z
end

local function deletePed(id)
    local data = spawned[id]
    if not data then return end

    if data.interactId and GetResourceState('interact') == 'started' then
        pcall(function()
            exports.interact:RemoveLocalEntityInteraction(data.ped, data.interactId)
        end)
        pcall(function()
            exports.interact:RemoveInteraction(data.interactId)
        end)
    end

    if data.target and GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeLocalEntity(data.ped)
    end

    if data.ped and DoesEntityExist(data.ped) then
        DeleteEntity(data.ped)
    end

    spawned[id] = nil
end

local function addInteract(id, ped, label, onSelect)
    local system = Config.Interact.system
    local interactId = ('dj_blackmarket_%s'):format(id)

    if system == 'interact' and GetResourceState('interact') == 'started' then
        exports.interact:AddLocalEntityInteraction({
            entity = ped,
            id = interactId,
            name = interactId,
            distance = Config.Interact.distance,
            interactDst = Config.Interact.interactDst,
            offset = Config.Interact.offset,
            options = {
                {
                    label = label,
                    action = function()
                        onSelect()
                    end,
                },
            },
        })
        return interactId, false
    end

    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = interactId,
                icon = 'fa-solid fa-comments',
                label = label,
                distance = Config.Interact.interactDst + 0.8,
                onSelect = onSelect,
            },
        })
        return interactId, true
    end

    return interactId, false
end

local function spawnPed(id, def)
    if spawned[id] and spawned[id].ped and DoesEntityExist(spawned[id].ped) then
        return
    end

    if not loadModel(def.model) then return end

    local z = groundZ(def.coords)
    local ped = CreatePed(0, def.model, def.coords.x, def.coords.y, z, def.coords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetPedDefaultComponentVariation(ped)
    PlacePedOnGroundProperly(ped)
    SetEntityHeading(ped, def.coords.w)
    FreezeEntityPosition(ped, true)

    if def.scenario then
        TaskStartScenarioInPlace(ped, def.scenario, 0, true)
    end

    SetModelAsNoLongerNeeded(def.model)

    spawned[id] = {
        ped = ped,
        def = def,
    }

    local interactId, usedTarget = addInteract(id, ped, def.interactLabel, function()
        OpenBlackMarket(id)
    end)

    spawned[id].interactId = interactId
    spawned[id].target = usedTarget
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
                    image = 'images/blackmarket_gps.png',
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
            image = ('images/%s.png'):format(entry.item),
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
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())
        local dealerDist = #(playerCoords - vec3From(Config.Dealer.coords))

        if dealerDist < Config.Dealer.spawnDistance then
            spawnPed('dealer', Config.Dealer)
        else
            deletePed('dealer')
        end

        if Config.GpsVendor.enabled then
            local gpsDist = #(playerCoords - vec3From(Config.GpsVendor.coords))
            if gpsDist < Config.GpsVendor.spawnDistance then
                spawnPed('gps', Config.GpsVendor)
            else
                deletePed('gps')
            end
        end

        if Config.Interact.system == 'drawtext' then
            local showing = false
            for id, data in pairs(spawned) do
                if data.ped and DoesEntityExist(data.ped) then
                    local dist = #(playerCoords - GetEntityCoords(data.ped))
                    if dist < Config.Interact.interactDst + 0.4 then
                        showing = true
                        lib.showTextUI(('[E] %s'):format(data.def.interactLabel))
                        if IsControlJustReleased(0, 38) then
                            OpenBlackMarket(id)
                        end
                    end
                end
            end
            if not showing then
                lib.hideTextUI()
            end
            Wait(showing and 0 or 1000)
        else
            Wait(1000)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeUi()
    deletePed('dealer')
    deletePed('gps')
    if gpsBlip and DoesBlipExist(gpsBlip) then
        RemoveBlip(gpsBlip)
    end
    lib.hideTextUI()
end)
