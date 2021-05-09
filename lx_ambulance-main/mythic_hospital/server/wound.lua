--[[ESX = nil 
TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

ESX.RegisterUsableItem('bandage', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bandage = "bandage"
    xPlayer.removeInventoryItem('bandage', 1)

    TriggerClientEventInternal('mythic_hospital:client:RemoveBleed', source)
    --TriggerClientEvent('esx_ambulancejob:useItem', source, 'bandage')
end)--]]

local PlayerInjuries = {}

function GetCharsInjuries(source)
    return PlayerInjuries[source]
end




RegisterServerEvent('mythic_hospital:server:SyncInjuries')
AddEventHandler('mythic_hospital:server:SyncInjuries', function(data)
    PlayerInjuries[source] = data
end)