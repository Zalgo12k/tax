ESX = nil
local vehicleprices = {}
local yuzde = 1

MySQL.ready(function()
    local result = MySQL.Sync.fetchAll('SELECT * FROM vehicles')

    for i = 1, #result, 1 do
        if vehicleprices[(GetHashKey(result[i].model))] == nil then
            table.insert(vehicleprices, {model = GetHashKey(result[i].model), price = result[i].price})
        end
    end
    Citizen.CreateThread(function()
        TriggerEvent('esx:getSharedObject',  function(obj) ESX = obj end)
        while ESX == nil do
            Citizen.Wait(100)
        end
        Vergi()
    end)
end)

function Vergi()
    local result = MySQL.Sync.fetchAll("SELECT * FROM owned_vehicles")
    local xPlayers = ESX.GetPlayers()

    for i = 1, #result, 1 do
        if result[i].job == "" or result[i].job == nil then
            local sqlplayer = ESX.GetPlayerFromIdentifier(result[i].owner)

            if sqlplayer ~= nil then
                for j = 1, #xPlayers, 1 do
                    local xPlayer = ESX.GetPlayerFromId(xPlayers[j])

                    if xPlayer.identifier == result[i].owner then
                        local model = (json.decode(result[i].vehicle).model)

                        for m = 1, #vehicleprices, 1 do
                            if vehicleprices[m].model == model then
                                TriggerEvent('esx_billing:sendBill',  xPlayers[j], 'society_police', 'Araç Vergisi: '..result[i].plate, ((vehicleprices[m].price * yuzde) / 100) , 1)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

TriggerEvent("cron", 6, 0, Vergi)
TriggerEvent("cron:runAt", 21, 30, Vergi)