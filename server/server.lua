ESX = nil

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

RegisterNetEvent("esx_jail_locker:requestMenu")
AddEventHandler("esx_jail_locker:requestMenu", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local alreadyStored = {}
    local isCop, counts = false, 0
    for k,v in pairs(Config.allowedViewersJobs) do
        if xPlayer.job.name == v then 
            isCop = true
        end
    end

    MySQL.Async.fetchAll("SELECT * FROM lockers WHERE identifier != @a", {
        ['a'] = xPlayer.identifier
    }, function(result)
        if isCop then
            for k,v in pairs(result) do
                counts = counts + 1
                table.insert(alreadyStored, {name = v.name, content = json.decode(v.inventory)})
            end
        end
        
        MySQL.Async.fetchAll("SELECT * FROM lockers WHERE identifier = @a", {
            ['a'] = xPlayer.identifier
        }, function(result)
            if result[1] then
                TriggerClientEvent("esx_jail_locker:openMenu", _src, true, isCop, {alreadyStored, counts})
            else 
                TriggerClientEvent("esx_jail_locker:openMenu", _src, false, isCop, {alreadyStored, counts})
            end
        end)
    end)
end)

RegisterNetEvent("esx_jail_locker:recover")
AddEventHandler("esx_jail_locker:recover", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    MySQL.Async.fetchAll("SELECT inventory FROM lockers WHERE identifier = @a",{
        ['a'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            MySQL.Async.execute("DELETE FROM lockers WHERE identifier = @a",{
                ['a'] = xPlayer.identifier
            })
            local items = json.decode(result[1].inventory)
            for k,v in pairs(items) do
                xPlayer.addInventoryItem(v[1], tonumber(v[2]))
            end
            TriggerClientEvent("esx_jail_locker:callback", _src, "~g~Objets récupérés !")
        end
    end)
end)

RegisterNetEvent("esx_jail_locker:deposit")
AddEventHandler("esx_jail_locker:deposit", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    
    local toStore, count = {}, 0
    for k,v in pairs(xPlayer.getInventory()) do
        local shouldStore = true
        if v.count <= 0 then shouldStore = false end
        for _,blacklistedItem in pairs(Config.blacklistedItems) do
            if v.name == blacklistedItem then
                shouldStore = false
            end
        end
        if shouldStore then
            xPlayer.removeInventoryItem(v.name, v.count)
            table.insert(toStore, {v.name, v.count, v.label})
            count = count + 1
        end
    end


    if count <= 0 then
        TriggerClientEvent("esx_jail_locker:callback", _src, "~r~Vous n'avez rien à déposer !")
        return
    end

    MySQL.Async.insert("INSERT INTO lockers (identifier, name, inventory) VALUES (@a,@b,@c)",{
        ['a'] = xPlayer.identifier,
        ['b'] = GetPlayerName(_src),
        ['c'] = json.encode(toStore)
    }, function()
        TriggerClientEvent("esx_jail_locker:callback", _src, "~g~Objets déposés !")
    end)
end)