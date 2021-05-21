  
local cat, desc = "locker", "Casier des cellules"
local isWaitingServerResponse = false
local isMenuOpened = false
local sub = function(str)
    return cat .. "_" .. str
end

RegisterNetEvent("esx_jail_locker:callback")
AddEventHandler("esx_jail_locker:callback", function(message)
    isWaitingServerResponse = false
    ESX.ShowNotification(message)
end)

function openMenu(storedState, isCop, storedData)
    if isMenuOpened or isWaitingServerResponse then return end
    isMenuOpened = true

    local selectedLocker = 1

    FreezeEntityPosition(PlayerPedId(), true)
    RMenu.Add(cat, sub("main"), RageUI.CreateMenu("Casiers", desc))
    RMenu:Get(cat, sub("main")).Closed = function()        
    end


    RMenu.Add(cat, sub("view"), RageUI.CreateSubMenu(RMenu:Get(cat, sub("main")), "Casiers", desc))
    RMenu:Get(cat, sub("view")).Closed = function()
    end

    RMenu.Add(cat, sub("inspect"), RageUI.CreateSubMenu(RMenu:Get(cat, sub("view")), "Casiers", desc))
    RMenu:Get(cat, sub("inspect")).Closed = function()
    end
    

    RageUI.Visible(RMenu:Get(cat, sub("main")), true)

    Citizen.CreateThread(function()
        while isMenuOpened do
            local shouldStayOpened = false
            local function tick()
                shouldStayOpened = true
            end
            RageUI.IsVisible(RMenu:Get(cat, sub("main")), true, true, true, function()
                tick()
                if storedState then
                    RageUI.ButtonWithStyle("Récuperer mes objets", "Vous permets de récuperer vos objets dans ce conteneur sécurisé.", {}, true, function(_,_,s)
                        if s then
                            isWaitingServerResponse = true
                            shouldStayOpened = false
                            ESX.ShowNotification("~o~Récupération de vos objets en cours...")
                            TriggerServerEvent("esx_jail_locker:recover")
                        end
                    end)
                else
                    RageUI.ButtonWithStyle("Déposer mes objets", "Vous permets de déposer vos objets dans ce conteneur sécurisé.", {}, true, function(_,_,s)
                        if s then
                            isWaitingServerResponse = true
                            shouldStayOpened = false
                            ESX.ShowNotification("~o~Dépôt de vos objets en cours...")
                            TriggerServerEvent("esx_jail_locker:deposit")
                        end
                    end)
                end

                if isCop then 
                    RageUI.ButtonWithStyle("Voir les casiers", "Vous permets de voir le contenu des caisers", {}, true, function(_,_,s)
                    end, RMenu:Get(cat, sub("view")))
                end
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("view")), true, true, true, function()
                tick()
                if storedData[2] <= 0 then
                    RageUI.Separator("~r~Aucuns casiers !")
                else
                    for k,v in pairs(storedData[1]) do
                        RageUI.ButtonWithStyle("Casier de ~y~"..v.name, "Appuyez pour voir le casier de la personne en question", {RightLabel = "→→"}, true, function(_,_,s)
                            if s then
                                selectedLocker = k
                            end
                        end, RMenu:Get(cat, sub("inspect")))
                    end
                end
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("inspect")), true, true, true, function()
                tick()
                if not storedData[1][selectedLocker] then
                    RageUI.GoBack()
                else
                    for k,v in pairs(storedData[1][selectedLocker].content) do
                        RageUI.ButtonWithStyle("~b~(~s~x"..v[2].."~b~) "..v[3], nil, {}, true, function() end)
                    end
                end
            end, function()
            end)

            if not shouldStayOpened and isMenuOpened then
                isMenuOpened = false
            end
            Wait(0)
        end
        FreezeEntityPosition(PlayerPedId(), false)
        RMenu:Delete(cat, sub("main"))
        RMenu:Delete(cat, sub("view"))
        RMenu:Delete(cat, sub("inspect"))
    end)
end

RegisterNetEvent("esx_jail_locker:openMenu")
AddEventHandler("esx_jail_locker:openMenu", openMenu)