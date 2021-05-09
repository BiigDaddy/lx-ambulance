--[[
    ADD YOUR FRAMEWORK BILLING HERE

    If the player is bill successfully, return true. If they're not, return false
]]
ESX = nil 
TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

function BillPlayer(source, amount)

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local account = "bank"

    TriggerClientEvent('mythic_notify:client:SendAlert', src, { text = 'You\'ve Been Treated & Billed for ' .. amount .. '$', type = 'inform'})
    xPlayer.removeAccountMoney(account, amount)

    return true
end