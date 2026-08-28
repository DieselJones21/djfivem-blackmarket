local itemsByName = {}
local lastPurchase = {}

CreateThread(function()
    for i = 1, #Config.Items do
        local entry = Config.Items[i]
        itemsByName[entry.item] = entry
    end
end)

local function dealerCoords()
    local c = Config.Dealer.coords
    return vec3(c.x, c.y, c.z)
end

local function gpsVendorCoords()
    local c = Config.GpsVendor.coords
    return vec3(c.x, c.y, c.z)
end

local function isNearShop(src, shop)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end

    local coords = GetEntityCoords(ped)
    local maxDist = Config.MaxDealDistance + 2.0

    if shop == 'gps' then
        if not Config.GpsVendor.enabled then return false end
        return #(coords - gpsVendorCoords()) <= maxDist
    end

    return #(coords - dealerCoords()) <= maxDist
end

local function isBlocked(src)
    local job = Bridge.GetJobName(src)
    return job and Config.BlockedJobs[job] == true
end

lib.callback.register('dj_blackmarket:getMoney', function(source)
    return Bridge.GetMoney(source)
end)

lib.callback.register('dj_blackmarket:canOpen', function(source, shop)
    if isBlocked(source) then
        return { ok = false, reason = 'blocked' }
    end

    if not isNearShop(source, shop or 'dealer') then
        return { ok = false, reason = 'too_far' }
    end

    return { ok = true, money = Bridge.GetMoney(source) }
end)

lib.callback.register('dj_blackmarket:purchase', function(source, data)
    if type(data) ~= 'table' then
        return { ok = false, error = Config.Notify.invalid }
    end

    local shop = data.shop == 'gps' and 'gps' or 'dealer'
    local itemName = tostring(data.item or '')
    local method = data.method == 'cash' and 'cash' or 'black_money'
    local amount = math.floor(tonumber(data.amount) or 1)

    if isBlocked(source) then
        return { ok = false, error = Config.Notify.blocked }
    end

    if not isNearShop(source, shop) then
        return { ok = false, error = Config.Notify.tooFar }
    end

    local now = GetGameTimer()
    if lastPurchase[source] and (now - lastPurchase[source]) < Config.PurchaseCooldown then
        return { ok = false, error = Config.Notify.cooldown }
    end

    local entry

    if shop == 'gps' then
        if itemName ~= Config.GpsVendor.item then
            return { ok = false, error = Config.Notify.invalid }
        end

        entry = {
            item = Config.GpsVendor.item,
            priceBlack = Config.GpsVendor.priceBlack,
            priceCash = Config.GpsVendor.priceCash,
            max = 5,
        }
    else
        entry = itemsByName[itemName]
        if not entry then
            return { ok = false, error = Config.Notify.invalid }
        end
    end

    if amount < 1 then amount = 1 end
    if amount > (entry.max or 1) then
        amount = entry.max or 1
    end

    local unitPrice = method == 'cash' and entry.priceCash or entry.priceBlack
    local total = unitPrice * amount

    if not Bridge.CanCarry(source, entry.item, amount) then
        return { ok = false, error = Config.Notify.noItem }
    end

    if not Bridge.RemoveMoney(source, method, total) then
        return { ok = false, error = Config.Notify.noMoney }
    end

    local metadata
    if entry.item:find('WEAPON_', 1, true) == 1 then
        metadata = { registered = false }
    end

    local added = Bridge.AddItem(source, entry.item, amount, metadata)
    if not added then
        Bridge.AddMoney(source, method, total)
        return { ok = false, error = Config.Notify.noItem, money = Bridge.GetMoney(source) }
    end

    lastPurchase[source] = now

    local money = Bridge.GetMoney(source)
    return {
        ok = true,
        message = shop == 'gps' and Config.Notify.gpsBought or Config.Notify.purchased,
        money = money,
    }
end)

AddEventHandler('playerDropped', function()
    lastPurchase[source] = nil
end)

CreateThread(function()
    Wait(500)

    if GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterUsableItem(Config.Gps.item, function(src)
            TriggerClientEvent('dj_blackmarket:useGps', src)
        end)
    end

    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateUseableItem(Config.Gps.item, function(src)
            TriggerClientEvent('dj_blackmarket:useGps', src)
        end)
    end
end)
