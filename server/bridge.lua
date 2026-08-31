Bridge = {}

local framework = 'none'
local ESX, QBCore

local function detectFramework()
    if Config.Framework == 'esx' or Config.Framework == 'qb' or Config.Framework == 'qbx' then
        return Config.Framework
    end

    if GetResourceState('qbx_core') == 'started' then
        return 'qbx'
    end

    if GetResourceState('qb-core') == 'started' then
        return 'qb'
    end

    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end

    return 'none'
end

local function ensureFramework()
    if framework ~= 'none' and (framework ~= 'esx' or ESX) and (framework ~= 'qb' or QBCore) then
        return
    end

    framework = detectFramework()

    if framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    elseif framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
    end
end

CreateThread(function()
    ensureFramework()
end)

local function getESXPlayer(src)
    if not ESX then
        ESX = exports['es_extended']:getSharedObject()
    end
    return ESX.GetPlayerFromId(src)
end

local function getQBPlayer(src)
    if framework == 'qbx' then
        return exports.qbx_core:GetPlayer(src)
    end

    if not QBCore then
        QBCore = exports['qb-core']:GetCoreObject()
    end

    return QBCore.Functions.GetPlayer(src)
end

function Bridge.GetName(src)
    ensureFramework()
    if framework == 'esx' then
        local player = getESXPlayer(src)
        if player then
            if player.getName then
                return player.getName()
            end
            if player.get and player.get('firstName') then
                return ('%s %s'):format(player.get('firstName') or '', player.get('lastName') or '')
            end
        end
    end

    if framework == 'qb' or framework == 'qbx' then
        local player = getQBPlayer(src)
        local info = player and player.PlayerData and player.PlayerData.charinfo
        if info then
            return (('%s %s'):format(info.firstname or '', info.lastname or '')):gsub('%s+$', '')
        end
    end

    return GetPlayerName(src) or 'Customer'
end

function Bridge.GetJobName(src)
    ensureFramework()
    if framework == 'esx' then
        local player = getESXPlayer(src)
        return player and player.job and player.job.name or 'unemployed'
    end

    if framework == 'qb' or framework == 'qbx' then
        local player = getQBPlayer(src)
        return player and player.PlayerData and player.PlayerData.job and player.PlayerData.job.name or 'unemployed'
    end

    return 'unemployed'
end

local function getOxCount(src, itemName)
    if GetResourceState('ox_inventory') ~= 'started' then
        return 0
    end

    local count = exports.ox_inventory:Search(src, 'count', itemName)
    return tonumber(count) or 0
end

local function getAccountAmount(src, method)
    ensureFramework()
    if framework == 'esx' then
        local player = getESXPlayer(src)
        if not player then return 0 end

        if method == 'cash' then
            if player.getMoney then
                return player.getMoney() or 0
            end
            local account = player.getAccount and player.getAccount('money')
            return account and account.money or 0
        end

        local account = player.getAccount and player.getAccount('black_money')
        return account and account.money or 0
    end

    if framework == 'qb' or framework == 'qbx' then
        local player = getQBPlayer(src)
        if not player then return 0 end

        if method == 'cash' then
            return player.Functions.GetMoney('cash') or 0
        end

        local dirty = player.Functions.GetMoney('black_money')
        if dirty and dirty > 0 then
            return dirty
        end
    end

    if method == 'cash' then
        return getOxCount(src, 'money')
    end

    return getOxCount(src, 'black_money')
end

function Bridge.GetMoney(src)
    return {
        cash = getAccountAmount(src, 'cash'),
        black_money = getAccountAmount(src, 'black_money'),
    }
end

function Bridge.AddMoney(src, method, amount)
    amount = math.floor(amount + 0.5)
    if amount <= 0 then return false end

    if framework == 'esx' then
        local player = getESXPlayer(src)
        if not player then return false end
        if method == 'cash' then
            player.addMoney(amount)
            return true
        end
        player.addAccountMoney('black_money', amount)
        return true
    end

    if framework == 'qb' or framework == 'qbx' then
        local player = getQBPlayer(src)
        if not player then return false end
        if method == 'cash' then
            return player.Functions.AddMoney('cash', amount, 'blackmarket-refund')
        end
        if player.Functions.AddMoney then
            player.Functions.AddMoney('black_money', amount, 'blackmarket-refund')
            return true
        end
    end

    local itemName = method == 'cash' and 'money' or 'black_money'
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(src, itemName, amount)
    end

    return false
end

function Bridge.RemoveMoney(src, method, amount)
    amount = math.floor(amount + 0.5)
    if amount <= 0 then return false end
    if getAccountAmount(src, method) < amount then return false end

    if framework == 'esx' then
        local player = getESXPlayer(src)
        if not player then return false end

        if method == 'cash' then
            player.removeMoney(amount)
            return true
        end

        player.removeAccountMoney('black_money', amount)
        return true
    end

    if framework == 'qb' or framework == 'qbx' then
        local player = getQBPlayer(src)
        if not player then return false end

        if method == 'cash' then
            return player.Functions.RemoveMoney('cash', amount, 'blackmarket')
        end

        if player.Functions.GetMoney('black_money') and player.Functions.GetMoney('black_money') >= amount then
            return player.Functions.RemoveMoney('black_money', amount, 'blackmarket')
        end
    end

    local itemName = method == 'cash' and 'money' or 'black_money'
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:RemoveItem(src, itemName, amount)
    end

    return false
end

function Bridge.AddItem(src, item, count, metadata)
    if GetResourceState('ox_inventory') ~= 'started' then
        return false
    end

    return exports.ox_inventory:AddItem(src, item, count, metadata)
end

function Bridge.CanCarry(src, item, count)
    if GetResourceState('ox_inventory') ~= 'started' then
        return true
    end

    return exports.ox_inventory:CanCarryItem(src, item, count)
end

function Bridge.Notify(src, description, nType)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Black Market',
        description = description,
        type = nType or 'inform',
    })
end
