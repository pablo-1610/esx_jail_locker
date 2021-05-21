ESX = nil

Citizen.CreateThread(function()
    local onCoolDown = false
    local position = Config.position
    TriggerEvent("esx:getSharedObject", function(object)
        ESX = object
    end)
    while ESX == nil do Wait(1) end
    while true do
        local interval = 150
        local playerPos = GetEntityCoords(PlayerPedId())
        local dist = #(playerPos-position)
        if dist <= Config.drawDist then
            interval = 0
            DrawMarker(22, position, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0,0,255, 255, 55555, false, true, 2, false, false, false, false)
            if dist <= 1.0 then
                AddTextEntry("HELP", "Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le casier des cellules")
                DisplayHelpTextThisFrame("HELP", 0)
                if IsControlJustPressed(0, 51) then
                    if not onCoolDown then
                        TriggerServerEvent("esx_jail_locker:requestMenu")
                        onCoolDown = true
                        Citizen.SetTimeout(100, function()
                            onCoolDown = false
                        end)
                    end
                end
            end
        end
        Wait(interval)
    end
end)